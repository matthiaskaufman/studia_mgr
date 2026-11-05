from pathlib import Path
from typing import Annotated, Literal
import json

import numpy as np
from pydantic import BaseModel, ConfigDict, Field, model_validator
from scipy.interpolate import CubicSpline


PositiveFloat = Annotated[float, Field(gt=0)]
NonNegativeFloat = Annotated[float, Field(ge=0)]


class ValidatedModel(BaseModel):
    model_config = ConfigDict(
        extra="forbid",
        frozen=True,
        allow_inf_nan=False,
        validate_default=True,
    )


class OUConfig(ValidatedModel):
    std: NonNegativeFloat
    tau_s: PositiveFloat


class OUProcess:
    """Generator próbek OU. Nie jest używany podczas całkowania ODE."""

    def __init__(
        self,
        config: OUConfig,
        rng: np.random.Generator,
    ):
        self.config = config
        self.rng = rng

    def generate(self, times_s: np.ndarray) -> np.ndarray:
        times_s = np.asarray(times_s, dtype=float)

        if (
            times_s.ndim != 1
            or times_s.size < 2
            or not np.isfinite(times_s).all()
            or np.any(np.diff(times_s) <= 0)
        ):
            raise ValueError(
                "Czasy muszą być skończone, ściśle rosnące "
                "i zawierać co najmniej dwie próbki."
            )

        values = np.zeros(times_s.size)

        # Początek scenariusza: zerowe odchylenie od wiatru bazowego.
        for k, dt in enumerate(np.diff(times_s), start=1):
            a = np.exp(-dt / self.config.tau_s)
            noise_std = self.config.std * np.sqrt(
                -np.expm1(-2.0 * dt / self.config.tau_s)
            )

            values[k] = (
                a * values[k - 1]
                + noise_std * self.rng.normal()
            )

        return values


class WindConfig(ValidatedModel):
    duration_s: PositiveFloat = 6000.0
    sample_dt_s: PositiveFloat = 0.5

    speed_mean_mps: PositiveFloat = 10.0
    direction_mean_deg: float = 90.0

    speed_ou: OUConfig = Field(
        default_factory=lambda: OUConfig(std=0.3, tau_s=10.0)
    )
    direction_ou: OUConfig = Field(
        default_factory=lambda: OUConfig(std=3.0, tau_s=25.0)
    )

    speed_limit_mps: PositiveFloat = 1.5
    direction_limit_deg: Annotated[float, Field(gt=0, lt=180)] = 10.0

    seed: Annotated[int, Field(ge=0)] = 42

    @model_validator(mode="after")
    def check_speed_limit(self):
        if self.speed_limit_mps > self.speed_mean_mps:
            raise ValueError(
                "speed_limit_mps nie może przekraczać speed_mean_mps."
            )
        return self


class WindScenario(ValidatedModel):
    schema_version: Literal[1] = 1
    interpolation: Literal["natural_cubic"] = "natural_cubic"
    direction_convention: Literal["to_ccw_from_x"] = "to_ccw_from_x"

    config: WindConfig

    times_s: tuple[float, ...]
    speed_raw_mps: tuple[float, ...]
    direction_raw_deg: tuple[float, ...]

    @model_validator(mode="after")
    def check_samples(self):
        n = len(self.times_s)

        if n < 2:
            raise ValueError("Scenariusz wymaga co najmniej dwóch próbek.")

        if (
            len(self.speed_raw_mps) != n
            or len(self.direction_raw_deg) != n
        ):
            raise ValueError("Wszystkie tablice muszą mieć tę samą długość.")

        if any(
            right <= left
            for left, right in zip(self.times_s, self.times_s[1:])
        ):
            raise ValueError("Czasy muszą być ściśle rosnące.")

        if self.times_s[0] != 0.0:
            raise ValueError("Scenariusz musi zaczynać się od t=0.")

        if self.times_s[-1] != self.config.duration_s:
            raise ValueError("Ostatni czas musi być równy duration_s.")

        return self

    @classmethod
    def generate(cls, config: WindConfig) -> "WindScenario":
        intervals = max(
            1,
            int(np.ceil(config.duration_s / config.sample_dt_s)),
        )
        times = np.linspace(0.0, config.duration_s, intervals + 1)

        speed_seed, direction_seed = np.random.SeedSequence(
            config.seed
        ).spawn(2)

        speed = OUProcess(
            config.speed_ou,
            np.random.default_rng(speed_seed),
        ).generate(times)

        direction = OUProcess(
            config.direction_ou,
            np.random.default_rng(direction_seed),
        ).generate(times)

        return cls(
            config=config,
            times_s=tuple(times.tolist()),
            speed_raw_mps=tuple(speed.tolist()),
            direction_raw_deg=tuple(direction.tolist()),
        )


class WindSample(ValidatedModel):
    speed_mps: NonNegativeFloat
    direction_rad: float
    vx_mps: float
    vy_mps: float


class WindModel:
    """Ciągła funkcja czasu. Po inicjalizacji nie wykonuje losowań."""

    def __init__(self, scenario: WindScenario):
        self.scenario = scenario

        self._speed = CubicSpline(
            scenario.times_s,
            scenario.speed_raw_mps,
            bc_type="natural",
            extrapolate=False,
        )

        self._direction = CubicSpline(
            scenario.times_s,
            scenario.direction_raw_deg,
            bc_type="natural",
            extrapolate=False,
        )

    def __call__(self, t: float) -> WindSample:
        t = float(t)
        cfg = self.scenario.config

        if not np.isfinite(t) or not 0.0 <= t <= cfg.duration_s:
            raise ValueError(
                f"Czas musi należeć do [0, {cfg.duration_s}] s."
            )

        speed_raw = float(self._speed(t))
        direction_raw_deg = float(self._direction(t))

        speed = (
            cfg.speed_mean_mps
            + cfg.speed_limit_mps
            * np.tanh(speed_raw / cfg.speed_limit_mps)
        )

        direction_deg = (
            cfg.direction_mean_deg
            + cfg.direction_limit_deg
            * np.tanh(direction_raw_deg / cfg.direction_limit_deg)
        )
        direction_rad = float(np.deg2rad(direction_deg))

        return WindSample(
            speed_mps=float(speed),
            direction_rad=direction_rad,
            vx_mps=float(speed * np.cos(direction_rad)),
            vy_mps=float(speed * np.sin(direction_rad)),
        )

def main():
    config = WindConfig(
        duration_s=10000.0,
        sample_dt_s=0.5,
        seed=42,
    )

    wind_scenario = WindScenario.generate(config)

    path = Path('data/test.json')
    with path.open("r", encoding="utf-8") as read_file:
        data = json.load(read_file)

    data['wind_scenario'] = wind_scenario.dict()

    json_str = json.dumps(data, indent=4)
    # path = Path(str(path) + '.wind')
    with open(path, "w", encoding="utf-8") as f:
        f.write(json_str)

if __name__ == '__main__':
    main()
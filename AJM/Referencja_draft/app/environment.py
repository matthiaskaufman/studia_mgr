import json
from typing import Tuple
from math import radians
from pathlib import Path


from numpy import sin, cos, pi
import matplotlib.pyplot as plt
from pydantic import BaseModel, ConfigDict, PrivateAttr

from wind_model import WindScenario, WindModel


class FrozenModel(BaseModel):
    model_config = ConfigDict(
        frozen=True,
        extra="forbid",
        allow_inf_nan=False,
    )


class Buoy(FrozenModel):
    x: float
    y: float
    r: float


class StartPosition(FrozenModel):
    x: float
    y: float
    psi: float  # radiany


class FinishLine(FrozenModel):
    left: Buoy
    right: Buoy


class Environment(FrozenModel):
    """Środowisko symulacji jachtu."""

    buoys: tuple[Buoy, ...]
    finishLine: FinishLine
    startPosition: StartPosition
    scenarioName: str
    wind_scenario: WindScenario
    _windModel: WindModel = PrivateAttr()

    @classmethod
    def createFromJson(cls, fileName: str | Path) -> "Environment":
        path = Path(fileName)

        with path.open("r", encoding="utf-8") as read_file:
            data = json.load(read_file)

        buoys = tuple(
            Buoy(x=x, y=y, r=r)
            for x, y, r in data["trasa"]
        )

        start_x, start_y, start_psi_deg = data["start"]

        start_position = StartPosition(
            x=start_x,
            y=start_y,
            psi=radians(float(start_psi_deg)),
        )

        left_x, left_y = data["meta"]["left"]
        right_x, right_y = data["meta"]["right"]

        finish_line = FinishLine(
            left=Buoy(x=left_x, y=left_y, r=0.0),
            right=Buoy(x=right_x, y=right_y, r=0.0),
        )
        wind_scenario = WindScenario.model_validate(data['wind_scenario'])
        wind_model = WindModel(wind_scenario)

        environment = cls(
            buoys=buoys,
            startPosition=start_position,
            finishLine=finish_line,
            scenarioName=str(fileName),
            wind_scenario=wind_scenario,
        )
        environment._windModel = wind_model
        return environment

    @property
    def regionSize(self) -> Tuple[float, float, float, float]:
        return (-1000, 1500, -500, 2000)


    def plot(self, xWayPoints=[], yWayPoints=[], course=[]):
        fig, ax = plt.subplots()
        ax.set_aspect('equal', 'box')
        plt.axis(self.regionSize)

        for buoy in self.buoys:
            circle = plt.Circle((buoy.x, buoy.y), buoy.r, color='black')
            ax.add_artist(circle)
        dx = 30 * cos(self.startPosition.psi)
        dy = 30 * sin(self.startPosition.psi)
        ax.arrow(self.startPosition.x, self.startPosition.y, dx, dy, head_width=10, head_length=20, fc='k', ec='k')
        ax.plot((self.finishLine.left.x, self.finishLine.right.x), (self.finishLine.left.y, self.finishLine.right.y), 'k')
        ax.plot(xWayPoints, yWayPoints)
        step = int(len(xWayPoints) / 10)
        for index in range(step, len(xWayPoints), step):
            dx = 5 * cos(course[index])
            dy = 5 * sin(course[index])
            ax.arrow(xWayPoints[index], yWayPoints[index], dx, dy, head_width=2, head_length=4)
        return fig, ax

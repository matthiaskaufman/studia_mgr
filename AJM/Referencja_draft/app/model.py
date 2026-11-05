from __future__ import annotations
import json
from collections.abc import Iterable, Iterator
from dataclasses import dataclass, astuple, asdict
from pathlib import Path
from typing import Tuple, List
from pydantic import BaseModel, Field
from scipy.interpolate import PchipInterpolator
from scipy.integrate import ode
import numpy as np
from numpy import sin, cos, log, arctan2, sqrt, add, pi, deg2rad, rad2deg
import matplotlib.pyplot as plt

from environment import Environment
from wind_model import WindSample

# pylint: disable=C0103
# pylint: disable=C0116
# pylint: disable=C0115
# pylint: disable=R0902
# pylint: disable=R0903

par = {}


par['m'] = 25900                         # (kg),mass of the vehicle
par['Ixx'] = 133690
par['Izz'] = 24760
par['Ixz'] = 2180                        # moment of inertia
par['a11'] = 970
par['a22'] = 17430
par['a44'] = 106500
par['a66'] = 101650
par['a24'] = -13160
par['a26'] = -6190
par['a46'] = 4730                        # (kg),added mass coef.

par['vt'] = 10                           # the norm of wind velocity
# par['alpha_w'] = np.pi                   # the direction of wind (coming from the north, ie going south)
par['alpha_w'] = np.pi * 3 / 2
# par['alpha_w'] = 0

par['rho_a'] = 1.2                       # (kg/m^3), air density
par['As'] = 170                          # (m^2), sail area
par['h0'] = 0.0005                       # (m), roughness height
par['h1'] = 11.58                        # (m), reference height
par['z_s'] = -11.58                      # (m), (x,y,z) is the CoE
par['xs'] = 0
par['ys'] = 0
par['zs'] = -11.58                       # (m), (x,y,z) is the CoE
par['Xce'] = 0.6                         # (m), distance along the mast to the CoE
par['Xm'] = 0.3                          # (m), x-coordinate of the mast

par['rho_w'] = 1025                      # (kg/m^3), water density
par['Ar'] = 1.17                         # (m^2), rudder area
par['d_r'] = 1.9                         # rudder draft
par['zeta_r'] = 0.8                      # rudder efficiency
par['x_r'] = -8.2
par['z_r'] = -0.78                       # (m), (x,y,z) is the CoE
par['xr'] = -8.2
par['yr'] = 0
par['zr'] = -0.78                        # (m), (x,y,z) is the CoE

par['Ak'] = 8.7                          # (m^2), keel area
par['d_k'] = 2.49                        # keel draft
par['zeta_k'] = 0.7                      # keel efficiency
par['x_k'] = 0
par['z_k'] = -0.58                       # (m), (x,y,z) is the CoE
par['xk'] = 0
par['yk'] = 0
par['zk'] = -0.58                        # (m), (x,y,z) is the CoE

par['x_h'] = 0
par['z_h'] = -1.18                       # (m), (x,y,z) is the CoE
par['xh'] = 0
par['yh'] = 0
par['zh'] = -1.18                        # (m), (x,y,z) is the CoE

par['w_c'] = 60000                       # (N), crew weight 20000
par['x_c'] = -8                          # (m), crew position
par['y_bm'] = 3.6                        # (m), yacht beam

par['a'] = -5.89
par['b'] = 8160
par['c'] = 120000
par['d'] = 50000




def sailcoef(attack):
    # generate a lookup table for the lift/drag coefficients for the sail
    # and compute Cls/Cds from the lookup table using interpolation.
    # lookup table
    xdata = np.linspace(-np.pi, np.pi, 73)  # every 5 degrees
    xdata = xdata / np.pi * 180
    # lift curve
    p1 = [0, 0.15, 0.32, 0.48, 0.7, 0.94, 1.15, 1.3, 1.28, 1.15, 1.1, 1.05, 1,
          0.9, 0.82, 0.72, 0.68, 0.56, 0.48, 0.32, 0.21, 0.08, -0.06, -0.18,
          -0.3, -0.4, -0.53, -0.64, -0.72, -0.84, -0.95, -1.04, -1.1, -1.14,
          -1.08, -0.76, 0]
    p1.reverse()
    p1 = list(-1 * np.array(p1))
    p2 = [0.15, 0.32, 0.48, 0.7, 0.94, 1.15, 1.3, 1.28, 1.15, 1.1, 1.05, 1,
          0.9, 0.82, 0.72, 0.68, 0.56, 0.48, 0.32, 0.21, 0.08, -0.06, -0.18,
          -0.3, -0.4, -0.53, -0.64, -0.72, -0.84, -0.95, -1.04, -1.1, -1.14,
          -1.08, -0.76, 0]
    yldata = p1 + p2
    # drag curve
    p1 = [0.1, 0.12, 0.14, 0.16, 0.19, 0.26, 0.35, 0.46, 0.54, 0.62, 0.7, 0.78,
          0.9, 0.98, 1.04, 1.08, 1.16, 1.2, 1.24, 1.26, 1.28, 1.34, 1.36, 1.37,
          1.33, 1.31, 1.28, 1.26, 1.25, 1.2, 1.1, 1.04, 0.88, 0.8, 0.64, 0.38,
          0.1]
    p1.reverse()
    p2 = [0.12, 0.14, 0.16, 0.19, 0.26, 0.35, 0.46, 0.54, 0.62, 0.7, 0.78, 0.9,
          0.98, 1.04, 1.08, 1.16, 1.2, 1.24, 1.26, 1.28, 1.34, 1.36, 1.37,
          1.33, 1.31, 1.28, 1.26, 1.25, 1.2, 1.1, 1.04, 0.88, 0.8, 0.64,
          0.38, 0.1]
    yddata = p1 + p2
    # fit the input angle of attack into the interval [-pi,pi]
    if attack > np.pi:
        attack = np.mod(attack + np.pi, 2 * np.pi) - np.pi
    else:
        if attack < -np.pi:
            attack = np.mod(attack - np.pi, -2 * np.pi) + np.pi
    # # interpolation
    attack = attack / np.pi * 180
    Cls = PchipInterpolator(xdata, yldata)(attack)
    Cds = PchipInterpolator(xdata, yddata)(attack)
    return Cls, Cds

def ruddercoef(attack):
    # generate a lookup table for the lift/drag coefficients for the sail
    # and compute Cls/Cds from the lookup table using interpolation.
    # lookup table
    xdata = np.linspace(-np.pi, np.pi, 73)  # every 5 degrees
    xdata = xdata / np.pi * 180
    # lift curve
    p1 = [0, 0.42, 0.73, 0.95, 1.1, 1.165, 1.18, 1.155, 1.12,
          1.065, 1, 0.92, 0.83, 0.72, 0.62, 0.48, 0.33, 0.16]
    p1.reverse()
    yl = list(-1 * np.array(p1))
    p2 = [0, 0.42, 0.73, 0.95, 1.1, 1.165, 1.18, 1.155, 1.12,
          1.065, 1, 0.92, 0.83, 0.72, 0.62, 0.48, 0.33, 0.16, 0] + yl
    p2.reverse()
    p2 = list(-1 * np.array(p2))
    p3 = [0.42, 0.73, 0.95, 1.1, 1.165, 1.18, 1.155, 1.12, 1.065,
          1, 0.92, 0.83, 0.72, 0.62, 0.48, 0.33, 0.16, 0] + yl
    yldata = p2 + p3
    # drag curve
    yd = [0, 0.03, 0.06, 0.1, 0.17, 0.3, 0.48, 0.74, 0.98, 1.18,
          1.34, 1.5, 1.65, 1.76, 1.89, 1.97, 2.01, 2.05]
    yd.reverse()
    p1 = [0, 0.03, 0.06, 0.1, 0.17, 0.3, 0.48, 0.74, 0.98, 1.18,
          1.34, 1.5, 1.65, 1.76, 1.89, 1.97, 2.01, 2.05, 2.08]
    p1 = p1 + yd
    p1.reverse()
    p2 = [0.03, 0.06, 0.1, 0.17, 0.3, 0.48, 0.74, 0.98, 1.18,
          1.34, 1.5, 1.65, 1.76, 1.89, 1.97, 2.01, 2.05, 2.08]
    p2 = p2 + yd
    yddata = p1 + p2
    if attack > np.pi:
        attack = np.mod(attack + np.pi, 2 * np.pi) - np.pi
    else:
        if attack < -np.pi:
            attack = np.mod(attack - np.pi, -2 * np.pi) + np.pi
    # interpolation
    attack = attack / np.pi * 180
    Clr = PchipInterpolator(xdata, yldata)(attack)
    Cdr = PchipInterpolator(xdata, yddata)(attack)
    return Clr, Cdr

def keelcoef(attack):
    # generate a lookup table for the lift/drag coefficients for the sail
    # and compute Cls/Cds from the lookup table using interpolation.
    # lookup table
    xdata = np.linspace(-np.pi, np.pi, 73)  # every 5 degrees
    xdata = xdata / np.pi * 180
    # lift curve
    p1 = [0, 0.425, 0.74, 0.94, 1.1, 1.17, 1.19, 1.16, 1.12, 1.07, 0.99, 0.92,
          0.84, 0.74, 0.63, 0.49, 0.345, 0.185]
    p1.reverse()
    yl = list(-1 * np.array(p1))
    p1 = [0, 0.425, 0.74, 0.94, 1.1, 1.17, 1.19, 1.16, 1.12, 1.07, 0.99, 0.92,
          0.84, 0.74, 0.63, 0.49, 0.345, 0.185, 0]
    p1 = p1 + yl
    p1.reverse()
    p1 = list(-1 * np.array(p1))
    p2 = [0.425, 0.74, 0.94, 1.1, 1.17, 1.19, 1.16, 1.12, 1.07, 0.99, 0.92,
          0.84, 0.74, 0.63, 0.49, 0.345, 0.185, 0]
    p2 = p2 + yl
    yldata = p1 + p2
    # drag curve
    yd = [0, 0.04, 0.07, 0.1, 0.17, 0.3, 0.49, 0.76, 0.98, 1.19, 1.34,
          1.5, 1.65, 1.77, 1.88, 1.96, 2.01, 2.05]
    yd.reverse()
    p1 = [0, 0.04, 0.07, 0.1, 0.17, 0.3, 0.49, 0.76, 0.98, 1.19, 1.34,
          1.5, 1.65, 1.77, 1.88, 1.96, 2.01, 2.05, 2.09]
    p1 = p1 + yd
    p1.reverse()
    p2 = [0.04, 0.07, 0.1, 0.17, 0.3, 0.49, 0.76, 0.98, 1.19, 1.34, 1.5, 1.65,
          1.77, 1.88, 1.96, 2.01, 2.05, 2.09]
    p2 = p2 + yd
    yddata = p1 + p2
    # fit the input angle of attack into the interval [-pi,pi]
    if attack > np.pi:
        attack = np.mod(attack + np.pi, 2 * np.pi) - np.pi
    else:
        if attack < -np.pi:
            attack = np.mod(attack - np.pi, -2 * np.pi) + np.pi
    # interpolation
    attack = attack / np.pi * 180
    Clk = PchipInterpolator(xdata, yldata)(attack)
    Cdk = PchipInterpolator(xdata, yddata)(attack)
    return Clk, Cdk

def resistancehull(alpha_a):
    xdata = np.linspace(0, 6, 13)  # every 0.5m/s
    ydata = np.array([0, 0.15, 0.35, 0.5, 0.675, 0.825, 1.175, 1.4, 2,
                      4.85, 9.85, 18.46, 27.5]) * 1000
    # interpolation
    if alpha_a <= 6:
        F = PchipInterpolator(xdata, ydata)(alpha_a)
    else:
        F = PchipInterpolator(xdata, ydata, extrapolate=True)(alpha_a)
    return F

def X_dot_ext(V_in, wind_sample: WindSample):
    # use the system parameters
    # retrieve the system state from the field input vector "V_in"
    x = V_in[3] # 0
    y = V_in[4] # 1
    phi = V_in[5] # 2
    psi = V_in[6] # 3
    u = V_in[7] # 4
    v = V_in[8] # 5
    p = V_in[9] # 6
    r = V_in[10] # 7
    nu = np.array([[u], [v], [p], [r]])
    # retrieve the input signals from the vector "V_in"
    delta_r = V_in[0]
    delta_sbar = V_in[1]
    y_w = V_in[2]
    # evaluate the matrix M and C in the model
    M_RB = [[par['m'], 0, 0, 0],
            [0, par['m'], 0, 0],
            [0, 0, par['Ixx'], -par['Ixz']],
            [0, 0, -par['Ixz'], par['Izz']]]
    M_RB = np.array(M_RB)
    C_RB = [[0, -par['m'] * r, 0, 0],
            [par['m'] * r, 0, 0, 0],
            [0, 0, 0, 0],
            [0, 0, 0, 0]]
    C_RB = np.array(C_RB)
    M_A = [[par['a11'], 0, 0, 0],
           [0, par['a22'], par['a24'], par['a26']],
           [0, par['a24'], par['a44'], par['a46']],
           [0, par['a26'], par['a46'], par['a66']]]
    M_A = np.array(M_A)
    C_A = [[0, 0, 0, -par['a22'] * nu.item(1) - par['a24'] * nu.item(2) - par['a26'] * nu.item(3)],
           [0, 0, 0, par['a11'] * nu.item(0)],
           [0, 0, 0, 0],
           [par['a22'] * nu.item(1) + par['a24'] * nu.item(2) + par['a26'] * nu.item(3),
            -par['a11'] * nu.item(0), 0, 0]]
    C_A = np.array(C_A)
    M = M_RB + M_A
    # calculate the tau vector, ie forces and moments generated from:
    # the sail
    vt = par['vt'] + wind_sample.speed_mps
    alpha_w = par['alpha_w'] + deg2rad(wind_sample.direction_rad)
    v_t = [[vt * cos(alpha_w)],
           [vt * sin(alpha_w)],
           [0]]
    v_t = np.array(v_t)
    v_tw = log(abs(par['z_s']) * cos(phi) / par['h0']) / log(par['h1'] / par['h0']) * v_t
    v_tw = np.array(v_tw)
    R1 = [[cos(-psi), -sin(-psi), 0],
          [sin(-psi), cos(-psi), 0],
          [0, 0, 1]]
    R1 = np.array(R1)
    R2 = [[1, 0, 0],
          [0, cos(-phi), -sin(-phi)],
          [0, sin(-phi), cos(-phi)]]
    R2 = np.array(R2)
    v_tb = R2.dot(R1).dot(v_tw)   # wind expressed in the body frame
    # print('v_tb: ', v_tb)
    V_in = [[u], [v], [0]]
    V_in = np.array(V_in)
    temp1 = np.array([p, 0, r])
    temp2 = np.array([par['xs'], par['ys'], par['zs']])
    temp3 = np.array([np.cross(temp1, temp2)]).T
    V_awb = v_tb - V_in - temp3
    V_awu = V_awb[0]
    V_awv = V_awb[1]
    alpha_aw = arctan2(V_awv.real, -V_awu.real)
    # (sail luffing or not)
    if alpha_aw > delta_sbar:
        delta_s = delta_sbar
    elif alpha_aw < -delta_sbar:
        delta_s = -delta_sbar
    else:
        delta_s = alpha_aw
    alpha_as = alpha_aw - delta_s
    [Cls, Cds] = sailcoef(alpha_as)
    Ls = 0.5 * par['rho_a'] * par['As'] * (V_awu ** 2 + V_awv ** 2) * Cls
    Ds = 0.5 * par['rho_a'] * par['As'] * (V_awu ** 2 + V_awv ** 2) * Cds
    tau_sail = [Ls * sin(alpha_aw) - Ds * cos(alpha_aw),
                Ls * cos(alpha_aw) + Ds * sin(alpha_aw),
                -(Ls * cos(alpha_aw) + Ds * sin(alpha_aw)) * par['zs'],
                - (Ls * sin(alpha_aw) - Ds * cos(alpha_aw)) * par['Xce'] * sin(delta_s) + (Ls * cos(alpha_aw) + Ds * sin(alpha_aw)) * (par['Xm'] - par['Xce'] * cos(delta_s))]
    tau_sail = np.array(tau_sail)
    Mzs = tau_sail[3]
    # the rudder
    v_aru = -u + r * par['yr']
    v_arv = -v - r * par['xr'] + p * par['zr']
    alpha_ar = arctan2(v_arv.real, -v_aru.real)
    alpha_a = alpha_ar - delta_r
    [Clr, Cdr] = ruddercoef(alpha_a)
    Cdr = Cdr + Clr ** 2 * par['Ar'] / (np.pi * 2 * par['zeta_r'] * par['d_r'] ** 2)
    Lr = 0.5 * par['rho_w'] * par['Ar'] * (v_aru ** 2 + v_arv ** 2) * Clr
    Dr = 0.5 * par['rho_w'] * par['Ar'] * (v_aru ** 2 + v_arv ** 2) * Cdr
    tau_rudder = [[Lr * sin(alpha_ar) - Dr * cos(alpha_ar)],
                  [Lr * cos(alpha_ar) + Dr * sin(alpha_ar)],
                  [-(Lr * cos(alpha_ar) + Dr * sin(alpha_ar)) * par['zr']],
                  [(Lr * cos(alpha_ar) + Dr * sin(alpha_ar)) * par['xr']]]
    tau_rudder = np.array(tau_rudder)
    Mzr = tau_rudder[3]
    # the tau vector is finally given by:
    tau = tau_sail + tau_rudder
    # calculate the damping forces and moments:
    # from the keel
    v_aku = -u + r * par['yk']
    v_akv = -v - r * par['xk'] + p * par['zk']
    alpha_ak = arctan2(v_akv.real, -v_aku.real)
    alpha_e = alpha_ak
    [Clk, Cdk] = keelcoef(alpha_e)
    Cdk = Cdk + Clk ** 2 * par['Ak'] / (np.pi * 2 * par['zeta_k'] * par['d_k'] ** 2)
    Lk = 0.5 * par['rho_w'] * par['Ak'] * (v_aku ** 2 + v_akv ** 2) * Clk
    Dk = 0.5 * par['rho_w'] * par['Ak'] * (v_aku ** 2 + v_akv ** 2) * Cdk
    D_keel = [[-Lk * sin(alpha_ak) + Dk * cos(alpha_ak)],
              [-Lk * cos(alpha_ak) - Dk * sin(alpha_ak)],
              [-(-Lk * cos(alpha_ak) - Dk * sin(alpha_ak)) * par['zk']],
              [-(Lk * cos(alpha_ak) + Dk * sin(alpha_ak)) * par['xk']]]
    D_keel = np.array(D_keel)
    # from the hull
    v_ahu = -u + r * par['yh']
    v_ahv = (-v - r * par['xh'] + p * par['zh']) / cos(phi)
    v_ah = sqrt(v_aku ** 2 + v_akv ** 2)
    alpha_ah = arctan2(v_ahv.real, -v_ahu.real)
    Frh = resistancehull(v_ah)
    D_hull = [[Frh * cos(alpha_ah)],
              [-Frh * sin(alpha_ah) * cos(phi)],
              [Frh * sin(alpha_ah) * cos(phi) * par['zh']],
              [-Frh * sin(alpha_ah) * cos(phi) * par['xh']]]
    D_hull = np.array(D_hull)
    # from heel and yaw
    # (compute first eta_dot and thereby phi_dot and psi_dot)
    J = [[cos(psi), -sin(psi) * cos(phi), 0, 0],
         [sin(psi), cos(psi) * cos(phi), 0, 0],
         [0, 0, 1, 0],
         [0, 0, 0, cos(phi)]]
    J = np.array(J)
    eta_dot = J.dot(nu)
    # print(eta_dot)
    phi_dot = eta_dot.item(2)
    psi_dot = eta_dot.item(3)
    D_heelandyaw = [[0],
                    [0],
                    [par['c'] * phi_dot * abs(phi_dot)],
                    [par['d'] * psi_dot * abs(psi_dot) * cos(phi)]]
    D_heelandyaw = np.array(D_heelandyaw)
    # compute total damping vector D
    D = D_keel + D_hull + D_heelandyaw
    # righting moment plus internal moving mass system (ie transversal weight)
    phi_deg = phi * 180 / np.pi
    M_xw = -y_w * par['w_c'] * par['y_bm'] * cos(phi)
    M_zw = -y_w * par['w_c'] * par['x_c'] * sin(abs(phi))
    G = [[0],
         [0],
         [par['a'] * phi_deg ** 2 + par['b'] * phi_deg + M_xw],
         [M_zw]]
    G = np.array(G)
    # computation of nu_dot
    temp3 = np.linalg.solve(M, tau)
    temp2 = np.linalg.solve(M, G)
    temp0 = np.linalg.solve(M, (add(C_RB.dot(nu), C_A.dot(nu))))
    temp1 = np.linalg.solve(M, D)
    nu_dot = add(add(-temp0, -temp1), add(-temp2, temp3))
    # output the derivative of the state extended with the sail angle
    X_dot_ext = eta_dot.tolist() + nu_dot.tolist()
    X_dot_ext = [e[0] for e in X_dot_ext]
    return X_dot_ext


class InputStructure(BaseModel):
    rudderAngle: float = Field(..., ge=-np.pi/4, le=np.pi/4) # [0]
    sailAngle: float = Field(..., ge=0, le=np.pi/2) # [1]
    massPosition: float = 0 # [2]

    class Config:
        validate_assignment = True


@dataclass(frozen=True)
class StateStructure:
    x: float # = V_in[3] # 0
    y: float # = V_in[4] # 1
    phi: float # = V_in[5] # 2
    psi: float # = V_in[6] # 3
    u: float # = V_in[7] # 4
    v: float # = V_in[8] # 5
    p: float # = V_in[9] # 6
    r: float # = V_in[10] # 7


@dataclass(frozen=True)
class OutputStructure:
    state: StateStructure


class Yacht(Iterable):
    def __init__(self, environment: Environment):
        self.environment = environment
        self.t0 = 0
        self.dt = 1
        self.tk = 10
        self._t = self.t0
        self._x = StateStructure(x=environment.startPosition.x,
                                 y=environment.startPosition.y,
                                 phi=0,
                                 psi=environment.startPosition.psi,
                                 u=3,
                                 v=0,
                                 p=0,
                                 r=0)
        self._calculeted = True
        self._inputStructure = InputStructure(rudderAngle=0, sailAngle=0, massPosition=0)

        self._outputStructureHistory: List[OutputStructure] = []
        self._inputStructureHistory: List[InputStructure] = []
        self._timeHistory: List[float] = []

    def save(self, experimentName=''):
        # with open('results', '')
        p = Path('.', 'results')
        p.mkdir(exist_ok=True)
        p = p / f'result{experimentName}.json'
        data = dict()
        data['history'] = [{'t': t, 'u': u.dict(), 'y': asdict(y)} for t, u, y \
                           in zip(self._timeHistory, self._inputStructureHistory, self._outputStructureHistory)]
        data['scenario'] = self.environment.model_dump(mode="json")
        with open(p, 'w') as outfile:
            json.dump(data, outfile)

    def calculateOutput(self) -> OutputStructure:
        self._outputStructureHistory.append(OutputStructure(state=self._x))
        self._inputStructureHistory.append(self._inputStructure)
        self._timeHistory.append(self._t)
        def f(t, x):
            u = np.array([self._inputStructure.rudderAngle,
                          self._inputStructure.sailAngle,
                          self._inputStructure.massPosition])
            temp = np.concatenate((u, x))
            wind_sample = self.environment._windModel(t)
            dotx = X_dot_ext(temp, wind_sample)
            return dotx
        r = ode(f).set_integrator('dopri5', atol=1e-5, rtol=1e-5)
        # r = ode(f).set_integrator('dopri5', atol=1e-10, rtol=1e-10)
        r.set_initial_value(astuple(self._x), self._t)
        x = r.integrate(r.t + self.dt)
        self._x = StateStructure(x=x[0],
                                 y=x[1],
                                 phi=x[2],
                                 psi=x[3],
                                 u=x[4],
                                 v=x[5],
                                 p=x[6],
                                 r=x[7])
        output = OutputStructure(state=self._x)
        self._calculeted = True
        return output

    def nextStep(self) -> float:
        if self._calculeted:
            self._t += self.dt
            self._calculeted = False
        return self._t

    def getInputStructure(self) -> InputStructure:
        self._inputStructure = InputStructure(rudderAngle=0, sailAngle=0, massPosition=0)
        return self._inputStructure

    def __iter__(self) -> Iterator[Tuple[float, OutputStructure, InputStructure]]:
        return self

    def __next__(self) -> Tuple[float, OutputStructure, InputStructure]:
        t = self.nextStep()
        if self.tk < t:
            raise StopIteration
        return t, self.calculateOutput(), self.getInputStructure()

    def __len__(self) -> int:
        return int((self.tk-self.t0)/self.dt)

    def countSteps(self) -> int:
        return len(self)

    def plotMap(self):
        x = [out.state.x for out in self._outputStructureHistory]
        y = [out.state.y for out in self._outputStructureHistory]
        psi = [out.state.psi for out in self._outputStructureHistory]
        fig, ax = self.environment.plot(x, y, psi)
        return fig, ax

    def plotCourse(self):
        psi = [np.rad2deg(out.state.psi) for out in self._outputStructureHistory]
        u  = [np.rad2deg(inp.rudderAngle) for inp in self._inputStructureHistory]
        t = self._timeHistory
        fig, axs = plt.subplots(2)
        axs[0].plot(t, psi, label='yacht direction')
        # axs[0].plot((self.t0, self.tk),
        #         (np.rad2deg(par['alpha_w']), np.rad2deg(par['alpha_w'])), 'r:',
        #         label='wind direction')
        axs[0].plot(self.environment.wind_scenario.times_s,
                    [rad2deg(par['alpha_w']) + w for w in self.environment.wind_scenario.direction_raw_deg])
        axs[0].set_xlabel('time [s]')
        axs[0].set_ylabel('course [deg]')
        axs[0].legend()
        axs[0].set_xlim([min(t), max(t)])

        axs[1].plot(t, u, 'g')
        axs[1].set_xlabel('time [s]')
        axs[1].set_ylabel('rudder angle [deg]')
        axs[1].set_xlim([min(t), max(t)])
        return fig, axs

    def plotSpeed(self):
        u = [out.state.u for out in self._outputStructureHistory]
        v = [out.state.v for out in self._outputStructureHistory]
        sail  = [np.rad2deg(inp.sailAngle) for inp in self._inputStructureHistory]
        t = self._timeHistory
        fig, axs = plt.subplots(3)
        axs[0].plot(t, u)
        axs[0].set_title('speed')
        axs[0].set_ylabel('longitudinal [m/s]')
        axs[0].set_xlim([min(t), max(t)])
        axs[1].plot(t, v)
        axs[1].set_xlabel('time [s]')
        axs[1].set_ylabel('lateral [m/s]')
        axs[1].set_xlim([min(t), max(t)])
        axs[2].plot(t, sail, 'g')
        axs[2].set_xlabel('time [s]')
        axs[2].set_ylabel('sail angle [deg]')
        axs[2].set_xlim([min(t), max(t)])
        return fig, axs

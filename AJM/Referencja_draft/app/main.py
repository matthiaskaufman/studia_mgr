import matplotlib
matplotlib.use("TkAgg")
import matplotlib.pyplot as plt
from numpy import deg2rad
from tqdm import tqdm
from environment import Environment
from model import Yacht



def main():
    environment = Environment.createFromJson('data/trasa1.json')
    yacht = Yacht(environment)
    yacht.dt = 1
    yacht.tk = 300

    for t, y, u in tqdm(yacht, total=yacht.countSteps()):
        # for t, y, u in yacht:
        u.rudderAngle = deg2rad(10)
        u.sailAngle = deg2rad(10)
        # print(u)
        # print('czas = ',t)
        # print(y.state.psi)
    yacht.save()
    fig, ax = yacht.plotMap()
    fig, axs = yacht.plotCourse()
    fig, axs = yacht.plotSpeed()
    plt.show()
    yacht.save()

if __name__ == '__main__':
    main()

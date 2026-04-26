import numpy as np

class QuadParams:
    def __init__(self):

        # Simulation
        self.simTime = 20

        # Desired states
        self.zDes = -3
        self.xDes = 1
        self.yDes = 0.5
        self.yawDes = np.deg2rad(130)

        # PID gains [z, xy, yaw, pitchroll]
        self.P = [4, 0.005, 0.03, 0.0001]
        self.I = [1, 0, 0, 0]
        self.D = [4, 0.03, 0.003, 0.00008]

        self.iMax = [7.6, 0, 0, 0]
        self.iMin = [-7.6, 0, 0, 0]

        self.outMax = [7.6, np.deg2rad(15), 7.6, 7]
        self.outMin = [-7.6, np.deg2rad(-15), -7.6, -7]

        # Physical constants
        self.batteryVoltage = 7.6
        self.L = 90e-3
        self.La = self.L / np.sqrt(2)
        self.h = 12e-3

        D = 55e-3
        rho = 1.225
        CT = 0.08
        CQ = 0.004

        self.kThrust = CT * rho * D**4 / (4 * np.pi**2)
        self.kTorque = CQ * rho * D**4 / (4 * np.pi**2)

        mb = 16e-3
        mProp = (1/7)*1e-3

        self.m = 0.068 + mb + mProp
        self.g = 9.81

        self.Jx = 1/12*self.m*(self.L**2+self.h**2)
        self.Jy = self.Jx
        self.Jz = 1/12*self.m*(self.L**2+self.L**2)
        self.Jprop = 1/6*mProp*D**2

        self.Komega = .891e-3
        self.Ra = 0.6
        self.Kt = .890e-3
        self.TL = 0
import numpy as np
from controller import hover_controller
from utils import rotation_matrix

def quad_dynamics(t, S, p):

    xDot,yDot,zDot = S[3:6]
    roll,pitch,yaw = S[6:9]
    rollRate,pitchRate,yawRate = S[9:12]
    omega = S[12:16]

    V, zError, *_ = hover_controller(t,S,p)

    T = p.Kt/p.Ra*(V - p.Komega*omega)
    F = p.kThrust*omega**2
    omegaDot = (T - p.TL)/p.Jprop

    xyzDDot = -(rotation_matrix(roll,pitch,yaw) @
                np.array([0,0,np.sum(F)]))/p.m + np.array([0,0,p.g])

    rollDDot = 1/p.Jx*((F[0]+F[1])*p.L/2 - (F[2]+F[3])*p.L/2)
    pitchDDot = 1/p.Jy*((F[0]+F[3])*p.L/2 - (F[1]+F[2])*p.L/2)
    yawDDot = 1/p.Jz*(T[0]-T[1]+T[2]-T[3])

    Sdot = np.zeros_like(S)
    Sdot[0:3] = S[3:6]
    Sdot[3:6] = xyzDDot
    Sdot[6:9] = S[9:12]
    Sdot[9:12] = [rollDDot,pitchDDot,yawDDot]
    Sdot[12:16] = omegaDot
    Sdot[16] = zError  # integral state

    return Sdot
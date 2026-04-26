import numpy as np

def pid_controller(error, error_dot, error_int, Kp, Ki, Kd,
                   i_max, i_min, out_max, out_min):

    integral_term = np.clip(Ki * error_int, i_min, i_max)
    control = Kp*error + integral_term + Kd*error_dot
    control = np.clip(control, out_min, out_max)

    contributions = np.array([
        Kp*error,
        integral_term,
        Kd*error_dot,
        error
    ])

    return control, contributions


def hover_controller(t, S, p):

    x,y,z = S[0:3]
    xDot,yDot,zDot = S[3:6]
    roll,pitch,yaw = S[6:9]
    rollRate,pitchRate,yawRate = S[9:12]
    omega = S[12:16]
    zInt = S[16]

    # Z control
    zError = -(p.zDes - z)
    thrust, zPID = pid_controller(
        zError, zDot, zInt,
        p.P[0], p.I[0], p.D[0],
        p.iMax[0], p.iMin[0],
        p.outMax[0], p.outMin[0]
    )

    # Yaw control
    yawError = p.yawDes - yaw
    yawCmd, yawPID = pid_controller(
        yawError, -yawRate, 0,
        p.P[2], p.I[2], p.D[2],
        p.iMax[2], p.iMin[2],
        p.outMax[2], p.outMin[2]
    )

    # Position control
    XErr = p.xDes - x
    YErr = p.yDes - y

    XRel = XErr*np.cos(yaw) + YErr*np.sin(yaw)
    YRel = -XErr*np.sin(yaw) + YErr*np.cos(yaw)

    pitchDes, xPID = pid_controller(
        XRel, -xDot, 0,
        p.P[1], p.I[1], p.D[1],
        p.iMax[1], p.iMin[1],
        p.outMax[1], p.outMin[1]
    )

    rollDes, yPID = pid_controller(
        YRel, -yDot, 0,
        p.P[1], p.I[1], p.D[1],
        p.iMax[1], p.iMin[1],
        p.outMax[1], p.outMin[1]
    )

    rollErr = rollDes - roll
    pitchErr = -pitchDes - pitch

    rollCmd, rollPID = pid_controller(
        rollErr, -rollRate, 0,
        p.P[3], p.I[3], p.D[3],
        p.iMax[3], p.iMin[3],
        p.outMax[3], p.outMin[3]
    )

    pitchCmd, pitchPID = pid_controller(
        pitchErr, -pitchRate, 0,
        p.P[3], p.I[3], p.D[3],
        p.iMax[3], p.iMin[3],
        p.outMax[3], p.outMin[3]
    )

    Mfr = thrust - yawCmd/p.La + pitchCmd/p.La - rollCmd/p.La
    Mfl = thrust + yawCmd/p.La + pitchCmd/p.La + rollCmd/p.La
    Mbr = thrust + yawCmd/p.La - pitchCmd/p.La - rollCmd/p.La
    Mbl = thrust - yawCmd/p.La - pitchCmd/p.La + rollCmd/p.La

    V = np.clip(np.array([Mfl,Mbl,Mbr,Mfr]),0,p.batteryVoltage)

    return V, zError, yawError, pitchErr, rollErr
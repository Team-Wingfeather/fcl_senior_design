import numpy as np
from scipy.integrate import solve_ivp
from params import QuadParams
from dynamics import quad_dynamics

p = QuadParams()

S0 = np.zeros(17)

sol = solve_ivp(
    lambda t,S: quad_dynamics(t,S,p),
    [0,p.simTime],
    S0,
    rtol=1e-3,
    atol=1e-6,
    max_step=0.01
)

t = sol.t
S = sol.y.T

print("Simulation complete.")
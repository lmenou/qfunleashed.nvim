"""Script for random trial."""

import selectionpattern.pattern_cahn as cahn
import selectionpattern.startor as start
import selectionpattern.trackerCreator as trac

########################
# SIMU: Long simulations
########################

coucou

h = 4.0
dct_diff = {"diffA": 1, "diffB": 6}
dict_rate = {"alphaA": 0.4, "betaA": 0.9, "alphaB": 0.4444, "betaB": 1.0}
dict_grid = {"size": 100, "shape": 100, "periodic": True}
dict_perturb = {"epsilon": 2e-3, "q": dict_rate["betaB"]}
dict_Cahn = {"nu": 0.1, "chi": 1.2}
simulation_time = 1e4  # Small trial here
# Initialisation
eq = cahn.patterning_cahn.CahnEq(h, dict_rate, dict_diff, dict_Cahn)

initstate = start.starter.initState(
    h, dict_rate, dict_grid, dict_perturb, zeroState=False, noise=True
)
# Reinitialise trackers
trackers = trac.trac.VideoTracker()
# Run the simulation
sol = eq.solve(initstate, simulation_time, tracker=trackers)

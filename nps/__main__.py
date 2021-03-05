from nps.core import JuliaFractal, SolarClock

import os


programs = { "solar_clock"  : SolarClock, "julia_fractal": JuliaFractal }
programs.get(os.environ.get("SHADER", "solar_clock"), SolarClock).run()
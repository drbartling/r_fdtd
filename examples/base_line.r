# Transmission line
lineType    <- TL_COAX
lineLength  <- 3.0   # meters
a           <- 4e-3   # meters
b           <- 23.5e-3   # meters
rCon        <- 1.68e-8
gIns        <- 3.146e-6
muCon       <- 1
muIns       <- 1
epsDi       <- 4.5

# Termination
Rg         <- 0
Rl         <- 1e-6

# Signal Source
signalAmplitude <- -1
signalWidth     <- 400e-12
signalShape     <- SS_Step
signalType      <- SS_VOLTAGE

# Simulation
resolution <- 100   # points per meter
runTime    <- 2.2
T_fr       <- 0
plotRefreshPeriod   <- 10

# Misc.
pointCapacitance <- 2e-12   # Capacitance of transistors
epsCap <- log(b/a)
epsCap <- epsCap * pointCapacitance
epsCap <- epsCap * resolution
epsCap <- epsCap / (2*pi)
epsCap <- epsCap / 8.854e-12
epsCap <- epsCap + epsDi

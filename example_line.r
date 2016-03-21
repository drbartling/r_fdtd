# Transmission line
lineType    <- TL_COAX  # Type of transmission line
lineLength  <- 3.0      # length of tranmission line (meters)
a           <- 4e-3     # dimension a of transmission line (meters)
b           <- 23e-3    # dimension b of transmission line (meters)
rCon        <- 1.68e-8  # resistivity of conductor
gIns        <- 3.146e-6 # conductivity of insulator
muCon       <- 1        # relative magnetic permiability of conductor
muIns       <- 1        # relative magnetic permiability of insulator
epsDi       <- 4.5      # relative electric permittivity of insulator

# Termination
Rg         <- 0         # Source termination (0 to match)
Rl         <- 0         # Load termination (0 to match)

# Signal Source
signalAmplitude <- 1
signalWidth     <- 400e-12
signalShape     <- SS_Step
signalType      <- SS_VOLTAGE

# Simulation
resolution <- 200   # points per meter
runTime    <- 3
T_fr       <- 0
plotRefreshPeriod   <- 5

# Discontinuities
#                               Type,    a (M),  b (M),  r(ohm), g(mho), u-C,    u-I,    e-D, Discontinuity, Start Point (M),    Length (M)
discontinuities <- rbind(
                            c(  TL_COAX, 0,      0,      0,      0,      0,      0,      2,  TL_STEP,      1,                  1.5 )
                        )

# Add discontinuities to base file.
# Get source directory using getSrcDirectory(function(x) {x}) and concatenate it
# to the base file name.
source(paste(getSrcDirectory(function(x) {x}), "//", "air_w_pnp.r", sep=""))

# Discontinuities

#                               Type,              a (M),   b (M),    r(ohm), g(mho), u-C,    u-I,    e-D,    Discontinuity, Start Point (M),    Length (M)
discontinuities <- rbind(
                            discontinuities, 
                            c(  0,                 0,       0,        0,      0,      0,      0,      1.8,    TL_STEP,       2.50,               0 )
                        )

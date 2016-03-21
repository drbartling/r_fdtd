source("gas_w_pnp.r")

# Discontinuities

#                               Type,              a (M),   b (M),    r(ohm), g(mho), u-C,    u-I,    e-D,    Discontinuity, Start Point (M),    Length (M)
discontinuities <- rbind(
                            discontinuities, 
                            c(  0,                 0,       0,        0,      0,      0,      0,      80.0,   TL_STEP,       2.90,               0 )
                        )

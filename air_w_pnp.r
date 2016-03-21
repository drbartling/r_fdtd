source("air_wo_pnp.r")

# Discontinuities

#                               Type,              a (M),   b (M),    r(ohm), g(mho), u-C,    u-I,    e-D,    Discontinuity, Start Point (M),    Length (M)
discontinuities <- rbind(
                            discontinuities, 
                            c(  0,                 0,       0,        0,      0,      0,      0,      epsCap, TL_POINT,      0.25,               0 ),
                            c(  0,                 0,       0,        0,      0,      0,      0,      epsCap, TL_POINT,      0.75,               0 )
                        )

source("base_line.r")

# Discontinuities

#                               Type,              a (M),   b (M),    r(ohm), g(mho), u-C,    u-I,    e-D,    Discontinuity, Start Point (M),    Length (M)
discontinuities <- rbind(
                            c(  0,                 4.0e-3,  15.95e-3, 0,      0,      0,      0,      2.75,   TL_STEP,       1.0,                0 ),
                            c(  TL_PARALLEL_PLATE, 37.6e-3, 5.00e-3,  0,      0,      0,      0,      1.0,    TL_STEP,       2.0,                0 )
                        )


source("physical_constants.R")

# Physical transmission line types
TL_COAX             <- 1
TL_STRIP_LINE       <- 2
TL_MICRO_STRIP      <- 3
TL_PARALLEL_PLATE   <- 4
TL_TWO_WIRE         <- 5

# Physical and discontinuity parameters
TL_TYPE                 <- 1
TL_A                    <- 2
TL_B                    <- 3
TL_RC                   <- 4
TL_GI                   <- 5
TL_UC                   <- 6
TL_UI                   <- 7
TL_ED                   <- 8
TL_LINE_PARAMETER_COUNT <- 8
TL_DISCONTINUITY        <- 9
TL_START                <- 10
TL_STOP                 <- 11
TL_DISC_PARAMETER_COUNT <- 11

# Model parameters
TL_R    <- 1
TL_L    <- 2
TL_G    <- 3
TL_C    <- 4
TL_MODEL_PARAMETER_COUNT    <- 4

# Discontinuity types
TL_STEP <- 1
TL_RAMP <- 2
TL_CURVE <- 3
TL_POINT <- 4

TL_PhysicalTransmisionLine <- function(type, a, b, rc, gi, uc, ui, ed, length)
{
    tl <- array(0, dim=c(TL_LINE_PARAMETER_COUNT, length))
    tl[TL_TYPE, 1:length]    <- lineType     #
    tl[TL_A, 1:length]       <- a            #   Inner conductor radius (m).
    tl[TL_B, 1:length]       <- b            #   Outer conductor radius (m).
    tl[TL_RC, 1:length]      <- rCon         #   Resistance (Ohm/m).
    tl[TL_GI, 1:length]      <- gIns         #   Conductance (Mho/m).
    tl[TL_UC, 1:length]      <- muCon        #   Permiability of Conductor.
    tl[TL_UI, 1:length]      <- muIns        #   Permiability of Insulator.
    tl[TL_ED, 1:length]      <- epsDi        #   Innter dielectric constant.

    return (tl)
}

TL_RelativeToAbsoluteParameters <- function(relativeLine)
{
    # Translate from relative to absolute permitivity and permiability
    end = dim(relativeLine)[2]
    absoluteLine <- relativeLine
    
    absoluteLine[c(TL_UC, TL_UI),1:end] <- relativeLine[c(TL_UC, TL_UI),1:end] *
                                           VACUUM_PERMEABILITY
                                           
    absoluteLine[TL_ED,1:end] <- relativeLine[TL_ED,1:end] * VACUUM_PERMITTIVITY
    
    return (absoluteLine)
}

TL_MetersToPoints <- function(valueInMeters, metersPerPoint)
{
    valueInPoints <- floor(valueInMeters / metersPerPoint)
    return (valueInPoints)
}

TL_AddStepDiscontinuity <- function(tLine, discontinuity)
{
    discStart <- discontinuity[TL_START]
    end <- dim(tLine)[2]
    for(i in TL_TYPE:TL_ED)
    {
        if (discontinuity[i] > 0)
        {
            tLine[i, discStart:end] <- discontinuity[i]
        }
    }
    return (tLine)
}

TL_AddRampDiscontinuity <- function(tLine, discontinuity)
{
    discStart <- discontinuity[TL_START]
    discStop  <- min(dim(tLine)[2], (discStart + discontinuity[TL_STOP]))
    discLength <- discStop - discStart + 1
    end <- dim(tLine)[2]
    for(i in TL_A:TL_ED)
    {
        if (discontinuity[i] > 0)
        {
            tLine[i, (discStart + 1):end] <- discontinuity[i]
            tLine[i, discStart:discStop] <- seq(tLine[i, discStart],
                                                discontinuity[i],
                                                length=discLength)
        }
    }
    return (tLine)
}

TL_AddCurveDiscontinuity <- function(tLine, discontinuity)
{
    
    end <- dim(tLine)[2]
    
    discStart <- discontinuity[TL_START]
    discStop  <- min(dim(tLine)[2], (discStart + discontinuity[TL_STOP]))
    discLength <- discStop - discStart + 1
    discMid <- floor(discStart + discLength / 2)
    for(i in TL_A:TL_ED)
    {
        if (discontinuity[i] > 0)
        {
            tLine[i, discStart:end] <- tLine[i, discStart] +
                                       pnorm((discStart:end),
                                       discMid, floor(discLength / 8)) *
                                       (discontinuity[i] -
                                       tLine[i, discStart])
        }
    }

    return (tLine)
}

TL_AddPointDiscontinuity <- function(tLine, discontinuity)
{
    discStart <- discontinuity[TL_START]
    for(i in TL_A:TL_ED)
    {
        if (discontinuity[i] > 0)
        {
            tLine[i, discStart] <- discontinuity[i]
        }
    }

    return (tLine)
}

TL_AddDiscontinuity <- function(tLine, discontinuity)
{
    if (TL_STEP == discontinuity[TL_DISCONTINUITY])
    {
        tLine <- TL_AddStepDiscontinuity(tLine, discontinuity)
    } else if(TL_RAMP == discontinuity[TL_DISCONTINUITY])
    {
        tLine <- TL_AddRampDiscontinuity(tLine, discontinuity)
    }else if (TL_CURVE == discontinuity[TL_DISCONTINUITY])
    {
        tLine <- TL_AddCurveDiscontinuity(tLine, discontinuity)
    }else if (TL_POINT == discontinuity[TL_DISCONTINUITY])
    {
        tLine <- TL_AddPointDiscontinuity(tLine, discontinuity)
    }else
    {
        cat("Invalid Discontinuity Type\n\n")
        stop()
    }

    return (tLine)
}

TL_SurfaceResistance <- function(r)
{
    return (r)
}

TL_ModelCoax <- function(lineSegment)
{
    modelLineSegment <- 1:TL_MODEL_PARAMETER_COUNT
    
    # renaming variables to make formulae easier to read
    a   <- lineSegment[TL_A]
    b   <- lineSegment[TL_B]
    rc  <- lineSegment[TL_RC]
    uc  <- lineSegment[TL_UC]
    gi  <- lineSegment[TL_GI]
    ed  <- lineSegment[TL_ED]
    
    rs <- TL_SurfaceResistance(rc)
    
    modelLineSegment[TL_R] <- rs / 2 / pi *  (1 / a + 1 / b)  # Resistance [R/m]
    modelLineSegment[TL_L] <- uc / 2 / pi * log(b / a)  # Inductance [H/m]
    modelLineSegment[TL_G] <- 2 * pi * gi / log(b / a)  # Conductance [S/m]
    modelLineSegment[TL_C] <- 2 * pi * ed / log(b / a)  # Capacitance [F/m]
    
    return (modelLineSegment)
}

TL_ModelStripLine <- function(lineSegment)
{
    return (1:TL_MODEL_PARAMETER_COUNT)
}

TL_ModelMicroStrip <- function(lineSegment)
{
    return (1:TL_MODEL_PARAMETER_COUNT)
}

TL_ModelParallelPlate <- function(lineSegment)
{
    modelLineSegment <- 1:TL_MODEL_PARAMETER_COUNT
    
    # renaming variables to make formulae easier to read
    a   <- lineSegment[TL_A]
    b   <- lineSegment[TL_B]
    rc  <- lineSegment[TL_RC]
    uc  <- lineSegment[TL_UC]
    gi  <- lineSegment[TL_GI]
    ed  <- lineSegment[TL_ED]
    
    rs <- TL_SurfaceResistance(rc)
    
    modelLineSegment[TL_R] <- 2 * rs / a  # Resistance [R/m]
    modelLineSegment[TL_L] <- uc * b / a  # Inductance [H/m]
    modelLineSegment[TL_G] <- gi * a / b  # Conductance [S/m]
    modelLineSegment[TL_C] <- ed * a / b  # Capacitance [F/m]
    
    return (modelLineSegment)
}

TL_ModelTwoWire <- function(lineSegment)
{
    modelLineSegment <- 1:TL_MODEL_PARAMETER_COUNT
    
    # renaming variables to make formulae easier to read
    a   <- lineSegment[TL_A]
    b   <- lineSegment[TL_B]
    rc  <- lineSegment[TL_RC]
    uc  <- lineSegment[TL_UC]
    gi  <- lineSegment[TL_GI]
    ed  <- lineSegment[TL_ED]
    
    rs <- TL_SurfaceResistance(rc)
    
    const <- log((b / a) + sqrt((b / a) ^ 2 - 1))
    
    modelLineSegment[TL_R] <- 2 * rs / pi / a  # Resistance [R/m]
    modelLineSegment[TL_L] <- uc / pi * const  # Inductance [H/m]
    modelLineSegment[TL_G] <- pi * gi / const  # Conductance [S/m]
    modelLineSegment[TL_C] <- pi * ed / const  # Capacitance [F/m]
    
    return (modelLineSegment)
}

TL_MODEL_FUNCTION <- c(TL_ModelCoax,
                       TL_ModelStripLine,
                       TL_ModelMicroStrip,
                       TL_ModelParallelPlate,
                       TL_ModelTwoWire)

TL_ModelTransmissionLine <- function(physicalLine)
{
    end         <- dim(physicalLine)[2]
    modelLine   <- array(0, dim=c(TL_MODEL_PARAMETER_COUNT, end))
    
    for(i in 1:end)
    {
        modelLine[ , i] <- TL_MODEL_FUNCTION[[physicalLine[TL_TYPE, i]]](physicalLine[ , i])
    }
    
    return (modelLine)
}

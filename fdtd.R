#FDTD Transmission Line Simulation

# Include files
source("transmission_line.R")
source("signal_sources.R")

FDTD_SimulateFile <- function(fileName, doPlot = 1)
{
    # Select and read transmission line file
    source(fileName)

    
    
    # Define Simulation Parameters
    K  <- lineLength * resolution + 1   #   Number of grid points.
    dz <- lineLength / (K - 1)          #   Grid spacing (m)
    z  <- (0:(K - 1)) * dz              #   Z-axis (m).

    # Define base physical description of transmission line
    rTransmissionLine <- TL_PhysicalTransmisionLine(lineType, a, b, rCon, gIns,
                                                    muCon, muIns, epsDi, K)

    # Define discontinuities
    if (exists("discontinuities"))
    {
        discontinuities[ , c(TL_START, TL_STOP)] <- TL_MetersToPoints(discontinuities[ , c(TL_START, TL_STOP)], dz)
        for(i in 1:dim(discontinuities)[1])
        {
            rTransmissionLine <- TL_AddDiscontinuity(rTransmissionLine, discontinuities[i, ])
        }
    }

    # Translate from relative to absolute permitivity and permiability
    aTransmissionLine <- TL_RelativeToAbsoluteParameters(rTransmissionLine)

    # Calculate transmission line RLGC parameters from physical description
    mTransmissionLine <- TL_ModelTransmissionLine(aTransmissionLine)

    if (Rg == 0)
    {
        Rg <- sqrt(mTransmissionLine[TL_L, 1] / mTransmissionLine[TL_C, 1])
    }

    if (Rl == 0)
    {
        Rl <- sqrt(mTransmissionLine[TL_L, K] / mTransmissionLine[TL_C, K])
    }

    if(signalType == SS_CURRENT)
    {
        # Parallel Conductance [Mho/m]
        mTransmissionLine[TL_G, 2]    <- (1 / Rg) / dz
    } else
    {
        # Series Resistance [Ohm/m]
        mTransmissionLine[TL_R, 1]    <- Rg / dz
    }

    mTransmissionLine[TL_R, K-1]  <- Rl/dz   # Load Resistance

    # Axis scaling
    if(signalType == SS_CURRENT)
    {
        Imax <- abs(signalAmplitude)*1.1 # Current y-scale [mA]
        Vmax <- Imax*50     # Voltage y-scale [V]
    }else
    {
        Vmax <- abs(signalAmplitude)*1.1 # Voltage y-scale [V]
        Imax <- Vmax/(50)   # Current y-scale [mA]
    }

    # Propagation velocity (m/s)
    vp <-  1 / sqrt(mTransmissionLine[TL_L, ] * mTransmissionLine[TL_C, ])

    # Critical time step   (s/step)
    dt <- (dz / max(vp)) / 2

    signalWidth <- signalWidth / dt # convert signalWidth from time to steps
    t0    <- 5 * signalWidth
    if (T_fr == 0)
        T_fr <- floor(signalWidth)
    end

    #   Number of time steps, amount of time it takes a signal to travel the
    #   length of the line 10 times + the time to inject the signal
    N <- floor(runTime * sum(dz / vp) / dt + t0 * 2)
    if (N > 2^24)
    {
        cat("Whoah something blew up!\n\n")
        stop()
    }
    
    #  Initialize Voltage and Current Arrays
    V <- array(0, dim = c(1, K)) # zeros(1,K)
    I <- array(0, dim = c(1, K))
    Vmeas <- array(0, dim = c(1, N))
    t <- (1:N)
    t <- (t * dt) - t0 * dt

    #  Define update-equation constants.
    c1 <- -(2 * dt) / (dt * dz * mTransmissionLine[TL_R, ] + 2 * dz*
          mTransmissionLine[TL_L, ])
    c2 <- (2 * mTransmissionLine[TL_L, ] - dt * mTransmissionLine[TL_R, ]) /
          (2 * mTransmissionLine[TL_L, ] + dt * mTransmissionLine[TL_R, ])
    c3 <- -(2 * dt) / (dt * dz * mTransmissionLine[TL_G, ] + 2 * dz *
          mTransmissionLine[TL_C, ])
    c4 <- (2 * mTransmissionLine[TL_C, ] - dt * mTransmissionLine[TL_G, ]) /
          (2 * mTransmissionLine[TL_C, ] + dt * mTransmissionLine[TL_G, ])

    #    FDTD loop
    n <- 1
    while (n <= N)
    {

        #   Set the generator output.
        signal <- SS_GenerateSignal(n, signalAmplitude, t0, signalWidth, signalShape)
        if (signalType == SS_VOLTAGE)
        {
            V[1] <- signal[n]
        } else if (signalType == SS_CURRENT)
        {
            I[1] <- signal[n]
        } else
        {
            cat("Invalid Source Function\n\n")
            stop()
        }

        #   Voltage update equation loop.
        for(k in 2:K)
        {
           V[k] <- c3[k] * (I[k] - I[k-1]) + c4[k] * V[k]
        }

        #   Current update equation loop.
        for(k in 1:K-1)
        {
            I[k] <- c1[k] * (V[k+1] - V[k]) + c2[k] * I[k]
        }

        #   Set the Right-most boundary condition on the current sample.
        I[K] <- I[K-1]   # short end

        Vmeas[n] <- V[2] # - V[1]/2

        if (1 == doPlot)
        {
            if (0 == (n %% plotRefreshPeriod))
            {
                dev.hold()
                par(mfcol=c(3,1))
                plot(z, V[1:K], ylim=c(-Vmax, Vmax),
                    type="l", lwd=2, col="red",
                    main="Voltage Vs. Distance",
                    xlab="Distance (M)", ylab="Voltage(V)")
                plot(z, I[1:K], ylim=c(-Imax, Imax),
                    type="l", lwd=2, col="blue",
                    main="Current Vs. Distance",
                    xlab="Distance (M)", ylab="Current(A)")
                plot(t[1:n], Vmeas[1:n],
                    type="l", lwd=2, col="red",
                    xlim=c(t[n]-t[N], t[n]), ylim=c(-Vmax, Vmax),
                    main="Voltage Vs. Time", xlab="Time (S)", ylab="Voltage(V)")
                dev.flush()
            }
        }
        n <- n + 1
    }

    result <- array(0, dim = c(2, N))
    result[1, ] <- t
    result[2, ] <- Vmeas

    return(result)
}

FDTD_PlotTDRData <- function(data, fileList)
{
    colorCount <- 4
    plotColors <- c("black", "red", "blue", "forestgreen")

    xLimits <- c(0,0)
    yLimits <- xLimits

    for(i in 1:length(data))
    {
        xLimits <- c(min(data[[i]][1, ], xLimits), max(data[[i]][1, ], xLimits))
        yLimits <- c(min(data[[i]][2, ], yLimits), max(data[[i]][2, ], yLimits))
    }

    i = 1
    plot(data[[1]][1, ], data[[1]][2, ],
        type="l", lwd=2, col = plotColors[i %% colorCount + 1],
        xlim = xLimits, ylim = yLimits,
        main="Voltage Vs. Time", xlab="Time (S)", ylab="Voltage(V)")

    if(length(data) > 1)
    {
        for(i in 2:length(data))
        {
            lines(data[[i]][1, ], data[[i]][2, ],
                xlim = xLimits, ylim = yLimits,
                type = "l", lwd = 2, lty = i, col = plotColors[i %% colorCount + 1])
        }
    }

    legend(0, yLimits[2], basename(fileList[1:length(data)]), cex=0.8,
        col=plotColors[(1:length(data))%% colorCount + 1], lty=1:length(data))

    return(0)
}

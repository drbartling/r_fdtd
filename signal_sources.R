
SS_PULSE <- 1
SS_STEP  <- 2
SS_SINE  <- 3

SS_VOLTAGE <- 1
SS_CURRENT <- 2

SS_Pulse <- function(signal, amplitude, t0, sigma)
{
    signal <- amplitude * (dnorm(signal, t0, sigma) / dnorm(t0, t0, sigma))
    return (signal)
}

SS_Step <- function(signal, amplitude, t0, sigma)
{
    signal <- amplitude * pnorm(signal, t0, sigma)
    return (signal)
}

SS_Sin <- function(signal, amplitude, t0, sigma)
{
    signal <- amplitude * sin((signal / sigma) - t0)
}

SS_SquarePulse1 <- function(signal, amplitude, t0, sigma)
{
    signal <- signal - t0
    signal <- abs(signal)
    window <- signal < (sigma / 1)
    signal <- signal < sigma
    signal <- filter(signal, window, "convolution", 2, FALSE)
    #signal <- filter(signal, window, "convolution", 1, TRUE)
    signal <- signal * amplitude

    return (signal)
}


SS_SquarePulse2 <- function(signal, amplitude, t0, sigma)
{
    signal <- SS_Step(signal, amplitude, t0 - sigma, sigma/5) -
              SS_Step(signal, amplitude, t0 + sigma, sigma/5)
              
    return (signal)
}

SS_GenerateSignal <- function(length, amplitude, t0, sigma, Shape)
{
    signal <- 1:length
    signal <- Shape(signal, amplitude, t0, sigma)
    return (signal)
}

options(scipen = -20)   # Force scientific notation
rm(list = ls())         # Remove environemnent variables
graphics.off()          # Close any open graphics

source("fdtd.R")

fileName <- file.choose(new = FALSE)

dev.new()
data <- list()
data <- c(data, list(FDTD_SimulateFile(fileName, doPlot=1)))

dev.new()
FDTD_PlotTDRData(data, fileName)

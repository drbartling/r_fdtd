
options(scipen = -20)   # Force scientific notation
rm(list = ls())         # Remove environemnent variables
graphics.off()          # Close any open graphics

source("fdtd.R")

# Select Files

exampleDir <- ".\\examples"
fileList <- list.files(path = exampleDir)
fileList <- paste(exampleDir, "\\", fileList, sep="")

fileCount <- length(fileList)

data <- list()
data <- c(data, list(FDTD_SimulateFile(fileList[1], doPlot=1)))

dev.new()

FDTD_PlotTDRData(data, fileList)

if(fileCount > 1)
{
    for(i in 2:fileCount)
    {
        data <- c(data, list(FDTD_SimulateFile(fileList[i], doPlot=0)))
        FDTD_PlotTDRData(data, fileList)
    }
}


options(scipen = -20)   # Force scientific notation
rm(list = ls())         # Remove environemnent variables
graphics.off()          # Close any open graphics

source("fdtd.R")

# Select Files

fileList <- ""
i = 1
repeat
{
    fileName <- file.choose(new = FALSE)
    cat(i, fileList[i], "\n", i, fileName, "\n")
    flush.console()
    if(fileName == fileList[i])
    {
        fileCount <- i - 1
        break
    } else
    {
        i = i + 1
        fileList <- c(fileList, fileName)
    }
}

fileList <- fileList[2:i]

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

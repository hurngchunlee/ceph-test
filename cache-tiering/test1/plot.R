library(ggplot2)
library(gtable)
library(grid)

args = commandArgs(trailingOnly=TRUE)

if (length(args)==0) {
  stop("At least one argument must be supplied (input file).dat", call.=FALSE)
}

data <- read.table(args[1], quote="\"", comment.char="")

xmin <- min(data$V2)
xmax <- max(data$V2)

cache_pool <- subset(data, V1 == "cephfs-data-cache")
cache_pool <- subset(cache_pool, V3 != "rbd_directory")

storage_pool <- subset(data, V1 == "cephfs-data-ec3p2-osd")
storage_pool <- subset(storage_pool, V3 != "rbd_directory")

p0 <- ggplot(cache_pool, aes(x = V2, y = V4, fill=V3)) + 
	coord_cartesian(xlim = c(xmin, xmax)) +
	geom_area(position = 'stack') + 
	xlab("time") + ylab("object count") + 
	theme(legend.title = element_blank())

p1 <- ggplot(cache_pool, aes(x = V2, y = V4)) +
	coord_cartesian(xlim = c(xmin, xmax)) +
	geom_line(aes(color = V3), size = 1)  + 
	xlab("time") + ylab("object count")   +
	theme(legend.title = element_blank())

p2 <- ggplot(storage_pool, aes(x = V2, y = V4)) + 
	coord_cartesian(xlim = c(xmin, xmax))   +
	geom_line(aes(color = V3), size = 1)    + 
	xlab("time") + ylab("object count")     +
	theme(legend.title = element_blank())

g0 <- ggplotGrob(p0)
g1 <- ggplotGrob(p1)
g2 <- ggplotGrob(p2)

g <- rbind(g0, g1, g2, size = "first")
g$widths <- unit.pmax(g0$widths, g1$widths, g2$widths)
setEPS()
postscript("plot.eps")
grid.draw(g)
dev.off()


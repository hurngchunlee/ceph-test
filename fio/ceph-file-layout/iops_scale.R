#!/usr/bin/Rscript

library(ggplot2)
fio_result <- read.csv("fio_result.csv")

"seqw:w" -> iotype
2048 -> fs
512 -> ustripe
4 -> sobject

data <- subset(fio_result, io_type == iotype & fsize == fs & stripe_unit == ustripe & object_size == sobject)
print(data)

max(data$iops) -> max_iops
max(data$lat)  -> max_lat

max_lat / max_iops -> fscale

max_iops / 15 -> txt_offset

# iops vs object_size
mplot <- ggplot(data) +
         geom_line(aes(x=nthreads, y=iops)) +
         geom_line(aes(x=nthreads, y=lat/fscale), color="red") +
         geom_point(aes(x=nthreads, y=lat/fscale), color="red", show.legend=FALSE) +
         geom_text(aes(x=nthreads, y=lat/fscale+txt_offset, label=lat), color="red", show.legend=FALSE) +
         labs(y="IOPS", title=paste0("IOPS scalability")) +
         scale_x_discrete(name="Number of threads", limits=data$nthreads) +
         scale_y_continuous(sec.axis = sec_axis(trans = ~.*fscale, name = "latency (usec)")) +
         coord_cartesian(xlim = c(-10,150)) +
         theme( axis.ticks.y.right = element_line(color = "red"),
                axis.text.y.right  = element_text(color = "red"),
                axis.title.y.right = element_text(color = "red") )

ggsave(plot=mplot,
       width  = 9,
       height = 6,
       dpi    = 600,
       filename=paste0("plot_iops_scale_iotype_",iotype,"_fs_",fs,".pdf"))


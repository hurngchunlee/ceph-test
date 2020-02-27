#!/usr/bin/Rscript

library(ggplot2)
fio_result <- read.csv("fio_result.csv")

1   -> fs
"seqr:r" -> iotype
data <- subset(fio_result, io_type == iotype & fsize == fs)

data$variable <- data$stripe_unit + data$object_size

print(data)

# iops vs object_size
mplot <- ggplot() +
         geom_line(data=subset(data, stripe_unit == 256 & object_size==1), aes(x=nthreads, y=bw/1024)) +
         geom_line(data=subset(data, stripe_unit == 256 & object_size==2), aes(x=nthreads, y=bw/1024)) +
         geom_line(data=subset(data, stripe_unit == 256 & object_size==4), aes(x=nthreads, y=bw/1024)) +
         geom_line(data=subset(data, stripe_unit == 512 & object_size==1), aes(x=nthreads, y=bw/1024)) +
         geom_line(data=subset(data, stripe_unit == 512 & object_size==2), aes(x=nthreads, y=bw/1024)) +
         geom_line(data=subset(data, stripe_unit == 512 & object_size==4), aes(x=nthreads, y=bw/1024)) +
         labs(y="Throughput (MiB)", title=paste0("Throughput vs CephFS object size (", iotype, ")")) +
         #scale_x_discrete(name="object size (MiB)", limits=data$object_size) +
         coord_cartesian(xlim = c(0,130))

ggsave(plot=mplot,
       width  = 9,
       height = 6,
       dpi    = 600,
       filename=paste0(paste("plot_bw_objectsize_scale_", iotype, fs, sep="_"), ".pdf"))


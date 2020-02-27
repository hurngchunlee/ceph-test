#!/usr/bin/Rscript

library(ggplot2)
fio_result <- read.csv("fio_result.csv")

128  -> nt

for ( su in c("512","256","128","64") ) {
    for ( iotype in c("seqr:r","seqw:w","randr:r") ) {
        for ( s in c("1", "2048") ) {
            
            data <- subset(fio_result, io_type == iotype & fsize == s & nthreads == nt & stripe_unit == su)
 
            print(paste(nt, su, iotype, s, sep=": "))
            print(data)
 
            max(data$iops) -> max_iops
            max(data$lat)  -> max_lat
 
            max_lat / max_iops -> fscale

            max_iops / 15 -> txt_offset
 
            if ( nrow(data) > 0 ) {
                # iops vs object_size 
                mplot <- ggplot(data=data) +
                         geom_col(aes(x=object_size, y=iops), width=0.4) +
                         geom_line(aes(x=object_size, y=lat/fscale), color="red") +
                         geom_point(aes(x=object_size, y=lat/fscale), color="red", show.legend=FALSE) +
                         geom_text(aes(x=object_size, y=lat/fscale+txt_offset, label=lat), color="red", show.legend=FALSE) +
                         labs(y="IOPS", title=paste0("IOPS vs CephFS object size (", iotype, ", fsize:", s, "MiB)")) +
                         scale_x_discrete(name="object size (MiB)", limits=data$object_size) +
                         scale_y_continuous(sec.axis = sec_axis(trans = ~.*fscale, name = "latency (usec)")) +
                         coord_cartesian(xlim = c(0,6)) +
                         theme( axis.ticks.y.right = element_line(color = "red"),
                                axis.text.y.right  = element_text(color = "red"),
                                axis.title.y.right = element_text(color = "red") )
             
                ggsave(plot=mplot,
                       width  = 9,
                       height = 6,
                       dpi    = 600,
                       filename=paste0(paste("plot_iops_objectsize_nt", nt, "su", su, iotype, s, sep="_"), ".pdf"))
            }
        }
    }
}


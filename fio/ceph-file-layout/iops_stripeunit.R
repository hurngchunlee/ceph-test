#!/usr/bin/Rscript

library(ggplot2)
fio_result <- read.csv("fio_result.csv")

128 -> nt

for ( os in c("1", "2", "4") ) {
    for ( iotype in c("seqr:r","seqw:w","randr:r") ) {
        for ( s in c("1", "2048") ) {
            
            data <- subset(fio_result, io_type == iotype & fsize == s & nthreads == nt & object_size == os)
 
            print(paste(nt, os, iotype, s, sep=": "))
            print(data)
 
            max(data$iops) -> max_iops
            max(data$lat)  -> max_lat
 
            max_lat / max_iops -> fscale

            max_iops / 15 -> txt_offset
 
            if ( nrow(data) > 0 ) {
                # iops vs stripe_unit
                mplot <- ggplot(data=data) +
                         geom_col(aes(x=stripe_unit, y=iops), width=32) +
                         geom_line(aes(x=stripe_unit, y=lat/fscale), color="red") +
                         geom_point(aes(x=stripe_unit, y=lat/fscale), color="red", show.legend=FALSE) +
                         geom_text(aes(x=stripe_unit, y=lat/fscale+txt_offset, label=lat), color="red", show.legend=FALSE) +
                         labs(y="IOPS", title=paste0("IOPS vs CephFS stripe unit (", iotype, ", fsize:", s, "MiB)")) +
                         scale_x_discrete(name="stripe unit (KiB)", limits=data$stripe_unit) +
                         scale_y_continuous(sec.axis = sec_axis(trans = ~.*fscale, name = "latency (usec)")) +
                         coord_cartesian(xlim = c(0,600)) +
                         theme( axis.ticks.y.right = element_line(color = "red"),
                                axis.text.y.right  = element_text(color = "red"),
                                axis.title.y.right = element_text(color = "red") )
             
                ggsave(plot=mplot,
                       width  = 9,
                       height = 6,
                       dpi    = 600,
                       filename=paste0(paste("plot_iops_stripeunit_nt", nt, "os", os, iotype, s, sep="_"), ".pdf"))
            }
        }
    }
}

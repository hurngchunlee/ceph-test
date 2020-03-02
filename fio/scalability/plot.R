#!/usr/bin/Rscript

library(ggplot2)

# dataset for CephFS 
data_cephfs <- read.csv("cephfs.csv.default.2")

d_cephfs_randr_2g <- subset(data_cephfs, iotype == "randr" & fsize == "2g")
d_cephfs_seqr_2g  <- subset(data_cephfs, iotype == "seqr"  & fsize == "2g")

d_cephfs_randr_1m <- subset(data_cephfs, iotype == "randr" & fsize == "1m")
d_cephfs_seqr_1m  <- subset(data_cephfs, iotype == "seqr"  & fsize == "1m")

# dataset for NetApp
data_netapp <- read.csv("netapp_qos.csv")

d_netapp_randr_2g <- subset(data_netapp, iotype == "randr" & fsize == "2g")
d_netapp_seqr_2g  <- subset(data_netapp, iotype == "seqr"  & fsize == "2g")

d_netapp_randr_1m <- subset(data_netapp, iotype == "randr" & fsize == "1m")
d_netapp_seqr_1m  <- subset(data_netapp, iotype == "seqr"  & fsize == "1m")

#########################################################################################################
# plot for randr on 2g file
#########################################################################################################
p_data <- rbind(d_cephfs_randr_2g,d_netapp_randr_2g) 
p_data$lat_mean_ms <- p_data$lat_mean_ns / 1000000
p_data$lat_stdv_ms <- p_data$lat_stdv_ns / 1000000

p_title <- "Random read on 2GiB file with 8KiB block size"
p_ofile_prefix <- "p_randr_2g_"

p_randr_iops <- ggplot(data=p_data, mapping=aes(x=n_jobs_total, y=iops, group=sys, colour=sys)) +
                   geom_line() + geom_point(aes(shape=sys)) +
                   scale_x_discrete(name="Number of jobs", limits=p_data$n_jobs_total) +
                   coord_cartesian(xlim = c(0,150)) +
                   ylab("IOPS") +
                   ggtitle(p_title)

ggsave(plot=p_randr_iops, width=9, height=6, dpi=600, filename=paste0(p_ofile_prefix,"iops.pdf"))

p_randr_lat <- ggplot(data=p_data, mapping=aes(x=n_jobs_total, y=lat_mean_ms, group=sys, colour=sys)) +
                  geom_line() + geom_point(aes(shape=sys)) +
                  geom_errorbar(aes(ymin=lat_mean_ms-lat_stdv_ms, ymax=lat_mean_ms+lat_stdv_ms)) +
                  scale_x_discrete(name="Number of jobs", limits=p_data$n_jobs_total) +
                  coord_cartesian(xlim = c(0,150)) +
                  ylab("Latency (msec)") +
                  ggtitle(p_title)

ggsave(plot=p_randr_lat, width=9, height=6, dpi=600, filename=paste0(p_ofile_prefix,"lat.pdf"))

#########################################################################################################
# plot for seqr on 2g file
#########################################################################################################
p_data <- rbind(d_cephfs_seqr_2g,d_netapp_seqr_2g) 
p_data$lat_mean_ms <- p_data$lat_mean_ns / 1000000
p_data$lat_stdv_ms <- p_data$lat_stdv_ns / 1000000
p_data$bwidth_mb   <- p_data$bwidth / 1024

p_title <- "Sequencial read on 2GiB file with 64KiB block size"

p_ofile_prefix <- "p_seqr_2g_"

p_seqr_bw <- ggplot(data=p_data, mapping=aes(x=n_jobs_total, y=bwidth_mb, group=sys, colour=sys)) +
             geom_line() + geom_point(aes(shape=sys)) +
             scale_x_discrete(name="Number of jobs", limits=p_data$n_jobs_total) +
             coord_cartesian(xlim = c(0,150)) +
             ylab("Throughput (MiB)") +
             ggtitle(p_title)

ggsave(plot=p_seqr_bw, width=9, height=6, dpi=600, filename=paste0(p_ofile_prefix,"bw.pdf"))

p_seqr_iops <- ggplot(data=p_data, mapping=aes(x=n_jobs_total, y=iops, group=sys, colour=sys)) +
               geom_line() + geom_point(aes(shape=sys)) +
               scale_x_discrete(name="Number of jobs", limits=p_data$n_jobs_total) +
               coord_cartesian(xlim = c(0,150)) +
               ylab("IOPS") +
               ggtitle(p_title)

ggsave(plot=p_seqr_iops, width=9, height=6, dpi=600, filename=paste0(p_ofile_prefix,"iops.pdf"))

p_seqr_lat <- ggplot(data=p_data, mapping=aes(x=n_jobs_total, y=lat_mean_ms, group=sys, colour=sys)) +
              geom_line() + geom_point(aes(shape=sys)) +
              geom_errorbar(aes(ymin=lat_mean_ms-lat_stdv_ms, ymax=lat_mean_ms+lat_stdv_ms)) +
              scale_x_discrete(name="Number of jobs", limits=p_data$n_jobs_total) +
              coord_cartesian(xlim = c(0,150)) +
              ylab("Latency (msec)") +
              ggtitle(p_title)

ggsave(plot=p_seqr_lat, width=9, height=6, dpi=600, filename=paste0(p_ofile_prefix,"lat.pdf"))

#########################################################################################################
# plot for randr on 1m file
#########################################################################################################
p_data <- rbind(d_cephfs_randr_1m,d_netapp_randr_1m)
p_data$lat_mean_ms <- p_data$lat_mean_ns / 1000000
p_data$lat_stdv_ms <- p_data$lat_stdv_ns / 1000000
p_data$bwidth_mb   <- p_data$bwidth / 1024

p_title <- "Random read on 1MiB file with 8KiB block size"

p_ofile_prefix <- "p_randr_1m_"

p_randr_iops <- ggplot(data=p_data, mapping=aes(x=n_jobs_total, y=iops, group=sys, colour=sys)) +
                   geom_line() + geom_point(aes(shape=sys)) +
                   scale_x_discrete(name="Number of jobs", limits=p_data$n_jobs_total) +
                   coord_cartesian(xlim = c(0,150)) +
                   ylab("IOPS") +
                   ggtitle(p_title)

ggsave(plot=p_randr_iops, width=9, height=6, dpi=600, filename=paste0(p_ofile_prefix,"iops.pdf"))

p_randr_lat <- ggplot(data=p_data, mapping=aes(x=n_jobs_total, y=lat_mean_ms, group=sys, colour=sys)) +
                  geom_line() + geom_point(aes(shape=sys)) +
                  geom_errorbar(aes(ymin=lat_mean_ms-lat_stdv_ms, ymax=lat_mean_ms+lat_stdv_ms)) +
                  scale_x_discrete(name="Number of jobs", limits=p_data$n_jobs_total) +
                  coord_cartesian(xlim = c(0,150)) +
                  ylab("Latency (msec)") +
                  ggtitle(p_title)

ggsave(plot=p_randr_lat, width=9, height=6, dpi=600, filename=paste0(p_ofile_prefix,"lat.pdf"))

#########################################################################################################
# plot for seqr on 1m file
#########################################################################################################
p_data <- rbind(d_cephfs_seqr_1m,d_netapp_seqr_1m) 
p_data$lat_mean_ms <- p_data$lat_mean_ns / 1000000
p_data$lat_stdv_ms <- p_data$lat_stdv_ns / 1000000
p_data$bwidth_mb   <- p_data$bwidth / 1024

p_title <- "Sequencial read on 1MiB file with 64KiB block size"

p_ofile_prefix <- "p_seqr_1m_"

p_seqr_bw <- ggplot(data=p_data, mapping=aes(x=n_jobs_total, y=bwidth_mb, group=sys, colour=sys)) +
             geom_line() + geom_point(aes(shape=sys)) +
             scale_x_discrete(name="Number of jobs", limits=p_data$n_jobs_total) +
             coord_cartesian(xlim = c(0,150)) +
             ylab("Throughput (MiB)") +
             ggtitle(p_title)

ggsave(plot=p_seqr_bw, width=9, height=6, dpi=600, filename=paste0(p_ofile_prefix,"bw.pdf"))

p_seqr_iops <- ggplot(data=p_data, mapping=aes(x=n_jobs_total, y=iops, group=sys, colour=sys)) +
               geom_line() + geom_point(aes(shape=sys)) +
               scale_x_discrete(name="Number of jobs", limits=p_data$n_jobs_total) +
               coord_cartesian(xlim = c(0,150)) +
               ylab("IOPS") +
               ggtitle(p_title)

ggsave(plot=p_seqr_iops, width=9, height=6, dpi=600, filename=paste0(p_ofile_prefix,"iops.pdf"))

p_seqr_lat <- ggplot(data=p_data, mapping=aes(x=n_jobs_total, y=lat_mean_ms, group=sys, colour=sys)) +
              geom_line() + geom_point(aes(shape=sys)) +
              geom_errorbar(aes(ymin=lat_mean_ms-lat_stdv_ms, ymax=lat_mean_ms+lat_stdv_ms)) +
              scale_x_discrete(name="Number of jobs", limits=p_data$n_jobs_total) +
              coord_cartesian(xlim = c(0,150)) +
              ylab("Latency (msec)") +
              ggtitle(p_title)

ggsave(plot=p_seqr_lat, width=9, height=6, dpi=600, filename=paste0(p_ofile_prefix,"lat.pdf"))

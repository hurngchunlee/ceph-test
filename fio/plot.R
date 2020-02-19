
library(ggplot2)
fio_result <- read.csv("fio_result.csv")


# data for use case 1: 1M file, sequencial read/write
data_case1 <- subset(fio_result, (io_type == "seqrw:r" | io_type == "seqrw:w" ) & fsize == "1")
data_case1$case <- rep(1, nrow(data_case1))
data_case1 <- transform(data_case1, case_iotype=paste(case, io_type, sep=":"))

# data for use case 2: 2G file, sequencial write
data_case2 <- subset(fio_result, (io_type == "seqw:w" ) & fsize == "2048")
data_case2$case <- rep(2, nrow(data_case2))
data_case2 <- transform(data_case2, case_iotype=paste(case, io_type, sep=":"))

# data for use case 3: 2G file, random read
data_case3 <- subset(fio_result, (io_type == "randr:r" ) & fsize == "2048")
data_case3$case <- rep(3, nrow(data_case3))
data_case3 <- transform(data_case3, case_iotype=paste(case, io_type, sep=":"))

# plots for evaluating impact of stripe unit, with object size fixed to 4m
data_comp_su_t32 <- rbind( subset(data_case1, nthreads == "32" & object_size == "4"), 
                           subset(data_case2, nthreads == "32" & object_size == "4"),
                           subset(data_case3, nthreads == "32" & object_size == "4") )

plot_comp_su_tpt <- ggplot(data=data_comp_su_t32) + 
                       geom_bar(aes(factor(stripe_unit), y=bw/1024, fill=case_iotype), position="dodge", stat="identity") + 
                       labs(x="stripe unit (KiB)", y="throughput (MiB)", title="Thoughput vs stripe unit (threads:32, object_size:4m)")

plot_comp_su_iops <- ggplot(data=data_comp_su_t32) + 
  geom_bar(aes(factor(stripe_unit), y=iops, fill=case_iotype), position="dodge", stat="identity") + 
  labs(x="stripe unit (KiB)", y="# IOPS", title="IOPS vs stripe unit (threads:32, object_size:4m)")

plot_comp_su_lat <- ggplot(data=data_comp_su_t32) + 
  geom_bar(aes(factor(stripe_unit), y=lat, fill=case_iotype), position="dodge", stat="identity") + 
  labs(x="stripe unit (KiB)", y="latency (usec)", title="latency vs stripe unit (threads:32, object_size:4m)")

# plots for evaluating impact of object size, with stripe_unit fixed to 64k
data_comp_so_t32 <- rbind( subset(data_case1, nthreads == "32" & stripe_unit == "64"), 
                           subset(data_case2, nthreads == "32" & stripe_unit == "64"),
                           subset(data_case3, nthreads == "32" & stripe_unit == "64") )

plot_comp_so_tpt <- ggplot(data=data_comp_so_t32) + 
  geom_bar(aes(factor(object_size), y=bw/1024, fill=case_iotype), position="dodge", stat="identity") + 
  labs(x="object size (MiB)", y="throughput (MiB)", title="Thoughput vs object size (threads:32, stripe_unit:64k)")

plot_comp_so_iops <- ggplot(data=data_comp_so_t32) + 
  geom_bar(aes(factor(object_size), y=iops, fill=case_iotype), position="dodge", stat="identity") + 
  labs(x="object size (MiB)", y="# IOPS", title="IOPS vs object size (threads:32, stripe_unit:64k)")

plot_comp_so_lat <- ggplot(data=data_comp_so_t32) + 
  geom_bar(aes(factor(object_size), y=lat, fill=case_iotype), position="dodge", stat="identity") + 
  labs(x="object size (MiB)", y="latency (usec)", title="latency vs object size (threads:32, stripe_unit:64k)")

# plots for scalability evaluation (random read)
data_scale_su512k_os4m <- subset(fio_result, (io_type == "randr:r" ) & fsize == "2048" & stripe_unit == "512" & object_size == "4")

plot_scale_su512k_os4m_iops <- ggplot(data=data_scale_su512k_os4m) +
  geom_line(aes(x=nthreads, y=iops)) + labs(y="IOPS", title="IOPS (stripe_unit:512k, object_size:4m)") +
  scale_x_discrete(name="# threads", limits=data_scale_su512k_os4m$nthreads)

plot_scale_su512k_os4m_lat <- ggplot(data=data_scale_su512k_os4m) +
  geom_line(aes(x=nthreads, y=lat)) + labs(y="latency (usec)", title="latency (stripe_unit:512k, object_size:4m)") +
  scale_x_discrete(name="# threads", limits=data_scale_su512k_os4m$nthreads)

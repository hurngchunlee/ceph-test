library(ggplot2)

load(file='speed.Rdata')

p_speed <- ggplot(data=data, mapping=aes(x=nj, y=avg, group=sys, colour=sys)) +
                  geom_line() + geom_point(aes(shape=sys)) +
                  geom_errorbar(aes(ymin=avg-std, ymax=avg+std)) +
                  scale_x_discrete(name="#number of jobs", limits=data$nj) +
                  coord_cartesian(xlim = c(0,210)) +
                  ylab("speed (MiB/s)") +
                  ggtitle("ft-preprocessing speed")

ggsave(plot=p_speed, width=9, height=6, dpi=600, filename=paste0("ft-preprocessing-speed.pdf"))

p_throughput <- ggplot(data=data, mapping=aes(x=nj, y=nj*avg, group=sys, colour=sys)) +
                  geom_line() + geom_point(aes(shape=sys)) +
                  scale_x_discrete(name="#number of jobs", limits=data$nj) +
                  coord_cartesian(xlim = c(0,210)) +
                  ylab("throughput (MiB/s)") +
                  ggtitle("ft-preprocessing throughput")

ggsave(plot=p_throughput, width=9, height=6, dpi=600, filename=paste0("ft-preprocessing-throughput.pdf"))

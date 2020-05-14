dm_home <- Sys.getenv('DM_HOME')
if (dm_home == '') {
	stop('DM_HOME is not defined.', call.=F)
}

args <- commandArgs(trailingOnly=T)

if (length(args) == 0) {
	stop('Missing data file.', call.=F)
} else if(length(args) > 1) {
	stop('Only one data file allowed.', call.=F)
}

df <- read.csv(args[1], sep='\t')
summary(df)
ofn <- sprintf('cv.%s.pdf', format(Sys.time(), '%Y-%m-%d'))
pdf(file=ofn)
# plotSrcInfo(df, F)

sfn <- paste(dm_home, 'lib', 'makeDateLabels.R', sep='/')
source(sfn, chdir=T)
sfn <- paste(dm_home, 'lib', 'getYaxisInfo.R', sep='/')
source(sfn, chdir=T)

dl <- makeDateLabels(df$date)
print(dl)

ya_info <- getYaxisInfo(max(df[, 2:ncol(df)]))
y_max <- max(ya_info)
print(y_max)

colors <- c('red', 'orange', 'green', 'blue', 'black')

plot(
	c(as.Date(dl$tk[1], '%Y-%m-%d'), as.Date(dl$tk[length(dl$tk)], '%Y-%m-%d')),
	c(0, y_max),
	type='n',
	xlab='Month',
	xaxt='n',
	yaxt='n',
	ylab='Number of cases')

l_date <- df[length(df$date), 1]
axis(1, at=dl$tk, labels=F)
text(dl$tk, par('usr')[3], labels=dl$lb, srt=45, adj=c(1.2, 1), xpd=T)
axis(2, at=ya_info, labels=ya_info, las=1)
title(paste('New cases through', l_date, sep=' through '))

for(i in c(2:ncol(df))) {
	lines(as.Date(df$date, '%Y-%m-%d'), df[, i], col=colors[i-1])
}

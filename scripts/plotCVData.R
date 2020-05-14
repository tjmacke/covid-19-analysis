# ds, fname must be set before calling
#
cv <- read.csv(fname, sep='\t')
colnames(cv) <- c('date', 'region', 'country', 'lat', 'long', 'confirmed', 'deaths', 'recovered')
cv$conf_diff <- c(NA, diff(cv$confirmed))
cv$d2c <- cv$deaths/cv$confirmed
cv$r2c <- cv$recovered/cv$confirmed

# put some space on the right side for 2nd axis
par(mar=c(5, 5, 5, 5))

# plot the various counts
plot(as.Date(cv$date, '%Y-%m-%d'), cv$confirmed, type='l', xlab='Date', ylab='Count')
lines(as.Date(cv$date, '%Y-%m-%d'), cv$deaths, col='red')
lines(as.Date(cv$date, '%Y-%m-%d'), cv$recovered, col='green')
lines(as.Date(cv$date, '%Y-%m-%d'), cv$conf_diff, lty=1, col='orange')
title(main=paste(dataset, ' Covid-19 Counts Through ', cv$date[nrow(cv)], 'T23:59:59Z', sep=''))
title(sub='Source: https://github.com/CSSEGISandData/COVID-19', cex=0.4)
legend('topleft', inset=c(0.02, 0.02), bg='white',
	legend=c('confirmed', 'deaths', 'recovered', 'conf_diff', 'deaths/confirmed'),
		col=c('black', 'red', 'green', 'orange', 'blue'), lty=c(1,1,1,1,1), cex=0.7)

# plot the deaths/confirmed
par(new=T)
plot(as.Date(cv$date, '%Y-%m-%d'), cv$d2c, type='l', lty=1, col='blue', axes=F, xlab=NA, ylab=NA)
#lines(as.Date(cv$date, '%Y-%m-%d'), cv$r2c, lty=2, col='green')
axis(side=4)
mtext(side=4, line=2.5, 'Deaths/Confirmed')

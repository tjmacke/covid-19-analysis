# expexts ds, fname to be set before calling
#
cv <- read.csv(fname, sep='\t')
colnames(cv) <- c('date', 'region', 'country', 'lat', 'long', 'confirmed', 'deaths', 'recovered')
cv$conf_diff <- c(NA, diff(cv$confirmed))
cv$death_diff <- c(NA, diff(cv$deaths))
cv$d2c <- cv$deaths/cv$confirmed
cv$r2c <- cv$recovered/cv$confirmed

# put some space on the right side for 2nd axis
par(mar=c(5, 5, 5, 5))

# plot the various counts
plot(as.Date(cv$date, '%Y-%m-%d'), cv$deaths, type='l', col='red', xlab='Date', ylab='Deaths')
lines(as.Date(cv$date, '%Y-%m-%d'), cv$death_diff, lty=1, col='orange')
# linear model of the death_diff since 2020-03-20
# rd <- cv[as.Date(cv$date, '%Y-%m-%d') >= as.Date('2020-03-20', '%Y-%m-%d'),]
# linear model of the death_diff for last 15 days
rd <- cv[as.Date(cv$date, '%Y-%m-%d') >= as.Date(cv[nrow(cv)-14,'date'], '%Y-%m-%d'),]
rd_lm <- lm(rd$death_diff ~ as.Date(rd$date, '%Y-%m-%d'))
abline(rd_lm, col='orange', lty=2)
# graph annotations
title(main=paste(dataset, ' Covid-19 Deaths Through ', cv$date[nrow(cv)], 'T23:59:59Z', sep=''))
title(sub='Source: https://github.com/CSSEGISandData/COVID-19', cex=0.4)
legend('topleft', inset=c(0.02, 0.02), bg='white',
	legend=c('deaths', 'death_diff', 'lm(dd ~ date, last 15 days)', 'deaths/confirmed'),
		col=c('red', 'orange', 'orange', 'blue'), lty=c(1,1,2,1), cex=0.7)

# plot the deaths/confirmed
par(new=T)
plot(as.Date(cv$date, '%Y-%m-%d'), cv$d2c, type='l', lty=1, col='blue', axes=F, xlab=NA, ylab=NA)
axis(side=4)
mtext(side=4, line=2.5, 'Deaths/Confirmed')

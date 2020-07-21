# ds, fname must be set before calling
#

# sources:
src_world <- 'https://github.com/CSSEGISandData/COVID-19'
src_states <- 'https://covidtracking.com/api/v1/states/daily.csv'

cv <- read.csv(fname, sep='\t')
colnames(cv) <- c('date', 'region', 'country', 'lat', 'long', 'confirmed', 'deaths', 'recovered', 'source')
cv$d2c <- cv$deaths/cv$confirmed

# put some space on the right side for 2nd axis
par(mar=c(5, 5, 5, 5))

# plot the various counts
plot(as.Date(cv$date, '%Y-%m-%d'), cv$confirmed, type='l', xlab='Date', ylab='Count')
lines(as.Date(cv$date, '%Y-%m-%d'), cv$deaths, col='red')
lines(as.Date(cv$date, '%Y-%m-%d'), cv$recovered, col='green')

# titles & legends
title(main=paste(dataset, ' Covid-19 Counts Through ', cv$date[nrow(cv)], 'T23:59:59Z', sep=''))
title(sub=paste('Source:', ifelse(cv$source[1] == 'world', src_world, src_states), sep=' '), cex=0.4)
legend('topleft', inset=c(0.02, 0.02), bg='white',
	legend=c('confirmed', 'deaths', 'recovered', 'deaths/confirmed'),
		col=c('black', 'red', 'green', 'blue'), lwd=c(1, 1, 1, 1), cex=0.7)

# plot the deaths/confirmed using scale on right side
par(new=T)
plot(as.Date(cv$date, '%Y-%m-%d'), cv$d2c, type='l', lty=1, col='blue', axes=F, xlab=NA, ylab=NA)
axis(side=4)
mtext(side=4, line=2.5, 'Deaths/Confirmed')

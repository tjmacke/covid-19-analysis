# ds, fname must be set before calling
#

# sources:
src_world <- 'https://github.com/CSSEGISandData/COVID-19'
src_states <- 'https://covidtracking.com/api/v1/states/daily.csv'

cv <- read.csv(fname, sep='\t')
colnames(cv) <- c('date', 'region', 'country', 'lat', 'long', 'confirmed', 'deaths', 'recovered', 'source')
cv$daily_confirmed <- c(cv$confirmed[1], diff(cv$confirmed))
cv$d2c <- cv$deaths/cv$confirmed

# put some space on the right side for 2nd axis
par(mar=c(5, 5, 5, 5))

# plot the various counts
plot(as.Date(cv$date, '%Y-%m-%d'), cv$confirmed, type='l', xlab='Date', ylab='Count')
lines(as.Date(cv$date, '%Y-%m-%d'), cv$daily_confirmed, lty=1, col='grey67')
lines(as.Date(cv$date, '%Y-%m-%d'), cv$deaths, col='red')

# daily confirmed (dc) and linear model of last 15 days fo ds vs date
dc_pre <- cv[as.Date(cv$date, '%Y-%m-%d') <= as.Date(cv[nrow(cv)-14, 'date'], '%Y-%m-%d'),]
dc <- cv[as.Date(cv$date, '%Y-%m-%d') >= as.Date(cv[nrow(cv)-14, 'date'], '%Y-%m-%d'),]
dc_lm <- lm(dc$daily_confirmed ~ as.Date(dc$date, '%Y-%m-%d'))
# Use 2 lines: first is dc not used in model, second is dc used in model
lines(as.Date(dc_pre$date, '%Y-%m-%d'), dc_pre$daily_confirmed, lty=1, col='grey67')
lines(as.Date(dc$date, '%Y-%m-%d'), dc$daily_confirmed, lty=1, lwd=3, col='grey67')
abline(dc_lm, lty=2)

# titles & legends
title(main=paste(dataset, ' Covid-19 Counts Through ', cv$date[nrow(cv)], 'T23:59:59Z', sep=''))
title(sub=paste('Source:', ifelse(cv$source[1] == 'world', src_world, src_states), sep=' '), cex=0.4)
legend('topleft', inset=c(0.02, 0.02), bg='white',
	legend=c('confirmed','daily confirmed used in model','daily confirmed not used int model','lm(dc ~ date, last 15 days)','deaths/confirmed','deaths'),
		col=c('black','grey67','grey67','black','blue','red'), lwd=c(1,3,1,1,1,1), lty=c(1,1,1,3,1,1), cex=0.7)

# plot the deaths/confirmed using scale on right side
par(new=T)
plot(as.Date(cv$date, '%Y-%m-%d'), cv$d2c, type='l', lty=1, col='blue', axes=F, xlab=NA, ylab=NA)
axis(side=4)
mtext(side=4, line=2.5, 'Deaths/Confirmed')

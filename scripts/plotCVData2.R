# expexts ds, fname must be set before calling
#

# sources:
src_world <- 'https://github.com/CSSEGISandData/COVID-19'
src_states <- 'https://covidtracking.com/api/v1/states/daily.csv'

cv <- read.csv(fname, sep='\t')
colnames(cv) <- c('date', 'region', 'country', 'lat', 'long', 'confirmed', 'deaths', 'recovered', 'source')
cv$daily_confirmed <- c(cv$confirmed[1], diff(cv$confirmed))
cv$daily_deaths <- c(cv$deaths[1], diff(cv$deaths))
cv$d2c <- cv$deaths/cv$confirmed

# put some space on the right side for 2nd axis
par(mar=c(5, 5, 5, 5))

# plot the deaths
plot(as.Date(cv$date, '%Y-%m-%d'), cv$deaths, type='l', col='red', xlab='Date', ylab='Deaths')

# daily deaths (dd) and linear model of last 15 days of dd vs date.
dd_pre <- cv[as.Date(cv$date, '%Y-%m-%d') <= as.Date(cv[nrow(cv)-14, 'date'], '%Y-%m-%d'),]
dd <- cv[as.Date(cv$date, '%Y-%m-%d') >= as.Date(cv[nrow(cv)-14, 'date'], '%Y-%m-%d'),]
dd_lm <- lm(dd$daily_deaths ~ as.Date(dd$date, '%Y-%m-%d'))
# Use 2 lines: first is dd not used in model (thin), second is  dd used in model (thick)
lines(as.Date(dd_pre$date, '%Y-%m-%d'), dd_pre$daily_deaths, lty=1, col='orange')
lines(as.Date(dd$date, '%Y-%m-%d'), dd$daily_deaths, lty=1, lwd=3, col='orange')
# Now this works well, as the extended line makes the slope easier to see
abline(dd_lm, lty=2)

# titles & legends
title(main=paste(dataset, ' Covid-19 Deaths Through ', cv$date[nrow(cv)], 'T23:59:59Z', sep=''))
title(sub=paste('Source:', ifelse(cv$source[1] == 'world', src_world, src_states), sep=' '), cex=0.4)
legend('topleft', inset=c(0.02, 0.02), bg='white',
	legend=c('deaths', 'daily deaths used in model', 'daily deaths not used in model', 'lm(dd ~ date, last 15 days)', 'deaths/confirmed'),
		col=c('red', 'orange', 'orange', 'black', 'blue'), lwd=c(1,3,1,1,1), lty=c(1,1,1,2,1), cex=0.7)

# plot the deaths/confirmed using scale on right side
par(new=T)
plot(as.Date(cv$date, '%Y-%m-%d'), cv$d2c, type='l', lty=1, col='blue', axes=F, xlab=NA, ylab=NA)
axis(side=4)
mtext(side=4, line=2.5, 'Deaths/Confirmed')

# expexts ds, fname must be set before calling
#

# sources:
src_world <- 'https://github.com/CSSEGISandData/COVID-19'
src_states <- 'https://covidtracking.com/api/v1/states/daily.csv'

cv <- read.csv(fname, sep='\t', header=F)
colnames(cv) <- c('date', 'region', 'country', 'lat', 'long', 'confirmed', 'deaths', 'recovered', 'source', 'cc2')
cv$daily_confirmed <- c(cv$confirmed[1], diff(cv$confirmed))
cv$daily_deaths <- c(cv$deaths[1], diff(cv$deaths))
cv$d2c <- cv$deaths/cv$confirmed

# put some space on the right side for 2nd axis
par(mar=c(5, 5, 5, 5))

# plot the deaths
plot(as.Date(cv$date, '%Y-%m-%d'), cv$confirmed, type='l', col='black', xlab='Date', ylab='Count')

# daily deaths (dd) and linear model of last 15 days of dd vs date.
# dd_pre <- cv[as.Date(cv$date, '%Y-%m-%d') <= as.Date(cv[nrow(cv)-14, 'date'], '%Y-%m-%d'),]
# dd <- cv[as.Date(cv$date, '%Y-%m-%d') >= as.Date(cv[nrow(cv)-14, 'date'], '%Y-%m-%d'),]
# dd_lm <- lm(dd$daily_deaths ~ as.Date(dd$date, '%Y-%m-%d'))
# Use 2 lines: first is dd not used in model (thin), second is  dd used in model (thick)
# lines(as.Date(dd_pre$date, '%Y-%m-%d'), dd_pre$daily_deaths, lty=1, col='orange')
# lines(as.Date(dd$date, '%Y-%m-%d'), dd$daily_deaths, lty=1, lwd=3, col='orange')
# Now this works well, as the extended line makes the slope easier to see
# abline(dd_lm, lty=2)

cv$ifr_14 <- NA
# # look at 1fr_14 for from 2020-06-01
fr <- as.integer(rownames(cv[as.Date(cv$date, '%Y-%m-%d') == as.Date('2020-06-01', '%Y-%m-%d'),]))
lr <- nrow(cv)
for(i in fr:lr) {
	cv[i, 'ifr_14'] <- cv[i, 'daily_deaths']/cv[i-14, 'daily_confirmed']
}
ifr_14_lm <- lm(cv$ifr_14 ~ as.Date(cv$date, '%Y-%m-%d'))

# titles & legends
title(main=paste(dataset, ' Covid-19 IFR-14 Through ', cv$date[nrow(cv)], 'T23:59:59Z', sep=''))
title(sub=paste('Source:', ifelse(cv$source[1] == 'world', src_world, src_states), sep=' '), cex=0.4)
legend('topleft', inset=c(0.02, 0.02), bg='white',
	legend=c('confirmed', 'deaths/confirmed (ifr 0)', 'ifr 14', 'lm(ifr 14 ~ date, from 2020-06-01)'),
		col=c('black', 'blue', 'pink','black'), lwd=c(1,1,1,1), lty=c(1,1,1,2), cex=0.7)

# plot the deaths/confirmed using scale on right side
par(new=T)
plot(as.Date(cv$date, '%Y-%m-%d'), cv$d2c, type='l', lty=1, col='blue', axes=F, xlab=NA, ylab=NA)
lines(as.Date(cv$date, '%Y-%m-%d'), cv$ifr_14, col='pink')
abline(ifr_14_lm, lty=2)

axis(side=4)
mtext(side=4, line=2.5, 'IFR-14')

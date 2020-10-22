plotCVData <- function(ds, df) {

	# sources
	src_world <- 'https://github.com/CSSEGISandData/COVID-19'
	src_states <- 'https://covidtracking.com/api/v1/states/daily.csv'

	# put some space on the right side for 2nd axis
	par(mar=c(5, 5, 5, 5))

	# plot the various counts
	plot(as.Date(df$date, '%Y-%m-%d'), df$confirmed, type='l', xlab='Date', ylab='Count')
	lines(as.Date(df$date, '%Y-%m-%d'), df$deaths, col='red')
	lines(as.Date(df$date, '%Y-%m-%d'), df$recovered, col='green')

	# titles & legends
	title(main=paste(dataset, ' Covid-19 Counts Through ', df$date[nrow(df)], 'T23:59:59Z', sep=''))
	title(sub=paste('Source:', ifelse(df$source[1] == 'world', src_world, src_states), sep=' '), cex=0.4)
	legend('topleft', inset=c(0.02, 0.02), bg='white',
		legend=c('confirmed', 'deaths', 'recovered', 'deaths/confirmed'),
			col=c('black', 'red', 'green', 'blue'), lwd=c(1, 1, 1, 1), cex=0.7)

	# plot the deaths/confirmed using scale on right side
	par(new=T)
	plot(as.Date(df$date, '%Y-%m-%d'), df$d2c, type='l', lty=1, col='blue', axes=F, xlab=NA, ylab=NA)
	axis(side=4)
	mtext(side=4, line=2.5, 'Deaths/Confirmed')
}

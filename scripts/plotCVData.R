plotCVData <- function(ds, df) {

	# sources
	src_world <- 'https://github.com/CSSEGISandData/COVID-19'
	src_states <- 'https://covidtracking.com/api/v1/states/daily.csv'

        # vaccinations begin:
	v_start <- '2020-12-14'
	v_start_2d <- '2021-01-11'

	dm_home <- Sys.getenv('DM_HOME')
	if (dm_home == '') {
		stop('DM_HOME is not defined.', call=.F)
	}
	sfn <- paste(dm_home, 'lib', 'getYaxisInfo.R', sep='/')
	source(sfn, chdir=T)

	ya_info <- getYaxisInfo(max(df$confirmed))
	y_max <- max(ya_info)

	# put some space on the right side for 2nd axis, so set RM to LM
	mvals <- par('mar')
	mvals[4] <- mvals[2]
	par(mar = mvals)

	# plot the various counts
	plot(
		c(as.Date(df$date[1], '%Y-%m-%d'), as.Date(df$date[nrow(df)], '%Y-%m-%d')),
		c(0, y_max),
		type='n',
		xlab='Date',
		ylab='Counts',
		yaxt='n'
	)
	lines(as.Date(df$date, '%Y-%m-%d'), df$confirmed, col='black')
	lines(as.Date(df$date, '%Y-%m-%d'), df$deaths, col='red')
	lines(as.Date(df$date, '%Y-%m-%d'), df$recovered, col='green')

	# add a line that shows when vaccinations started
	abline(v=as.Date(v_start, '%Y-%m-%d'), col='magenta', lty=2)
	abline(v=as.Date(v_start_2d, '%Y-%m-%d'), col='magenta')

	# add the axes
	axis(2, at=ya_info, labels=ya_info) #, las=1)

	# add titles
	title(main=paste(ds, ' Covid-19 Counts Through ', df$date[nrow(df)], 'T23:59:59Z', sep=''))
	title(sub=paste('Source:', ifelse(df$source[1] == 'world', src_world, src_states), sep=' '), cex=0.4)


	# add the legend
	legend('top', inset=c(0, 0.02), bg='white',
		legend=c(
			'confirmed',
			'deaths',
			'recovered',
			'deaths/confirmed',
			paste('vaccination dose 1 starts:', v_start, sep=' '),
			paste('vaccination dose 2 starts:', v_start_2d, sep=' ')
		),
		col=c('black', 'red', 'green', 'blue', 'magenta', 'magenta'),
		lty=c(1, 1, 1, 1, 2, 1),
		lwd=c(1, 1, 1, 1, 1, 1),
		cex=ifelse(par('mfrow')[1] == 1, 0.7, 0.5)
	)

	# plot the deaths/confirmed using scale on right side
	par(new=T)
	plot(as.Date(df$date, '%Y-%m-%d'), df$d2c, type='l', lty=1, col='blue', axes=F, xlab=NA, ylab=NA)
	axis(side=4)
	mtext(side=4, line=2.5, 'Deaths/Confirmed')
}

plotCVData2 <- function(ds, df) {

	# sources:
	src_world <- 'https://github.com/CSSEGISandData/COVID-19'
	src_states <- 'https://covidtracking.com/api/v1/states/daily.csv'

	# vaccinations begin:
	v_start <- '2020-12-14'

	dm_home <- Sys.getenv('DM_HOME')
	if (dm_home == '') {
		stop('DM_HOME is not defined.', call=.F)
	}
	sfn <- paste(dm_home, 'lib', 'getYaxisInfo.R', sep='/')
	source(sfn, chdir=T)

	ya_info <- getYaxisInfo(max(df$deaths))
	y_max <- max(ya_info)

	# put some space on the right side for 2nd axis
	mvals <- par('mar')
	mvals[4] <- mvals[2]
	par(mar = mvals)

	# plot the deaths
	plot(
		c(as.Date(df$date[1], '%Y-%m-%d'), as.Date(df$date[nrow(df)], '%Y-%m-%d')),
		c(0, y_max),
		type='n',
		xlab='Date',
		ylab='Counts',
		yaxt='n'
	)
	lines(as.Date(df$date, '%Y-%m-%d'), df$deaths, col='red')

	# add the axes
	axis(2, at=ya_info, labels=ya_info)

	# daily deaths (dd) and linear model of last 15 days of dd vs date.
	dd_pre <- df[as.Date(df$date, '%Y-%m-%d') <= as.Date(df[nrow(df)-14, 'date'], '%Y-%m-%d'),]
	dd <- df[as.Date(df$date, '%Y-%m-%d') >= as.Date(df[nrow(df)-14, 'date'], '%Y-%m-%d'),]
	dd_lm <- lm(dd$daily_deaths ~ as.Date(dd$date, '%Y-%m-%d'))
	# Use 2 lines: first is dd not used in model (thin), second is  dd used in model (thick)
	lines(as.Date(dd_pre$date, '%Y-%m-%d'), dd_pre$daily_deaths, lty=1, col='orange')
	lines(as.Date(dd$date, '%Y-%m-%d'), dd$daily_deaths, lty=1, lwd=3, col='orange')
	# Now this works well, as the extended line makes the slope easier to see
	abline(dd_lm, lty=2)

	# add a line that shows when vaccinations started
	abline(v=as.Date(v_start, '%Y-%m-%d'), col='magenta')

	# add titles
	title(main=paste(ds, ' Covid-19 Deaths Through ', df$date[nrow(df)], 'T23:59:59Z', sep=''))
	title(sub=paste('Source:', ifelse(df$source[1] == 'world', src_world, src_states), sep=' '), cex=0.4)

	# add the legend
	legend('top', inset=c(0, 0.02), bg='white',
		legend=c('deaths',
			 'daily deaths used in model',
			 'daily deaths not used in model',
			 'lm(dd ~ date, last 15 days)',
			 'deaths/confirmed',
			 paste('vaccination starts:', v_start, sep=' ')
		),
		col=c('red', 'orange', 'orange', 'black', 'blue', 'magenta'),
		lwd=c(1,3,1,1,1, 1),
		lty=c(1,1,1,2,1, 1),
		cex=0.7
	)

	# plot the deaths/confirmed using scale on right side
	par(new=T)
	plot(as.Date(df$date, '%Y-%m-%d'), df$d2c, type='l', lty=1, col='blue', axes=F, xlab=NA, ylab=NA)
	axis(side=4)
	mtext(side=4, line=2.5, 'Deaths/Confirmed')
}

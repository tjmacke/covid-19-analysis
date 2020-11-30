plotCVDeaths_byWeek <- function(ds, df) {

	# sources:
	src_world <- 'https://github.com/CSSEGISandData/COVID-19'
	src_states <- 'https://api.covidtracking.com/v1/states/daily.csv'

	dm_home <- Sys.getenv('DM_HOME')
	if (dm_home == '') {
		stop('DM_HOME is not defined.', call=.F)
	}
	sfn <- paste(dm_home, 'lib', 'getYaxisInfo.R', sep='/')
	source(sfn, chdir=T)

	mon <- df[cv$weekday == 'Monday',]
	if (ncol(mon) == 0) {
		stop('no Mondays in dataset', call=.F)
	}

	m2c_idx <- as.integer(rownames(mon))
	m2c_len <- c(diff(m2c_idx), nrow(df) - m2c_idx[length(m2c_idx)] + 1)

	f_mon <- m2c_idx[1]
	l_mon <- m2c_idx[length(m2c_idx)]
	f_row <- f_mon
	l_row <- nrow(df)

	if (l_row - l_mon < 6) { # short week, skip
		l_mon = l_mon - 7
		if (l_mon < f_mon) {
			stop('data has only 1 short week.', call=.F)
		}
		l_row = l_mon + 6
	}

	dpw <- c()
	for (i in seq(f_row, l_row, 7)) {
		dpw <- c(dpw, sum(cv[i:(i+6), 'daily_deaths']))
	}
	l_mon_row <- nrow(mon)
	if (length(dpw) < nrow(mon)) {
		dpw <- c(dpw, NA)
		l_mon_row = l_mon_row - 1
	}
	mon$dpw <- dpw

	ya_info <- getYaxisInfo(max(mon$dpw, na.rm=T))
	y_max <- max(ya_info)

	first_mondays <- mon[mon$mday <= 7,]

	plot(
		c(as.Date(mon[1, 'date'], '%Y-%m-%d'), as.Date(mon[l_mon_row, 'date'], '%Y-%m-%d')),
		c(0, y_max),
		type='n',
		xlab='First Monday of Month',
		xaxt='n',
		ylab='Weekly Deaths',
		yaxt='n'
	)
	lines(as.Date(mon$date, '%Y-%m-%d'), mon$dpw)
	axis(1, at=as.Date(first_mondays$date, '%Y-%m-%d'), labels=F)
        text(as.Date(first_mondays$date, '%Y-%m-%d'), par("usr")[3] - 500.0, labels=first_mondays$date, srt=45, adj=1, xpd=T, cex=0.6)
	axis(2, at=ya_info, labels=ya_info, las=1)
	title(main=paste(ds, 'Weekly COVID-19 Deaths; Weeks start on Monday', sep=' '))
	title(sub=paste('Source:', src_world, sep=' '))

	abline(h=ya_info, lty=3, col='black')
	abline(v=as.Date(first_mondays$date, '%Y-%m-%d'), lty=3, col='black')
}

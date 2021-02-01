plotCVDeaths_byWeek <- function(ds, df, val='deaths') {

	# sources:
	src_world <- 'https://github.com/CSSEGISandData/COVID-19'
	src_states <- 'https://api.covidtracking.com/v1/states/daily.csv'

	# vaccinations begin:
	v_start <- '2020-12-14'
	v_start_2d <- '2021-01-11'

	dm_home <- Sys.getenv('DM_HOME')
	if (dm_home == '') {
		stop('DM_HOME is not defined.', call=.F)
	}
	sfn <- paste(dm_home, 'lib', 'getYaxisInfo.R', sep='/')
	source(sfn, chdir=T)

	f_val = paste('daily_', val, sep='')
	t_val = paste(toupper(substring(val, 1, 1)), substring(val, 2), sep='')
	y_axis_cex = ifelse(val == 'confirmed', 0.5, 0.6)

	mondays <- df[df$weekday == 'Monday',]
	if (nrow(mondays) == 0) {
		stop('no Mondays in dataset', call=.F)
	}

	m2c_idx <- as.integer(rownames(mondays))

	f_monday <- m2c_idx[1]
	l_monday <- m2c_idx[length(m2c_idx)]
	f_row <- f_monday
	l_row <- nrow(df)
	if (l_row - l_monday < 6) { # last week is short
		if(l_monday == f_monday){
			stop('data has only 1 short week.', call=.F)
		}
		l_monday = l_monday- 7
		l_row = l_monday + 6
	}
	vpw <- c()
	for (i in seq(f_row, l_row, 7)) {
		vpw <- c(vpw, sum(df[i:(i+6), f_val]))
	}
	# deal with possible short final week
	if(length(vpw) < nrow(mondays)){
		vpw <- c(vpw, NA)
	}
	mondays$vpw <- vpw

	ya_info <- getYaxisInfo(max(mondays$vpw, na.rm=T))
	y_max <- max(ya_info)

	first_sundays <- df[df$weekday == 'Sunday' & df$mday <= 7,]

	plot(
		c(as.Date(df$date[1], '%Y-%m-%d'), as.Date(df$date[nrow(df)], '%Y-%m-%d')),
		c(0, y_max),
		type='n',
		xlab='First Sunday of Month',
		xaxt='n',
		ylab=paste('Weekly', t_val, sep=' ') ,
		yaxt='n'
	)
	lines(as.Date(mondays$date, '%Y-%m-%d'), mondays$vpw)
	axis(1, at=as.Date(first_sundays$date, '%Y-%m-%d'), labels=F)
        text(as.Date(first_sundays$date, '%Y-%m-%d'), par("usr")[3] - 500.0, labels=first_sundays$date, srt=45, adj=1, xpd=T, cex=0.6)
	axis(2, at=ya_info, labels=ya_info, las=1, cex.axis=y_axis_cex)

	# add a line that shows when vaccinations started
	abline(v=as.Date(v_start, '%Y-%m-%d'), col='magenta', lty=2)
	abline(v=as.Date(v_start_2d, '%Y-%m-%d'), col='magenta')

	title(main=paste(ds, 'COVID-19 Weekly',  paste(t_val, ';', sep=''),  'Weeks start on Monday', sep=' '))
	title(sub=paste('Source:', src_world, sep=' '))

	abline(h=ya_info, lty=3, col='black')
	abline(v=as.Date(first_sundays$date, '%Y-%m-%d'), lty=3, col='black')

	# add the legend
	legend('top', inset=c(0, 0.02), bg='white',
		legend=c(
			'weekly deaths',
			paste('vaccination dose 1 starts:', v_start, sep=' '),
			paste('vaccination dose 2 starts:', v_start_2d, sep=' ')
		),
		col=c('black', 'magenta', 'magenta'),
		lty=c(1, 2, 1),
		lwd=c(1, 1, 1),
		cex=0.7
	)
}

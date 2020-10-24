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

	print(mon)

	m2c_idx <- as.integer(rownames(mon))
	m2c_len <- c(diff(m2c_idx), nrow(df) - m2c_idx[length(m2c_idx)] + 1)

	f_mon <- m2c_idx[1]
	l_mon <- m2c_idx[length(m2c_idx)]
	f_row <- f_mon
	l_row <- nrow(df)

	print(c(f_mon, l_mon))

	if (l_row - l_mon < 6) { # short week, skip
		l_mon = l_mon - 7
		if (l_mon < f_mon) {
			stop('data has only 1 short week.', call=.F)
		}
		l_row = l_mon + 6
	}

	print(c(f_mon, l_mon))
	print(c(f_row, l_row))

	ya_info <- getYaxisInfo(max(df[f_row:l_row, 'daily_deaths']))
	y_max <- max(ya_info)

	print(ya_info)
	print(y_max)
}

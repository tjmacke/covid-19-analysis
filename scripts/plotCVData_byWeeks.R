plotCVData_byWeeks <- function(ds, df) {

	# sources:
	src_world <- 'https://github.com/CSSEGISandData/COVID-19'
	src_states <- 'https://api.covidtracking.com/v1/states/daily.csv'

	dm_home <- Sys.getenv('DM_HOME')
	if (dm_home == '') {
		stop('DM_HOME is not defined.', call=.F)
	}
	sfn <- paste(dm_home, 'lib', 'getYaxisInfo.R', sep='/')
	source(sfn, chdir=T)

	# display 1-4 last weeks
	if (exists('last_n')) {
		last_n <- ifelse(last_n > 4, 4, ifelse(last_n < 1, 1, last_n))
	} else {
		last_n <- 4
	}

	mon <- df[cv$weekday == 'Monday',]
	if (ncol(mon) == 0) {
		stop('no Mondays in dataset', call=.F)
	}
	m2c_idx <- as.integer(rownames(mon))
	m2c_len <- c(diff(m2c_idx), nrow(df) - m2c_idx[length(m2c_idx)] + 1)

	f_mon <- ifelse(nrow(mon) >= last_n, nrow(mon) - last_n + 1, 1)
	l_mon <- length(m2c_idx)

	f_row = m2c_idx[f_mon]
	l_row = nrow(df)
	ya_info <- getYaxisInfo(max(df[f_row:l_row, 'daily_deaths']))
	y_max <- max(ya_info)

	# Start the plot
	plot(
		c(1, 7),
		c(0, y_max),
		type='n',
		xlab='Day of the Week',
		xaxt='n',
		ylab='Daily Deaths',
		yaxt='n'
	)

	# add the axes & titles
	x_tk <- seq(1, 7)
	x_lb <- c('Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun')
	axis(1, at=x_tk, labels=x_lb)
	axis(2, at=ya_info, labels=ya_info, las=1)
	title(main='US Daily COVID-19 Deaths by Week')
	title(sub=paste('Source:', ifelse(df$source[1] == 'world', src_world, src_states), sep=''))

	# add a nice grid
	abline(h=ya_info, lty=3, col='black')
	abline(v=x_tk, lty=3, col='black')

	# this palate is called Amber color palette. 5 colors, skip the first
        # colors <- c('#ad3196', '#65bad1', '#adc842', '#ffbf00', '#dd8e87')
        colors <- c('#65bad1', '#adc842', '#ffbf00', '#dd8e87')

	c_idx <- length(colors) - last_n + 1
	l_col <- c()
	l_text <- c()

	# plot the selected weeks.
	for(m in seq(f_mon, l_mon)) {
		f_row <- m2c_idx[m]
		l_row <- ifelse(f_row+6 <= nrow(df), f_row+6, nrow(df))
		if (l_row > f_row) {
			lines(seq(1, l_row-f_row+1), df[f_row:l_row, 'daily_deaths'], lwd=3, col=colors[c_idx])
		} else {
			points(c(1), df[f_row, 'daily_deaths'], col=colors[c_idx])
		}
		l_col <- c(colors[c_idx], l_col) 
		is_short <- ifelse(l_row-f_row+1 < 7, paste(', ', l_row-f_row+1, ' days', sep=''), '')
		# l_text <- c(l_text, paste(df[f_row, 'date'], ', total = ', sum(df[f_row:l_row, 'daily_deaths']), is_short, sep=''))
		l_text <- c(paste(df[f_row, 'date'], ', total = ', sum(df[f_row:l_row, 'daily_deaths']), is_short, sep=''), l_text)
		c_idx <- c_idx + 1
	}

	# add the legend
	legend('bottom', inset=c(0, 0.02), bg='white',
		legend=l_text,
		col=l_col,
		lwd=3,
		lty=1)
}

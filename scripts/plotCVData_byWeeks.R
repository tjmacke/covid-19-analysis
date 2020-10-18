# dataset, fname, last_n must be set before calling
#

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

cv <- read.csv(fname, sep='\t', header=F)
colnames(cv) <- c('date', 'region', 'country', 'lat', 'long', 'confirmed', 'deaths', 'recovered', 'source', 'cc2')
cv$daily_confirmed <- c(cv$confirmed[1], diff(cv$confirmed))
cv$daily_deaths <- c(cv$deaths[1], diff(cv$deaths))
cv$weekday <- factor(weekdays(as.Date(cv$date, '%Y-%m-%d')), levels=c('Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'))

mon <- cv[cv$weekday == 'Monday',]
if (ncol(mon) == 0) {
	stop('no Mondays in dataset', call=.F)
}
m2c_idx <- as.integer(rownames(mon))
m2c_len <- c(diff(m2c_idx), nrow(cv) - m2c_idx[length(m2c_idx)] + 1)

f_mon <- ifelse(nrow(mon) >= last_n, nrow(mon) - last_n + 1, 1)
l_mon <- length(m2c_idx)

f_row = m2c_idx[f_mon]
l_row = nrow(cv)
ya_info <- getYaxisInfo(max(cv[f_row:l_row, 'daily_deaths']))
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

# add the axes & title
x_tk <- seq(1, 7)
x_lb <- c('Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun')
axis(1, at=x_tk, labels=x_lb)
axis(2, at=ya_info, labels=ya_info, las=1)
title(main='US Daily COVID-19 Deaths by Week')
title(sub=paste('Source:', ifelse(cv$source[1] == 'world', src_world, src_states), sep=''))

# add a nice grid
abline(h=ya_info, lty=3, col='black')
abline(v=x_tk, lty=3, col='black')

# set up the 4 colors & legend data
colors <- c('grey', 'darkorange4', 'orange', 'red')
c_idx <- length(colors) - last_n + 1
l_col <- c()
l_text <- c()

# plot the selected weeks.
for(m in seq(f_mon, l_mon)) {
	f_row <- m2c_idx[m]
	l_row <- ifelse(f_row+6 <= nrow(cv), f_row+6, nrow(cv))
	if (l_row > f_row) {
		lines(seq(1, l_row-f_row+1), cv[f_row:l_row, 'daily_deaths'], col=colors[c_idx])
	} else {
		points(c(1), cv[f_row, 'daily_deaths'], col=colors[c_idx])
	}
	l_col <- c(l_col, colors[c_idx]) 
	is_short <- ifelse(l_row-f_row+1 < 7, paste(', ', l_row-f_row+1, ' days', sep=''), '')
	l_text <- c(l_text, paste(cv[f_row, 'date'], ', total = ', sum(cv[f_row:l_row, 'daily_deaths']), is_short, sep=''))
	c_idx <- c_idx + 1
}

# add the legend
legend('bottom', inset=c(0, 0.02), bg='white',
	legend=l_text,
	col=l_col,
	lty=1)

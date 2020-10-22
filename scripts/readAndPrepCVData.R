readAndPrepCVData <- function(fname) {

        cv <- read.csv(fname, sep='\t', header=F)
        colnames(cv) <- c('date', 'region', 'country', 'lat', 'long', 'confirmed', 'deaths', 'recovered', 'source', 'cc2')
        cv$daily_confirmed <- c(cv$confirmed[1], diff(cv$confirmed))
        cv$daily_deaths <- c(cv$deaths[1], diff(cv$deaths))
        cv$d2c <- cv$deaths/cv$confirmed
	cv$weekday <- factor(weekdays(as.Date(cv$date, '%Y-%m-%d')), levels=c('Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'))
	return(cv)
}

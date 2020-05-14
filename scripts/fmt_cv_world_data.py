#! /usr/bin/python
#
import sys
import os
import getopt
import csv

def fix_date(d):
    w = d.split('/')
    return '20%02d-%02d-%02d' % (int(w[2]), int(w[0]), int(w[1]))

umsg = 'usage: %s [ -h ] csv-file'

# Edit as needed
HOME = os.getenv('HOME')
CV_HOME = '/'.join((HOME, 'work', 'COVID-19'))
CV_DATA = '/'.join((CV_HOME, 'csse_covid_19_data'))
CV_TSERIES = '/'.join((CV_DATA, 'csse_covid_19_time_series'))

opts, args = getopt.getopt(sys.argv[1:], 'h')
if len(opts) == 1:
    print >> sys.stderr, umsg % sys.argv[0]
    sys.exit(0)

if len(args) == 0:
    print >> sys.stderr, 'missing csv-file arg'
    print >> sys.stderr, umsg
    sys.exit(1)
elif len(args) > 1:
    print >> sys.stderr, 'only one csv-file arg allowed'
    print >> sys.stderr, umsg
    sys.exit(1)

cv_fname = CV_TSERIES + '/time_series_covid19_' + args[0] + '_global.csv'
with open(cv_fname, 'rb') as cvfile:
    cvreader = csv.reader(cvfile)
    rnum = 0
    for rec in cvreader:
        rnum += 1
        if rnum == 1:
            hdr = [f for f in rec]
            continue
        for i in range(4, len(rec)):
            print '%s\t%s\t%s\t%s\t%s\t%d' % (fix_date(hdr[i]), rec[0] if rec[0] != '' else '.', rec[1], rec[2], rec[3], int(rec[i]))

sys.exit(0)

#!/bin/bash

# current implementation of orglendar seems to be naive, so let's only retrieve the events we expect to happen in the next few weeks
START_DATE=`date -d "today" +%Y-%m-%d`
END_DATE=`date -d "3 weeks" +%Y-%m-%d`

# retrieve data from google, remove irrelevant data, convert format to orglendar and generate file
#google calendar list --date $START_DATE,$END_DATE | grep -v "^\[" | sed -e 's/^/** /' -e 's/,/\n   SCHEDULED: /' -e 's/ - .*$/\n/' | awk '/^\*\*/ {print "echo \""$0"\""} /^\s*SCHEDULED/ {print "date -d\""$2" "$3"\" +%Y-%m-%d | sed \"s/^.*$/   SCHEDULED: <&>/\"" }' | bash > ~/.config/awesome/google_cal_data.org

google calendar list --date $START_DATE,$END_DATE | grep -v "^\[" | sed -e 's/^/** /' -e 's/,/\n   SCHEDULED: /' | awk '/^\*\*/ {print "echo \""$0"\""} /^\s*SCHEDULED/ {print "date -d\""$2" "$3" "$4"\" +\"%Y-%m-%d %H:%M\" | sed \"s/^.*$/   SCHEDULED: <&>/\"" }' | bash > ~/.config/awesome/google_cal_data.org

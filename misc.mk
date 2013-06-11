# vim:ft=automake
#

# Set time
.PHONY: time
time: ntpdate
	ntpdate pool.ntp.org

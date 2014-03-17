# vim:ft=make
 
srcdir:= $(shell pwd)

CURL:=curl --silent --show-error
INSTALL:= install -b
MKDIR_P:= mkdir -p
TOUCH_R:= touch -r
TOUCH:= touch
dirstamp:= .dirstamp

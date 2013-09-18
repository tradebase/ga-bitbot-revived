#!/bin/bash


REDIS_INVOKE='redis-server redis.conf'
REDIS_START_DIR='$HOME/config/ga-bitbot/config'
GAL_INVOKE='pypy gal.py client'
GAL_START_DIR='$HOME/config/ga-bitbot'
USERNAME='trader'
ME=`whoami`
as_user() {
	if [ $ME == $USERNAME ] ; then
		bash -c "$1"
	else
		su - $USERNAME -c "$1"
	fi
}

all_start() {
	# set up screens
	if [ `screen -list | grep redissrv | wc -l` -eq 0 ] ; then screen -dmS redissrv ; fi
	if [ `screen -list | grep gal |  wc -l` -eq 0 ] ; then screen -dmS gal ; fi
	echo "Screens loaded..."
	echo `screen -list`

# if redis-server not running, start it.
	if [ `ps auxwww | grep redis-server | grep -v grep | wc -l` -eq 0 ] ; then
		as_user "screen -p 0 -S redissrv -X eval 'stuff \"cd $REDIS_START_DIR\"\015' "
		as_user "screen -p 0 -S redissrv -X eval 'stuff \"$REDIS_INVOKE\"\015' "
		echo "-- redis-server started."
		sleep 2
	else
		echo "** redis-server already running!!"
	fi

# change dir and start gal.py if needed
	if [ `ps auxwww | grep gal.py | grep -v grep | wc -l` -eq 0 ] ; then
		as_user "screen -p 0 -S gal -X eval 'stuff \"cd $GAL_START_DIR\"\015' "
		as_user "screen -p 0 -S gal -X eval 'stuff \"$GAL_INVOKE\"\015' "
		echo "-- gal.py started."
	else
		echo "** gal.py already running!!"
	fi


}

all_start

#  for i in `ps auxw|grep -i screen|grep -v grep | awk '{print $13}'` ; do screen -p 0 -S $i -X eval 'stuff ^C' ; screen -p 0 -S $i -X eval 'stuff \"exit\"\015' ; done


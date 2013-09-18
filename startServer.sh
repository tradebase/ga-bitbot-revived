#!/bin/bash

if [ `ls /run/shm/ | grep config | wc -l` -eq 0 ] ; then
	mkdir /run/shm/config
fi
cp -rf /home/trader/config/ga-bitbot/config_alt/* /run/shm/config/

REDIS_INVOKE='redis-server redis.conf'
REDIS_START_DIR='$HOME/config/ga-bitbot/config'
GAL_INVOKE='pypy gal.py server'
GAL_START_DIR='$HOME/config/ga-bitbot'
NODE_INVOKE='node server.js'
NODE_START_DIR='$HOME/config/ga-bitbot/tools/nimbs'
BOOKIE_INVOKE='python bcbookie.py'
BOOKIE_START_DIR='$HOME/config/ga-bitbot'
BIDMAKER_INVOKE='python bid_maker.py'
BIDMAKER_START_DIR='$HOME/config/ga-bitbot'
SENTINEL_INVOKE='./sentinel.sh'
SENTINEL_START_DIR='$HOME/config/ga-bitbot'

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
	if [ `ps auxwww | grep bcbookie.py | grep -v grep | wc -l` -eq 0 ] ; then
		# get bcbookie password
		echo "Please enter your bcbookie.py password to continue : "
		read BCBPW
	fi


	# set up screens
	if [ `screen -list | grep redissrv | wc -l` -eq 0 ] ; then screen -dmS redissrv ; fi
	if [ `screen -list | grep gal |  wc -l` -eq 0 ] ; then screen -dmS gal ; fi
	if [ `screen -list | grep node | wc -l` -eq 0 ] ; then screen -dmS node ; fi
	if [ `screen -list | grep bookie | wc -l` -eq 0 ] ; then screen -dmS bookie ; fi
	if [ `screen -list | grep bidmaker | wc -l` -eq 0 ] ; then screen -dmS bidmaker ; fi
	if [ `screen -list | grep sentinel | wc -l` -eq 0 ] ; then screen -dmS sentinel ; fi
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
		sleep 60
	else
		echo "** gal.py already running!!"
	fi

# start node server.js if needed
	if [ `ps auxwww | grep server.js | grep -v grep | wc -l` -eq 0 ] ; then
		as_user "screen -p 0 -S node -X eval 'stuff \"cd $NODE_START_DIR\"\015' "
		as_user "screen -p 0 -S node -X eval 'stuff \"$NODE_INVOKE\"\015' "
		echo "-- node server.js started."
		sleep 5
	else
		echo "** node server.js already running!!"
	fi

# start bcbookie if needed
	if [ `ps auxwww | grep bcbookie.py | grep -v grep | wc -l` -eq 0 ] ; then
		as_user "screen -p 0 -S bookie -X eval 'stuff \"cd $BOOKIE_START_DIR\"\015' "
		as_user "screen -p 0 -S bookie -X eval 'stuff \"$BOOKIE_INVOKE\"\015' "
		sleep 5
		as_user "screen -p 0 -S bookie -X eval 'stuff \"$BCBPW\"\015'"
		echo "-- bcbookie.py started."
		sleep 5
	else
		echo "** bcbookie.py already running!!"
	fi


# start bid_maker if needed
	if [ `ps auxwww | grep bid_maker.py | grep -v grep | wc -l` -eq 0 ] ; then
		as_user "screen -p 0 -S bidmaker -X eval 'stuff \"cd $BIDMAKER_START_DIR\"\015' "
		as_user "screen -p 0 -S bidmaker -X eval 'stuff \"$BIDMAKER_INVOKE\"\015' "
		echo "-- bid_maker.py started."
		sleep 5
	else
		echo "** bid_maker.py already running!!"
	fi

# start sentinel if needed
	if [ `ps auxwww | grep sentinel.sh | grep -v grep | wc -l` -eq 0 ] ; then
		as_user "screen -p 0 -S sentinel -X eval 'stuff \"cd $SENTINEL_START_DIR\"\015' "
		as_user "screen -p 0 -S sentinel -X eval 'stuff \"$SENTINEL_INVOKE\"\015' "
		echo "-- sentinel.sh started."
	else
		echo "** sentinel.sh already running!!"
	fi

}

all_start



#!/bin/bash
echo '     ___/\/\/\/\/\____________________________/\/\_____________________________'
echo '    _/\/\__________/\/\/\______/\/\/\/\____/\/\/\/\/\__/\/\__/\/\__/\/\__/\/\_ '
echo '   _/\/\__/\/\/\______/\/\____/\/\__/\/\____/\/\______/\/\/\/\____/\/\__/\/\_  '
echo '  _/\/\____/\/\__/\/\/\/\____/\/\__/\/\____/\/\______/\/\__________/\/\/\/\_   '
echo ' ___/\/\/\/\/\__/\/\/\/\/\__/\/\__/\/\____/\/\/\____/\/\______________/\/\_    '
echo '_______________________________________________________________/\/\/\/\___     '
echo -e '\n\nAutomatic installer\n'

if [[ "$UID" -ne "0" ]];then
	echo 'You must be root to install LXC Web Panel !'
	exit
fi

### BEGIN PROGRAM

INSTALL_DIR='/home/flatline/Desktop/gantry/web'

if [[ -d "$INSTALL_DIR" ]];then
	echo "You already have LXC Web Panel installed. You'll need to remove $INSTALL_DIR if you want to install"
	exit 1
fi

echo 'Installing requirement...'

apt-get update &> /dev/null

hash python3 &> /dev/null || {
	echo '+ Installing python3'
#	apt-get install -y python3 > /dev/null
	apt-get install -y python3
}

hash pip &> /dev/null || {
	echo '+ Installing python3 pip'
#	apt-get install -y python3-pip > /dev/null
	apt-get install -y python3-pip
}

python3 -c 'import flask' &> /dev/null || {
	echo '| + Flask python3...'
#	pip install flask==0.9 2> /dev/null
	pip install flask==0.9 2
}


hash git &> /dev/null || {
	echo '+ Installing Git'
#	apt-get install -y git > /dev/null
	apt-get install -y git
}

echo 'Cloning LXC Web Panel...'
git clone https://github.com/Engility-TechWorks/TechWorks-ContainerManager.git "$INSTALL_DIR"

echo -e '\nInstallation complete!\n\n'


echo 'Adding /etc/init.d/gantry...'

cat > '/etc/init.d/gantry' <<EOF
#!/bin/bash
#
# /etc/init.d/gantry
#
### BEGIN INIT INFO
# Provides: gantry
# Required-Start: \$local_fs \$network
# Required-Stop: \$local_fs
# Default-Start: 2 3 4 5
# Default-Stop: 0 1 6
# Short-Description: gantry Start script
### END INIT INFO


WORK_DIR="$INSTALL_DIR"
SCRIPT="lwp.py"
DAEMON="/usr/bin/python3 \$WORK_DIR/\$SCRIPT"
PIDFILE="/var/run/gantry.pid"
USER="root"

function start () {
	echo -n 'Starting server...'
	/sbin/start-stop-daemon --start --pidfile \$PIDFILE \\
		--user \$USER --group \$USER \\
		-b --make-pidfile \\
		--chuid \$USER \\
		--chdir \$WORK_DIR \\
		--exec \$DAEMON
	echo 'done.'
	}

function stop () {
	echo -n 'Stopping server...'
	/sbin/start-stop-daemon --stop --pidfile \$PIDFILE --signal KILL --verbose
	echo 'done.'
}


case "\$1" in
	'start')
		start
		;;
	'stop')
		stop
		;;
	'restart')
		stop
		start
		;;
	*)
		echo 'Usage: /etc/init.d/gantry {start|stop|restart}'
		exit 0
		;;
esac

exit 0
EOF

mkdir -p /etc/lxc/auto
chmod +x '/etc/init.d/gantry'
#update-rc.d gantry defaults &> /dev/null
update-rc.d gantry defaults &
echo 'Done'
/etc/init.d/gantry start
echo 'Connect on http://your-ip-address:5000/'
echo 'To manage service use : sudo service gantry start|stop|restart'

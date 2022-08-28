export HISTTIMEFORMAT="%y-%m-%d %T> "
HISTSIZE=10000

# default options for LESS
# -J add status column on the left, marks columns with search hits.
# -M more verbose status line.
# -R don't convert raw input, lets escape sequences be interpreted.
# -I case insensitive searching.
export LESS='-JMIR'

export VISUAL=vim
export EDITOR="$VISUAL"



# make dir and cd
function mkcd { mkdir "$1" && cd "$1" ; }

# get dir from a file name and cd to it
function cd1 { 
	local dir="`dirname $1`"
	echo "Your dir: '$dir'"
	cd "$dir"
}

# create .bak for a file, if bak already exist - overwrite
# can be used with templates, e.g. `bak *.txt`
function bak { 
	for f in "$@"
	do
		mv "$f" "$f.bak"; 
	done
}

# if bak already exists, create bak1, bak2 etc
function bak1 { 
	for f in "$@"
	do
		local newf="$f.bak"
		if [[ -f $newf ]]; then
			local idx=1
			while [[ -f $newf$idx ]]; do
				idx=$(( $idx + 1 ))
			done
			newf="$newf$idx"
		fi
		mv "$f" "$newf"; 
	done
}

# show help for a function and pipe to less
function h {
	$@ --help | less
}

# run a command and pipe result to less
function l {
	$@ | less
}


# timestamp to time
# timestamp can be in seconds or milliseconds
# returns time in current timezone (UTC +3 in Msc)
# to get UTC time, use: `TZ=UTC ts2time 0` or uts2time
function ts2time {
	local ts=$1
	if (("$ts" > "10000000000")); then
	# asume that this ts is in ms
		echo "TS in ms, TZ: $TZ"
		local str=$(date +"%F %T" -d @$(($ts/1000)))
		local ms=${ts: -3}
		echo "$str.$ms"
	else
		echo "TS in seconds, TZ: $TZ"
		date +"%F %T" -d @$ts
	fi
}

function time2ts {
	if [[ -z "$1" ]]; then
		date +"%s"
	else
		date --date "$1" +"%s"
	fi
}

# return current external ip 
function myip {
	curl -s https://checkip.amazonaws.com

	curl -s ipinfo.io
	# shorter
	# curl -s ifconfig.me
}

# add timestamp use like this:
# <CMD> | addts
function addts {
	while read line; do 
		echo "$(date -Iseconds): $line"
	done
}

# list 10 recently modified files
function lsr {
	ls -lth "$@" | head -n10
}

# will rety provided command until it succeeded (0 is returned)
function retryUntil0  {
	local i=0
	local cmd="$1"
	local wait="${2:-30}"
	echo "Running command '$cmd', timeout '$wait'"
	while true; do
		printf "$i $(date -Iseconds)	"
		$cmd
		retVal=$?
		if [ $retVal -eq 0 ]; then
    		break
		fi
		sleep $wait
		((i++))
	done
	say "Retry succeeded after $i attempts"	
}

#!/usr/bin/env bash
# A Script to Convert FreePBX call recordings from WAV to ogg

#configs

#possible values of log verbose:
#quiet 		Show nothing at all; be silent. 
#panic 		Only show fatal errors which could lead the process to crash, such as an assertion failure. This is not currently used for anything. 
#fatal 		Only show fatal errors. These are errors after which the process absolutely cannot continue. 
#error 		Show all errors, including ones which can be recovered from. 
#warning 	Show all warnings and errors. Any message related to possibly incorrect or unexpected events will be shown. 
#info		Show informative messages during processing. This is in addition to warnings and errors. This is the default value.  
#verbose		Same as info, except more verbose. 
#debug		Show everything, including debugging information. 

LEVEL="panic"

#-loglevel [flags+]loglevel | -v [flags+]loglevel
#Set logging level and flags used by the library.
#The optional flags prefix can consist of the following values:
#‘repeat’
#	Indicates that repeated log output should not be compressed to the first line and the "Last message repeated n times" line will be omitted. 
#‘level’
#        Indicates that log output should add a [level] prefix to each message line. This can be used as an alternative to log coloring, e.g. when dumping the log to file. 
#Flags can also be used alone by adding a ’+’/’-’ prefix to set/reset a single flag without affecting other flags or changing loglevel. When setting both flags and loglevel, a ’+’ separator is expected between the last flags value and before loglevel. 
LOGLEVEL="-loglevel"

#path of call records.
recordspath="/var/spool/asterisk/monitor/"

#date. Modify only for optimization
recordsdate="$(date +%Y)/$(date +%m)/$(date +%d)/"

#path of records to convert. Modify only for optimization. For other purposes modify $recordspath and $recordsdate
corepath="$recordspath$recordsdate"

#CDR database name
database="asteriskdb"

#CDR database user
db_user="user"

#CDR database user's pass
db_pass="batteryhorsestaple"

#core function
for wavfile in $(find "$corepath" -type f -name '*.wav')
do	
	#strings processing
	wavfilenopath="$(echo "$wavfile" | sed 's/.*\///')";
	oggfile="$(echo ${wavfile//'.wav'/'.ogg'})"
	oggfilenopath="$(echo "$oggfile" | sed 's/.*\///' )";
	# sed is faster than basename
	#core convertation
	nice ffmpeg "$LOGLEVEL" "$LEVEL" -i "$wavfile" "$oggfile" && rm -frv "$wavfile"
	# TODO: File check condtions optimization
	#if [ -f "$oggfile" ] then
		mysql -u "$db_user" -p "$db_pass" -s -N -D "$database" <<< "UPDATE cdr SET recordingfile='$oggfilenopath' WHERE recordingfile = '$wavfilenopath'"
	#fi

done


#!/bin/bash

#####
## Shell script to facilitate easy running of a command when the contents
## of a watched file changes. This script is intended to be used with
## reload.sh to work around the fact that nfs shares on vagrant VMs
## break fswatch.
# See https://github.com/DrLongGhost/reload
#####

# Populate last 5 commands from bash history
PRESET_CMD[0]=`cat ~/.bash_history | tail -1 | head -1`
PRESET_CMD[1]=`cat ~/.bash_history | tail -2 | head -1`
PRESET_CMD[2]=`cat ~/.bash_history | tail -3 | head -1`
PRESET_CMD[3]=`cat ~/.bash_history | tail -4 | head -1`
PRESET_CMD[4]=`cat ~/.bash_history | tail -5 | head -1`

# Enter additional preset commands here
PRESET_CMD[5]='make test'

# Do not edit this one
PRESET_CMD[9]='Enter a custom command'

control_c()
# run if user hits control-c
{
  local now=`date +%s`
  if [ `expr $now - $last_time` -lt 2 ] ; then
    exit $?
  else
    echo "Re-running command. Press ctl-c twice quickly to quit"
    echo "$cmd"
    eval $cmd;
    last_time=$now;
  fi
}

function HELP {
  echo -e \\n"Option -f allows you to specify the file to monitor"\\n
  echo -e \\n"Option -c allows you to specify the command to run"\\n
  echo -e \\n"For complete usage instructions, see https://github.com/DrLongGhost/reload"\\n
  exit 1
}

while getopts c:f: FLAG; do
  case $FLAG in
    c)  #set option "c"
      OPT_C=$OPTARG
      ;;
    f)  #set option "f"
      OPT_F=$OPTARG
      ;;
    h)  #show help
      HELP
      ;;
    \?) #unrecognized option - show help
      echo -e \\n"Option -${BOLD}$OPTARG${NORM} not allowed."
      HELP
      #If you just want to display a simple error message instead of the full
      #help, remove the 2 lines above and uncomment the 2 lines below.
      #echo -e "Use ${BOLD}$SCRIPT -h${NORM} to see the help documentation."\\n
      #exit 2
      ;;
  esac
done

# Prompt to get the directory, if needed
if [[ -z "$OPT_F" ]] ; then
  echo "What file do you want to monitor?"
  read -e monitorfile
else
  monitorfile="$OPT_F";
fi

# Prompt to get the command, if needed
if [[ -z "$OPT_C" ]] ; then
  echo "What command do you wish to run? Pick a preset or enter a custom command."
  for i in "${!PRESET_CMD[@]}"
  do
    if [[ $i == "14" ]] ; then
      printf "%s: %s\n" "$i" `${PRESET_CMD[$i]}`
    else
      printf "%s: %s\n" "$i" "${PRESET_CMD[$i]}"
    fi;
  done
  read -e -p "[9]" commandarg;
else
  commandarg="$OPT_C";
fi

if [[ $commandarg =~ [0-9,\w]+ || $commandarg == "" ]] ; then
  if [[ $commandarg == "9" || $commandarg == "" ]] ; then
    # Custom command
    echo "Enter your custom command"
    read -e cmd
    echo "${cmd}" >> ~/.bash_history
  else
    cmd="${PRESET_CMD[$commandarg]}"
  fi;
else
  cmd="$commandarg"
fi

fullcommand="$monitorfile"
echo "$fullcommand $cmd"

trap control_c SIGINT

while true
do
    rand1=`cat $monitorfile`
    sleep 1
    rand2=`cat $monitorfile`
    if [ "$rand1" != "$rand2" ];
    then
      echo "$cmd"
      eval $cmd;
    fi
done

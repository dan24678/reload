#!/bin/bash

#####
## Shell script to facilitate easy reloading of a browser or unit tests when
## a monitored directory changes. See https://github.com/DrLongGhost/reload
#####

# Default directory to monitor
DEFAULT_DIR='.'

# Default command. Editable.
DEFAULT_CMD="reload_chrome"

# Do not edit these
PRESET_CMD[0]=$DEFAULT_CMD
PRESET_CMD[1]='Select browser(s) to reload'

# Enter additional preset commands here
PRESET_CMD[2]='make test'

# Populate last 5 commands from bash history
PRESET_CMD[4]=`cat ~/.bash_history | tail -1 | head -1`
PRESET_CMD[5]=`cat ~/.bash_history | tail -2 | head -1`
PRESET_CMD[6]=`cat ~/.bash_history | tail -3 | head -1`
PRESET_CMD[7]=`cat ~/.bash_history | tail -4 | head -1`
PRESET_CMD[8]=`cat ~/.bash_history | tail -5 | head -1`

# Do not edit this one
PRESET_CMD[9]='Enter a custom command'

# If include/exclude is specified with no arguments, this is the default
DEFAULT_INCLUDE_REGEX='(php|cfg|ini|js|txt|csv|py|htm|json|yaml|ctp|html|rb|feature|md|css)$'

# When ALWAYS_USE_DEFAULT_REGEX is set to "1", the script will always use the DEFAULT_INCLUDE_REGEX.
# This flag eliminates the need to specify: -i ''
# to get the DEFAULT_INCLUDE_REGEX to be recognized.
ALWAYS_USE_DEFAULT_REGEX=1

DEFAULT_EXCLUDE_REGEX='(tmp|cache|\.log)'

BROWSER[0]='chrome'
BROWSER[1]='firefox'
BROWSER[2]='safari'
BROWSER[3]='opera'

last_time=1
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

reload_chrome()
{
  osascript -e 'tell application "Google Chrome"' -e 'reload active tab of window 1' -e 'end tell'
}

reload_firefox()
{
  osascript -e 'tell application "Firefox"' -e 'activate' -e 'end tell' -e 'tell application "System Events"' -e 'tell process "Firefox"' -e 'keystroke "r" using {command down}' -e 'end tell' -e 'end tell'
}

reload_safari()
{
  osascript -e 'tell application "Safari"' -e 'set docUrl to URL of document 1' -e 'set URL of document 1 to docUrl' -e 'end tell'
}

reload_opera()
{
  osascript -e 'tell application "Opera"' -e 'activate' -e 'end tell' -e 'tell application "System Events"' -e 'tell process "Opera"' -e 'keystroke "r" using {command down}' -e 'end tell' -e 'end tell'
}

function HELP {
  echo -e \\n"Option -d allows you to specify the directory to monitor"\\n
  echo -e \\n"Option -c allows you to specify the command to run"\\n
  echo -e \\n"Option -i allows you to specify a match pattern of file paths to include (whitelist)"\\n
  echo -e \\n"Option -e allows you to specify a match pattern of file paths to exclude (blacklist)"\\n
  echo -e \\n"For complete usage instructions, see https://github.com/DrLongGhost/reload"\\n
  exit 1
}

fsw_arg=""

while getopts :c:d:i:e:h FLAG; do
  case $FLAG in
    c)  #set option "c"
      OPT_C=$OPTARG
      ;;
    d)  #set option "d"
      OPT_D=$OPTARG
      ;;
    i)  #set option "i"
      OPT_I=$OPTARG
      if [[ $OPTARG == "" ]] ; then
        OPT_I="$DEFAULT_INCLUDE_REGEX"
      fi
      fsw_arg="-E -I -i '${OPT_I}' -e '.'"
      ;;
    e)  #set option "e"
      OPT_E=$OPTARG
      if [[ $OPTARG == "" ]] ; then
        OPT_E="$DEFAULT_EXCLUDE_REGEX"
      fi
      fsw_arg="-E -I -e '${OPT_E}'"
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

if [[ $fsw_arg == "" && $ALWAYS_USE_DEFAULT_REGEX == 1 ]] ; then
  fsw_arg="-E -I -i '${DEFAULT_INCLUDE_REGEX}' -e '.'"
fi

# Prompt to get the directory, if needed
if [[ -z "$OPT_D" ]] ; then
  echo "What directory do you want to monitor?"
  read -e -p "[$DEFAULT_DIR]" monitordir
  if [[ $monitordir == "" ]] ; then monitordir="$DEFAULT_DIR" ; fi;
else
  monitordir="$OPT_D";
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

if [[ $commandarg =~ [0-9,\w]+ && -n "$OPT_C" ]] ; then
  whichbrowser="$OPT_C"
elif [[ $commandarg =~ [0-9,\w]+ || $commandarg == "" ]] ; then
  if [[ $commandarg == "0" ]] ; then
    # Default browser setting
    cmd="$DEFAULT_CMD"
  elif [[ $commandarg == "1" ]] ; then
    # Select browser
    echo "Which browser(s)?"
    for i in "${!BROWSER[@]}"
    do
      printf "%s: %s\n" "$i" "${BROWSER[$i]}"
    done
    read whichbrowser
    #browsername="${BROWSER[$whichbrowser]}"
    #cmd="reload_$browsername"
  elif [[ $commandarg == "9" || $commandarg == "" ]] ; then
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

# Lastly, build list of browsers to reload
# TODO: Make this code not lame
if [ -n "$whichbrowser" ] ; then
  cmd=""
  if [[ $whichbrowser =~ 0 ]] ; then
    cmd="reload_chrome"
  fi
  if [[ $whichbrowser =~ 1 ]] ; then
    if [[ $cmd == "" ]] ; then
      cmd="reload_firefox";
    else
      cmd="$cmd ; reload_firefox"
    fi
  fi
  if [[ $whichbrowser =~ 2 ]] ; then
    if [[ $cmd == "" ]] ; then
      cmd="reload_safari";
    else
      cmd="$cmd ; reload_safari"
    fi
  fi
  if [[ $whichbrowser =~ 3 ]] ; then
    if [[ $cmd == "" ]] ; then
      cmd="reload_opera";
    else
      cmd="$cmd ; reload_opera"
    fi
  fi
fi

fullcommand="fswatch $fsw_arg $monitordir | (while read event; do echo \$event; $cmd ; done)"
echo "$fullcommand"
trap control_c SIGINT

while :
  do
    eval $fullcommand
done

# reload.sh Overview

reload.sh is a shell script for OS-X that aids in refreshing browsers or running tests when files
in a monitored directory change. This script is basically a convenience wrapper
around fswatch ([https://github.com/emcrisostomo/fswatch](https://github.com/emcrisostomo/fswatch)). It requires fswatch
be installed as a dependency. On OS-X, fswatch can be installed via either macports or homebrew:


> #### MacPorts
> $ port install fswatch

> #### Homebrew
> $ brew install fswatch


reload.sh is designed to be easy to use. Once installed, you can run the script
without any arguments and it will prompt you for the name of the directory to
monitor and ask whether you want to run a command or refresh specific browsers
when files in the monitored directory have changed. 

Each supported argument/feature is explained below.

### Directory (-d)
Specifies the directory which should be monitored. You will be prompted by the
script to enter the directory path, unless a directory is provided via the -d
flag:

> reload.sh -d /path/to/dir

When the program prompts you to enter a directory, hitting enter without entering
a value will automatically use the default. The default is determined by the value
of the DEFAULT_DIR shell variable in the script, which you can change to your
liking. The default DEFAULT_DIR is '.'


### Command (-c)
Specifies the command to run when a change is detected. You will be prompted by the
script to enter a command, unless a command is provided via the -c flag:

> reload.sh -c 'make test'

When the program prompts you to choose a command, hitting enter without entering
a value will automatically use the default. The default is determined by the value
of the DEFAULT_CMD shell variable in the script, which you can change to your
liking.

If you would like to refresh one or more browsers when files are changed, there
are several ways to indicate this. You can enter a 1 when prompted and then choose
your browser(s) or you can supply the numeric shortcuts via the -c flag:

> ### This will refresh both chrome and firefox:
> reload.sh -c '0,1'

Also, there are named functions for the browser refresh commands which can also
be referenced:

> reload.sh -c 'reload\_safari ; reload\_opera'

You can trigger as many browser refreshes as you want. Note that it is only the
active tab in each browser that will be reloaded. Full list of supported browser commands:

> 0 or reload\_chrome

> 1 or reload\_firefox

> 2 or reload\_safari

> 3 or reload\_opera


### Include (-i)

The include argument allows you to specify a regular expression to limit which
files in the given directory can trigger the command. Only files matching the
regex will trigger the command. Here is an example:

> reload.sh -c 'make test' -d ~/git -i '\\.js$'

As a result of supplying the above arguments, file changes to ~/git/widget.js
would trigger the "make test" command but file changes to ~/git/README.md would
not.

By default, the DEFAULT\_INCLUDE\_REGEX regular expression is used to
only run the configured command when relevant JS, PHP, HTML, etc. files are changed.
If you work in Ruby, Java or other languages not yet represented in DEFAULT\_INCLUDE\_REGEX,
you will want to add the desired file extensions into the regex.

Alternately, you can set the ALWAYS\_USE\_DEFAULT\_REGEX value to "0" to
modify the behavior to no longer ignore non-matching files by default.

### Exclude (-e)

The exclude argument allows you to specify a regular expression to exclude
files in the given directory from triggering the command. Only files that do
NOT match the regex will trigger the command. Here is an example:

> reload.sh -c 'make test' -d ~/git -e '\\.js$'

As a result of supplying the above arguments, file changes to ~/git/widget.js
would not trigger the "make test" command but file changes to ~/git/README.md would.

It is also possible to set up a default regular expression to be used
when the -e flag is passed with an empty argument:

> reload.sh -e ''

The above command would use the regular expression defined in the
DEFAULT\_EXCLUDE\_REGEX shell variable in the script, which can be customized
to your liking.

### Additional Tips

It may be helpful to be able to easily trigger the command at will once reload.sh is
already running. This is helpful if you need to rerun a test without having to
change any of the test files. For this purpose, the control-c keyboard shortcut
will automatically re-run the command (provided the terminal has focus). Since
control-c needs to also allow the user to exit reload.sh once it is running, logic
was added so that hitting control-c TWICE (within 1 second) will exit the script
rather than simply re-run the command again.

### Changelog

2016-07-18: 

* The default option when prompted is now "custom command"
* Prior 5 commands from ~/.bash_history are shown as choices in the prompt
* Any custom command that is typed in will be manually appended to ~/.bash_history
 


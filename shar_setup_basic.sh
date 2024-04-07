#!/bin/sh
# This script is for basic installation of a Wine prefix for SHAR. Descriptions of stuff in 'printf' commands below.

WINEPREFIX="$HOME/.wine-shar"
WINEPREFIXTEXT="$(echo "$WINEPREFIX" | sed -e "s|^$HOME|~|g")"
WINEARCH="win32"
CHOICEERROR=false

# puts terminal into alternative view, separate from other commands etc.
tput smcup 

# returns to main terminal view on script exit. First time I've ever used 'trap' so probably overkill.
trap 'tput rmcup; exit 0' 0
trap 'tput rmcup; exit 1' 1
trap 'tput rmcup; exit 2' 2

clear
while true; do
	printf '%s\n%s\n%s%b%s\n%s\n\n' \
	"This script will set up a Wine prefix for SHAR in '$WINEPREFIXTEXT' the way it's" \
	"done in Clifforus's tutorial (https://www.youtube.com/watch?v=oSQUPZoqNCQ)," \
	"effectively automating the manual method. This script " "\033[1mWILL NOT\033[0m" " install SHAR," \
	"the mod launcher or LiveSplit."

	printf '%s%b%s\n%s\n' \
	"For Linux beginners, you should probably use Lutris instead. This " "\033[1mwill\033[0m" " set up" \
	"the Wine prefix and install SHAR too."

	printf '%s\n\n%s\n%s\n%s\n\n' \
	"Do you want instructions on how to install using Lutris?" \
	"1) Lutris instructions" \
	"2) Continue automated Wine prefix setup" \
	"3) Quit"

	[ "$CHOICEERROR" = true ] && printf '%s\n' \
	"Invalid input, enter \"1\", \"2\" or \"3\"!"

	printf '%s' \
	"Please select [1-3]: "

	read -r ANSWER
	case $ANSWER in
		1)
			clear
			printf '%s\n%s\n%s\n%s\n%s\n%s\n\n' \
			"1) Install Lutris (https://lutris.net/downloads)" \
			"2) Open it and click the \"+\" icon on the top-left and select \"Search the Lutris" \
			"   site for installers\"" \
			"3) Search for \"The Simpsons: Hit & Run\"" \
			"4) Choose \"PC Mod Launcher v1.26.1\". It should then install SHAR + the mod" \
			"   launcher"

			printf '%s\n%s\n%s\n%s\n\n' \
			"To run LiveSplit, click SHAR in your Lutris menu (when it's installed) and," \
			"next to \"Play\" at the bottom-left, click the arrow to the right of the Wine" \
			"logo button, then click \"Run EXE inside Wine prefix\", then find your" \
			"'LiveSplit.exe'"

			printf '%s\n' \
			"Press <Enter> to exit"
			read -r EXITINPUT

			exit 0 ;;
		2)
			CHOICEERROR=false
			break ;;
		3)
			tput rmcup
			exit 0 ;;
		*)
			CHOICEERROR=true
			clear ;; # improvements more than welcome.
	esac
done

clear
while true; do
	printf '%s\n%s\n\n' \
	"Obviously, you will need Wine to be installed on your system to continue. Wine" \
	"can be installed on:"

	printf '%s\n%s\n%s\n%s\n%s\n\n\n' \
	"Ubuntu: https://wiki.winehq.org/Ubuntu" \
	"Fedora: https://wiki.winehq.org/Fedora" \
	"Arch-based (Arch, Manjaro etc., \"multilib\" needs to be enabled in" \
	"\"/etc/pacman.conf\"):" \
	"run \"sudo pacman -S wine\" in terminal"

	printf '%s\n\n' \
	"You will also need Winetricks. This can be installed on:"

	printf '%s\n%s\n%s\n%s\n%s\n\n\n' \
	"Ubuntu: run \"sudo apt install winetricks\" (???, I don't know)" \
	"Arch-based (ditto \"multilib\" from wine install):" \
	"run \"sudo pacman -S winetricks\" in terminal" \
	"If your distro is not mentioned, it's because I don't know how installation" \
	"works on it. Feel free to suggest installation methods for other distros!"

	printf '%s\n\n' \
	"You will also need an active internet connection!"

	if [ "$CHOICEERROR" = true ]; then
		printf '%s\n' \
		"Invalid input, enter \"Y\" or \"N\"!"
	else
		printf '%s' \
		"Continue? [Y/n] "
	fi

	read -r ANSWER
	case $ANSWER in
		[Yy][Ee][Ss]|[Yy])
			CHOICEERROR=false
			break ;;
		[Nn][Oo]|[Nn])
			exit 0 ;;
		*)
			CHOICEERROR=true
			clear ;; # improvements more than welcome.
	esac
done

if [ ! -d "$WINEPREFIX" ]; then
	printf '\n%s\n' \
	"Creating Wine prefix at '$WINEPREFIXTEXT'"
else
	printf '\n%s\n%s\n%s\n\n' \
	"'$WINEPREFIXTEXT' already exists! You can either continue (errors could occur but" \
	"unlikely) or delete '$WINEPREFIXTEXT'(be sure nothing important is in" \
	"'$WINEPREFIXTEXT')."

	printf 'Continue? [Y/n] '

	[ "$CHOICEERROR" = true ] && printf '\n%s\n' \
	"Invalid input, enter \"Y\" or \"N\"!"

	while true; do
		read -r ANSWER
		case $ANSWER in
			[Yy][Ee][Ss]|[Yy])
				CHOICEERROR=false
				break ;;
			[Nn][Oo]|[Nn])
				exit 0 ;;
			*)
				CHOICEERROR=true
				clear ;;
		esac
	done
fi

if wineboot 2>/dev/null ; then
	printf '%s\n\n' \
	"Finished setting up Wine prefix in '$WINEPREFIXTEXT'"
else
	printf '%s\n%s\n%s\n\n' \
	"Failed setting up Wine prefix!" \
	"Deleting '$WINEPREFIXTEXT' and re-running this script may help, but make sure you" \
	"have nothing important in '$WINEPREFIXTEXT'!"

	printf '%s\n' \
	"Press <Enter> to exit"
	read -r EXITINPUT

	exit 1
fi

printf '%s\n%s\n%s\n' \
"Installing .NET 4.6.1" \
"This may take a while (at least 5-10+ minutes)" \
"You may get some prompts to click on"

if winetricks -q -f dotnet461 1>/dev/null 2>/dev/null ; then # remove "#>/dev/null" for more verbose output.
	printf '%s\n\n' \
	"Installed .NET 4.6.1"
else
	printf '%s\n\n' \
	".NET 4.6.1 installation failed!"

	printf '%s\n' \
	"Press <Enter> to exit"
	read -r EXITINPUT

	exit 1
fi

printf '%s\n%s\n%s\n' \
"Installing DXVK" \
"This may take a while" \
"You may get some prompts to click on"

if winetricks -q -f dxvk 1>/dev/null 2>/dev/null; then # remove "#>/dev/null" for more verbose output.
	printf '%s\n\n' \
	"Installed DXVK!"
else
	printf '%s\n%s\n%s\n\n' \
	"DXVK installation failed!" \
	"Deleting '$WINEPREFIXTEXT' and re-running this script may help, but make sure you" \
	"have nothing important in '$WINEPREFIXTEXT'!"

	printf '%s\n' \
	"Press <Enter> to exit"
	read -r EXITINPUT

	exit 1
fi

printf '%s\n%s\n%s\n\n' \
"Prefix fully set up! To run SHAR properly, format your input like below" \
"(replace text in [] and remove []):" \
"WINEPREFIX=$WINEPREFIXTEXT wine [PATH-TO-MOD-LAUNCHER]"

printf '%s\n%s\n%s\n\n' \
"To run LiveSplit, run (ditto above with []):" \
"WINEPREFIX=$WINEPREFIXTEXT wine [PATH-TO-LIVESPLIT]" \
"(it is best pracice to run LiveSplit after SHAR has opened)"

printf '%s\n%s\n\n' \
"If '$WINEPREFIXTEXT' starts with a \".\", it will be a hidden directory. Enable" \
"showing hidden files in your file browser of choice to see it."

printf '%s\n' \
"Press <Enter> to exit"
read -r EXITINPUT

exit 0

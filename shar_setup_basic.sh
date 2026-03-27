#!/bin/sh
# This script is for basic installation of a Wine prefix for SHAR. Descriptions of stuff in 'printf' commands below.

WINEPREFIX="$HOME/.wine-shar"
WINEPREFIXTEXT="$(echo "$WINEPREFIX" | sed -e "s|^$HOME|~|g")"
CHOICEERROR=false

WINEALTPREFIX="${XDG_DATA_HOME:-$HOME/.local/share}/wineprefixes/wine-shar"
WINEALTPREFIXLOC="$(echo "$WINEALTPREFIX" | sed -e "s|/wine-shar||g")"
WINEALTPREFIXTEXT="$(echo "$WINEALTPREFIX" | sed -e "s|^$HOME|~|g")"
WINEALTPREFIXLOCTEXT="$(echo "$WINEALTPREFIXLOC" | sed -e "s|^$HOME|~|g")"

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

	printf '%s\n%s\n\n' \
	"Obviously, you will need Wine to be installed on your system to continue. Wine" \
	"can be installed on:"

	printf '%s\n%s\n%s\n\n\n' \
	"Ubuntu: https://wiki.winehq.org/Ubuntu" \
	"Fedora: https://wiki.winehq.org/Fedora" \
	"Arch-based (Arch, Manjaro etc.): run \"sudo pacman -S wine\" in terminal"

	printf '%s\n\n' \
	"You will also need Winetricks. This can be installed on:"

	printf '%s\n%s\n%s\n%s\n\n\n' \
	"Ubuntu: run \"sudo apt install winetricks\"" \
	"Arch-based: run \"sudo pacman -S wine\" in terminal" \
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
			clear ;;
	esac
done

if [ -n "$XDG_DATA_HOME" ] || [ -d "$HOME/.local/share" ]; then
	while true; do
		printf '\n%s\n%s\n%s\n\n\n' \
			"This script will set up a Wine prefix at '$WINEPREFIXTEXT'. Alternatively, you" \
			"can set it up in '$WINEALTPREFIXTEXT'. This is" \
			"considered cleaner as it won't clog up your home directory."

		if [ "$CHOICEERROR" = true ]; then
			printf '%s\n' \
			"Invalid input, enter \"Y\" or \"N\"!"
		else
			printf '%s' \
			"Use '$WINEALTPREFIXLOCTEXT'? [Y/n] "
		fi

		read -r ANSWER
		case $ANSWER in
			[Yy][Ee][Ss]|[Yy])
				CHOICEERROR=false
				if [ ! -d "$WINEALTPREFIXLOC" ]; then
					mkdir "$WINEALTPREFIXLOC" 2>&1 1>/dev/null
				fi

				WINEPREFIX="$WINEALTPREFIX"
				WINEPREFIXTEXT="$WINEALTPREFIXTEXT"

				if [ ! -d "$WINEALTPREFIXLOC" ]; then
					printf "%s\n" \
						"'$WINEALTPREFIXLOCTEXT' doesn't exist/could not be created!"

					printf '%s\n' \
					"Press <Enter> to exit"
					read -r EXITINPUT

					exit 1
				fi


				break ;;
			[Nn][Oo]|[Nn])
				break ;;
			*)
				CHOICEERROR=true
				clear ;;
		esac
	done
fi

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

printf '%s\n' \
"Installing corefonts..." \

if winetricks -q -f corefonts 1>/dev/null 2>/dev/null; then # remove "#>/dev/null" for more verbose output.
	printf '%s\n\n' \
	"Installed corefonts!"
else
	printf '%s\n%s\n%s\n\n' \
	"corefonts installation failed!" \
	"Deleting '$WINEPREFIXTEXT' and re-running this script may help, but make sure you" \
	"have nothing important in '$WINEPREFIXTEXT'!"

	printf '%s\n' \
	"Press <Enter> to exit"
	read -r EXITINPUT

	exit 1
fi

printf '%s\n' \
"Installing GDI+..." \

if winetricks -q -f gdiplus 1>/dev/null 2>/dev/null; then # remove "#>/dev/null" for more verbose output.
	printf '%s\n\n' \
	"Installed GDI+!"
else
	printf '%s\n%s\n%s\n\n' \
	"GDI+ installation failed!" \
	"Deleting '$WINEPREFIXTEXT' and re-running this script may help, but make sure you" \
	"have nothing important in '$WINEPREFIXTEXT'!"

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

printf '%s\n%s\n%s\n\n%s\n' \
"Installing .NET 4.6.1" \
"You may get some prompts to click on" \
"If you don't have enough disk space, installation may fail" \
"This may take a while (at least 5-10+ minutes)..."

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

printf '%s\n%s\n%s\n\n' \
"Prefix fully set up! To run SHAR properly, run the command below:" \
"WINEPREFIX=$WINEPREFIXTEXT wine <PATH-TO-MOD-LAUNCHER>"

printf '%s\n%s\n%s\n\n' \
"To run LiveSplit, run:" \
"WINEPREFIX=$WINEPREFIXTEXT wine <PATH-TO-LIVESPLIT>" \
"(it is best pracice to run LiveSplit after SHAR has opened)"

printf '%s\n%s\n\n' \
"If '$WINEPREFIXTEXT' starts with a \".\", it will be a hidden directory. Enable" \
"showing hidden files in your file browser of choice to see it."

printf '%s\n' \
"Press <Enter> to exit"
read -r EXITINPUT

exit 0

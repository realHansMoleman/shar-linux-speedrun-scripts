#!/bin/sh
# An advanced version of "shar_install_basic.sh", ripping some of the code from
# it. This script adds custom Wine prefix locations via user input, creation of
# a shell script and desktop file if wanted and other additions.

## Variables
WINEPREFIX="${XDG_DATA_HOME:-$HOME/.local/share}/wineprefixes/wine-shar/"
WINEARCH=win32
WINEPREFIXLOC="${XDG_DATA_HOME:-$HOME/.local/share}/wineprefixes/"
FIRSTRUN=true

## Functions
# Function that prompts user to enter variables.
# Asks for which option to choose.
optionschoice() {
	printf '%s\n%s\n%s\n%s\n%s\n%s\n%s\n%s\n%s\n%s\n\n' \
	"Options:" \
	"1) Change Wine prefix location" \
	"2) Set up Wine prefix + .NET + DXVK" \
	"3) Set up Mod Launcher launching script file" \
	"4) Set up Mod Launcher .desktop file" \
	"5) Set up LiveSplit launching script file" \
	"6) Set up LiveSplit .desktop file" \
	"7) Set up Mod Launcher + LiveSplit script file" \
	"8) Set up Mod Launcher + LiveSplit .desktop file" \
	"q) Quit"

	printf '%s' \
	"Choose [1-8 or q]: "

	# Loop for if input is invalid.
	while true; do
		read -r CHOICEANSWER

		case $CHOICEANSWER in
			1)
				wineprefixsetting
				break
				;;
			2)
				wineprefixsetup
				break
				;;
			3)
				launchershellscript
				break
				;;
			4)
				launcherdesktopfile
				break
				;;
			5)
				livesplitshellscript
				break
				;;
			6)
				livesplitdesktopfile
				break
				;;
			7)
				bothscriptfiles
				break
				;;
			8)
				bothdesktopfiles
				break
				;;
			[Qq]|[Qq][Uu][Ii][Tt])
				printf '%s\n' \
				"Exiting."
				exit 0
				;;
			*)
				printf '%s'\
				"Invalid input, choose [1-8 or q]"
		esac
	done
}

wineprefixsetting() {
	# Asks for erasing variables and continuing, exits function on user rejection.
	if [ "$FIRSTRUN" = false ]; then
		printf '\n%s\n%s' \
		"Really change Wine prefix (erases previously entered custom locations" \
		"on confirmation)? [Y/n] "

		read -r ANSWER

		case $ANSWER in
			[Yy][Ee][Ss]|[Yy])
				WINEPREFIX="${XDG_DATA_HOME:-$HOME/.local/share}/wineprefixes/wine-shar/"
				WINEPREFIXLOC="${XDG_DATA_HOME:-$HOME/.local/share}/wineprefixes/"
				printf '\n'
				;;
			*)
				printf '\n'

				optionschoice
				return
				;;
		esac
	fi

	# Asks for location of output.
	printf '\n%s\n\n%s\n%s\n%s\n%s\n\n' \
	"Please enter Wine prefix location" \
	"(Location if left empty or is errorneous:" \
	"'\$XDG_DATA_HOME/wineprefixes/wine-shar/'; or" \
	"'\$HOME/.local/share/wineprefixes/wine-shar/' if \"XDG_DATA_HOME\" is" \
	"unset)"

	printf '%s' \
	"Enter prefix location, relative locations won't work but '~' will!): "

	read -r PREFIXANSWER

	# Sets variable 
	# XDG variables etc. not converted, needs fixing!!!
	if [ -n "$PREFIXANSWER" ] || ! $(echo "$PREFIXANSWER" | grep -q "^\s*$"); then
	WINEPREFIX="$(echo "$PREFIXANSWER" | sed "s|\~|\\$HOME|g")"
	# Attempt at turning relative paths into absolute paths (without using
	# 'realpath' since that will fail on non-existant paths). Needs more work.
#	if ( echo "PREFIXANSWER" | grep -v "^/" ); then
#		PREFIXANSWER="$(echo "$PREFIXANSWER" | sed "s|^|\\$PWD|g;s|\/\.\/|\/|g")"
#	fi
	WINEPREFIXLOC="$(echo "$WINEPREFIX" | sed "s|\(.*\)/..*|\1/|g")"
	fi

	printf '%s\n\n' \
	"Prefix set as $WINEPREFIX"

	# variable to make sure first message of function is outputted only on repeat.
	FIRSTRUN=false
	optionschoice
}

## Wine prefix setup functions
# Function to set up Wine prefix.
wineprefixsetup() {
	# Check and subsequent exit (if true) if prefix location is existing file.
	if [ -f "$WINEPREFIX" ]; then
		printf '\n%s\n\n' \
		"Location is file! Exiting."

		printf '%s\n' \
		"Press [ENTER] to continue."
		read -r DUMP

		optionschoice
		return

	# Checks and asks user about file output overwrite.
	elif [ -d "$WINEPREFIX" ]; then
		printf '%s\n' \
		"$WINEPREFIX exists! Continue? [Y/n] "

		read -r ANSWER

		case $ANSWER in
			[Yy]es|[Yy])
				;;
			*)
				printf '%s\n\n' \
				"Cancelled!"
				optionschoice
				return
				;;
		esac
	fi

	# Asks user for confirmation of setting up Wine prefix.
	printf '%s' \
	"Do you want to create a prefix at $WINEPREFIX? [Y/n] "

	read -r ANSWER

	case $ANSWER in
		[Yy]es|[Yy])
			wineprefixcreate
			;;
		*)
			printf '\n' \
			;;
	esac


	printf '%s' \
	"Install .NET 4.6.1 to prefix? [Y/n] "

	read -r ANSWER

	case $ANSWER in
		[Yy]es|[Yy])
		dotnetinstall
			;;
		*)
			printf '\n'
			;;
	esac

	printf '%s' \
	"Install DXVK to prefix? [Y/n] "

	read -r ANSWER

	case $ANSWER in
		[Yy]es|[Yy])
			dxvkinstall
			optionschoice
			return
				;;
		*)
			printf '%s\n\n' \
			"Finished!"

			optionschoice
			return
			;;
	esac
}

# Function to create Wine prefix.
wineprefixcreate() {
	# Asks user if they want to (recursively) make directory if non-existent.
	if [ ! -d "$WINEPREFIXLOC" ]; then
		printf '%s\n%s' \
		"$WINEPREFIXLOC doesn't exist! Create directory (uses" \
		"'mkdir -p' so will recursively create directories, be careful)? [Y/n]: "
		
		read -r ANSWER

		case $ANSWER in
			[Yy][Ee][Ss]|[Yy])
				if ! mkdir -p "$WINEPREFIXLOC"; then
					printf '%s\n' \
					"Directory creation failed!"

					printf '%s\n' \
					"Press [ENTER] to continue."
					read -r DUMP

					optionschoice
					return
				fi
				;;
			# Follows pacman logic of handling 'yes/no' as opposed to asking for valid
			# input like basic version of this script.
			*)
				optionschoice
				return
				;;
		esac
	fi
	
	printf '%s\n' \
	"Setting up prefix at $WINEPREFIX..."

	# 'wineboot' used to create prefix without any need for user interaction.
	if wineboot 2>/dev/null ; then
		printf '%s\n\n' \
		"Finished setting up Wine prefix in '$WINEPREFIX'"
	else
		printf '%s\n\n' \
		"Failed setting up Wine prefix! Exiting."

		printf '%s\n' \
		"Press [ENTER] to continue."
		read -r DUMP

		optionschoice
		return
	fi
}

# Function to install .NET to Wine prefix.
dotnetinstall() {
	printf '%s\n%s\n' \
	"Installing .NET 4.6.1" \
	"This may take a while (at least 5-10+ minutes)..."

	# Installs .NET 4.6.1 via Winetricks non-verbosely and forcefully (hopefully
	# removes all GUI prompts). Remove "#>/dev/null" for more verbose output.
	if winetricks -q -f dotnet461 1>/dev/null 2>/dev/null ; then
		printf '%s\n\n' \
		"Installed .NET 4.6.1"
	else
		printf '%s\n\n' \
		".NET 4.6.1 installation failed! Exiting!"

		printf '%s\n' \
		"Press [ENTER] to continue."
		read -r DUMP
	fi
}

# Function to install DXVK to Wine prefix.
dxvkinstall() {
	printf '%s\n%s\n' \
	"Installing DXVK" \
	"This may take a while..."

	# Installs DXVK via Winetricks non-verbosely and forcefully (hopefully removes
	# all GUI prompts). Remove "#>/dev/null" for more verbose output.
	if winetricks -q -f dxvk 1>/dev/null 2>/dev/null; then
		printf '%s\n\n' \
		"Installed DXVK!"
	else
		printf '%s\n\n' \
		"DXVK installation failed!"

		printf '%s\n' \
		"Press [ENTER] to continue."
		read -r DUMP
	fi
}

## Script and .desktop functions
# Function to create shell file to Lucas' Mod Launcher if the user chooses.
launchershellscript() {
	# Checks for if the name for what will be the launcher shell script is a
	# directory (why it would ever be a directory I don't know but for the 1 in a
	# million chance it is a directory then it skips the process).
	if [ -d shar_mod_launcher.sh ]; then
		printf '%s\n' \
		"\"shar_mod_launcher.sh\" is directory, not going to ask for creation."

		printf '%s\n' \
		"Press [ENTER] to continue."
		read -r DUMP

		optionschoice
		return
	fi

	if [ -f shar_mod_launcher.sh ]; then
		printf '\n%s' \
		"File already exists. Overwrite? [Y/n] "
		
		read -r ANSWER

		case $ANSWER in
			[Yy][Ee][Ss]|[Yy])
				;;
			*)
				printf '%s\n' \
				"Press [ENTER] to continue."
				read -r DUMP

				optionschoice
				return
				;;
		esac
	fi

	printf '\n%s' \
	"Enter Lucas' Mod Launcher filepath: "

	read -r LMLPATH
	
	# Creates (or overwrites) shell script with relevant information.
	if printf '%s\n%s' \
	"#!/bin/sh" \
	"WINEPREFIX=\"$WINEPREFIX\" wine \"$LMLPATH\"" > shar_mod_launcher.sh; then
		printf '\n%s\n%s\n%s\n\n' \
		"Successfully created shar_mod_launcher.sh!" \
		"Make sure to change it to be executable" \
		"(can be done with \"chmod +x shar_mod_launcher.sh\")."

		printf '%s\n' \
		"Press [ENTER] to continue."
		read -r DUMP
	else
		printf '\n%s\n\n' \
		"Failed to create shar_mod_launcher.sh!"

		printf '%s\n' \
		"Press [ENTER] to continue."
		read -r DUMP
	fi

	optionschoice
}

launcherdesktopfile() {
	# Checks if XDG_DESKTOP_DIR is set, otherwise set loc as current directory.
	if [ -n "$XDG_DESKTOP_DIR" ]; then
		DESKTOPFILELOC="$XDG_DESKTOP_DIR"
	else
		DESKTOPFILELOC="$PWD"
	fi

	# Asks for input from user for output directory.
	printf '%s\n\n' \
	"Please enter which directory you want the file to be created: "

	printf '%s\n%s\n%s\n\n' \
	"(Location if left empty:" \
	"$XDG_DESKTOP_DIR; or" \
	"$PWD if \"\$XDG_DESKTOP_DIR\" is unset)"

	printf '%s' \
	"Enter location: "

	read -r DESKTOPFILELOCANSWER

	# Checks if user-entered string is empty, uses answer if not.
	# I have no idea if "*" works in test commands.
	if [ -n "$DESKTOPFILELOCANSWER" ] && [ "$DESKTOPFILELOCANSWER" != " *" ]; then
		DESKTOPFILELOC="$DESKTOPFILELOCANSWER"
	fi

	# Checks if directory exists/file output is directory, both exit function if true.
	if [ -d "$DESKTOPFILELOC/lucas_mod_launcher.desktop" ]; then
		printf '\n%s\n' \
		"File output is directory! Aborting."

		printf '%s\n' \
		"Press [ENTER] to continue."
		read -r DUMP

		optionschoice
		return

	elif [ ! -d "$DESKTOPFILELOC" ]; then
		printf '\n%s\n' \
		"Creation failed! Directory not found."

		printf '%s\n' \
		"Press [ENTER] to continue."
		read -r DUMP

		optionschoice
		return
	fi

	# Checks for file overwrite and asks user whether to continue or not. These
	# checks need to fix "./" etc. outputting 2 '/'s, only a minor issue though and
	# will probably only need a 'sed' command but not added just in case I think of
	# any complications later on and this issue doesn't have any real effect.
	if [ -f "$DESKTOPFILELOC/lucas_mod_launcher.desktop" ] ; then
		printf '%s' \
		"'$DESKTOPFILELOC/lucas_mod_launcher.desktop' exists! Overwrite? [Y/n] "

		read -r ANSWER

		case $ANSWER in
			[Yy][Ee][Ss]|[Yy])
				;;
			[Nn][Oo]|[Nn])
				optionschoice
				return
				;;
		esac
	fi

	# Asks user for LML location.
	printf '\n%s' \
	"Enter Lucas' Mod Launcher filepath: "

	read -r LMLPATH

	printf '%s\n%s\n\n%s' \
	"Choose an icon to use (likely best to leave this field blank and instead use" \
	"your desktop environment's specific method to change icons)." \
	"Enter icon: "

	read -r ICON

	# LML .desktop file creation.
	if printf '%s\n%s\n%s\n%s\n%s\n' \
	"[Desktop Entry]" \
	"Name=Lucas' Mod Launcher" \
	"Exec=env WINEPREFIX=\"$WINEPREFIX\" wine '$LMLPATH'" \
	"Type=Application" \
	"Icon=$ICON" \
	> "$DESKTOPFILELOC/lucas_mod_launcher.desktop"; then
		printf '\n%s\n%s\n%s\n%s\n\n' \
		"LiveSplit .desktop file created!" \
		"Make sure to change it to be executable" \
		"(can be done with cd'ing to output directory then running \"chmod +x" \
		"livesplit.desktop\")."

		printf '%s\n' \
		"Press [ENTER] to continue."
		read -r DUMP

		optionschoice
		return
	else
		printf '%s\n\n' \
		"Mod Launcher .desktop file creation failed!"

		printf '%s\n' \
		"Press [ENTER] to continue."
		read -r DUMP

		printf '\n'

		optionschoice
		return
	fi
}

livesplitshellscript() {
	# Checks if file output is directory, exits if true.
	if [ -d livesplit.sh ]; then
		printf '%s\n' \
		"\"livesplit.sh\" is directory, not going to ask for creation."

		printf '%s\n' \
		"Press [ENTER] to continue."
		read -r DUMP

		optionschoice
		return
	fi

	if [ -f livesplit.sh ]; then
		printf '\n%s' \
		"File already exists. Overwrite? [Y/n] "
		
		read -r ANSWER

		case $ANSWER in
			[Yy][Ee][Ss]|[Yy])
				;;
			*)
				printf '%s\n' \
				"Press [ENTER] to continue."
				read -r DUMP

				optionschoice
				return
				;;
		esac
	fi

	printf '\n%s' \
	"Enter LiveSplit filepath: "

	read -r LIVESPLITPATH
	
	# Creates (or overwrites) shell script with relevant information.
	if printf '%s\n%s' \
	"#!/bin/sh" \
	"WINEPREFIX=\"$WINEPREFIX\" wine \"$LIVESPLITPATH\"" > livesplit.sh; then
		printf '\n%s\n%s\n%s\n\n' \
		"Successfully created livesplit.sh!" \
		"Make sure to change it to be executable" \
		"(can be done with \"chmod +x livesplit.sh\")."

		printf '%s\n' \
		"Press [ENTER] to continue."
		read -r DUMP
	else
		printf '\n%s\n\n' \
		"Failed to create livesplit.sh!"

		printf '%s\n' \
		"Press [ENTER] to continue."
		read -r DUMP
	fi

	optionschoice
}

livesplitdesktopfile() {
	# Checks if XDG_DESKTOP_DIR is set, otherwise set loc as current directory.
	if [ -n "$XDG_DESKTOP_DIR" ]; then
		DESKTOPFILELOC="$XDG_DESKTOP_DIR"
	else
		DESKTOPFILELOC="$PWD"
	fi

	# Asks for input from user for output directory.
	printf '%s\n\n' \
	"Please enter which directory you want the file to be created: "

	printf '%s\n%s\n%s\n\n' \
	"(Location if left empty:" \
	"$XDG_DESKTOP_DIR; or" \
	"$PWD if \"\$XDG_DESKTOP_DIR\" is unset)"

	printf '%s' \
	"Enter location: "

	read -r DESKTOPFILELOCANSWER

	# Checks if string is empty, if not then uses answer.
	if [ -n "$DESKTOPFILELOCANSWER" ] && [ "$DESKTOPFILELOCANSWER" != " *" ]; then
		DESKTOPFILELOC="$DESKTOPFILELOCANSWER"
	fi

	# Checks if directory exists/file output is directory, both exit function if true.
	if [ -d "$DESKTOPFILELOC/livesplit.desktop" ]; then
		printf '\n%s\n' \
		"File output is directory! Aborting."

		printf '%s\n' \
		"Press [ENTER] to continue."
		read -r DUMP

		optionschoice
		return

	elif [ ! -d "$DESKTOPFILELOC" ]; then
		printf '\n%s\n' \
		"Creation failed! Directory not found."

		printf '%s\n' \
		"Press [ENTER] to continue."
		read -r DUMP

		optionschoice
		return
	fi

	# Asks user about overwriting file if it exists.
	if [ -f "$DESKTOPFILELOC/livesplit.desktop" ] ; then
		printf '%s' \
		"'$DESKTOPFILELOC/livesplit.desktop' exists! Overwrite? [Y/n] "

		read -r ANSWER

		case $ANSWER in
			[Yy][Ee][Ss]|[Yy])
				;;
			[Nn][Oo]|[Nn])
				optionschoice
				return
				;;
		esac
	fi

	# Asks for LiveSplit filepath.
	printf '\n%s' \
	"Enter LiveSplit.exe filepath: "

	read -r LIVESPLITPATH

	printf '%s\n%s\n\n%s' \
	"Choose an icon to use (likely best to leave this field blank and instead use" \
	"your desktop environment's specific method to change icons)." \
	"Enter icon: "

	read -r ICON

	# LiveSplit .desktop file creation.
	if printf '%s\n%s\n%s\n%s\n%s\n' \
	"[Desktop Entry]" \
	"Name=LiveSplit" \
	"Exec=env WINEPREFIX=\"$WINEPREFIX\" wine '$LIVESPLITPATH'" \
	"Type=Application" \
	"Icon=$ICON" \
	> "$DESKTOPFILELOC/livesplit.desktop"; then
		printf '\n%s\n%s\n%s\n%s\n\n' \
		"LiveSplit .desktop file created!" \
		"Make sure to change it to be executable" \
		"(can be done with cd'ing to output directory then running \"chmod +x" \
		"livesplit.desktop\")."

		printf '%s\n' \
		"Press [ENTER] to continue."
		read -r DUMP

		optionschoice
		return
	else
		printf '%s\n' \
		"LiveSplit .desktop file creation failed!"

		printf '%s\n' \
		"Press [ENTER] to continue."
		read -r DUMP

		optionschoice
		return
	fi
}

bothscriptfiles() {
	# Asks user for 2 separate shell scripts or combined script.
	printf '%s\n%s\n%s\n\n' \
	"You can either create 2 separate shell script files or create one that opens" \
	"Lucas' Mod Launcher and waits for the actual game to launch before opening" \
	"LiveSplit."
	
	printf '%s\n%s\n' \
	"1) Create 2 seperate files" \
	"2) Create 1 file"

	printf '%s' \
	"Choose option: "

	read -r COMBINEDSHELLANSWER

	case $COMBINEDSHELLANSWER in
		1)
			;;
		2)
			;;
		*)
			optionschoice
			return
			;;
	esac

	# Asks for LML and LiveSplit locations.
	printf '%s' \
	"Enter Mod Launcher file path: "

	read -r LMLPATH

	printf '%s' \
	"Enter LiveSplit file path: "

	read -r LIVESPLITPATH

	case $COMBINEDSHELLANSWER in
		# Case for 2 separate files.
		1)
			# Check for if file outputs are directories, exits function if true.
			if [ -d "lucas_mod_launcher.sh" ]; then
				printf '%s\n\n' \
				"'lucas_mod_launcher.sh' is directory! Exiting."

				printf '%s\n' \
				"Press [ENTER] to continue."
				read -r DUMP

				optionschoice
				return

			elif  [ -d "livesplit.sh" ] ; then
				printf '%s\n\n' \
				"'livesplit.sh' is directory! Exiting."

				printf '%s\n' \
				"Press [ENTER] to continue."
				read -r DUMP

				optionschoice
				return
			fi

			# Checks for if file output points to existing file and asks for overwrite.
			if [ -f "lucas_mod_launcher.sh" ] ; then
				printf '%s' \
				"'lucas_mod_launcher.sh' exists! Overwrite? [Y/n] "

				read -r ANSWER

				case $ANSWER in
					[Yy][Ee][Ss]|[Yy])
						;;
					[Nn][Oo]|[Nn])
						optionschoice
						return
						;;
				esac
			fi

			if [ -f "livesplit.sh" ] ; then
				printf '%s' \
				"'livesplit.sh' exists! Overwrite? [Y/n] "

				read -r ANSWER

				case $ANSWER in
					[Yy][Ee][Ss]|[Yy])
						;;
					[Nn][Oo]|[Nn])
						printf '%s\n' \
						"Press [ENTER] to continue."
						read -r DUMP

						optionschoice
						return
						;;
				esac
			fi

			# Creates both files, exits function on error.
			if printf '%s\n%s\n%s' \
			"#!/bin/sh" \
			"WINEPREFIX=\"$WINEPREFIX\"" \
			"wine \"$LMLPATH\"" \
			> shar_mod_launcher.sh; then
				printf '%s\n' \
				"Mod Launcher shell script file created!"
			else
				printf '%s\n' \
				"Mod Launcher shell script file creation failed!"

				printf '%s\n' \
				"Press [ENTER] to continue."
				read -r DUMP

				optionschoice
				return
			fi

			if printf '%s\n%s%s\n' \
			"#!/bin/sh" \
			"WINEPREFIX=\"$WINEPREFIX\"" \
			"wine \"$LIVESPLITPATH\"" \
			> livesplit.sh; then
				printf '%s\n' \
				"LiveSplit shell script file created!"

				printf '%s\n' \
				"Press [ENTER] to continue."
				read -r DUMP

				optionschoice
				return
			else
				printf '%s\n' \
				"LiveSplit shell script file creation failed!"

				printf '%s\n' \
				"Press [ENTER] to continue."
				read -r DUMP

				optionschoice
				return
			fi
			;;
		2)
			# Check for if output file is directory.
			if [ -d "shar_launch.sh" ]; then
				printf '%s\n\n' \
				"'shar_launch.sh' is directory! Exiting."

				printf '%s\n' \
				"Press [ENTER] to continue."
				read -r DUMP

				optionschoice
				return
			fi

			# Checks for overwrite and asks user.
			 if [ -f "shar_launch.sh" ]; then
				printf '%s\n' \
				"File exists, overwrite?"

				read -r ANSWER

				case $ANSWER in
					[Yy][Ee][Ss]|[Yy])
						;;
					[Nn][Oo]|[Nn])
						optionschoice
						return
						;;
				esac
			fi

				if printf '%s\n%s\n%s\n%s\n%s\n%s\n%s\n%s\n%s\n%s\n%s\n%s' \
				"#!/bin/sh" \
				"WINEPREFIX=\"$WINEPREFIX\"" \
				"setsid -f wine \"$LMLPATH\" 1>/dev/null 2>/dev/null" \
				"echo \"Waiting for SHAR to be open...\"" \
				"while true; do" \
				"	if pgrep Simpsons.exe; then" \
				"		setsid -f \"$LIVESPLITPATH\" 1>/dev/null 2>/dev/null" \
				"		echo \"You can now exit this script.\"" \
				"	else" \
				"		sleep 5" \
				"	fi" \
				"done" \
				> "shar_launch.sh"; then
					printf '%s\n%s\n\n' \
					"Mod launcher shell script created!" \
					"LiveSplit will wait to launch after SHAR launches."

					printf '%s\n%s\n\n' \
					"Make sure to change the script to be executable" \
					"(can be done with \"chmod +x shar_launch.sh\")."

					printf '%s\n' \
					"Press [ENTER] to continue."
					read -r DUMP

					optionschoice
					return
				else
					printf '%s\n\n' \
					"Creation failed!"

					printf '%s\n' \
					"Press [ENTER] to continue."
					read -r DUMP

					optionschoice
					return
				fi
	esac
}

bothdesktopfiles() {
	# Directory of file output
	DESKTOPFILELOC=${XDG_DESKTOP_DIR:-$PWD}
	# Used for asking user for overwrite later. Needs to be a variable as this
	# function's specific overwrite code is dependant on another variable and
	# overwrite needs a separate 'if' statement. Probably a better way to do it so
	# contribute if you want!!! Set to false here to act as a reset in case no
	# overwrite is needed.
	OVERWRITEASK="false"

	# No. of files choice.
	printf '%s\n%s\n\n' \
	"You can either create 2 separate .desktop files or create one that opens one" \
	"program and has a right-click option to open the other."

	printf '%s\n%s\n' \
	"1) Create 1 combined file" \
	"2) Create 2 separate files"

	printf '%s' \
	"Choose option: "

	read -r COMBINEDANSWER

	case $COMBINEDANSWER in
		1)
			;;
		2)
			;;
		*)
			return
			;;
	esac

	# Location choice.
	printf '%s\n%s\n%s\n%s\n\n' \
	"Please enter location to create file(s)" \
	"(Location if left empty:" \
	"'\$XDG_DESKTOP_DIR'; or" \
	"current directory if \"XDG_DESKTOP_DIR\" is unset"

	printf '%s' \
	"Enter file(s) location: "

	read -r DESKTOPFILELOCANSWER

	# Check for if input was empty (empty includes single space, probably could be improved).
	if [ -n "$DESKTOPFILELOCANSWER" ] && [ "$DESKTOPFILELOCANSWER" != " *" ]; then
		DESKTOPFILELOC=$DESKTOPFILELOCANSWER
	fi

	# LML path input.
	printf '%s' \
	"Enter Mod Launcher file path: "

	read -r LMLPATH

	# LiveSplit path input.
	printf '%s' \
	"Enter LiveSplit file path: "

	read -r LIVESPLITPATH

	case $COMBINEDANSWER in
		# Case for creation of 1 file.
		1)
			# Asks which program is primary and which is secondary (has to be opened with
			# right-click).
			printf '%s\n\n' \
			"Which program would you like to open with left-click?"

			printf '%s\n%s\n\n' \
			"1) Lucas' Mod Launcher" \
			"2) LiveSplit"

			printf '%s' \
			"Please select 1 or 2: "

			read -r COMBINEDPRIORITY

			# Check for if file outputs are directories and exits function if true.
			if [ "$COMBINEDPRIORITY" = "1" ] && [ -d "$DESKTOPFILELOC/lucas_mod_launcher.desktop" ]; then
				printf '%s\n\n' \
				"'$DESKTOPFILELOC/lucas_mod_launcher.desktop' is directory! Exiting."

				printf '%s\n' \
				"Press [ENTER] to continue."
				read -r DUMP

				optionschoice
				return

			elif [ "$COMBINEDPRIORITY" = "2" ] && [ -d "$DESKTOPFILELOC/livesplit.desktop" ] ; then
				printf '%s\n\n' \
				"'$DESKTOPFILELOC/livesplit.desktop' is directory! Exiting."

				printf '%s\n' \
				"Press [ENTER] to continue."
				read -r DUMP

				optionschoice
				return
			fi

			# Check for if files exist and asks for overwrite.
			if [ "$COMBINEDPRIORITY" = "1" ] && [ -f "$DESKTOPFILELOC/lucas_mod_launcher.desktop" ]; then
				printf '%s' \
				"'lucas_mod_launcher.desktop' exists, overwrite? [Y/n] "
				OVERWRITEASK="true"

			elif [ "$COMBINEDPRIORITY" = "2" ] && [ -f "$DESKTOPFILELOC/livesplit.desktop" ]; then
				printf '%s' \
				"'livesplit.desktop' exists, overwrite? [Y/n] "
				OVERWRITEASK="true"
			fi

			if [ $OVERWRITEASK = "true" ]; then
				read -r ANSWER

				case $ANSWER in
					[Yy][Ee][Ss]|[Yy])
						;;
					[Nn][Oo]|[Nn])
						optionschoice
						return
						;;
				esac
			fi

			printf '%s\n%s\n\n%s' \
			"Choose an icon to use (likely best to leave this field blank and instead use" \
			"your desktop environment's specific method to change icons)." \
			"Enter icon: "

			read -r ICON

			printf '\n%s\n%s' \
			"Choose an icon to use for the secondary action" \
			"(again same caveats as above): "

			read -r ICON2

			case $COMBINEDPRIORITY in
				# Creates files, structured based on earlier priority choice, exits function on
				# error.
				1)
					if printf '%s\n%s\n%s\n%s\n%s\n%s\n\n%s\n%s\n%s\n%s\n' \
					"[Desktop Entry]" \
					"Name=Lucas' Mod Launcher" \
					"Exec=env WINEPREFIX=\"$WINEPREFIX\" wine '$LMLPATH'" \
					"Actions=LiveSplit" \
					"Type=Application" \
					"Icon=$ICON" \
					"[Desktop Action LiveSplit]" \
					"Name=Open LiveSplit" \
					"Exec=env WINEPREFIX=\"$WINEPREFIX\" wine '$LIVESPLITPATH'" \
					"Icon=$ICON2" \
					> "$DESKTOPFILELOC/lucas_mod_launcher.desktop"; then
						printf '%s\n' \
						"Success!"

						printf '%s\n' \
						"Press [ENTER] to continue."
						read -r DUMP

						optionschoice
						return
					else
						printf '%s\n' \
						"Creation failed!"

						printf '%s\n' \
						"Press [ENTER] to continue."
						read -r DUMP

						optionschoice
						return
					fi
					;;
				2)
					if printf '%s\n%s\n%s\n%s\n%s\n%s\n\n%s\n%s\n%s\n%s\n' \
					"[Desktop Entry]" \
					"Name=Open LiveSplit" \
					"Exec=env WINEPREFIX=\"$WINEPREFIX\" wine '$LIVESPLITPATH'" \
					"Type=Application" \
					"Actions=LML" \
					"Icon=$ICON" \
					"[Desktop Action LML]" \
					"Name=Lucas' Mod Launcher" \
					"Exec=env WINEPREFIX=\"$WINEPREFIX\" wine '$LMLPATH'" \
					"Icon=$ICON2" \
					> "$DESKTOPFILELOC/lucas_mod_launcher.desktop"; then
						printf '%s\n' \
						"Success!"

						printf '%s\n' \
						"Press [ENTER] to continue."
						read -r DUMP

						optionschoice
						return
					else
						printf '%s\n' \
						"Creation failed!"

						printf '%s\n' \
						"Press [ENTER] to continue."
						read -r DUMP

						optionschoice
						return
					fi
					;;
			esac
			;;
		# Case for creation of 2 separate files.
		2)
			# Checks for if file output points to existing directory and exits function.
			if [ -d "$DESKTOPFILELOC/lucas_mod_launcher.desktop" ]; then
				printf '%s\n\n' \
				"'$DESKTOPFILELOC/lucas_mod_launcher.desktop' is directory! Exiting."

				printf '%s\n' \
				"Press [ENTER] to continue."
				read -r DUMP

				optionschoice
				return
			elif [ -d "$DESKTOPFILELOC/livesplit.desktop" ] ; then
				printf '%s\n\n' \
				"'$DESKTOPFILELOC/livesplit.desktop' is directory! Exiting."

				printf '%s\n' \
				"Press [ENTER] to continue."
				read -r DUMP

				optionschoice
				return
			fi

			# Checks for if file output points to existing file and asks for overwrite.
			if [ -f "$DESKTOPFILELOC/lucas_mod_launcher.desktop" ] ; then
				printf '%s' \
				"'$DESKTOPFILELOC/lucas_mod_launcher.desktop' exists! Overwrite? [Y/n] "

				read -r ANSWER

				case $ANSWER in
					[Yy][Ee][Ss]|[Yy])
						;;
					[Nn][Oo]|[Nn])
						optionschoice
						return
						;;
				esac
			fi

			if [ -f "$DESKTOPFILELOC/livesplit.desktop" ] ; then
				printf '%s' \
				"'$DESKTOPFILELOC/livesplit.desktop' exists! Overwrite? [Y/n] "

				read -r ANSWER

				case $ANSWER in
					[Yy][Ee][Ss]|[Yy])
						;;
					[Nn][Oo]|[Nn])
						optionschoice
						return
						;;
				esac
			fi

			# Writes to files and aborts function if it fails.
			if [ -f "$DESKTOPFILELOC/livesplit.desktop" ] ; then
				printf '%s' \
				"'$DESKTOPFILELOC/livesplit.desktop' exists! Overwrite? [Y/n] "

				read -r ANSWER

				case $ANSWER in
					[Yy][Ee][Ss]|[Yy])
						;;
					[Nn][Oo]|[Nn])
						optionschoice
						return
						;;
				esac
			fi

			printf '%s\n%s\n%s\n\n%s' \
			"Choose an icon to use for the Mod Launcher (likely best to leave this field" \
			"blank and instead use your desktop environment's specific method to change" \
 			"icons)." \
			"Enter icon: "

			read -r ICON

			printf '\n%s\n%s' \
			"Choose an icon to use for Livesplit" \
			"(again same caveats as above): "

			read -r ICON2

			# LML .desktop file creation.
			if printf '%s\n%s\n%s\n%s\n%s\n' \
			"[Desktop Entry]" \
			"Name=Lucas' Mod Launcher" \
			"Exec=env WINEPREFIX=\"$WINEPREFIX\" wine '$LMLPATH'" \
			"Type=Application" \
			"Icon=$ICON" \
			> "$DESKTOPFILELOC/lucas_mod_launcher.desktop"; then
				printf '%s\n' \
				"Mod Launcher .desktop file created!"
			else
				printf '%s\n' \
				"Mod Launcher .desktop file creation failed!"

				printf '%s\n' \
				"Press [ENTER] to continue."
				read -r DUMP

				optionschoice
				return
			fi

			# LiveSplit .desktop file creation.
			if printf '%s\n%s\n%s\n%s\n%s\n' \
			"[Desktop Entry]" \
			"Name=Open LiveSplit" \
			"Exec=env WINEPREFIX=\"$WINEPREFIX\" wine '$LIVESPLITPATH'" \
			"Type=Application" \
			"Icon=$ICON2" \
			> "$DESKTOPFILELOC/lucas_mod_launcher.desktop"; then
				printf '%s\n' \
				"LiveSplit .desktop file craeated!"

				printf '%s\n' \
				"Press [ENTER] to continue."
				read -r DUMP

				optionschoice
				return
			else
				printf '%s\n' \
				"LiveSplit .desktop file creation failed!"

				printf '%s\n' \
				"Press [ENTER] to continue."
				read -r DUMP

				optionschoice
				return
			fi
			;;
	esac
}

# Main script (yes it really is only 4 lines)
printf '%s\n%s\n' \
"This script is a much more advanced version of the basic version. Use the" \
"basic version if you are new to Linux."

wineprefixsetting

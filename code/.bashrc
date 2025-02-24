# bash -c zsh

# colours
# use like:
# echo "${RED} red text ${NORMAL} normal text"
BLACK=$(tput setaf 0)
RED=$(tput setaf 1)
GREEN=$(tput setaf 2)
LIME_YELLOW=$(tput setaf 190)
YELLOW=$(tput setaf 3)
POWDER_BLUE=$(tput setaf 153)
BLUE=$(tput setaf 4)
MAGENTA=$(tput setaf 5)
CYAN=$(tput setaf 6)
WHITE=$(tput setaf 7)
BRIGHT=$(tput bold)
NORMAL=$(tput sgr0)
BLINK=$(tput blink)
REVERSE=$(tput smso)
UNDERLINE=$(tput smul)

alias src=". ~/.bashrc"

# pnputil cmds dont work with pwsh's sudo but do work with bashs gsudo
mouse() {
    if [[ "${1,,}" == "d" ]]; then
        # disable mouse
        bwsh "pnputil /disable-device '<UID>'"
    elif [[ "${1,,}" == "e" ]]; then
        # enable mouse
        bwsh "pnputil /enable-device '<UID>'"
    else
        echo "${RED}<error>${NORMAL} mouse function needs a 'd' or 'e' argument to disable or enable respectively${RED}<exiting>"
    fi
}

# set <app> sound to <device>
# <device> names: speakers, headphones, default etc
# note2self: chromium is still chrome.exe
# SoundVolumeView.exe /SetAppDefault [Name] [Default Type] [Process Name/ID]
svv() {
    # todo: default device assumed to be speakers
    if [[ $# -lt 2 ]] ; then
        echo "${RED}<error>${NORMAL} svv needs a device first argument and n app arguments ${RED}<exiting>"
    else
        # loop over args starting from index 2 
        for app in "${@:2}"; do
            bwsh "SoundVolumeView.exe /SetAppDefault 'High Definition Audio Device\Device\\${1}\Render' all ${app}.exe"
        done
    fi
}

# diff two dirs recursively
#  diff -ur <path> <path>
# get files only found in second dir
# comm -13 <(cd <path> && find -type f | sort) <(cd <path> && find -type f | sort)
# remove paths to double check we only talking about file differences here not just a dir change
# comm -13 <(cd <path> && find -type f -execdir echo {} ';' | sort) <(cd <path> && find -type f -execdir echo {} ';' | sort)

# find lowhyph files and pipe to vlc queue
# works for hc-wxf1m files cos they all caps and no spaces
qvlc() {
    find . -name "*[a-z]*.MP4" -type f | xargs vlc
}

# lowercase, condense spaces, hypenenate!
# idea: turn this kind of function that uses pipes into a template
#       basically: if (pipe condition) { return read data } else {return $@ }
lowhyph() {
    if (( $# == 0 )) ; then
        # use piped input
        # idea: learn how to check for piped input before running code blindly lol
        while read data; do
            echo "${data,,}" | tr -s " " | tr " " "-"
        done
    else
        # use function parameters as input
        echo "${@,,}" | tr -s " " | tr " " "-"
    fi
}

# get processes
getproc() {
    # if we return a pwsh object then can perhaps access .ProcessName from bash somehow
    bwsh "Get-Process | Where-Object { \$_.ProcessName -like '*$1*' }" # | Out-String
}

# get process name
getprocname() {
    bwsh "(Get-Process | Where-Object { \$_.ProcessName -like '*$1*' }).ProcessName"
}

# kill processes by name
# taskkill /im <name-of-exe> /f
killproc() {
    bwsh "sudo taskkill /im $(getprocname "${1}").exe /f"
}

# git
alias gitlog="git log --all --decorate --oneline --graph"

gitrev() {
    if [[ $# -eq 0 ]] ; then
        echo "${RED}<error>${NORMAL} gitrev needs a commit id argument to run ${RED}<exiting>"
    else
        git revert --no-commit "${1}..HEAD"
        git commit -am "gitrevved to ${1}"
    fi
}

# web greppin'
# run in a directory containing downloaded website files
# alt approach to download it all first
# usage: webgrep <url> <pattern>
webgrep() {
    # download ENTIRE website (extremely verbose)
    # wget --no-clobber --convert-links --random-wait -r -p -E -e robots=off -U mozilla ./LOCAL/DIR http://site/path/
    
    # download sensible amount of website
    # (actually still downloads heaps, need a timeout or recurse limit etc)
    wget -m -p -E -k -K -np ./webgrep "${1}"

    # parsing idea: we dont want to follow and download front facing urls (to different parts of the site)
    # sometimes we only want all the necessary files to make the target page load and function
    # to do this could use the <p> or <h1> or <div> etc front facing html elements as indicators
    # could also try a brute recurse limit
    
    # cd to web files
    cd ./webgrep
    
    # html greppin'
    # only match lines that are 255 characters or less
    # helps exclude output-clogging minified files etc
    grep -i -r -x ".\{1,255\}${2}.\{1,255\}" *
}

clamtime() {
    # install and start daemon
    clamd --install
    net start clamd
    # update definitions
    freshclam
    # run using gsudo in bash
    # --fdpass (does this even help? research file permission errors)
    # "$EUID"
    find /c/ -printf '%f\n' | xargs clamdscan --multiscan --suppress-ok-results > "some/path/clamtime.log"
}

# get exclusion paths from defender (todo: add a get/set switch)
alias exclusions="bwsh 'Get-MpPreference | Select-Object -Property ExclusionPath -ExpandProperty ExclusionPath'"

# get $path line by line
# syntax requires single-quote alias cmd wrapper and doublequotes inside cmd
alias ppath='echo $PATH | tr : "\n"'

# return maximum metadata values
exifall() {
    exiftool -ee3 -U -G3:1 -api requestall=3 -api largefilesupport "$1"
}

# coin flip
coinflip() {
    (( RANDOM % 2 )) && echo "$1" || echo "$2"
}

# list filesizes of dir contents
alias dirsize="du -sh * | sort -h"

# call pwsh from bash
bwsh() {
    pwsh -Command "$@"
}

# create new toast notification via pwsh
newtoast() {
    bwsh "New-BurntToastNotification -Text '$@'"
}

# fix teredo state via pwsh
teredofix() {
    bwsh "sudo netsh interface teredo set state type=enterpriseclient"
}

# full ip reset and fix teredo state via pwsh
ipfreely() {
    # cmd /k ./jimip.bat
    # how to better handle multiple sudo calls?
    bwsh "sudo ipconfig /release"
    bwsh "sudo ipconfig /release6"
    bwsh "sudo ipconfig /renew"
    bwsh "sudo ipconfig /renew6"
    bwsh "sudo ipconfig /flushdns"
    bwsh "sudo ipconfig /displaydns"
    teredofix
}

# full scoop update
# only git cannot be updated via this function as git bash is running
scoopclean() {
    powershell.exe -c "scoop update pwsh"
    # how to better handle multiple sudo calls?
    bwsh scoop-clean.ps1
    # call takeown.exe recursively and hide all terminal spam
    ( bwsh "sudo takeown /r /d y /f C:\scoop\apps\7zip > /dev/null 2>&1 & " > /dev/null 2>&1 & ) | grep -vi success
}

# dcr-sr45 convert and sort
# assumption: files directly imported from camera always use capital letter extensions
dcrsr45() {
    if [ "$#" -ge 2 ]; then
        # use args to determine ffmpeg cmd to run
        
        # audio
        if [[ "${1,,}" == "src" ]]; then
            # source copy audio
            ca="copy"
        elif [[ "${1,,}" == "aac" ]]; then
            # convert AC3 audio to aac
            ca="aac -b:a 192k"
        else
            echo "[ERROR] supplied audio encoding argument '$1' is missing, malformed, or not recognised"
        fi

        # video
        if [[ "$2" == "src" ]]; then
            # source copy video
            cv="copy"
        elif [[ "$2" == "x264" ]]; then
            # encode as libx264 (+aac encode if needed)
            cv="libx264 -movflags +faststart -preset veryslow -crf 17 -vf yadif=1"
        fi

        # run computed ffmpeg cmd
        echo -e "run computed ffmpeg cmd:\nffmpeg -i <input.ext> -c:v $cv -c:a $ca <output.mp4>\n"
        for file in *.MPG; do ffmpeg -i "$file" -c:v $cv -c:a $ca "./${file%.*}".mp4; done

        # move outputted mp4s
        if [ ! -d "src" ]; then
            mkdir src
        fi
        mv *.MPG ./src
    else
        echo -e "[ERROR] please supply src/aac for audio encoding type as first argument and src/x264 video encoding type as second argument"
    fi
}

# invert operations for E:\ssd\vegas\dcrsr45-v2
# readarray -d '' sfks_dir < <(find "$home" -iname "*.mp4.sfk" -type f -printf '%h\n' | sort -u)
# readarray -d '' sfks < <(find "$home" -iname "*.mp4.sfk" -type f)
# readarray -d '' sfks_base < <(find "$home" -iname "*.mp4.sfk" -type f -exec basename \{\} .mp4.sfk \; )
dcrsr45_sfk() {
    # home dir for v2 copy of project dir
    home="/c/dir1"
    # manual collection of dirs that contain .sfk project files
    sfks_dir=("/c/dir1 /c/dir2")
    # for every sfk project file get extensionless basename to match to .MPG or .mp4
    sfks_base=$(find "$home" -iname "*.mp4.sfk" -type f -exec basename \{\} .mp4.sfk \;)
    # loop through sfk-containing dirs
    for sfk in "${sfks_dir[@]}"; do
        # if sfk dir has a ./mpg/ folder expect relevant MPG's to be inside
        if [[ -d "${sfk}/mpg" ]]; then
            # move to ./mpg/ dir
            cd "${sfk}/mpg"
            # loop through source MPG's
            for file in *.MPG; do
                # get extensionless MPG filename
                base=$(basename "$file" .MPG)
                # if MPG filename matches a sfk filename
                if [[ "$sfks_base" =~ "$base" ]]; then
                    # source video + aac audio encode and replace old mp4 with source-copied mp4
                    ffmpeg -y -i "$file" -c:v copy -c:a aac "../${file%.*}".mp4
                fi
            done
        else
            # catch sfk's that aren't associated with a ./mpg/ MPG file
            echo "sfk-dir has no ./mpg/ dir: $sfk"
            echo "$sfk" >> "$home/sfk-mpg-exceptions.txt"
        fi
    done
}

# search notes
notes() {
    grep -niRF "$1" --exclude-dir=me <path>
}

# search historical bookmarks
bookmarks() {
    grep -hiPoR '(?<=href=")[^"]*' path/to/bookmarks | grep "$1" # | sort -u
    # idea: try return a whole section aka a folder of bookmarks somehow
    #       itll be different for html vs json etc
    #       should be predictable strings to target
    #       tracing nesting will be ugly i bet
}

# base string for youtube-dl commands
# because can't use an alias plus a string to set a new alias
# aka aliases are not normal variables doi
ytdl_base="yt-dlp.exe --no-abort-on-error --external-downloader aria2c --external-downloader-args '-j 16 -x 16 -s 16 -k 1M'"

alias ytdl=$ytdl_base

alias ytdlmp3="$ytdl_base -x --audio-format mp3 --add-metadata --audio-quality 0"

# download multiple playlists from a batch file and place into individial folders
# accepts multiple string arguments in a row as playlists
# usage: ytdlpl playlist1 "playlist 2" 'playlist 3'

# this is actually for mp3s only as it stands, so should rename to ytdlalbum or something
ytdlpl() {    
    if (( $# == 0 )) ; then
        # use piped input
        # idea: learn how to check for piped input before running code blindly lol
        while read data; do
            echo "${data}" | xargs yt-dlp.exe --cookies-from-browser chromium --no-abort-on-error --external-downloader aria2c --external-downloader-args '-j 16 -x 16 -s 16 -k 1M' -x --audio-format mp3 --add-metadata --audio-quality 0 -o '%(playlist)s/%(playlist_index)s - %(title)s.%(ext)s'
        done
        # echo "yea-nah m8 fuck off"
    else
        # use function parameters as input
        echo "${@}" | xargs yt-dlp.exe --cookies-from-browser chromium --no-abort-on-error --external-downloader aria2c --external-downloader-args '-j 16 -x 16 -s 16 -k 1M' -x --audio-format mp3 --add-metadata --audio-quality 0 -o '%(playlist)s/%(playlist_index)s - %(title)s.%(ext)s'
    fi
}

# yt-dlp.exe --skip-download --print "%(duration>%H:%M:%S.%s)s %(creator)s %(uploader)s - %(title)s" tbuH6N33_SY

# download with browser cookies
# C:\ungoogled-chromium\current\chrome.exe --profile-directory=Default
# has an issue with chromium file permissions
# fix: close chromium then run cmd
alias ytdlcookie="$ytdl_base --cookies-from-browser chromium"

winappdata() {
    find /c/ProgramData "/c/Program Files" "/c/Program Files (x86)" /c/Users/larry/AppData -iname "*$1*" -not -path "*/tldr/*"
}

# limit to HKEY_LOCAL_MACHINE for now
regfind() {
    find /proc/registry32/HKEY_LOCAL_MACHINE -iname "*$1*" | sort -u
}

# variation for values
# -F option?
# could/should this function be a param/option in regfind()?
# are the *<value>* asterisk wrappers necessary around the query for grep? needed for find, but i think it might mess grep up
reggrep() {
    grep -inR "*$1*" /proc/registry32/HKEY_LOCAL_MACHINE | sort -u
}

# get count of files by extension
extc() {
    find . -name '*.?*' -type f | sort -r | cut -d. -f1 | sort -r | tr '[:upper:]' '[:lower:]' | sort | uniq --count | sort -rn
}

# get count of files by extension...but different and probably worse
extc2() {
    find . -name '*.?*' -type f | tac -rs [^-\n] | cut -d. -f1 | tac -rs [^-\n] | tr '[:upper:]' '[:lower:]' | sort | uniq --count | sort -rn
}

# list functions and aliases defined in .bashrc
mybashrc() {
    echo -e "\nmybashrc:"

    funcs="$(declare -F | grep -v '\-f \_' | grep -Po 'declare[[:space:]]\-f[[:space:]]\K.*')"
    aliases="$(compgen -a)"

    # use ${COLUMNS} to estimate --columns value
    # assume a standard word is 10 characters long
    # assume a word gap of 10 is needed
    # so divide ${COLUMNS} by 20 and add a +2 buffer

    # adjust for very wide terminals
    if [ "${COLUMNS}" -gt 120 ]; then
        cols="$((${COLUMNS} / 40))"
    else
        cols="$((${COLUMNS} / 24))"
    fi

    # echo "${COLUMNS}"

    # repeat '-' n times to make a line
    printf "%$((${cols} * 18))s\n" | tr " " "-"

    echo -e "${funcs}\n${aliases}" | sort | pr -t --columns "${cols}"
    # echo
}

# display .bashrc functions and aliases
mybashrc
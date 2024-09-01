# bash -c zsh

# call pwsh from bash
bwsh() {
    pwsh -Command "$@"
}

# create new toast notification via pwsh
newtoast() {
    bwsh "New-BurntToastNotification -Text '$1'"
}

# fix teredo state via pwsh
teredofix() {
    bwsh "sudo netsh interface teredo set state type=enterpriseclient"
}

# full ip reset and fix teredo state via pwsh
ipfreely() {
    # cmd /k /c/evo/bin/jimip.bat
    bwsh "sudo ipconfig /release"
    bwsh "sudo ipconfig /release6"
    bwsh "sudo ipconfig /renew"
    bwsh "sudo ipconfig /renew6"
    bwsh "sudo ipconfig /flushdns"
    bwsh "sudo ipconfig /displaydns"
    teredofix
}

# full scoop update
alias scoopclean="bwsh scoop-clean.ps1"

# get exclusion paths from defender (todo: add a get/set switch)
alias exclusions="bwsh 'Get-MpPreference | Select-Object -Property ExclusionPath -ExpandProperty ExclusionPath'"

# idea: automate moving some bigger steam game(s) from C drive to different drive and back again safely (copy, check, delete method) 

# get $path line by line
# syntax requires single-quote alias cmd wrapper and doublequotes inside cmd
alias ppath='echo $PATH | tr : "\n"'

# return maximum metadata values
# from: https://exiftool.org/faq.html#Q30
exifall() {
    exiftool -ee3 -U -G3:1 -api requestall=3 -api largefilesupport "$1"
}

# coin flip
coinflip() {
    (( RANDOM % 2 )) && echo "$1" || echo "$2"
}

# list filesizes of dir contents
alias dirsize="du -sh * | sort -h"

# from: https://unix.stackexchange.com/a/607547
b64decode() {
    if [ "$#" -gt 0 ]; then
        # concatenated arguments fed via a pipe
        printf %s "$@" | base64 --decode
    else
        base64 --decode  # read from stdin
    fi
    ret=$?
    # add one newline character
    echo 
    # return with base64's exit status to report decoding errors if any
    return "$ret"
}

# reverse input (jerry-rigged rev)
# from: https://stackoverflow.com/a/46594266
rev() {
    if [ "$#" -gt 0 ]; then
        # concatenated arguments fed via a pipe
        printf '%s' "$@" | base64 --decode
    else
        base64 --decode  # read from stdin
    fi
    ret=$?
    # add one newline character
    echo 
    # return with base64's exit status to report decoding errors if any
    return "$ret"
    
    echo "$1"
    # echo "$1" | grep -o . | tac | tr -d '\n'
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

# readarray -d '' sfks_dir < <(find "$home" -iname "*.mp4.sfk" -type f -printf '%h\n' | sort -u)
# readarray -d '' sfks < <(find "$home" -iname "*.mp4.sfk" -type f)
# readarray -d '' sfks_base < <(find "$home" -iname "*.mp4.sfk" -type f -exec basename \{\} .mp4.sfk \; )
dcrsr45_sfk() {
    # home dir for v2 copy of project dir
    home="/home/dir"
    # manual collection of dirs that contain .sfk project files
    sfks_dir=("dir1" "dir2" "etc")
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
    grep -niRF "$1" --exclude-dir=larry /c/larry
}

# search historical bookmarks
boo() {
    grep -hiPoR '(?<=href=")[^"]*' /c/larry | grep "$1" # | sort -u
}

# base string for youtube-dl commands
# because can't use an alias plus a string to set a new alias like a variable can
ytdl_base="yt-dlp.exe --no-abort-on-error --external-downloader aria2c --external-downloader-args '-j 16 -x 16 -s 16 -k 1M'"

alias ytdl=$ytdl_base

alias ytdlmp3="$ytdl_base -x --audio-format mp3 --add-metadata --audio-quality 0"

alias ytdlcookie="$ytdl_base --cookies-from-browser chromium"

# search windows application installation + configuration locations
winappdata() {
    find /c/ProgramData "/c/Program Files" "/c/Program Files (x86)" /c/Users/larry/AppData -iname "*$1*" -not -path "*/tldr/*"
}

# limit to HKEY_LOCAL_MACHINE for now
regfind() {
    find /proc/registry32/HKEY_LOCAL_MACHINE -iname "*$1*" | sort -u
}

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
    funcs="$(declare -F | grep -v '\-f \_' | grep -Po 'declare[[:space:]]\-f[[:space:]]\K.*')"
    aliases="$(compgen -a)"
    echo -e "\nmybashrc:"

    # use ${COLUMNS} to estimate --columns value
    # assume a standard word is 10 characters long
    # assume a word gap of 10 is needed
    # so divide ${COLUMNS} by 20 and add a +2 buffer

    # currently values not right for very wide terminals
    # (too many columns squished and --- line too long)
    cols="$((${COLUMNS} / 22))"

    # repeat '-' n times to make a line
    printf "%$((${cols} * 18))s\n" | tr " " "-"

    echo -e "${funcs}\n${aliases}" | sort | pr -t --columns "${cols}"
    # echo
}

# display .bashrc functions and aliases
mybashrc
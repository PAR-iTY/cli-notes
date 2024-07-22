# bash -c zsh

# idea: automate moving some bigger steam game(s) from C drive to different drive and back again safely (copy, check, delete method) 

# list functions and aliases defined in .bashrc
alias bashrc="declare -F | grep -v git && compgen -a | sed -e 's/^declare \-f//'"

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

# lauch my scoop clean cmd in pwsh from bash
alias scoopclean="pwsh -Command scoop-clean.ps1"

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
    grep -niRF "$1" --exclude-dir=me /c/evo/notes
}

# search historical bookmarks
boo() {
    grep -hiPoR '(?<=href=")[^"]*' /d/umit/mdl/c-to-sea/bookmarks | grep "$1" # | sort -u
    # idea: try return a whole section aka a folder of bookmarks somehow
    #       itll be different for html vs json etc
    #       should be predictable strings to target
    #       tracing nesting will be ugly i bet
}

# added to fix bash not remembering history if exited by clicking the top-right corner [X]
# from: https://stackoverflow.com/questions/10488498/bash-history-does-not-update-in-git-for-windows-git-bash
# PROMPT_COMMAND="history -a"

# base string for youtube-dl commands
# because can't use an alias plus a string to set a new alias
# aka aliases are not normal variables doi
ytdl_base="yt-dlp.exe --no-abort-on-error --external-downloader aria2c --external-downloader-args '-j 16 -x 16 -s 16 -k 1M'"

alias ytdl=$ytdl_base

alias ytdlmp3="$ytdl_base -x --audio-format mp3 --add-metadata --audio-quality 0"

# download with browser cookies (mainly for instagram)
# C:\evo\scoop\apps\ungoogled-chromium\current\chrome.exe --profile-directory=Default
# has an issue with chromium file permissions...sudo?
alias ytdlig="$ytdl_base --cookies-from-browser chromium"

# search windows application installation + configuration locations
# todo: add follow up delete option (-exec rm -rf? -delete? <alias> | rm?)
# todo: figure out sudo / admin issues (self-relaunch-as-admin?)
winappdata() {
    find /c/ProgramData "/c/Program Files" "/c/Program Files (x86)" /c/Users/jim/AppData -iname "*$1*" -not -path "*/tldr/*"
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

# get count of files by extension...differently?
extc2() {
    find . -name '*.?*' -type f | tac -rs [^-\n] | cut -d. -f1 | tac -rs [^-\n] | tr '[:upper:]' '[:lower:]' | sort | uniq --count | sort -rn
}

# something similar for group policy search?
# C:\Windows\System32\GroupPolicy
# https://social.technet.microsoft.com/Forums/en-US/c712b27e-5dac-47b9-8acf-1af0d3430440/group-policy-folder-in-windows-10

echo -e "~/.bashrc functions and aliases:\n"
bashrc
# youtube-dl

## todo

`youtube-dl --get-url --format best <url>`
get url

`--rm-cache-dir`
delete all filesystem cache files

`--hls-prefer-native`
`--hls-prefer-ffmpeg`
preference for HLS downloads

## audio

`-x`
audio only

`--audio-format mp3`
post-processed with ffmpeg into mp3

`--audio-quality 0`
tell post-processor to use best audio quality

`--add-metadata`
added ID3 tag metadata

## aria2c

`--external-downloader aria2c`
de-throttled HTTP download speed

`--external-downloader-args <"args">`
pass arguments to external downloader

### aria2c arguments

`-s <n>`
download a file using <n> connections

`-j <n>`
use <n> concurrent downloads

`-x <n>`
number of allowed connections

`-k <size>`
size of chunks to download
use `<n>K` (kilobytes) or `<n>M` (megabytes)

`--external-downloader-args "-x2 -k2M"`
use 2 download sources and use 2 MB chunks

## solutions

`youtube-dl --external-downloader aria2c --external-downloader-args "-j 16 -x 16 -s 16 -k 1M" -x --audio-format mp3 --add-metadata --audio-quality 0 <url>`
get best quality audio as mp3 with metadata with de-throttled download speeds with aria2c

`youtube-dl --no-part --restrict-filenames --hls-prefer-native --user-agent "x" --add-header "x"`
get HLS with specific browser and header infomation

`youtube-dl -i -o "%(playlist_index)s-%(title)s" --get-filename --skip-download "playlist URL" > yt-playlist.txt`
get playlist video titles as log file

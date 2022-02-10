# youtube-dl

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

`--add-metadata`
added ID3 tag metadata

## aria2c

`--external-downloader aria2c`
de-throttled HTTP download speed

`--external-downloader-args "-x2 -k2M"`
use 2 download sources and use 2 MB chunks

## solutions

`youtube-dl --external-downloader aria2c -x --audio-format mp3 --add-metadata`

`youtube-dl --no-part --restrict-filenames --hls-prefer-native --user-agent "x" --add-header "x"`

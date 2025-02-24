# ffmpeg

personal collection of notes, parameters, commands etc

<!-- todo -->
## cuda gpu + scale to 1080p
`ffmpeg -hwaccel cuda -hwaccel_output_format cuda -i "input_file.mp4" -c:a copy -vf "scale_cuda=-2:1080" -c:v h264_nvenc "output_file.mp4"`
-hwaccel cuda chooses appropriate hw accelerator
-hwaccel_output_format cuda keeps the decoded frames in GPU memory
-c:v h264_nvenc selects the NVIDIA hardware accelerated H.264 encoder

## miniDV firewire conversion
<!-- Best way is a Firewire 800 to Thunderbolt 2 plus a Thunderbolt 2 to Thunderbolt 3 adapter. And then using either Quicktime (if you're okay with it's default de-interlacing and other "enhancements" it does) or just dumping the raw DV files using ffmpeg. Here's the command I use: -->
`ffmpeg -f avfoundation -capture_raw_data true -i "DV-VCR" -c copy -map 0 -f rawvideo capture.dv`

<!-- And then if you want to convert to Prores LT: -->
`ffmpeg -i capture.dv -c:v prores_ks -profile:v 1 -colorspace smpte170m -color_primaries smpte170m -color_trc 1 -c:a copy -movflags +write_colr capture_prores.mov`

`ffmpeg -i "$(ytdl --get-url o60dwXu_i40 | head -n 1)" -i "$(ytdl --get-url o60dwXu_i40 | head -n 2)" -c copy | vlc`
pass youtube media url to vlc

## input

`-i "$(ls -Art | tail -n 1)"`
use the most recently added (/modified?) file in cwd

## parameters

`-movflags faststart`
shift moov atom to start of file
only for the MOV family such as MP4, M4A, M4V, MOV

`-map 0`
map all streams

`-preset veryslow`
give up speed, use CPU heavily, and attain quality

`-map_metadata 0:s:a:0`
copies metadata from the first input file (0:), first audio stream (s:a:0) (where the metadata is) to all output files (global metadata)

`-r 30`
set framerate

### filters

`-vf`
video filter

`-vf eq`
filter expression

`-vf eq=saturation="1.2":contrast="1.2"`
set the saturation/contrast expression
The value must be a float in range 0.0 to 3.0. default is "1"

`filtername=option1=value1:option2=value2:option3=value3...`
these filters can be in any order

`-vf yadif=1`
yet another deinterlacing filter

`-vf yadif_cuda`
if you have nvidia and CUDA installed

### rotate

`ffmpeg -i input.ext -vf "transpose=1" output.ext`
re-encodes by default - does not need rotation metadata

`ffmpeg -i input.ext -metadata:s:v rotate="90" -codec copy output.ext`
doesn't re-encode - does need rotation metadata

`-b:v 1M`
set video bitrate

### h.264

`-crf`
`0` lossless
`18` indistinguishable from lossless
`23` default
`51` worst

### h.265

`-crf`
`0` lossless
`~22` indistinguishable from lossless
`28` default
`51` worst

`-vtag hvc1`
HEVC

### VP9

<!-- -threads 8 row-mt 1 -->

`-row-mt 1`
this has something to do with increasing thread use

`-crf`
`0` lossless
`~15` indistinguishable from lossless
`~30` default
`63` worst

`-crf x -b:v 0`
constant quality mode

use `-crf x` with `-b:v x` where `-b:v x` is non-zero (bitrate limit)
contrained quality mode

`-deadline best`
slower processing but smaller file size output

`ffmpeg -i input.ext -c:v libvpx-vp9 -crf 32 -b:v 0 -b:a 128k -ar 48000 -c:a libopus -s 1280:720 -r 30 output.webm`
example solution

### trimming

`-ss`
specifies start time
format = HH:MM:SS.xxx OR seconds

`-to`
specifies end time
format = HH:MM:SS.xxx

`-t`
specifies the duration
format = seconds

`ffmpeg -i input.ext -ss [start] -t [duration] -c copy output.ext`
`ffmpeg -ss 00:00:19 -i input.ext -c copy output.ext`
putting -ss before (much faster) or after (more accurate) the -i makes a big difference
can omit either the duration/end-time or the start time argument

## audio

`-b:a 320k -ac 2 -ar 44100 -joint_stereo 0`
high quality stereo

`-c:a libmp3lame -q:a 0`
VBR audio encoding

`-metadata artist="Dylan Brady"`
`-metadata album="Gentlemen Release Party"`
ID3-tag metadata
custom tags can be written if -movflags use_metadata_tags is added
This applies both for adding new tags or carrying over custom global tags from the input

`-write_id3v2 1`
AIFF muxer setting for preserving metadata

### opus

`-ar 48000`
44100 Hz is not supported by opus --> select 48 kHz

> "opus in MP4 support is experimental"
> "add `-strict -2` if you want to use it"

## solutions

`ffmpeg -i input.MPG -c:v libx264 -movflags +faststart -preset veryslow -crf 17 -vf yadif=1 -c:a aac output.mp4`
DCR-SR45 MPG to MP4

`for file in *.MPG; do ffmpeg -i "$file" -c:v libx264 -movflags +faststart -preset veryslow -crf 17 -vf yadif=1 -c:a aac "${file%.*}".mp4; done`
bash loop

myffmpeg loop
`for file in *.MPG; do myffmpeg source=$file "${file%.*}".mp4; done`

### discord embedding

- 8 MB file limit for all files including embedded
- accepts VP9 but not h.265
- only accepts VP9 wrapped in webm
- does not accept VP9 wrapped in mkv or mp4
  (my guess is discord uses wrapper/extension to determine embeddability rather than codec)

### MOV-h.265 --> MP4-h.264

- video editor wouldn't accept h.265
- ffmpeg wouldn't convert MOV-h.265 to MP4-h.264 directly

  `ffmpeg -i input.MOV -c copy output-1.mp4`

- stream copy MOV-h.265 to MP4 or MKV etc

  `ffmpeg -i output-1.mp4 -map 0 -c:v libx264 -crf 18 -c:a copy output-2.mp4`

- convert to MP4-h.264 and use map 0 to merge all h.265 streams

### animation tuned h.265 ed, edd n' eddy example

`ffmpeg -i ed.m2ts -c:a copy -c:v libx265 -vtag hvc1 -tune animation -crf 26 ed.mkv`

### create a GIF example

`ffmpeg -i input.ext -vf "fps=10,scale=320:-1:flags=lanczos,split[s0][s1];[s0]palettegen[p];[s1][p]paletteuse" -loop 0 output.gif`

### Jellyfin HLS playlist stream conversion example

`ffmpeg -fflags +genpts -i file:"input.ext" -map_metadata -1 -map_chapters -1 -threads 0 -map 0:0 -map 0:1 -map -0:s -codec:v:0 copy -start_at_zero -vsync -1 -codec:a:0 copy -strict -2 -copyts -avoid_negative_ts disabled -max_muxing_queue_size 2048 -f hls -max_delay 5000000 -hls_time 6 -hls_segment_type mpegts -start_number 0 -hls_segment_filename "output%d.ts" -hls_playlist_type vod -hls_list_size 0 -y "output.m3u8"`

`C:\Program Files\Jellyfin\Server\ffmpeg.exe -hwaccel cuda -hwaccel_output_format cuda -extra_hw_frames 3 -autorotate 0 -i file:"D:\OLD\Video\Movies\MCU\WandaVision (2021) COMPLETE S01 (1080p DSNP WEBRip 10bit HEVC x265 imSamirOFFICIAL)\WandaVision S01E01 1080p DSNP WEBRip 10bit HEVC x265 English DDP 5.1 Atmos ESub ~ imSamirOFFICIAL.mkv" -map_metadata -1 -map_chapters -1 -threads 0 -map 0:0 -map 0:1 -map -0:s -codec:v:0 h264_nvenc -preset default -b:v 5602708 -maxrate 5602708 -bufsize 11205416 -profile:v:0 high -g:v:0 72 -keyint_min:v:0 72 -sc_threshold:v:0 0 -vf "scale_cuda=format=nv12" -start_at_zero -vsync -1 -codec:a:0 aac -ac 6 -ab 640000 -copyts -avoid_negative_ts disabled -max_muxing_queue_size 2048 -f hls -max_delay 5000000 -hls_time 3 -hls_segment_type mpegts -start_number 0 -hls_segment_filename "C:\ProgramData\Jellyfin\Server\transcodes\f8f425448e444b441d7e85c081ed87e4%d.ts" -hls_playlist_type vod -hls_list_size 0 -y "C:\ProgramData\Jellyfin\Server\transcodes\f8f425448e444b441d7e85c081ed87e4.m3u8"`

### convert to h.264 and stream to VLC (to then cast to TV)

`ffmpeg -re -i "input.ext" -vcodec libx264 -f mpegts udp://127.0.0.1:1234?pkt_size=1316`
useful for casting to devices like TVs that can't display modern formats
apparently specifying a packet size is important

`udp://@127.0.0.1:1234?pkt_size=1316`
then in VLC open a network stream using `mpegts` value
note: must add the '@' for UDP to work

# ffplay

`ffplay -flags2 +export_mvs -vf codecview=mv=pf+bf+bb input.ext`
play a video and show motion vectors in real time

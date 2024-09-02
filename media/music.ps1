# loop n times with x delay and play random system media

# ffplay with parallel execution
# ffplay -autoexit $(Get-Random $(Get-ChildItem -Path "$env:windir\Media\*.wav"))
@(Get-ChildItem -Path "$env:windir\Media\*.wav").FullName | Out-File -Append "C:\DEV\Experiments\pwsh-music\wavs-test.txt";
Add-Content -Path "C:\DEV\Experiments\pwsh-music\wavs-test.txt" -Value "End of file"

# concat and overlay

# first get acceptable input file
@(Get-ChildItem -Path "C:\DEV\Experiments\pwsh-music\1\*.mp4").FullName | Out-File -Append "C:\DEV\Experiments\pwsh-music\vizs.txt";

ffmpeg -f concat safe 0 -i vizs.txt -filter_complex "overlay" concat-overlay.mp4

ffmpeg -f concat -safe 0 -i "C:\DEV\Experiments\pwsh-music\wavs-quotes.txt" -filter_complex "overlay,[0:a]showwaves=mode=line:s=hd480:colors=White[v]" -map "[v]" -map 0:a -pix_fmt yuv420p -b:a 360k -r:a 44100 "C:\DEV\Experiments\pwsh-music\concat-wav-viz-waves-overlay.mp4"

# concat
ffmpeg -f concat -safe 0 -i "C:\DEV\Experiments\pwsh-music\wavs-quotes.txt" -filter_complex "[0:a]showwaves=mode=line:s=hd480:colors=White[v]" -map "[v]" -map 0:a -pix_fmt yuv420p -b:a 360k -r:a 44100 "C:\DEV\Experiments\pwsh-music\concat-wav-viz-waves.mp4"

ffmpeg -f concat -safe 0 -i "C:\DEV\Experiments\pwsh-music\wavs-quotes.txt" -filter_complex "[0:a]avectorscope=s=480x480:zoom=1.5:rc=0:gc=200:bc=0:rf=0:gf=40:bf=0,format=yuv420p[v]; [v]pad=854:480:187:0[out]" -map "[out]" -map 0:a -b:v 700k -b:a 360k "C:\DEV\Experiments\pwsh-music\concat-wav-viz.mp4"

ffmpeg -i INPUT.wav -filter_complex "[0:a]ahistogram=s=hd480:slide=scroll:scale=log,format=yuv420p[v]" -map "[v]" -map 0:a -b:a 360k OUTPUT.mp4

# create a spectrogram as a single frame
ffmpeg -i INPUT.wav -lavfi 
showspectrumpic=s=hd480:legend=0, format=yuv420p 
SPECTROGRAM.png
 
# add png to audio - you need to know the length of audio
ffmpeg -loop 1 -i SPECTROGRAM.png -i INPUT.wav 
-s hd480 -t 00:01:00 -pix_fmt yuv420p 
-b:a 360k -r:a 44100 OUTPUT.mp4

# New-Item -Path "C:\DEV\Experiments\pwsh-music" -Name "wavs.txt" -ItemType "file" -Value $files;

# 1..100 | ForEach-Object -parallel {  }


# ffplay visauls options
# -vf aphasemeter (seems the same?)

# vlc with parallel execution
1..10 | ForEach-Object -parallel { $(Start-Process -FilePath "vlc.exe" -WorkingDirectory "C:\Program Files\VideoLAN\VLC" -ArgumentList "$(Get-Random $(Get-ChildItem -Path $env:windir\Media\*.wav))", "vlc:://quit") }

# ------------------------------------------------------------------------------------

# ffmpeg visualisation ideas
# https://lukaprincic.si/development-log/ffmpeg-audio-visualization-tricks


# ffmpeg -i INPUT_AUDIO.wav -filter_complex 
# "[0:a]avectorscope=s=480x480:zoom=1.5:rc=0:gc=200:bc=0:rf=0:gf=40:bf=0,format=yuv420p[v]; 
#  [v]pad=854:480:187:0[out]" 
#  -map "[out]" -map 0:a 
# -b:v 700k -b:a 360k 
# OUTPUT_VIDEO.mp4

# ------------------------------------------------------------------------------------

# new idea
Add-Type -AssemblyName System.Speech

$input = "Name One", "Name Two"

foreach ($name in $input) {
  $speak = New-Object System.Speech.Synthesis.SpeechSynthesizer
  $streamFormat = [System.Speech.AudioFormat.SpeechAudioFormatInfo]::new(8000, [System.Speech.AudioFormat.AudioBitsPerSample]::Sixteen, [System.Speech.AudioFormat.AudioChannel]::Mono)
  $speak.SetOutputToWaveFile("C:\tmp\$name.wav", $streamFormat)
  $speak.Speak($name)
  $speak.Dispose()
}

# or

Add-Type –AssemblyName System.Speech
$SpeechSynthesizer = New-Object –TypeName System.Speech.Synthesis.SpeechSynthesizer
$SpeechSynthesizer.SetOutputToWaveFile('C:\temp\myName.wav')
$SpeechSynthesizer.Speak('Hello, World!')

# ------------------------------------------------------------------------------------


# can also try .PlaySync() .PlayLooping() and more

# download Get-MediaInfo package
Find-Package -Name "Get-MediaInfo" | Install-Package

# view all SoundPlayer functions
New-Object System.Media.SoundPlayer $(Get-Random $(Get-ChildItem -Path "$env:windir\Media\*.wav")) | Get-Member

# play and get length in milliseconds of wav
1..100 | % { $file = Get-Random $(Get-ChildItem -Path "$env:windir\Media\*.wav"); $player = New-Object System.Media.SoundPlayer $file; $milliseconds = $(Get-MediaInfo $file).Duration * 1000; Start-Sleep -Milliseconds $($milliseconds / 1.2) && $player.Play() }

# idea: delay by that length minus n milliseconds before playing next wav
1..100 | % { $file = Get-Random $(Get-ChildItem -Path "$env:windir\Media\*.wav"); $player = New-Object System.Media.SoundPlayer $file; $milliseconds = $(Get-MediaInfo $file).Duration * 1000; $player.Play() && Start-Sleep -Milliseconds $milliseconds }

# ffplay experiments
1..100 | % { $file = Get-Random $(Get-ChildItem -Path "$env:windir\Media\*.wav"); $milliseconds = $(Get-MediaInfo $file).Duration * 1000; ffplay $file && Start-Sleep -Milliseconds $milliseconds }


# format for alternating play cmds, expand for more patterns
# make every 4th sound heavy, loud etc, will that help create a 4/4 sound?
1..20 | % { $_ % 2 -eq 0 ? (write-host "$_ is even") : (write-host "$_ is odd") }

# alternate different millisecond delays
1..100 | % { $_ % 2 -eq 0 ? ( Start-Sleep -Milliseconds 50 && (New-Object System.Media.SoundPlayer $(Get-Random $(Get-ChildItem -Path "$env:windir\Media\*.wav").FullName)).Play() ) : ( Start-Sleep -Milliseconds 150 && (New-Object System.Media.SoundPlayer $(Get-Random $(Get-ChildItem -Path "$env:windir\Media\*.wav").FullName)).Play() ) }

# new powershell beat just dropped
1..100 | % { Start-Sleep -Milliseconds 150 && (New-Object System.Media.SoundPlayer $(Get-Random $(Get-ChildItem -Path "$env:windir\Media\*.wav").FullName)).Play() }

# parallel execution (same for System.Media.SoundPlayer as no -parallel)
1..100 | ForEach-Object -parallel { (New-Object System.Media.SoundPlayer $(Get-Random $(Get-ChildItem -Path "$env:windir\Media\*.wav"))).Play() }
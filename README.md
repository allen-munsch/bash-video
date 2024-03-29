# bash-video
bash cli video editing "suite" which ... just wraps ffmpeg



```
Usage: bash_video.sh <operation> <input_file> [arguments...]

Available operations:
 splice <start_time> <end_time> <output_file> - Cut a video segment
 join <file1> <file2> <output_file> - Join multiple videos
 speedup <speed_factor> <output_file> - Change playback speed
 optimize <output_file> - Optimize video to reduce size
 popleft <duration> <output_file> - Remove a segment from the beginning of the video
 popright <duration> <output_file> - Remove a segment from the end of the video
 trim <start_time> <end_time> <output_file> - Trim video by start and end times
 extractaudio <output_file> - Extract audio from video
 addaudio <audio_file> <output_file> - Add audio to video
 resize <width> <height> <output_file> - Resize video
 rotate <rotation> <output_file> - Rotate video (90, 180, 270)
 record <output_file> <duration> - Record screen
 addsubtitle <subtitle_file> <output_file> - Add subtitle to video
 filter <filter_name> <output_file> - Apply video filter
 overlay <image_file> <position> <output_file> - Overlay image on video
 thumbnail <output_file> <timestamp> - Generate video thumbnail
```

# install

```
git clone git@github.com:allen-munsch/bash-video.git
cd bash-video

alias bv="$(pwd)/bash-video.sh"

./tests.sh
bv
```

# Contributing

feel free to 

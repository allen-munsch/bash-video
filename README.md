# bash-video
bash cli video editing "suite" which ... just wraps ffmpeg

I just kept forgetting all the little configuration bits.

I have used this to splice up and put together demo videos, my workflow is the following:

1) Record a demo video using ( https://obsproject.com/download )
2) I use full video sink, and an audio source connected to my headset
3) Open the clip using VLC, jot down the times to splice up the video

Example video editing flow, where I do a speedup, and remove a section of video because of dead air:

```
alias bv="$(pwd)/bash-video.sh"
cat tests.sh 

# speedup 2x
bv speedup ./2024-04-15\ 23-03-47.mp4 2 hubspot-email.mp4

# check it
open hubspot-email.mp4

# documentation check
cat tests.sh 

# start splicing
bv popright hubspot-email.mp4 75 left.mp4
bv popleft hubspot-email.mp4 95 right.mp4

# join the left and right clips
bv join left.mp4 right.mp4 hubspot-email-multiseat.mp4

# check the final cut
open hubspot-email-multiseat.mp4 
```

# install

```
git clone git@github.com:allen-munsch/bash-video.git
cd bash-video

alias bv="$(pwd)/bash-video.sh"

# example usage can be seen in the tests
./tests.sh

~$ bv

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

# Contributing

feel free to 


## filter docs

- https://ffmpeg.org/ffmpeg-filters.html

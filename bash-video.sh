#!/bin/bash

## bash_video.sh
##
## Utility Functions
##

# Show usage information
function show_usage() {
  echo "Usage: bash_video.sh <operation> <input_file> [arguments...]"
  echo "Available operations:"
  echo " splice <start_time> <end_time> <output_file> - Cut a video segment"
  echo " join <file1> <file2> <output_file> - Join multiple videos"
  echo " speedup <speed_factor> <output_file> - Change playback speed"
  echo " optimize <output_file> - Optimize video to reduce size"
  echo " popleft <duration> <output_file> - Remove a segment from the beginning of the video"
  echo " popright <duration> <output_file> - Remove a segment from the end of the video"
  echo " trim <start_time> <end_time> <output_file> - Trim video by start and end times"
  echo " extractaudio <output_file> - Extract audio from video"
  echo " addaudio <audio_file> <output_file> - Add audio to video"
  echo " resize <width> <height> <output_file> - Resize video"
  echo " rotate <rotation> <output_file> - Rotate video (90, 180, 270)"
  echo " record <output_file> <duration> - Record screen"
  echo " addsubtitle <subtitle_file> <output_file> - Add subtitle to video"
  echo " filter <filter_name> <output_file> - Apply video filter"
  echo " overlay <image_file> <position> <output_file> - Overlay image on video"
  echo " thumbnail <output_file> <timestamp> - Generate video thumbnail"
}

# Parse a time string
function parse_time() {
  TIME_STRING=$1
  SECONDS=$(echo "$TIME_STRING" | awk -F':' '{ print ($1 * 3600) + ($2 * 60) + $3 }')
}

# Check if a file exists and is compatible with FFmpeg
function verify_file() {
  FILE_PATH=$1
  if ! ffprobe "$FILE_PATH" &>/dev/null; then
    echo "Error: $FILE_PATH is not a valid video file or not compatible with FFmpeg."
    exit 1
  fi
}

##
## Video Editing Operations
##

# Cut a video segment
function splice_video() {
  INPUT_FILE=$1
  START_TIME=$2
  END_TIME=$3
  OUTPUT_FILE=$4
  verify_file "$INPUT_FILE"
  parse_time "$START_TIME"
  START_SECONDS=$SECONDS
  parse_time "$END_TIME"
  END_SECONDS=$SECONDS
  ffmpeg -ss "$START_SECONDS" -i "$INPUT_FILE" -t "$((END_SECONDS - START_SECONDS))" -c copy "$OUTPUT_FILE" || exit 1
}

# Join multiple videos
function join_videos() {
  INPUT_FILE1=$1
  INPUT_FILE2=$2
  OUTPUT_FILE=$3
  verify_file "$INPUT_FILE1"
  verify_file "$INPUT_FILE2"
  ffmpeg -i "concat:$INPUT_FILE1|$INPUT_FILE2" -c copy "$OUTPUT_FILE" || exit 1
}

# Change playback speed
function change_speed() {
  INPUT_FILE=$1
  SPEED_FACTOR=$2
  OUTPUT_FILE=$3
  verify_file "$INPUT_FILE"
  ffmpeg -i "$INPUT_FILE" -filter:v "setpts=$SPEED_FACTOR*PTS" -filter:a "atempo=$SPEED_FACTOR" "$OUTPUT_FILE" || exit 1
}

# Optimize video to reduce size
function optimize_video() {
  INPUT_FILE=$1
  OUTPUT_FILE=$2
  verify_file "$INPUT_FILE"
  ffmpeg -i "$INPUT_FILE" -vcodec libx264 -crf 28 "$OUTPUT_FILE" || exit 1
}

# Remove a segment from the beginning of the video
function popleft() {
  INPUT_FILE=$1
  DURATION=$2
  OUTPUT_FILE=$3
  verify_file "$INPUT_FILE"
  ffmpeg -ss "$DURATION" -i "$INPUT_FILE" -c copy "$OUTPUT_FILE" || exit 1
}

# Remove a segment from the end of the video
function popright() {
  INPUT_FILE=$1
  DURATION=$2
  OUTPUT_FILE=$3
  verify_file "$INPUT_FILE"
  DURATION_SECONDS=$(ffprobe -v error -show_entries format=duration -of default=noprint_wrappers=1:nokey=1 "$INPUT_FILE")
  END_SECONDS=$(echo "$DURATION_SECONDS - $DURATION" | bc)
  ffmpeg -ss 0 -i "$INPUT_FILE" -t "$END_SECONDS" -c copy "$OUTPUT_FILE" || exit 1
}

# Trim video by start and end times
function trim_video() {
  INPUT_FILE=$1
  START_TIME=$2
  END_TIME=$3
  OUTPUT_FILE=$4
  verify_file "$INPUT_FILE"
  ffmpeg -ss "$START_TIME" -i "$INPUT_FILE" -to "$END_TIME" -c copy "$OUTPUT_FILE" || exit 1
}

# Extract audio from video
function extract_audio() {
  INPUT_FILE=$1
  OUTPUT_FILE=$2
  verify_file "$INPUT_FILE"
  ffmpeg -i "$INPUT_FILE" -vn -acodec copy "$OUTPUT_FILE" || exit 1
}

# Add audio to video
function add_audio() {
  VIDEO_FILE=$1
  AUDIO_FILE=$2
  OUTPUT_FILE=$3
  verify_file "$VIDEO_FILE"
  verify_file "$AUDIO_FILE"
  ffmpeg -i "$VIDEO_FILE" -i "$AUDIO_FILE" -c:v copy -c:a aac -map 0:v:0 -map 1:a:0 "$OUTPUT_FILE" || exit 1
}

# Resize video
function resize_video() {
  INPUT_FILE=$1
  WIDTH=$2
  HEIGHT=$3
  OUTPUT_FILE=$4
  verify_file "$INPUT_FILE"
  ffmpeg -i "$INPUT_FILE" -vf "scale=$WIDTH:$HEIGHT" "$OUTPUT_FILE" || exit 1
}

# Rotate video
function rotate_video() {
  INPUT_FILE=$1
  ROTATION=$2
  OUTPUT_FILE=$3
  verify_file "$INPUT_FILE"
  case "$ROTATION" in
    "90")
      TRANSPOSE="transpose=1"
      ;;
    "180")
      TRANSPOSE="hflip,vflip"
      ;;
    "270")
      TRANSPOSE="transpose=2"
      ;;
    *)
      echo "Error: Invalid rotation value. Allowed values are 90, 180, or 270."
      exit 1
      ;;
  esac
  ffmpeg -i "$INPUT_FILE" -vf "$TRANSPOSE" "$OUTPUT_FILE" || exit 1
}

# Record screen
function record_screen() {
  OUTPUT_FILE=$1
  DURATION=$2
  ffmpeg -f x11grab -video_size $(xdpyinfo | grep dimensions | awk '{print $2}') -i :0.0 -t "$DURATION" "$OUTPUT_FILE" || exit 1
}

# Add subtitle to video
function add_subtitle() {
  INPUT_FILE=$1
  SUBTITLE_FILE=$2
  OUTPUT_FILE=$3
  verify_file "$INPUT_FILE"
  ffmpeg -i "$INPUT_FILE" -vf "subtitles=$SUBTITLE_FILE" "$OUTPUT_FILE" || exit 1
}

# Apply video filter
function apply_filter() {
  INPUT_FILE=$1
  FILTER=$2
  OUTPUT_FILE=$3
  verify_file "$INPUT_FILE"
  ffmpeg -i "$INPUT_FILE" -vf "$FILTER" "$OUTPUT_FILE" || exit 1
}

# Overlay image on video
function overlay_image() {
  INPUT_FILE=$1
  IMAGE_FILE=$2
  POSITION=$3
  OUTPUT_FILE=$4
  verify_file "$INPUT_FILE"
  ffmpeg -i "$INPUT_FILE" -i "$IMAGE_FILE" -filter_complex "overlay=$POSITION" "$OUTPUT_FILE" || exit 1
}

# Generate video thumbnail
function generate_thumbnail() {
  INPUT_FILE=$1
  OUTPUT_FILE=$2
  TIMESTAMP=$3
  verify_file "$INPUT_FILE"
  ffmpeg -ss "$TIMESTAMP" -i "$INPUT_FILE" -vframes 1 "$OUTPUT_FILE" || exit 1
}

# Add title to video
function add_title() {
  INPUT_FILE=$1
  TITLE=$2
  FONT_SIZE=$3
  FONT_COLOR=$4
  POSITION=$5
  DURATION=$6
  OUTPUT_FILE=$7
  verify_file "$INPUT_FILE"
  ffmpeg -i "$INPUT_FILE" -vf "drawtext=fontfile=/path/to/font.ttf:fontsize=$FONT_SIZE:fontcolor=$FONT_COLOR:box=1:boxcolor=black@0.5:boxborderw=5:x=(w-text_w)/2:y=$POSITION:enable='between(t,0,$DURATION)'" -codec:a copy "$OUTPUT_FILE" || exit 1
}

# Add fade in effect
function fade_in() {
  INPUT_FILE=$1
  DURATION=$2
  OUTPUT_FILE=$3
  verify_file "$INPUT_FILE"
  ffmpeg -i "$INPUT_FILE" -vf "fade=t=in:st=0:d=$DURATION" -codec:a copy "$OUTPUT_FILE" || exit 1
}

# Add fade out effect
function fade_out() {
  INPUT_FILE=$1
  DURATION=$2
  OUTPUT_FILE=$3
  verify_file "$INPUT_FILE"
  DURATION_SECONDS=$(ffprobe -v error -show_entries format=duration -of default=noprint_wrappers=1:nokey=1 "$INPUT_FILE")
  START_TIME=$(echo "$DURATION_SECONDS - $DURATION" | bc)
  ffmpeg -i "$INPUT_FILE" -vf "fade=t=out:st=$START_TIME:d=$DURATION" -codec:a copy "$OUTPUT_FILE" || exit 1
}

##
## Main Entry Point
##

if [ $# -lt 2 ]; then
  show_usage
  exit 1
fi

OPERATION=$1
INPUT_FILE=$2

case "$OPERATION" in
  "splice")
    if [ $# -ne 5 ]; then
      show_usage
      exit 1
    fi
    START_TIME=$3
    END_TIME=$4
    OUTPUT_FILE=$5
    splice_video "$INPUT_FILE" "$START_TIME" "$END_TIME" "$OUTPUT_FILE"
    ;;
  "join")
    if [ $# -ne 4 ]; then
      show_usage
      exit 1
    fi
    INPUT_FILE2=$3
    OUTPUT_FILE=$4
    join_videos "$INPUT_FILE" "$INPUT_FILE2" "$OUTPUT_FILE"
    ;;
  "speedup")
    if [ $# -ne 4 ]; then
      show_usage
      exit 1
    fi
    SPEED_FACTOR=$3
    OUTPUT_FILE=$4
    change_speed "$INPUT_FILE" "$SPEED_FACTOR" "$OUTPUT_FILE"
    ;;
  "optimize")
    if [ $# -ne 3 ]; then
      show_usage
      exit 1
    fi
    OUTPUT_FILE=$3
    optimize_video "$INPUT_FILE" "$OUTPUT_FILE"
    ;;
  "popleft")
    if [ $# -ne 4 ]; then
      show_usage
      exit 1
    fi
    DURATION=$3
    OUTPUT_FILE=$4
    popleft "$INPUT_FILE" "$DURATION" "$OUTPUT_FILE"
    ;;
  "popright")
    if [ $# -ne 4 ]; then
      show_usage
      exit 1
    fi
    DURATION=$3
    OUTPUT_FILE=$4
    popright "$INPUT_FILE" "$DURATION" "$OUTPUT_FILE"
    ;;
  "trim")
    if [ $# -ne 5 ]; then
      show_usage
      exit 1
    fi
    START_TIME=$3
    END_TIME=$4
    OUTPUT_FILE=$5
    trim_video "$INPUT_FILE" "$START_TIME" "$END_TIME" "$OUTPUT_FILE"
    ;;
  "extractaudio")
    if [ $# -ne 3 ]; then
      show_usage
      exit 1
    fi
    OUTPUT_FILE=$3
    extract_audio "$INPUT_FILE" "$OUTPUT_FILE"
    ;;
  "addaudio")
    if [ $# -ne 4 ]; then
      show_usage
      exit 1
    fi
    AUDIO_FILE=$3
    OUTPUT_FILE=$4
    add_audio "$INPUT_FILE" "$AUDIO_FILE" "$OUTPUT_FILE"
    ;;
  "resize")
    if [ $# -ne 5 ]; then
      show_usage
      exit 1
    fi
    WIDTH=$3
    HEIGHT=$4
    OUTPUT_FILE=$5
    resize_video "$INPUT_FILE" "$WIDTH" "$HEIGHT" "$OUTPUT_FILE"
    ;;
  "rotate")
    if [ $# -ne 4 ]; then
      show_usage
      exit 1
    fi
    ROTATION=$3
    OUTPUT_FILE=$4
    rotate_video "$INPUT_FILE" "$ROTATION" "$OUTPUT_FILE"
    ;;
  "record")
    if [ $# -ne 3 ]; then
      show_usage
      exit 1
    fi
    OUTPUT_FILE=$2
    DURATION=$3
    record_screen "$OUTPUT_FILE" "$DURATION"
    ;;
  "addsubtitle")
    if [ $# -ne 4 ]; then
      show_usage
      exit 1
    fi
    SUBTITLE_FILE=$3
    OUTPUT_FILE=$4
    add_subtitle "$INPUT_FILE" "$SUBTITLE_FILE" "$OUTPUT_FILE"
    ;;
  "filter")
    if [ $# -ne 4 ]; then
      show_usage
      exit 1
    fi
    FILTER=$3
    OUTPUT_FILE=$4
    apply_filter "$INPUT_FILE" "$FILTER" "$OUTPUT_FILE"
    ;;
  "overlay")
    if [ $# -ne 5 ]; then
      show_usage
      exit 1
    fi
    IMAGE_FILE=$3
    POSITION=$4
    OUTPUT_FILE=$5
    overlay_image "$INPUT_FILE" "$IMAGE_FILE" "$POSITION" "$OUTPUT_FILE"
    ;;
  "thumbnail")
    if [ $# -ne 4 ]; then
      show_usage
      exit 1
    fi
    OUTPUT_FILE=$3
    TIMESTAMP=$4
    generate_thumbnail "$INPUT_FILE" "$OUTPUT_FILE" "$TIMESTAMP"
    ;;
  *)
    show_usage
    exit 1
    ;;
esac
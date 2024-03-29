./bash-video.sh popright tests/test-1-2-3_14s.mp4 9 tests/popright.mp4
./bash-video.sh popleft tests/popright.mp4 2 tests/popleft.mp4
./bash-video.sh trim tests/test-1-2-3_14s.mp4 2 4 tests/trim.mp4
./bash-video.sh join tests/popleft.mp4 tests/trim.mp4 tests/join.mp4
./bash-video.sh speedup tests/test-1-2-3_14s.mp4 '4' tests/speedup.mp4
./bash-video.sh optimize tests/test-1-2-3_14s.mp4 tests/optimize.mp4
./bash-video.sh extractaudio tests/popleft.mp4 tests/audio.mp3
./bash-video.sh resize tests/test-1-2-3_14s.mp4 100 100 tests/resize-100-100.mp4
./bash-video.sh rotate tests/resize-100-100.mp4 90 tests/rotate-90.mp4
./bash-video.sh addsubtitle tests/test-1-2-3_14s.mp4 ./subtitles.srt tests/subtitle.mp4
./bash-video.sh filter tests/popleft.mp4 'hue=h=90:s=1:b=0.5' tests/filter.mp4
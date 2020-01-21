#! /bin/bash

src=${1:-~/Videos/}

function ffmpeg_flv(){
  local file="${1}"

  ffmpeg \
    -i "${file}" \
    -f flv \
    "rtmp://127.0.0.1/live/video.flv"
}

function ffmpeg_mpegts(){
  local file="${1}"
  local dir="${file%/*}"

  dir=${dir##*/}

  ffmpeg \
    -re \
    -i "${file}" \
    -bsf:v h264_mp4toannexb \
    -c copy \
    -f mpegts \
    "http://127.0.0.1:8000/publish/"
}

play_fn=ffmpeg_mpegts

if [[ -f "${src}" ]];then
  eval ${play_fn} \"${src}\"
elif [[ -d "${src}" ]];then
  for i in "${src}"/*{mkv,mp4};do
    eval ${play_fn} \"${i}\"
  done
fi


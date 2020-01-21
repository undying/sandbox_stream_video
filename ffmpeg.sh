#! /bin/bash

src=${1:-~/Videos/}

function ffmpeg_rtmp(){
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


while getopt 'rm' ARG;do
  case ${ARG} in
    r)
      play_fn=ffmpeg_rtmp
      ;;
    m)
      play_fn=ffmpeg_mpegts
      ;;
    *)
      echo "Usage: ${0} -[r|m] stream as rtmp or mpegts (default: mpegts)"
      exit 1
  esac
done

play_fn=${play_fn:-ffmpeg_mpegts}

if [[ -f "${src}" ]];then
  eval ${play_fn} \"${src}\"
elif [[ -d "${src}" ]];then
  while read -r i;do
    eval ${play_fn} \"${i}\"
  done < <(find "${src}" -type f -iname '*.mkv' -o -iname '*.mp4' -o -iname '*.avi')
fi


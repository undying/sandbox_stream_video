#! /bin/bash

function ffmpeg_rtmp(){
  local file="${1}"

  ffmpeg \
    -re \
    -i "${file}" \
    -c:v copy \
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
    -c:v copy \
    -f mpegts \
    "http://127.0.0.1:8000/publish/"
}


while getopts 'i:rm' ARG;do
  echo "${ARG}"
  case ${ARG} in
    r)
      play_fn=ffmpeg_rtmp
      ;;
    m)
      play_fn=ffmpeg_mpegts
      ;;
    i)
      src="${OPTARG}"
      ;;
    *)
      echo "Usage: ${0} -[r|m] stream as rtmp or mpegts (default: mpegts)"
      exit 1
  esac
done

play_fn=${play_fn:-ffmpeg_mpegts}
src=${src:-~/Videos}

if [[ -f "${src}" ]];then
  eval ${play_fn} \"${src}\"
elif [[ -d "${src}" ]];then
  while read -r i;do
    eval ${play_fn} \"${i}\"
  done < <(find "${src}" -type f -iname '*.mkv' -o -iname '*.mp4' -o -iname '*.avi')
fi


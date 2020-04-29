#! /bin/bash

PID_FILE="/run/minidlna/minidlna.pid"
trap 'kill $(<${PID_FILE}); exit' SIGTERM SIGINT

minidlnad || exit

while pgrep minidlnad > /dev/null;do
  sleep 2
done

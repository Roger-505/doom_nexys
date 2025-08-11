#!/bin/bash

WATCH_DIR="$DOOM/doom/nexys/fpga/vivado/vivado.runs/impl_1"
BITFILE="rvfpganexys.bit"

inotifywait -m -e create --format '%f' "$WATCH_DIR" | while read FILENAME
do
  if [[ "$FILENAME" == "$BITFILE" ]]; then
    notify-send -u critical -t 0 "Vivado" "Bitstream rvfpganexys.bit generation complete\!"
    break
  fi
done


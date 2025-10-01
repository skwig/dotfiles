#!/usr/bin/env sh
DIR="."
FILE="$DIR/fio-test.img"

# nix-shell -p fio ioping
fio --name=seqwrite --filename="$FILE" --size=4G --rw=write --bs=1M --direct=1 --iodepth=32 --ioengine=io_uring --runtime=30 --time_based --group_reporting
fio --name=seqread  --filename="$FILE" --rw=read  --bs=1M --direct=1 --iodepth=32 --ioengine=io_uring --runtime=30 --time_based --group_reporting
fio --name=randread --filename="$FILE" --rw=randread --bs=4k --direct=1 --iodepth=32 --ioengine=io_uring --runtime=30 --time_based --numjobs=4 --group_reporting
fio --name=randwrite --filename="$FILE" --rw=randwrite --bs=4k --direct=1 --iodepth=32 --ioengine=io_uring --runtime=30 --time_based --numjobs=4 --group_reporting
ioping -c 10 "$DIR"
# rm -f "$FILE"

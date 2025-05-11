#!/bin/sh

fio_args="
[global]
ioengine=libaio
direct=1
iodepth=16
bs=4k
size=100M
runtime=30
filename=/tmp/fio-test-file

[randread]
rw=randread

[randwrite]
rw=randwrite
"

echo "$fio_args" > /tmp/job.fio
fio --output-format=json /tmp/job.fio

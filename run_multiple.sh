#!/bin/sh
#
mnt_list=( 
  "/mnt/writeback"
 ) 
op_list=( "randwrite" "randread" ) 

RESDIR="RESULTS"
num_mnts=1
jobfile="./jobfile.fio"
offset=0G
filesize=2G
size=5G
rt=900s
iod=16

# include the FUNCTIONS
. $(dirname "$0")/Utils/functions.shinc

######################################################
# Write the FIO jobfile and issue the FIO command(s)
for mnt in "${mnt_list[@]}"; do
## OverWrites the FIO jobfile
#-------
# BEGIN - FIO [global] section
#
  cat <<EOF1 > "${jobfile}"
[global]
group_reporting=1
fsync_on_close=1
#time_based=1
#runtime=${rt}
clocksource=gettimeofday
direct=1
bs=4k
ioengine=libaio
iodepth=${iod}
size=${size}
offset=${offset}
filesize=${filesize}
verify=crc32c
verify_backlog=4096
verify_async=32
verify_fatal=1
verify_dump=1
EOF1

# Append JOBS sections - one per device/mntpt
  i=0
  while [ "$i" -lt "$num_mnts" ]; do
    jobstr="job$i"
    fn="${mnt}${i}/file"
#
    cat <<EOF2 >> "${jobfile}"

[${jobstr}]
filename=${fn}
EOF2

    if [ -e "$fn" ]; then
        rm -f $fn
    fi
    touch "$fn"
    (( i++ ))
  done  # end FOR num_mnts
# END - FIO job section
#
#----------------
# FIO jobfile written -now let's run the test
  for op in "${op_list[@]}"; do
      DATETIME="`date '+%Y%m%d%H%M%S'`"
      if [ ! -d "${RESDIR}" ]; then
          mkdir $RESDIR
      fi
      fio_log="${RESDIR}/${op}_${DATETIME}.log"
# clear the cache prior to fio job
      sync; echo 3 > /proc/sys/vm/drop_caches

      echo "+++++++++++++++++++++> ${DATETIME}"
      echo "${mnt}: Starting FIO ${jobfile} OP=${op} RT=${rt} FS=${filesize}"
#      cat "${jobfile}"

      fio --rw="${op}" "${jobfile}" &> "${fio_log}"
      fio_print "${fio_log}"
#
#    --verify=crc32c --verify_backlog=4096 --verify_async=32 \
#    fio --rw=randwrite --name=verify --size="$size" --loops="$loops" \
#      fio --rw="$op" --name=verify \
#        --offset="$offset" --filesize="$filesize" \
#        --time_based --runtime="$rt" \
#        --bs=4k --filename="$fn" --group_reporting --fsync_on_close=1 \
#        --direct=1 --ioengine=libaio --iodepth=64 \
#        --verify=crc32c --verify_backlog=4096 --verify_async=32 \
#        --verify_fatal=1 --verify_dump=1 
  done  # end FOR op
done  # end FOR mnt

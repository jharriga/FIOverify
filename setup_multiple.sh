#!/bin/bash
#----------------------------------------------------------------
# setup_MULTIPLE.sh - create/setup lvm device configuration
# Calls Utils/partitionMULTIPLE.shinc and Utils/setupMULTIPLE.shinc
#
# Configures the devices, creates the XFS filesystems and mounts the
# filesystems at the mount points, for each of the two device modes,
# listed below.
#
# CACHE CONFIGURATION:
#   Prepares the devices used for I/O'tests.
#   The tests run in one of these two 'cachemodes': 
#   XFSWRITETHROUGH (10 devices):
#     slowDEV (100GB): /dev/sde -> /dev/sdk
#     fastDEV (10GB): /dev/nvme0n1p5 -> nvme0n1p14
#     Block device: /dev/mapper/vg_cache0-lv_writethrough0 -> 10
#     Mount points: /mnt/writethrough1 -> 10 (XFS filesystems)
#   XFSWRITEBACK (10 devices):
#     slowDEV (100GB): /dev/sdl
#     fastDEV (10GB): /dev/nvme0n1p15 -> nvme0n1p24
#     Block device: /dev/mapper/vg_cache0-lv_writeback0 -> 10
#     Mount points: /mnt/writeback1 -> 10 (XFS filesystems)
#
#----------------------------------------

# Bring in other script files
myPath="${BASH_SOURCE%/*}"
if [[ ! -d "$myPath" ]]; then
    myPath="$PWD" 
fi

# Variables
source "$myPath/vars.shinc"

# Functions
source "$myPath/Utils/functions.shinc"

# Assign LOGFILE
LOGFILE="./LOGFILEsetupMULTIPLE"

#--------------------------------------

# check mountpts 
devarr=( "${hddDEV_arr[@]}" "${slowDEV_arr[@]}" "${fastDEV_arr[@]}" )

for dev in "${devarr[@]}"; do
  echo "Checking if ${dev} is in use, if yes abort"
  mount | grep ${dev}
  if [ $? == 0 ]; then
    echo "Device ${dev} is mounted - ABORTING!" 
    echo "User must manually unmount ${dev}"
    exit 1
  fi
done

# Create new log file
if [ -e $LOGFILE ]; then
  rm -f $LOGFILE
fi
touch $LOGFILE || error_exit "$LINENO: Unable to create LOGFILE."
updatelog "$PROGNAME - Created logfile: $LOGFILE"

# PARTITION devices
updatelog "Starting: PARTITION Devices"
source "$myPath/Utils/partitionMULTIPLE.shinc"
updatelog "Completed: PARTITION Devices"

# SETUP CACHE configuration
updatelog "Starting: DEVICES Setup"
source "$myPath/Utils/setupMULTIPLE.shinc"
updatelog "Completed: DEVICES Setup"

# Display mount points
echo "LVMcached WRITETHROUGH mount points"
df -T | grep "${writethroughMNT}"
echo "LVMcached WRITEBACK mount points"
df -T | grep "${writeback}"

updatelog "$PROGNAME - END"
echo "END ${PROGNAME}**********************"
exit 0

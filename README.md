# FIOverify
Runs FIO using the verification option.
(based on githib "hdd_nvme_dmcache" repo)

Creates twenty local XFS filesystems on dm-cache LVMs and uses FIO to
verify write operations on each of them.
* dm-cache : cachemode=writethrough (default)
* dm-cache : cachemode=writeback

Includes utility scripts to configure the local storage devices:
* setup_multiple.sh
* teardown_multiple.sh

After running 'setup_multiple.sh', the twenty mounted filesystems are named:
* /mnt/xfswritethrough0 ... xfswritethrough9
* /mnt/xfswriteback0 ... xfswriteback9

'teardown_multiple.sh' unmounts the filesystems and removes the LVM configurations.

# Edit 'vars.sh' to match your systems disk configuration. Key variables:
* WTslowDEV_arr  <-- HDD's to use as dm-cache writethrough origin device
* WBslowDEV_arr  <-- HDD's to use as dm-cache writeback origin device
* WTfastDEV_arr  <-- NVMe partitions to use as dm-cache writethrough fast device
* WBfastDEV_arr  <-- NVMe partitions to use as dm-cache writeback fast device

# Edit 'run_multiple.sh' vars to configure run parameters
* num_mnts       <-- how many active mountpts during FIO runs
* filesize       <-- szie for each of the test files

# Workflow
1) ./setup_multiple.sh
2) ./run_multiple.sh
3) ./teardown_multiple.sh

Leaves run results in timestamped logfiles in the RESULTS directory.

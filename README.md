# check_vhdx_size

Powershell script to check the size of a single or a directory of .vhdx disks. Made for use with Icinga2/NSClient++.

## Examples

### Check a single disk

Checks the disk "sid.vhdx" and exits with code 2 (Critical) if the maximal size of 5Gb is exceeded, exits with code 1 (Warning) if 80% of the maximal size is used and exits with code 0 (Ok) if everything is below those values.

Critical pr warning will be output.

```txt
.\check_vhdx_size.ps1 -p "D:\disks\sid.vhdx" -s -m 5 -w 0.8
```

### Check a directory of disks

Checks every .vhdx disk in the directory "D:\disks\" and exits with code 2 (Critical) if the maximal size of 5Gb is exceeded (per disk), exits with code 1 (Warning) if 80% of the maximal size is used (per disk) and exits with code 0 (Ok) if everything is below those values (per disk).

Means if only one of 10 disks exceeds the maximal size of 20Gb, the exit code will be 2.

Criticals and warnings will be output.

```txt
.\check_vhdx_size.ps1 -p "D:\disks\" -m 20 -w 0.8
```

## About

Made with ♥ by [aaronlyy](https://github.com/aaronlyy)

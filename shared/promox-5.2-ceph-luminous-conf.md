# My configuration on Proxmox 5.2 and Ceph Luminous

* I'm using Proxmox 5.2 with an internal ceph storage (Luminous) on 3 physical nodes.
* Each node are strictly identical. A node is a server DELL PowerEdge 1U R639:
    - 2 CPUs Intel Xeon E5-2650
    - 256GB RAM
    - 10 disks
* A RAID controller PERC H730P which is set in HBA mode (no RAID).
* Among the 10 disks, there are:
    - 2 SSD 200GB Intel S3710 2.5" in RAID1 ZFS dedicated to the OS.
    - 8 SSD 800GB Intel S3520 2.5" dedicated to the ceph storage (one disk = one OSD, so 8x3=24 OSDs in all).
* There is one network card 2x10Gbps SFP+ strictly dedicated to the ceph cluster network.

I have set a bonding on the two 10Gbps interfaces in active-backup mode with MTU=9000 like this:

```
auto bond1
iface bond1 inet static
    address      10.123.123.21/24
    slaves       ex0 ex1
    bond_miimon  100
    bond_mode    active-backup
    bond_primary ex0
    mtu          9000
```

In the cluster, I have set only one ceph pool `ceph-vm` with:

- size = 3
- min_size = 2
- pg_num = 1024
- rule_name = replicated_rule
- I haven't changed the CRUSH map

When I have created the proxmox storage `ceph-vm` (proxmox storage which uses the ceph
pool `ceph-vm` of course), I have set `--krbd=false`.


# Fio bench on a OSD disk ie a SSD 800GB Intel S3520

With the fio bench below, I obtain ~ 6261 iops:

```sh
~$ sudo fio --bs=4k --size=4G --numjobs=3 --time_based --runtime=40 --group_reporting --name myjob \
    --rw=randwrite --ioengine=libaio --iodepth=8 --direct=1 --fsync=1
myjob: (g=0): rw=randwrite, bs=4K-4K/4K-4K/4K-4K, ioengine=libaio, iodepth=8
...
fio-2.16
Starting 3 processes
myjob: Laying out IO file(s) (1 file(s) / 4096MB)
myjob: Laying out IO file(s) (1 file(s) / 4096MB)
myjob: Laying out IO file(s) (1 file(s) / 4096MB)
Jobs: 3 (f=3): [w(3)] [100.0% done] [0KB/23576KB/0KB /s] [0/5894/0 iops] [eta 00m:00s]
myjob: (groupid=0, jobs=3): err= 0: pid=1301992: Sat May 26 01:52:52 2018
  write: io=978.42MB, bw=25047KB/s, iops=6261, runt= 40001msec
    slat (usec): min=8, max=1967, avg=30.53, stdev=26.53
    clat (usec): min=383, max=41168, avg=3355.13, stdev=612.82
     lat (usec): min=448, max=41186, avg=3385.66, stdev=618.96
    clat percentiles (usec):
     |  1.00th=[ 2576],  5.00th=[ 2704], 10.00th=[ 2800], 20.00th=[ 2896],
     | 30.00th=[ 2992], 40.00th=[ 3120], 50.00th=[ 3216], 60.00th=[ 3376],
     | 70.00th=[ 3632], 80.00th=[ 3856], 90.00th=[ 4080], 95.00th=[ 4256],
     | 99.00th=[ 4512], 99.50th=[ 4704], 99.90th=[ 5024], 99.95th=[ 5344],
     | 99.99th=[11840]
    lat (usec) : 500=0.01%, 1000=0.01%
    lat (msec) : 2=0.01%, 4=86.86%, 10=13.10%, 20=0.02%, 50=0.01%
  cpu          : usr=1.36%, sys=7.63%, ctx=309269, majf=0, minf=193
  IO depths    : 1=0.1%, 2=0.1%, 4=0.1%, 8=100.0%, 16=0.0%, 32=0.0%, >=64=0.0%
     submit    : 0=0.0%, 4=100.0%, 8=0.0%, 16=0.0%, 32=0.0%, 64=0.0%, >=64=0.0%
     complete  : 0=0.0%, 4=100.0%, 8=0.1%, 16=0.0%, 32=0.0%, 64=0.0%, >=64=0.0%
     issued    : total=r=0/w=250473/d=0, short=r=0/w=0/d=0, drop=r=0/w=0/d=0
     latency   : target=0, window=0, percentile=100.00%, depth=8

Run status group 0 (all jobs):
  WRITE: io=978.42MB, aggrb=25046KB/s, minb=25046KB/s, maxb=25046KB/s, mint=40001msec, maxt=40001msec

Disk stats (read/write):
  sdc: ios=0/458559, merge=0/501013, ticks=0/68388, in_queue=68324, util=91.28%
```


# Fio bench on a VM which uses the Ceph storage

I have installed a little VM, a little Debian Stretch with 512MB RAM and a virtual 32GB disk with the
driver VirtIO. In the VM, I have made exactly the same fio bench as above and **I have ~ 362 iops**:

```sh
~$ sudo fio --bs=4k --size=4G --numjobs=3 --time_based --runtime=40 --group_reporting --name myjob \
    -rw=randwrite --ioengine=libaio --iodepth=8 --direct=1 --fsync=1
myjob: (g=0): rw=randwrite, bs=4K-4K/4K-4K/4K-4K, ioengine=libaio, iodepth=8
...
fio-2.16
Starting 3 processes
myjob: Laying out IO file(s) (1 file(s) / 4096MB)
myjob: Laying out IO file(s) (1 file(s) / 4096MB)
myjob: Laying out IO file(s) (1 file(s) / 4096MB)
Jobs: 3 (f=3): [w(3)] [100.0% done] [0KB/1464KB/0KB /s] [0/366/0 iops] [eta 00m:00s]
myjob: (groupid=0, jobs=3): err= 0: pid=4451: Sat May 26 01:55:22 2018
  write: io=58068KB, bw=1451.6KB/s, iops=362, runt= 40005msec
    slat (usec): min=22, max=45396, avg=1995.33, stdev=575.50
    clat (msec): min=1, max=125, avg=57.86, stdev= 4.42
     lat (msec): min=3, max=127, avg=59.85, stdev= 4.50
    clat percentiles (msec):
     |  1.00th=[   52],  5.00th=[   54], 10.00th=[   55], 20.00th=[   56],
     | 30.00th=[   57], 40.00th=[   58], 50.00th=[   58], 60.00th=[   59],
     | 70.00th=[   60], 80.00th=[   60], 90.00th=[   62], 95.00th=[   63],
     | 99.00th=[   67], 99.50th=[   69], 99.90th=[  124], 99.95th=[  125],
     | 99.99th=[  126]
    lat (msec) : 2=0.01%, 10=0.06%, 20=0.05%, 50=0.25%, 100=99.36%
    lat (msec) : 250=0.28%
  cpu          : usr=0.15%, sys=0.69%, ctx=50136, majf=0, minf=28
  IO depths    : 1=0.1%, 2=0.1%, 4=0.1%, 8=99.9%, 16=0.0%, 32=0.0%, >=64=0.0%
     submit    : 0=0.0%, 4=100.0%, 8=0.0%, 16=0.0%, 32=0.0%, 64=0.0%, >=64=0.0%
     complete  : 0=0.0%, 4=100.0%, 8=0.1%, 16=0.0%, 32=0.0%, 64=0.0%, >=64=0.0%
     issued    : total=r=0/w=14517/d=0, short=r=0/w=0/d=0, drop=r=0/w=0/d=0
     latency   : target=0, window=0, percentile=100.00%, depth=8

Run status group 0 (all jobs):
  WRITE: io=58068KB, aggrb=1451KB/s, minb=1451KB/s, maxb=1451KB/s, mint=40005msec, maxt=40005msec

Disk stats (read/write):
  vda: ios=0/33732, merge=0/27136, ticks=0/67368, in_queue=67368, util=98.36%
```

# Question

Am I wrong if I think the iops in the VM are very low as regard the hardware configuration?

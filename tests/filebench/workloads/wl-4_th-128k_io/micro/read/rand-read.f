# ------------------------------------------------------#
# workload: rand-read.f
# ------------------------------------------------------#
# These variables are changed dynamically

set $WORKLOAD_PATH="/tmp/lazyfs.fb.mnt"
set $WORKLOAD_TIME=900
set $NR_THREADS=4
set $LAZYFS_FIFO="/tmp/lfs.fb2.rand-read.131072.fifo"

set $NR_FILES=1
set $MEAN_DIR_WIDTH=1
set $IO_SIZE=128k
set $FILE_SIZE=16g
set $NR_ITERATIONS=131072

# ------------------------------------------------------#

define fileset name="fileset1", path=$WORKLOAD_PATH, entries=$NR_THREADS, dirwidth=$MEAN_DIR_WIDTH, dirgamma=0, filesize=$FILE_SIZE, prealloc

define process name="process1", instances=1
{
    thread name="thread1", memsize=10m, instances=1
    {
        flowop openfile name="open1", filesetname="fileset1", fd=1, indexed=1
        flowop read name="read1", fd=1, iosize=$IO_SIZE, iters=$NR_ITERATIONS, random
        flowop closefile name="close1", fd=1

        flowop finishoncount name="finish1", value=1
    }

    thread name="thread2", memsize=10m, instances=1
    {
        flowop openfile name="open2", filesetname="fileset1", fd=1, indexed=2
        flowop read name="read2", fd=1, iosize=$IO_SIZE, iters=$NR_ITERATIONS, random
        flowop closefile name="close2", fd=1

        flowop finishoncount name="finish2", value=1
    }

    thread name="thread3", memsize=10m, instances=1
    {
        flowop openfile name="open3", filesetname="fileset1", fd=1, indexed=3
        flowop read name="read3", fd=1, iosize=$IO_SIZE, iters=$NR_ITERATIONS, random
        flowop closefile name="close3", fd=1

        flowop finishoncount name="finish3", value=1
    }

    thread name="thread4", memsize=10m, instances=1
    {
        flowop openfile name="open4", filesetname="fileset1", fd=1, indexed=4
        flowop read name="read4", fd=1, iosize=$IO_SIZE, iters=$NR_ITERATIONS, random
        flowop closefile name="close4", fd=1

        flowop finishoncount name="finish4", value=1
    }
}

# ------------------------------------------------------#

create files

system "echo LazyFS: performing a cache checkpoint..."
system "sudo -u gsd sh -c 'echo lazyfs::cache-checkpoint > $LAZYFS_FIFO'"
sleep 40

system "echo LazyFS: clearing the cache..."
system "sudo -u gsd sh -c 'echo lazyfs::clear-cache > $LAZYFS_FIFO'"
sleep 20

system "echo OS: syncing workload folder..."
system "sync $WORKLOAD_PATH"
system "echo OS: clearing caches..."
system "echo 3 > /proc/sys/vm/drop_caches"

system "echo time: sync..."
system "date '+time sync %s.%N'"
system "echo time: sync..."

# ------------------------------------------------------#

system "echo workload: running..."
run $WORKLOAD_TIME
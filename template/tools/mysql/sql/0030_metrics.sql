USE `<:cmdb_database:>`;

DROP PROCEDURE IF EXISTS `add_all_metrics`;

DELIMITER //

CREATE PROCEDURE modify_metric(IN `_name`        VARCHAR(1024), IN `_type` NVARCHAR(1024), IN `_subtype` NVARCHAR(1024),
                               IN `_description` NVARCHAR(1024), IN `_unit` NVARCHAR(1024), IN `_isKPI` TINYINT(1), IN `_metrictype` NVARCHAR(1024))
  BEGIN
    SELECT @id := id
    FROM `cw_CI`
    WHERE orgId = 0 AND sysId = 0 AND type = 8 AND `key` = _name;

    IF @id IS NOT NULL
    THEN
      IF _type IS NOT NULL
      THEN
        UPDATE `cw_Attribute`
        SET value = _type
        WHERE ciId = @id AND `name` = 'type';
      END IF;

      IF _subtype IS NOT NULL
      THEN
        UPDATE `cw_Attribute`
        SET value = _subtype
        WHERE ciId = @id AND `name` = 'subtype';
      END IF;

      IF _description IS NOT NULL
      THEN
        UPDATE `cw_Attribute`
        SET value = _description
        WHERE ciId = @id AND `name` = 'description';
      END IF;

      IF _unit IS NOT NULL
      THEN
        UPDATE `cw_Attribute`
        SET value = _unit
        WHERE ciId = @id AND `name` = 'unit';
      END IF;

      IF _isKPI IS NOT NULL
      THEN
        UPDATE `cw_Attribute`
        SET value = _isKPI
        WHERE ciId = @id AND `name` = 'isKPI';
      END IF;

      IF _metrictype IS NOT NULL
      THEN
        UPDATE `cw_Attribute`
        SET value = _metrictype
        WHERE ciId = @id AND `name` = 'metrictype';
      END IF;

    END IF;
  END;

CREATE PROCEDURE add_metric(IN _name       NVARCHAR(1024), IN _type NVARCHAR(1024), IN _subtype NVARCHAR(1024),
                            IN _description NVARCHAR(1024), IN _unit NVARCHAR(1024), IN _platform NVARCHAR(1024),
                            IN _tags        NVARCHAR(10240), IN _isKPI BOOLEAN, IN _metrictype NVARCHAR(1024))
  BEGIN
    # create CI
    if not exists(select id from `cw_CI` WHERE `key` = _name and orgId = 0 and sysId = 0 and type = 8) then
      INSERT INTO `cw_CI` (orgId, sysId, `key`, type) VALUE (0, 0, _name, 8);
      SELECT @id := last_insert_id();

      # create attribute
      INSERT INTO `cw_Attribute` (orgId, sysId, ciId, `name`, value) VALUES
        (0, 0, @id, 'type', _type),
        (0, 0, @id, 'subtype', _subtype),
        (0, 0, @id, 'metrictype', _metrictype),
        (0, 0, @id, 'description', _description),
        (0, 0, @id, 'unit', _unit),
        (0, 0, @id, 'tag', _tags),
        (0, 0, @id, 'isKPI', _isKPI);

      # create service relationship
      IF (_platform IS NOT NULL)
      THEN
        IF (instr(_platform, 'linux') > 0)
        THEN
          SELECT @serviceId := id
          FROM `cw_CI`
          WHERE `orgId` = 0 AND `sysId` = 0 AND `key` = concat(_subtype, '_linux');
          IF (@serviceId IS NOT NULL)
          THEN
            INSERT INTO `cw_Relationship` (orgId, sysId, sourceId, targetId, type)
              VALUE (0, 0, @id, @serviceId, 1);
          END IF;
        END IF;

        SET @serviceId = NULL;
        IF (instr(_platform, 'windows') > 0)
        THEN
          SELECT @serviceId := id
          FROM `cw_CI`
          WHERE `orgId` = 0 AND `sysId` = 0 AND `key` = concat(_subtype, '_windows');
          IF (@serviceId IS NOT NULL)
          THEN
            INSERT INTO `cw_Relationship` (orgId, sysId, sourceId, targetId, type)
              VALUE (0, 0, @id, @serviceId, 1);
          END IF;
        END IF;
      END IF;
    ELSE
      call modify_metric(_name, _type, _subtype, _description, _unit, _isKPI, _metrictype);
    END IF;

  END;

CREATE PROCEDURE add_all_metrics()
  BEGIN
    DECLARE t_error INTEGER DEFAULT 0;
    DECLARE CONTINUE HANDLER FOR SQLEXCEPTION SET t_error=1;
    START TRANSACTION;

    SELECT @version := `value`
    FROM `cw_Meta_Database`
    WHERE `name` = 'version';
    IF (@version < 1.2)
    THEN
      SIGNAL SQLSTATE '45000'
      SET MESSAGE_TEXT = '请先将数据库升级到1.2版本以上';
    END IF;

--  参数定义: metric name, type, subtype, description, unit, tag, platform (optional: NULL, 'windows', 'linux' or 'linux,windows'), isKPI
--  chenxu
    call add_metric('cpu.idle', '系统', 'cpu', 'CPU除去等待磁盘IO操作外的因为任何原因而空闲的时间闲置时间', 'percent', Null, '["cpu", "host"]', False, 'regular');
    call add_metric('cpu.irq', '系统', 'cpu', '处理硬件中断时间', 'percent', Null, '["cpu", "host"]', True, 'regular');
    call add_metric('cpu.nice', '系统', 'cpu', '处理低优先级进程的CPU时间', 'percent', Null, '["cpu", "host"]', True, 'regular');
    call add_metric('cpu.state', '系统', 'cpu', 'cpu探针运行状态', 'none', Null, '["host"]', False, 'regular');
    call add_metric('cpu.sys', '系统', 'cpu', '内核时间', 'percent', Null, '["cpu", "host"]', True, 'regular');
    call add_metric('cpu.usr', '系统', 'cpu', '用户进程时间', 'percent', Null, '["cpu", "host"]', True, 'regular');

    call add_metric('df.bytes.free', '系统', 'disk', '磁盘可以使用的大小', 'none', Null, '["fstype", "host", "mount"]', True, 'regular');
    call add_metric('df.bytes.percentused', '系统', 'disk', '磁盘使用率', 'none', Null, '["fstype", "host", "mount"]', True, 'regular');
    call add_metric('df.bytes.total', '系统', 'disk', '存储系统的大小', 'bytes', Null, '["fstype", "host", "mount"]', True, 'regular');
    call add_metric('df.bytes.used', '系统', 'disk', '被使用的大小', 'bytes', Null, '["fstype", "host", "mount"]', True, 'regular');
    call add_metric('df.inodes.free', '系统', 'disk', 'number of inodes', 'bytes', Null, '["fstype", "host", "mount"]', False, 'regular');
    call add_metric('df.inodes.percentused', '系统', 'disk', 'percentage of inodes used', 'percent', Null, '["fstype", "host", "mount"]', False, 'regular');
    call add_metric('df.inodes.total', '系统', 'disk', 'number of inodes', 'none', Null, '["fstype", "host", "mount"]', False, 'regular');
    call add_metric('df.inodes.used', '系统', 'disk', 'number of inodes', 'none', Null, '["fstype", "host", "mount"]', False, 'regular');

    call add_metric('iostat.disk.await', '系统', 'io', '平均每次设备I/O操作的等待时间', 'ms', Null, '["dev", "host"]', False, 'counter');
    call add_metric('iostat.disk.ios_in_progress', '系统', 'io', 'Number of actual I/O requests currently in flight.', 'short', Null, '["dev", "host"]', False, 'regular');
    call add_metric('iostat.disk.msec_read', '系统', 'io', 'Time in msec spent reading', 'ms', Null, '["dev", "host"]', False, 'counter');
    call add_metric('iostat.disk.msec_total', '系统', 'io', 'Time in msec doing I/O', 'ms', Null, '["dev", "host"]', False, 'counter');
    call add_metric('iostat.disk.msec_weighted_total', '系统', 'io', 'Weighted time doing I/O (multiplied by ios_in_progress)', 'ms', Null, '["dev", "host"]', False, 'counter');
    call add_metric('iostat.disk.msec_write', '系统', 'io', 'Time in msec spent writing', 'ms', Null, '["dev", "host"]', False, 'counter');
    call add_metric('iostat.disk.r_await', '系统', 'io', 'The average time (in milliseconds) for read requests issued to the device to be served. ', 'ms', Null, '["dev", "host"]', False, 'counter');
    call add_metric('iostat.disk.read_merged', '系统', 'io', 'Number of reads merged', 'short', Null, '["dev", "host"]', False, 'counter');
    call add_metric('iostat.disk.read_requests', '系统', 'io', 'Number of reads completed', 'short', Null, '["dev", "host"]', False, 'counter');
    call add_metric('iostat.disk.read_sectors', '系统', 'io', 'Number of sectors read', 'short', Null, '["dev", "host"]', False, 'counter');
    call add_metric('iostat.disk.svctm', '系统', 'io', '平均每次IO请求的处理时间(毫秒为单位)', 'ms', Null, '["dev", "host"]', False, 'counter');

    call add_metric('iostat.avgqu-sz', '系统', 'io', '是平均请求队列的长度。毫无疑问，队列长度越短越好。', 'short', Null, '["device", "host"]', True, 'regular');
    call add_metric('iostat.avgrq-sz', '系统', 'io', '平均每次设备I/O操作的数据大小', 'short', Null, '["device", "host"]', True, 'regular');
    call add_metric('iostat.await', '系统', 'io', '每一个IO请求的处理的平均时间（单位是微秒毫秒）。', 'ms', Null, '["device", "host"]', True, 'regular');
    call add_metric('iostat.bytes_per_s', '系统', 'io', '平均每秒读写字节数', 'bytes', Null, '["host"]', True, 'regular');
    call add_metric('iostat.r/s', '系统', 'io', '每秒完成的读 I/O 设备次数', 'short', Null, '["device", "host"]', True, 'regular');
    call add_metric('iostat.r_await', '系统', 'io', '读的IO请求的处理的平均时间', 'ms', Null, '["device", "host"]', True, 'regular');
    call add_metric('iostat.w_await', '系统', 'io', '写的IO请求的处理的平均时间', 'ms', Null, '["device", "host"]', True, 'regular');
    call add_metric('iostat.rkB/s', '系统', 'io', '每秒读K字节数。是 rsect/s 的一半因为每扇区大小为512字节。', 'kbytes', Null, '["device", "host"]', True, 'regular');
    call add_metric('iostat.rrqm/s', '系统', 'io', '每秒这个设备相关的读取请求有多少被Merge了（当系统调用需要读取数据的时候，VFS将请求发到各个FS，如果FS发现不同的读取请求读取的是相同Block的数据，FS会将这个请求合并Merge）；wrqm/s：每秒这个设备相关的写入请求有多少被Merge了。', 'short', Null, '["device", "host"]', False, 'regular');
    call add_metric('iostat.svctm', '系统', 'io', '表示平均每次设备I/O操作的服务时间（以毫秒为单位）。如果svctm的值与await很接近，表示几乎没有I/O等待，磁盘性能很好，如果await的值远高于svctm的值，则表示I/O队列等待太长，系统上运行的应用程序将变慢。', 'ms', Null, '["device", "host"]', True, 'regular');
    call add_metric('iostat.w/s', '系统', 'io', '每秒完成的写I/O 设备次数', 'short', Null, '["device", "host"]', True, 'regular');
    call add_metric('iostat.wkB/s', '系统', 'io', '每秒写K字节数。是 rsect/s 的一半因为每扇区大小为512字节。', 'kbytes', Null, '["device", "host"]', True, 'regular');
    call add_metric('iostat.wrqm/s', '系统', 'io', '每秒进行 merge 的写操作数目', 'short', Null, '["device", "host"]', True, 'regular');
    call add_metric('iostat.percentage_util', '系统', 'io', '在统计时间内所有处理IO时间除以总共统计时间', 'percent', Null, '["device", "host"]', True, 'regular');

    call add_metric('net.sockstat.ipfragqueues', '系统', 'net', '等待重新组装的IP流数量', 'short', Null, '["host"]', False, 'regular');
    call add_metric('net.sockstat.memory', '系统', 'net', '分配给该socket类型的内存大小', 'bytes', Null, '["host", "type"]', True, 'regular');
    call add_metric('net.sockstat.num_orphans', '系统', 'net', '孤儿sockets数量', 'short', Null, '["host"]', True, 'regular');
    call add_metric('net.sockstat.num_sockets', '系统', 'net', 'sockets分配的数量，仅TCP', 'short', Null, '["host", "type"]', True, 'regular');
    call add_metric('net.sockstat.num_timewait', '系统', 'net', 'TCP sockets当前处TIME_WAIT状态数量', 'short', Null, '["host"]', False, 'regular');
    call add_metric('net.sockstat.sockets_inuse', '系统', 'net', '套接字使用的数量', 'short', Null, '["host", "type"]', False, 'regular');
    call add_metric('net.stat.tcp.abort', '系统', 'net', '内核中止连接数量', 'short', Null, '["host", "type"]', True, 'counter');
    call add_metric('net.stat.tcp.abort.failed', '系统', 'net', '内核中止失败数量，因为没有足够内存来复位', 'short', Null, '["host"]', False, 'regular');
    call add_metric('net.stat.tcp.congestion.recovery', '系统', 'net', '内存检测到假重传，能部分回收或全部CWND数量', 'short', Null, '["host", "type"]', False, 'counter');
    call add_metric('net.stat.tcp.delayedack', '系统', 'net', '发送不同类型的延迟确认数量', 'short', Null, '["host", "type"]', False, 'regular');
    call add_metric('net.stat.tcp.failed_accept', '系统', 'net', 'Number of times a connection had to be dropped after the 3WHS', 'short', Null, '["host", "reason"]', False, 'counter');
    call add_metric('net.stat.tcp.invalid_sack', '系统', 'net', '无效的SACK数量', 'short', Null, '["host", "type"]', False, 'counter');
    call add_metric('net.stat.tcp.memory.pressure', '系统', 'net', '进入"memory pressure"的次数', 'short', Null, '["host"]', False, 'regular');
    call add_metric('net.stat.tcp.memory.prune', '系统', 'net', '因内存不足放弃接收数据的次数', 'short', Null, '["host", "type"]', False, 'counter');
    call add_metric('net.stat.tcp.packetloss.recovery', '系统', 'net', '丢失恢复的次数', 'short', Null, '["host", "type"]', False, 'counter');
    call add_metric('net.stat.tcp.receive.queue.full', '系统', 'net', '因套接字接收队列慢导致被丢弃接收到的数据包数量', 'short', Null, '["host"]', False, 'counter');
    call add_metric('net.stat.tcp.reording', '系统', 'net', '检测到重新排序的次数', 'short', Null, '["detectedby", "host"]', False, 'regular');
    call add_metric('net.stat.tcp.retransmit', '系统', 'net', '重传次数', 'short', Null, '["host", "type"]', False, 'counter');
    call add_metric('net.stat.tcp.syncookies', '系统', 'net', 'SYN cookies数', 'short', Null, '["host", "type"]', False, 'regular');
    call add_metric('net.stat.udp.datagrams', '系统', 'net', '接收的数据包', 'short', Null, '["direction", "host"]', True, 'regular');
    call add_metric('net.stat.udp.errors', '系统', 'net', '接收错误数', 'short', Null, '["direction", "host", "reason"]', True, 'counter');


    call add_metric('proc.interrupts', '系统', 'process', 'the number of interrupts', 'short', Null, '["cpu", "host", "type"]', False, 'regular');
    call add_metric('proc.kernel.entropy_avail', '系统', 'process', '存储了熵池现在的大小', 'kbytes', Null, '["host"]', False, 'regular');
    call add_metric('proc.loadavg.15min', '系统', 'process', '15分钟内的平均进程数', 'short', Null, '["host"]', True, 'regular');
    call add_metric('proc.loadavg.1min', '系统', 'process', '1分钟内的平均进程数', 'short', Null, '["host"]', False, 'regular');
    call add_metric('proc.loadavg.5min', '系统', 'process', '5分钟内的平均进程数', 'short', Null, '["host"]', False, 'regular');
    call add_metric('proc.loadavg.runnable', '系统', 'process', '正在运行的进程数', 'short', Null, '["host"]', False, 'regular');
    call add_metric('proc.loadavg.total_threads', '系统', 'process', '进程总数', 'short', Null, '["host"]', False, 'regular');
    call add_metric('proc.meminfo.active', '系统', 'memory', '活跃使用中的高速缓冲存储器页面文件大小', 'kbytes', Null, '["host"]', True, 'regular');
    call add_metric('proc.meminfo.anonhugepages', '系统', 'memory', '未映射的大页面的大小', 'kbytes', Null, '["host"]', False, 'regular');
    call add_metric('proc.meminfo.anonpages', '系统', 'memory', '未映射的页的大小', 'kbytes', Null, '["host"]', False, 'regular');
    call add_metric('proc.meminfo.bounce', '系统', 'memory', '退回', 'kbytes', Null, '["host"]', False, 'regular');
    call add_metric('proc.meminfo.buffers', '系统', 'memory', '给文件的缓冲大小', 'kbytes', Null, '["host"]', False, 'regular');
    call add_metric('proc.meminfo.cached', '系统', 'memory', '高速缓冲存储器使用的大小', 'kbytes', Null, '["host"]', False, 'regular');
    call add_metric('proc.meminfo.commitlimit', '系统', 'memory', '指当前可以分配给程序使用的虚拟内存', 'kbytes', Null, '["host"]', False, 'regular');
    call add_metric('proc.meminfo.committed_as', '系统', 'memory', '指当前已分配给程序使用的总虚拟内存', 'kbytes', Null, '["host"]', False, 'regular');
    call add_metric('proc.meminfo.directmap1g', '系统', 'memory', 'The amount of memory being mapped to hugepages (1G in size)', 'kbytes', Null, '["host"]', False, 'regular');
    call add_metric('proc.meminfo.directmap2m', '系统', 'memory', 'The amount of memory being mapped to hugepages (2MB in size)', 'kbytes', Null, '["host"]', False, 'regular');
    call add_metric('proc.meminfo.directmap4k', '系统', 'memory', 'The amount of memory being mapped to standard 4k pages', 'kbytes', Null, '["host"]', False, 'regular');
    call add_metric('proc.meminfo.dirty', '系统', 'memory', '等待被写回到磁盘的内存大小', 'kbytes', Null, '["host"]', True, 'regular');
    call add_metric('proc.meminfo.hardwarecorrupted', '系统', 'memory', 'show the amount of memory in "poisoned pages"', 'kbytes', Null, '["host"]', False, 'regular');
    call add_metric('proc.meminfo.hugepagesize', '系统', 'memory', '大页面的分配', 'kbytes', Null, '["host"]', False, 'regular');
    call add_metric('proc.meminfo.inactive', '系统', 'memory', '不经常使用的高速缓冲存储器页面文件大小', 'kbytes', Null, '["host"]', False, 'regular');
    call add_metric('proc.meminfo.kernelstack', '系统', 'memory', 'The memory the kernel stack uses. This is not reclaimable.', 'kbytes', Null, '["host"]', False, 'regular');
    call add_metric('proc.meminfo.mapped', '系统', 'memory', '设备和文件映射的大小', 'kbytes', Null, '["host"]', False, 'regular');
    call add_metric('proc.meminfo.memavailable', '系统', 'memory', '可用内存', 'kbytes', Null, '["host"]', True, 'regular');
    call add_metric('proc.meminfo.memfree', '系统', 'memory', '空闲内存', 'kbytes', Null, '["host"]', False, 'regular');
    call add_metric('proc.meminfo.memtotal', '系统', 'memory', '总内存', 'kbytes', Null, '["host"]', False, 'regular');
    call add_metric('proc.meminfo.mlocked', '系统', 'memory', 'Pages locked to memory using the mlock() system call. Mlocked pages are also Unevictable.', 'kbytes', Null, '["host"]', False, 'regular');
    call add_metric('proc.meminfo.nfs_unstable', '系统', 'memory', '不稳定页表的大小', 'kbytes', Null, '["host"]', False, 'regular');
    call add_metric('proc.meminfo.pagetables', '系统', 'memory', '管理内存分页的索引表的大小', 'kbytes', Null, '["host"]', False, 'regular');
    call add_metric('proc.meminfo.shmem', '系统', 'memory', 'Total used shared memory (shared between several processes, thus including RAM disks, SYS-V-IPC and BSD like SHMEM)', 'kbytes', Null, '["host"]', False, 'regular');
    call add_metric('proc.meminfo.slab', '系统', 'memory', '内核数据结构缓存的大小，可减少申请和释放内存带来的消耗', 'kbytes', Null, '["host"]', False, 'regular');
    call add_metric('proc.meminfo.sreclaimable', '系统', 'memory', '可收回slab的大小', 'kbytes', Null, '["host"]', False, 'regular');
    call add_metric('proc.meminfo.sunreclaim', '系统', 'memory', '不可收回的slab的大小', 'kbytes', Null, '["host"]', False, 'regular');
    call add_metric('proc.meminfo.swapcached', '系统', 'memory', '被高速缓冲存储用的交换空间大小', 'kbytes', Null, '["host"]', False, 'regular');
    call add_metric('proc.meminfo.swapfree', '系统', 'memory', '空闲交换空间', 'kbytes', Null, '["host"]', True, 'regular');
    call add_metric('proc.meminfo.swaptotal', '系统', 'memory', '交换空间总大小', 'kbytes', Null, '["host"]', False, 'regular');
    call add_metric('proc.meminfo.unevictable', '系统', 'memory', 'Unevictable pages can not be swapped out for a variety of reasons', 'kbytes', Null, '["host"]', False, 'regular');
    call add_metric('proc.meminfo.vmallocchunk', '系统', 'memory', 'largest contigious block of vmalloc area which is free', 'kbytes', Null, '["host"]', False, 'counter');
    call add_metric('proc.meminfo.vmalloctotal', '系统', 'memory', '可以vmalloc虚拟内存大小', 'kbytes', Null, '["host"]', False, 'regular');
    call add_metric('proc.meminfo.vmallocused', '系统', 'memory', '已经被使用的虚拟内存大小', 'kbytes', Null, '["host"]', False, 'counter');
    call add_metric('proc.meminfo.writeback', '系统', 'memory', '正在被写回到磁盘的内存大小', 'kbytes', Null, '["host"]', False, 'regular');
    call add_metric('proc.meminfo.writebacktmp', '系统', 'memory', 'Memory used by FUSE for temporary writeback buffers', 'kbytes', Null, '["host"]', False, 'regular');
    call add_metric('proc.softirqs', '系统', 'process', 'the number of software interrupt', 'int', Null, '["cpu", "host", "type"]', False, 'regular');
    call add_metric('proc.net.bytes.in', '系统', 'process', 'The total number of bytes of data received by the interface', 'bytes', Null, '["host", "iface"]', True, 'counter');
    call add_metric('proc.net.bytes.out', '系统', 'process', 'The total number of bytes of data transmitted by the interface', 'bytes', Null, '["host", "iface"]', True, 'counter');
    call add_metric('proc.net.carrier.errs.out', '系统', 'process', 'The number of carrier losses detected by the device driver', 'short', Null, '["host", "iface"]', False, 'regular');
    call add_metric('proc.net.collisions.out', '系统', 'process', 'The number of collisions detected on the interface', 'short', Null, '["host", "iface"]', False, 'regular');
    call add_metric('proc.net.compressed.in', '系统', 'process', 'The number of compressed packets received by the device driver.', 'short', Null, '["host", "iface"]', False, 'regular');
    call add_metric('proc.net.compressed.out', '系统', 'process', 'The number of compressed packets transmitted by the device driver.', 'short', Null, '["host", "iface"]', False, 'regular');
    call add_metric('proc.net.dropped.in', '系统', 'process', 'The total number of packets dropped by the device driver.', 'short', Null, '["host", "iface"]', True, 'counter');
    call add_metric('proc.net.dropped.out', '系统', 'process', 'The total number of packets dropped by the device driver.', 'short', Null, '["host", "iface"]', True, 'regular');
    call add_metric('proc.net.errs.in', '系统', 'process', 'The total number of receive errors detected by the device driver.', 'short', Null, '["host", "iface"]', True, 'regular');
    call add_metric('proc.net.errs.out', '系统', 'process', 'The total number of transmit errors detected by the device driver.', 'short', Null, '["host", "iface"]', True, 'regular');
    call add_metric('proc.net.fifo.errs.in', '系统', 'process', 'The number of FIFO buffer errors', 'short', Null, '["host", "iface"]', False, 'regular');
    call add_metric('proc.net.fifo.errs.out', '系统', 'process', 'The number of FIFO buffer errors', 'short', Null, '["host", "iface"]', False, 'regular');
    call add_metric('proc.net.frame.errs.in', '系统', 'process', 'The number of packet framing errors', 'short', Null, '["host", "iface"]', False, 'regular');
    call add_metric('proc.net.multicast.in', '系统', 'process', 'The number of packet framing errors', 'short', Null, '["host", "iface"]', False, 'regular');
    call add_metric('proc.net.packets.in', '系统', 'process', 'The total number of packets of data received by the interface', 'short', Null, '["host", "iface"]', True, 'counter');
    call add_metric('proc.net.packets.out', '系统', 'process', 'The total number of packets of data transmitted by the interface', 'short', Null, '["host", "iface"]', True, 'counter');
    call add_metric('proc.stat.intr', '系统', 'process', '自系统启动以来，发生的所有的中断的次数', 'short', Null, '["host"]', False, 'regular');
    call add_metric('proc.stat.processes', '系统', 'process', '自系统启动以来所创建的任务的个数目', 'short', Null, '["host"]', False, 'counter');
    call add_metric('proc.stat.procs_blocked', '系统', 'process', '当前被阻塞的任务的数目', 'short', Null, '["host"]', False, 'regular');
    call add_metric('proc.uptime.now', '系统', 'process', '系统空闲的时间', 'ms', Null, '["host"]', False, 'regular');
    call add_metric('proc.uptime.total', '系统', 'process', '系统启动到现在的时间', 'ms', Null, '["host"]', False, 'regular');
    call add_metric('proc.vmstat.pgfault', '系统', 'process', 'Number of minor page faults (since the last boot)', 'short', Null, '["host"]', False, 'counter');
    call add_metric('proc.vmstat.pgmajfault', '系统', 'process', 'Number of major page faults (since the last boot)', 'short', Null, '["host"]', False, 'counter');
    call add_metric('proc.vmstat.pgpgin', '系统', 'process', 'Number of pageins', 'short', Null, '["host"]', False, 'counter');
    call add_metric('proc.vmstat.pgpgout', '系统', 'process', 'Number of pageouts', 'short', Null, '["host"]', False, 'regular');
    call add_metric('proc.vmstat.pswpin', '系统', 'process', 'Number of swapins', 'short', Null, '["host"]', False, 'counter');
    call add_metric('proc.vmstat.pswpout', '系统', 'process', 'Number of swapouts ', 'short', Null, '["host"]', False, 'counter');
    call add_metric('sys.numa.allocation', '系统', 'process', 'Number of pages allocated locally or remotely for processes executing on this node', 'short', Null, '["host", "node", "type"]', False, 'regular');
    call add_metric('sys.numa.foreign_allocs', '系统', 'process', 'Number of pages this node allocated because the preferred node did not have a free page to accommodate the request.', 'short', Null, '["host", "node"]', False, 'regular');
    call add_metric('sys.numa.interleave', '系统', 'process', 'Number of pages allocated successfully by the interleave strategy', 'short', Null, '["host", "node", "type"]', False, 'regular');
    call add_metric('sys.numa.zoneallocs', '系统', 'process', 'Number of pages allocated from the preferred node or not', 'short', Null, '["host", "node", "type"]', False, 'regular');


    call add_metric('proc.stat.cpu', '系统', 'process', 'cpu总使用率', 'none', Null, '["host", "type"]', False, 'regular');
    call add_metric('proc.stat.cpu.percpu', '系统', 'process', '每一个cpu的使用率', 'none', Null, '["cpu", "host", "type"]', False, 'regular');
    call add_metric('proc.stat.ctxt', '系统', 'process', '在各个cpu之间变换的内容的数量', 'none', Null, '["host"]', False, 'regular');
    call add_metric('proc.meminfo.percentused', '系统', 'memory', '使用的内存百分比', 'none', Null, '["host"]', False, 'regular');
    call add_metric('proc.meminfo.cmafree', '系统', 'memory', '没有被系统使用物理读写内存的剩余数量以kb作为单位', 'none', Null, '["host"]', False, 'regular');
    call add_metric('proc.meminfo.cmatotal', '系统', 'memory', '物理读写内存的总大小以kb作为单温', 'none', Null, '["host"]', False, 'regular');
    call add_metric('proc.scaling.cur', '系统', 'process', '目前cpu使用频率', 'none', Null, '["host"]', False, 'regular');

    call add_metric('iostat.disk.w_await', '系统', 'io', '平均每次设备I/O写入的等待时间', 'none', Null, '["dev", "host"]', False, 'counter');
    call add_metric('iostat.disk.write_merged', '系统', 'io', '写入的融合数量', 'none', Null, '["dev", "host"]', False, 'counter');
    call add_metric('iostat.disk.write_requests', '系统', 'io', '请求的写入数量', 'none', Null, '["dev", "host"]', False, 'counter');
    call add_metric('iostat.disk.write_sectors', '系统', 'io', '写入的区域数量', 'none', Null, '["dev", "host"]', False, 'counter');
    call add_metric('iostat.part.await', '系统', 'io', '为设备所服务的读取所需平均时间', 'none', Null, '["dev", "host"]', False, 'regular');
    call add_metric('iostat.part.msec_read', '系统', 'io', '读取时间以毫秒为单位', 'none', Null, '["dev", "host"]', False, 'counter');
    call add_metric('iostat.part.msec_total', '系统', 'io', '总时间以毫秒为单位', 'none', Null, '["dev", "host"]', False, 'counter');
    call add_metric('iostat.part.msec_weighted_total', '系统', 'io', '执行IO权重时间', 'none', Null, '["dev", "host"]', False, 'counter');
    call add_metric('iostat.part.msec_write', '系统', 'io', '写入花费时间以毫秒为单位', 'none', Null, '["dev", "host"]', False, 'counter');
    call add_metric('iostat.part.r_await', '系统', 'io', '读的IO请求的处理的平均时间', 'none', Null, '["dev", "host"]', False, 'regular');
    call add_metric('iostat.part.read_merged', '系统', 'io', '读取的融合数量', 'none', Null, '["dev", "host"]', False, 'counter');
    call add_metric('iostat.part.read_requests', '系统', 'io', '请求读取的数量', 'none', Null, '["dev", "host"]', False, 'counter');
    call add_metric('iostat.part.read_sectors', '系统', 'io', '读取的区域数量', 'none', Null, '["dev", "host"]', False, 'counter');
    call add_metric('iostat.part.svctm', '系统', 'io', '表示平均每次设备I/O操作的服务时间（以毫秒为单位）。如果svctm的值与await很接近，表示几乎没有I/O等待，磁盘性能很好，如果await的值远高于svctm的值，则表示I/O队列等待太长，系统上运行的应用程序将变慢。', 'none', Null, '["dev", "host"]', False, 'counter');
    call add_metric('iostat.part.w_await', '系统', 'io', '写的IO请求的处理的平均时间', 'none', Null, '["dev", "host"]', False, 'regular');
    call add_metric('iostat.part.write_merged', '系统', 'io', '写入的融合数量', 'none', Null, '["dev", "host"]', False, 'counter');
    call add_metric('iostat.part.write_requests', '系统', 'io', '请求读取的数量', 'none', Null, '["dev", "host"]', False, 'counter');
    call add_metric('iostat.part.write_sectors', '系统', 'io', '写入的区域数量', 'none', Null, '["dev", "host"]', False, 'counter');

    call add_metric('mem.topN', '系统', 'memory', '内存使用量topn的进程', 'none', Null, '["host", "pid", "pid_cmd"]', False, 'regular');
    call add_metric('netstat.state', '系统', 'net', '现在网络的状态', 'none', Null, '["host"]', False, 'regular');

    call add_metric('procnettcp.state', '系统', 'process', 'tcp目前的状态', 'none', Null, '["host"]', False, 'regular');
    call add_metric('procstats.state', '系统', 'process', '进程目前的状态', 'none', Null, '["host"]', False, 'regular');
    call add_metric('ssh_failed', '系统', 'net', '系统登录失败次数', 'none', Null, '["host","ip","usr"]', False, 'increment');

    call add_metric('jvm.deadlock.num', '系统', 'jvm', '进入死锁状态的JVM线程的数量', 'none', Null, '["host", "proccess", "process"]', False, 'regular');
    call add_metric('jvm.jstat.gcutil.compressed.class.space', '系统', 'jvm', '压缩类空间大小', 'none', Null, '["host", "proccess"]', False, 'regular');
    call add_metric('jvm.jstat.gcutil.full.gc.count', '系统', 'jvm', '老年代垃圾回收次数', 'none', Null, '["host", "proccess"]', False, 'regular');
    call add_metric('jvm.jstat.gcutil.full.gc.time', '系统', 'jvm', '老年代垃圾回收消耗时间', 'none', Null, '["host", "proccess"]', False, 'regular');
    call add_metric('jvm.jstat.gcutil.gc.total.time', '系统', 'jvm', '垃圾回收消耗总时间', 'none', Null, '["host", "proccess"]', False, 'regular');
    call add_metric('jvm.jstat.gcutil.usage.eden.space', '系统', 'jvm', 'Eden Space(伊甸园)的大小', 'none', Null, '["host", "proccess"]', False, 'regular');
    call add_metric('jvm.jstat.gcutil.usage.meta.space', '系统', 'jvm', '方法区使用大小（java1.8支持）', 'none', Null, '["host", "proccess"]', False, 'regular');
    call add_metric('jvm.jstat.gcutil.usage.old.space', '系统', 'jvm', '老年代使用大小', 'none', Null, '["host", "proccess"]', False, 'regular');
    call add_metric('jvm.jstat.gcutil.usage.survivor.space0', '系统', 'jvm', '幸存1区当前使用比例', 'none', Null, '["host", "proccess"]', False, 'regular');
    call add_metric('jvm.jstat.gcutil.usage.survivor.space1', '系统', 'jvm', '幸存2区当前使用比例', 'none', Null, '["host", "proccess"]', False, 'regular');
    call add_metric('jvm.jstat.gcutil.young.gc.count', '系统', 'jvm', '年轻代垃圾回收次数', 'none', Null, '["host", "proccess"]', False, 'regular');
    call add_metric('jvm.jstat.gcutil.young.gc.time', '系统', 'jvm', '年轻代垃圾回收时间', 'none', Null, '["host", "proccess"]', False, 'regular');

--     haiyuan
    call add_metric('hbase.master.Memory.HeapMemoryUsage.used', '服务', 'hbase.master', 'master heap已使用内存大小', 'byte', 'linux,windows', '["host"]', False, 'regular');
    call add_metric('hbase.master.Memory.HeapMemoryUsage.max', '服务', 'hbase.master', 'master heap规定最大大小', 'byte', 'linux,windows', '["host"]', False, 'regular');
    call add_metric('hbase.master.assignmentmanger.ritCountOverThreshold', '服务', 'hbase.master', 'region 执行 transition 操作超过预设时间默认值60秒', 'short', 'linux,windows', '["host"]', False, 'regular');
    call add_metric('hbase.master.assignmentmanger.ritOldestAge', '服务', 'hbase.master', 'region 执行transition操作最长的时间', 'ms', 'linux,windows', '["host"]', False, 'regular');
    call add_metric('hbase.master.asnmp.ssIgnmentmanger.ritCountOverTsnmp.hreshold', '服务', 'hbase.master', 'region 执行 transition 操作超过预设时间默认值60秒', 'short', 'linux,windows', '["host"]', False, 'regular');
    call add_metric('hbase.master.asnmp.ssIgnmentmanger.ritOldestAge', '服务', 'hbase.master', 'region 执行transition操作最长的时间', 'ms', 'linux,windows', '["host"]', False, 'regular');
    call add_metric('hbase.master.asnmp.ssIgnmentmanger.ritCount', '服务', 'hbase.master', 'regions被传送的数量', 'none', 'linux,windows', '["host"]', False, 'regular');
    call add_metric('hbase.master.ipc.ProcessCallTime_num_ops', '服务', 'hbase.master', '处理时间', 'ms', 'linux,windows', '["host"]', False, 'regular');
    call add_metric('hbase.master.ipc.numActiveHandler', '服务', 'hbase.master', 'master处理的IO请求线程数', 'short', 'linux,windows', '["host"]', False, 'regular');
    call add_metric('hbase.master.ipc.numCallsInGeneralQueue', '服务', 'hbase.master', '在general call 队列中call的数量', 'none', 'linux,windows', '["host"]', False, 'regular');
    call add_metric('hbase.master.ipc.numCallsInPriorityQueue', '服务', 'hbase.master', '在priority call 队列中的call的数量', 'none', 'linux,windows', '["host"]', False, 'regular');
    call add_metric('hbase.master.ipc.numCallsInReplicationQueue', '服务', 'hbase.master', '在replication call 队列中的call的数量', 'none', 'linux,windows', '["host"]', False, 'regular');
    call add_metric('hbase.master.ipc.numOpenConnections', '服务', 'hbase.master', '与master连接数量', 'short', 'linux,windows', '["host"]', False, 'regular');
    call add_metric('hbase.master.ipc.queueSize', '服务', 'hbase.master', '在call队列中的byte数量', 'none', 'linux,windows', '["host"]', False, 'regular');
    call add_metric('hbase.master.ipc.receivedBytes', '服务', 'hbase.master', 'master接收数据量', 'bytes', 'linux,windows', '["host"]', False, 'regular');
    call add_metric('hbase.master.ipc.sentBytes', '服务', 'hbase.master', 'master发送数据量', 'bytes', 'linux,windows', '["host"]', False, 'regular');
    call add_metric('hbase.master.jvmmetrics.GcCount', '服务', 'hbase.master', 'GC操作次数', 'short', 'linux,windows', '["host"]', False, 'counter');
    call add_metric('hbase.master.jvmmetrics.GcCountConcurrentMarkSweep', '服务', 'hbase.master', 'CMS GC操作次数', 'short', 'linux,windows', '["host"]', False, 'regular');
    call add_metric('hbase.master.jvmmetrics.GcCountParNew', '服务', 'hbase.master', 'ParNew GC 操作次数', 'short', 'linux,windows', '["host"]', False, 'counter');
    call add_metric('hbase.master.jvmmetrics.GcTimeMillis', '服务', 'hbase.master', 'GC操作时间', 'ms', 'linux,windows', '["host"]', True, 'counter');
    call add_metric('hbase.master.jvmmetrics.GcTimeMillisConcurrentMarkSweep', '服务', 'hbase.master', 'CMS GC操作时间', 'ms', 'linux,windows', '["host"]', False, 'counter');
    call add_metric('hbase.master.jvmmetrics.GcTimeMillisParNew', '服务', 'hbase.master', 'ParNew GC 操作时间', 'ms', 'linux,windows', '["host"]', False, 'counter');
    call add_metric('hbase.master.jvmmetrics.LogError', '服务', 'hbase.master', 'jvm发生崩溃产生ERROR的日志数量', 'short', 'linux,windows', '["host"]', False, 'regular');
    call add_metric('hbase.master.jvmmetrics.LogFatal', '服务', 'hbase.master', 'jvm发生崩溃产生Fatal的日志数量', 'short', 'linux,windows', '["host"]', False, 'regular');
    call add_metric('hbase.master.jvmmetrics.LogInfo', '服务', 'hbase.master', 'jvm发生崩溃产生Info的日志数量', 'short', 'linux,windows', '["host"]', False, 'regular');
    call add_metric('hbase.master.jvmmetrics.LogWarn', '服务', 'hbase.master', 'jvm发生崩溃产生Warn的日志数量', 'short', 'linux,windows', '["host"]', False, 'regular');
    call add_metric('hbase.master.server.averageLoad', '服务', 'hbase.master', 'master 平均负荷', 'short', 'linux,windows', '["host"]', False, 'regular');
    call add_metric('hbase.master.server.clusterRequests', '服务', 'hbase.master', '集群向master 发送的请求数量', 'short', 'linux,windows', '["host"]', False, 'counter');
    call add_metric('hbase.master.server.numDeadRegionServers', '服务', 'hbase.master', 'regionserver 不存活数量', 'short', 'linux,windows', '["host"]', True, 'regular');
    call add_metric('hbase.master.server.numRegionServers', '服务', 'hbase.master', 'regionserver 存活数量', 'short', 'linux,windows', '["host"]', True, 'regular');
    call add_metric('hbase.regionserver.Memory.HeapMemoryUsage.used', '服务', 'hbase.regionserver', 'regionserver heap已使用内存大小', 'byte', 'linux,windows', '["host"]', False, 'regular');
    call add_metric('hbase.regionserver.Memory.HeapMemoryUsage.max', '服务', 'hbase.regionserver', 'regionserver heap规定最大大小', 'byte', 'linux,windows', '["host"]', False, 'regular');
    call add_metric('hbase.regionserver.ipc.QueueCallTime_num_ops', '服务', 'hbase.regionserver', '响应时间', 'ms', 'linux,windows', '["host"]', False, 'regular');
    call add_metric('hbase.regionserver.ipc.numActiveHandler', '服务', 'hbase.regionserver', 'RegionServer处理的IO请求线程数', 'short', 'linux,windows', '["host"]', False, 'regular');
    call add_metric('hbase.regionserver.ipc.numOpenConnections', '服务', 'hbase.regionserver', '连接regionserver的rpc数量', 'short', 'linux,windows', '["host"]', False, 'regular');
    call add_metric('hbase.regionserver.jvmmetrics.GcCount', '服务', 'hbase.regionserver', 'GC操作次数', 'short', 'linux,windows', '["host"]', False, 'counter');
    call add_metric('hbase.regionserver.jvmmetrics.GcCountConcurrentMarkSweep', '服务', 'hbase.regionserver', 'CMS GC操作次数', 'short', 'linux,windows', '["host"]', False, 'regular');
    call add_metric('hbase.regionserver.jvmmetrics.GcCountParNew', '服务', 'hbase.regionserver', 'ParNew GC操作次数', 'short', 'linux,windows', '["host"]', False, 'counter');
    call add_metric('hbase.regionserver.jvmmetrics.GcTimeMillis', '服务', 'hbase.regionserver', 'GC操作时间', 'ms', 'linux,windows', '["host"]', True, 'counter');
    call add_metric('hbase.regionserver.jvmmetrics.GcTimeMillisConcurrentMarkSweep', '服务', 'hbase.regionserver', 'CMS GC操作时间', 'ms', 'linux,windows', '["host"]', False, 'counter');
    call add_metric('hbase.regionserver.jvmmetrics.GcTimeMillisParNew', '服务', 'hbase.regionserver', 'ParNew GC操作时间', 'ms', 'linux,windows', '["host"]', False, 'counter');
    call add_metric('hbase.regionserver.jvmmetrics.LogError', '服务', 'hbase.regionserver', 'jvm发生崩溃产生ERROR的日志数量', 'short', 'linux,windows', '["host"]', False, 'regular');
    call add_metric('hbase.regionserver.jvmmetrics.LogFatal', '服务', 'hbase.regionserver', 'jvm发生崩溃产生Fatal的日志数量', 'short', 'linux,windows', '["host"]', False, 'regular');
    call add_metric('hbase.regionserver.jvmmetrics.LogInfo', '服务', 'hbase.regionserver', 'jvm发生崩溃产生Info的日志数量', 'short', 'linux,windows', '["host"]', False, 'regular');
    call add_metric('hbase.regionserver.jvmmetrics.LogWarn', '服务', 'hbase.regionserver', 'jvm发生崩溃产生Warn的日志数量', 'short', 'linux,windows', '["host"]', False, 'regular');
    call add_metric('hbase.regionserver.regions.storeFileCount', '服务', 'hbase.regionserver', 'storeFile的总个数', 'short', 'linux,windows', '["host", "namespace", "region", "table"]', False, 'counter');
    call add_metric('hbase.regionserver.regions.storeFileSize', '服务', 'hbase.regionserver', 'storeFile的总大小', 'bytes', 'linux,windows', '["host", "namespace", "region", "table"]', False, 'counter');
    call add_metric('hbase.regionserver.server.Append_num_ops', '服务', 'hbase.regionserver', '执行Append操作的次数', 'short', 'linux,windows', '["host"]', False, 'regular');
    call add_metric('hbase.regionserver.server.Delete_num_ops', '服务', 'hbase.regionserver', '执行Delete操作的次数', 'short', 'linux,windows', '["host"]', False, 'counter');
    call add_metric('hbase.regionserver.server.FlushTime_num_ops', '服务', 'hbase.regionserver', '执行FlushTime操作的次数', 'short', 'linux,windows', '["host"]', False, 'counter');
    call add_metric('hbase.regionserver.server.Get_num_ops', '服务', 'hbase.regionserver', '执行Get操作的次数', 'short', 'linux,windows', '["host"]', False, 'counter');
    call add_metric('hbase.regionserver.server.Increment_num_ops', '服务', 'hbase.regionserver', '执行Increment操作的次数', 'short', 'linux,windows', '["host"]', False, 'regular');
    call add_metric('hbase.regionserver.server.Mutate_num_ops', '服务', 'hbase.regionserver', '执行Mutate操作的次数', 'short', 'linux,windows', '["host"]', False, 'regular');
    call add_metric('hbase.regionserver.server.Replay_num_ops', '服务', 'hbase.regionserver', '执行Replay操作的次数', 'short', 'linux,windows', '["host"]', False, 'regular');
    call add_metric('hbase.regionserver.server.ScanNext_num_ops', '服务', 'hbase.regionserver', '执行ScanNext操作的次数', 'short', 'linux,windows', '["host"]', False, 'regular');
    call add_metric('hbase.regionserver.server.SplitTime_num_ops', '服务', 'hbase.regionserver', '执行SplitTime操作的次数', 'short', 'linux,windows', '["host"]', False, 'regular');
    call add_metric('hbase.regionserver.server.blockCacheExpressHitPercent', '服务', 'hbase.regionserver', '缓存的命中率', 'percentage', 'linux,windows', '["host"]', False, 'regular');
    call add_metric('hbase.regionserver.server.blockCacheHitCount', '服务', 'hbase.regionserver', '命中缓存的次数', 'short', 'linux,windows', '["host"]', False, 'counter');
    call add_metric('hbase.regionserver.server.blockCacheMissCount', '服务', 'hbase.regionserver', '缓存不命中的次数', 'short', 'linux,windows', '["host"]', False, 'counter');
    call add_metric('hbase.regionserver.server.hlogFileCount', '服务', 'hbase.regionserver', 'hlog的总数', 'short', 'linux,windows', '["host"]', False, 'regular');
    call add_metric('hbase.regionserver.server.percentFilesLocal', '服务', 'hbase.regionserver', '能够从本地datanode中读取数据的百分比', 'percentage', 'linux,windows', '["host"]', False, 'regular');
    call add_metric('hbase.regionserver.server.readRequestCount', '服务', 'hbase.regionserver', 'regionserver读请求的数量', 'short', 'linux,windows', '["host"]', False, 'regular');
    call add_metric('hbase.regionserver.server.regionCount', '服务', 'hbase.regionserver', 'region的总数', 'short', 'linux,windows', '["host"]', False, 'regular');
    call add_metric('hbase.regionserver.server.slowAppendCount', '服务', 'hbase.regionserver', 'Append操作延迟超过阈值的次数', 'short', 'linux,windows', '["host"]', True, 'counter');
    call add_metric('hbase.regionserver.server.slowDeleteCount', '服务', 'hbase.regionserver', 'Delete操作延迟超过阈值的次数', 'short', 'linux,windows', '["host"]', True, 'counter');
    call add_metric('hbase.regionserver.server.slowGetCount', '服务', 'hbase.regionserver', 'Get操作延迟超过阈值的次数', 'short', 'linux,windows', '["host"]', True, 'counter');
    call add_metric('hbase.regionserver.server.slowIncrementCount', '服务', 'hbase.regionserver', 'Increment操作延迟超过阈值的次数', 'short', 'linux,windows', '["host"]', True, 'counter');
    call add_metric('hbase.regionserver.server.slowPutCount', '服务', 'hbase.regionserver', 'Put操作延迟超过阈值的次数', 'short', 'linux,windows', '["host"]', True, 'counter');
    call add_metric('hbase.regionserver.server.totalRequestCount', '服务', 'hbase.regionserver', 'regionserver 所有请求的数量', 'short', 'linux,windows', '["host"]', False, 'counter');
    call add_metric('hbase.regionserver.server.writeRequestCount', '服务', 'hbase.regionserver', 'regionserver写请求的数量', 'short', 'linux,windows', '["host"]', False, 'counter');
    call add_metric('hbase.regionserver.state', '服务', 'hbase.regionserver', '服务的当前状态（0表示正常，1表示异常）', 'none', 'linux,windows', '["host"]', False, 'regular');

    call add_metric('nginx.active_connections', '服务', 'nginx', '用户正在使用的连接数', 'none', 'linux,windows', '["host"]', True, 'regular');
    call add_metric('nginx.number_requests_reading', '服务', 'nginx', '正在读请求的连接数', 'none', 'linux,windows', '["host"]', False, 'regular');
    call add_metric('nginx.number_requests_waiting', '服务', 'nginx', '空闲（等待请求）的连接数', 'none', 'linux,windows', '["host"]', False, 'regular');
    call add_metric('nginx.number_requests_writing', '服务', 'nginx', '正在写响应的连接数', 'none', 'linux,windows', '["host"]', False, 'regular');
    call add_metric('nginx.state', '服务', 'nginx', '服务的当前状态（0表示正常，1表示异常）', 'none', 'linux,windows', '["host"]', False, 'regular');
    call add_metric('nginx.total_accepted_connections', '服务', 'nginx', '已经接受的连接总数', 'none', 'linux,windows', '["host"]', True, 'counter');
    call add_metric('nginx.total_handled_connections', '服务', 'nginx', '已经处理过的连接总数', 'none', 'linux,windows', '["host"]', True, 'counter');
    call add_metric('nginx.total_number_handled_requests', '服务', 'nginx', '用户请求总数', 'none', 'linux,windows', '["host"]', True, 'counter');


--     liuhui
    call add_metric('hadoop.datanode.activity.BlocksRead', '服务', 'hadoop.datanode', '从硬盘读块的次数', 'short', 'linux,windows', '["host"]', False, 'counter');
    call add_metric('hadoop.datanode.activity.BlocksRemoved', '服务', 'hadoop.datanode', '删除块操作的次数', 'short', 'linux,windows', '["host"]', False, 'counter');
    call add_metric('hadoop.datanode.activity.BlocksReplicated', '服务', 'hadoop.datanode', '备份块操作的个数', 'short', 'linux,windows', '["host"]', False, 'counter');
    call add_metric('hadoop.datanode.activity.BlocksWritten', '服务', 'hadoop.datanode', '从硬盘写块的次数', 'short', 'linux,windows', '["host"]', False, 'counter');
    call add_metric('hadoop.datanode.activity.BytesRead', '服务', 'hadoop.datanode', '从硬盘读块的字节数', 'bytes', 'linux,windows', '["host"]', False, 'counter');
    call add_metric('hadoop.datanode.activity.BytesWritten', '服务', 'hadoop.datanode', '从硬盘写块的字节数', 'bytes', 'linux,windows', '["host"]', False, 'counter');
    call add_metric('hadoop.datanode.activity.CopyBlockOpNumOps', '服务', 'hadoop.datanode', '复制块操作的个数', 'short', 'linux,windows', '["host"]', False, 'counter');
    call add_metric('hadoop.datanode.activity.FlushNanosAvgTime', '服务', 'hadoop.datanode', '文件系统flush平均花费时间', 'nano second', 'linux,windows', '["host"]', False, 'regular');
    call add_metric('hadoop.datanode.activity.FlushNanosNumOps', '服务', 'hadoop.datanode', '文件系统flush次数', 'short', 'linux,windows', '["host"]', False, 'regular');
    call add_metric('hadoop.datanode.activity.HeartbeatsNumOps', '服务', 'hadoop.datanode', '向namenode汇报的次数', 'short', 'linux,windows', '["host"]', False, 'counter');
    call add_metric('hadoop.datanode.activity.ReadBlockOpAvgTime', '服务', 'hadoop.datanode', '读操作平均花费时间', 'nano second', 'linux,windows', '["host"]', True, 'regular');
    call add_metric('hadoop.datanode.activity.ReadsFromLocalClient', '服务', 'hadoop.datanode', '本地读取的次数', 'short', 'linux,windows', '["host"]', False, 'counter');
    call add_metric('hadoop.datanode.activity.ReadsFromRemoteClient', '服务', 'hadoop.datanode', '远程读取的次数', 'short', 'linux,windows', '["host"]', False, 'counter');
    call add_metric('hadoop.datanode.activity.SendDataPacketBlockedOnNetworkNanosAvgTime', '服务', 'hadoop.datanode', '网络上发送块平均时间', 'nano second', 'linux,windows', '["host"]', False, 'regular');
    call add_metric('hadoop.datanode.activity.SendDataPacketTransferNanosAvgTime', '服务', 'hadoop.datanode', '网络上发送包平均时间', 'nano second', 'linux,windows', '["host"]', False, 'regular');
    call add_metric('hadoop.datanode.activity.VolumeFailures', '服务', 'hadoop.datanode', '单个磁盘簇出错导致服务异常的次数', 'short', 'linux,windows', '["host"]', True, 'counter');
    call add_metric('hadoop.datanode.activity.WriteBlockOpAvgTime', '服务', 'hadoop.datanode', '写操作平均花费时间', 'nano second', 'linux,windows', '["host"]', True, 'regular');
    call add_metric('hadoop.datanode.activity.WritesFromLocalClient', '服务', 'hadoop.datanode', '写本地的次数', 'short', 'linux,windows', '["host"]', False, 'counter');
    call add_metric('hadoop.datanode.activity.WritesFromRemoteClient', '服务', 'hadoop.datanode', '写远程的次数', 'short', 'linux,windows', '["host"]', False, 'counter');
    call add_metric('hadoop.datanode.fsdatasetstate-null.Remaining', '服务', 'hadoop.datanode', 'datanode 文件系统剩余的容量', 'bytes', 'linux,windows', '["host"]', True, 'regular');
    call add_metric('hadoop.datanode.jvmmetrics.GcCount', '服务', 'hadoop.datanode', 'JVM进行GC的次数', 'short', 'linux,windows', '["host"]', False, 'counter');
    call add_metric('hadoop.datanode.jvmmetrics.LogError', '服务', 'hadoop.datanode', 'GC Log中输出ERROR的次数', 'short', 'linux,windows', '["host"]', False, 'counter');
    call add_metric('hadoop.datanode.jvmmetrics.LogFatal', '服务', 'hadoop.datanode', 'GC Log中输出FATAL的次数', 'short', 'linux,windows', '["host"]', False, 'counter');
    call add_metric('hadoop.datanode.jvmmetrics.LogInfo', '服务', 'hadoop.datanode', 'GC Log中输出INFO的次数', 'short', 'linux,windows', '["host"]', False, 'counter');
    call add_metric('hadoop.datanode.jvmmetrics.LogWarn', '服务', 'hadoop.datanode', 'GC Log中输出WARN的次数', 'short', 'linux,windows', '["host"]', False, 'counter');
    call add_metric('hadoop.datanode.jvmmetrics.MemHeapMaxM', '服务', 'hadoop.datanode', 'JVM分配的堆大小', 'megabytes', 'linux,windows', '["host"]', False, 'regular');
    call add_metric('hadoop.datanode.jvmmetrics.MemHeapUsedM', '服务', 'hadoop.datanode', 'JVM已经使用的堆大小', 'megabytes', 'linux,windows', '["host"]', False, 'regular');
    call add_metric('hadoop.datanode.jvmmetrics.ThreadsBlocked', '服务', 'hadoop.datanode', '处于BLOCKED状态线程数量', 'short', 'linux,windows', '["host"]', False, 'regular');
    call add_metric('hadoop.datanode.jvmmetrics.ThreadsNew', '服务', 'hadoop.datanode', '处于NEW状态线程数量', 'short', 'linux,windows', '["host"]', False, 'regular');
    call add_metric('hadoop.datanode.jvmmetrics.ThreadsRunnable', '服务', 'hadoop.datanode', '处于RUNNABLE状态线程数量', 'short', 'linux,windows', '["host"]', False, 'regular');
    call add_metric('hadoop.datanode.state', '服务', 'hadoop.datanode', '服务的当前状态（0表示正常，1表示异常）', 'none', 'linux,windows', '["host"]', False, 'regular');

    
    call add_metric('hadoop.namenode.fsnamesystem.CapacityRemaining', '服务', 'hadoop.namenode', 'HDFS文件系统剩余的容量', 'bytes', 'linux,windows', '["host"]', True, 'regular');
    call add_metric('hadoop.namenode.fsnamesystem.CapacityRemainingGB', '服务', 'hadoop.namenode', 'HDFS文件系统剩余的容量(单位GB)', 'gigabytes', 'linux,windows', '["host"]', True, 'regular');
    call add_metric('hadoop.namenode.fsnamesystem.CapacityTotal', '服务', 'hadoop.namenode', 'HDFS文件系统总体容量', 'bytes', 'linux,windows', '["host"]', False, 'regular');
    call add_metric('hadoop.namenode.fsnamesystem.CapacityTotalGB', '服务', 'hadoop.namenode', 'HDFS文件系统总体容量(单位GB)', 'gigabytes', 'linux,windows', '["host"]', False, 'regular');
    call add_metric('hadoop.namenode.fsnamesystem.CapacityUsed', '服务', 'hadoop.namenode', 'HDFS文件系统已使用的容量', 'bytes', 'linux,windows', '["host"]', False, 'regular');
    call add_metric('hadoop.namenode.fsnamesystem.CapacityUsedGB', '服务', 'hadoop.namenode', 'HDFS文件系统已使用的容量(单位GB)', 'gigabytes', 'linux,windows', '["host"]', False, 'regular');
    call add_metric('hadoop.namenode.fsnamesystem.CorruptBlocks', '服务', 'hadoop.namenode', '已损坏的block数量', 'short', 'linux,windows', '["host"]', True, 'regular');
    call add_metric('hadoop.namenode.fsnamesystem.MissingBlocks', '服务', 'hadoop.namenode', '丢失的block数量', 'short', 'linux,windows', '["host"]', True, 'regular');
    call add_metric('hadoop.namenode.fsnamesystemstate.FilesTotal', '服务', 'hadoop.namenode', '文件总数', 'short', 'linux,windows', '["host"]', True, 'regular');
    call add_metric('hadoop.namenode.fsnamesystemstate.NumDeadDataNodes', '服务', 'hadoop.namenode', '死亡datanode 个数', 'short', 'linux,windows', '["host"]', True, 'regular');
    call add_metric('hadoop.namenode.fsnamesystemstate.TotalLoad', '服务', 'hadoop.namenode', '标识所有DataNodes上的文件访问次数', 'short', 'linux,windows', '["host"]', True, 'regular');
    call add_metric('hadoop.namenode.fsnamesystemstate.UnderReplicatedBlocks', '服务', 'hadoop.namenode', '副本个数不够的block', 'short', 'linux,windows', '["host"]', True, 'regular');
    call add_metric('hadoop.namenode.jvmmetrics.GcCount', '服务', 'hadoop.namenode', 'JVM进行GC的次数', 'short', 'linux,windows', '["host"]', False, 'counter');
    call add_metric('hadoop.namenode.jvmmetrics.GcTimeMillis', '服务', 'hadoop.namenode', 'GC花费的时间单位为微妙', 'ms', 'linux,windows', '["host"]', False, 'counter');
    call add_metric('hadoop.namenode.jvmmetrics.LogError', '服务', 'hadoop.namenode', 'GC Log中输出ERROR的次数', 'short', 'linux,windows', '["host"]', False, 'regular');
    call add_metric('hadoop.namenode.jvmmetrics.LogFatal', '服务', 'hadoop.namenode', 'GC Log中输出FATAL的次数', 'short', 'linux,windows', '["host"]', False, 'regular');
    call add_metric('hadoop.namenode.jvmmetrics.LogInfo', '服务', 'hadoop.namenode', 'GC Log中输出INFO的次数', 'short', 'linux,windows', '["host"]', False, 'regular');
    call add_metric('hadoop.namenode.jvmmetrics.LogWarn', '服务', 'hadoop.namenode', 'GC Log中输出WARN的次数', 'short', 'linux,windows', '["host"]', False, 'regular');
    call add_metric('hadoop.namenode.jvmmetrics.MemHeapMaxM', '服务', 'hadoop.namenode', 'JVM分配的堆大小', 'megabytes', 'linux,windows', '["host"]', False, 'regular');
    call add_metric('hadoop.namenode.jvmmetrics.MemHeapUsedM', '服务', 'hadoop.namenode', 'JVM已经使用的堆大小', 'megabytes', 'linux,windows', '["host"]', False, 'regular');
    call add_metric('hadoop.namenode.jvmmetrics.ThreadsBlocked', '服务', 'hadoop.namenode', '处于BLOCKED状态线程数量', 'short', 'linux,windows', '["host"]', False, 'regular');
    call add_metric('hadoop.namenode.jvmmetrics.ThreadsNew', '服务', 'hadoop.namenode', '处于NEW状态线程数量', 'short', 'linux,windows', '["host"]', False, 'regular');
    call add_metric('hadoop.namenode.jvmmetrics.ThreadsRunnable', '服务', 'hadoop.namenode', '处于RUNNABLE状态线程数量', 'short', 'linux,windows', '["host"]', False, 'regular');
    call add_metric('hadoop.namenode.namenodeactivity.AddBlockOps', '服务', 'hadoop.namenode', '写入block次数', 'short', 'linux,windows', '["host"]', False, 'counter');
    call add_metric('hadoop.namenode.namenodeactivity.BlockReportNumOps', '服务', 'hadoop.namenode', 'block report的次数', 'short', 'linux,windows', '["host"]', False, 'counter');
    call add_metric('hadoop.namenode.namenodeactivity.CreateFileOps', '服务', 'hadoop.namenode', '创建文件次数', 'short', 'linux,windows', '["host"]', False, 'counter');
    call add_metric('hadoop.namenode.namenodeactivity.DeleteFileOps', '服务', 'hadoop.namenode', '删除文件次数', 'short', 'linux,windows', '["host"]', False, 'counter');
    call add_metric('hadoop.namenode.state', '服务', 'hadoop.namenode', '服务的当前状态（0表示正常，1表示异常）', 'none', 'linux,windows', '["host"]', False, 'regular');

    call add_metric('mapreduce.job.counter.mapCounterValue', '服务', 'mapreduce', 'Counter value of map tasks', 'short', 'linux,windows', '["host"]', False, 'regular');
    call add_metric('mapreduce.job.counter.reduceCounterValue', '服务', 'mapreduce', 'Counter value of reduce tasks', 'short', 'linux,windows', '["host"]', False, 'regular');
    call add_metric('mapreduce.job.counter.totalCounterValue', '服务', 'mapreduce', 'Counter value of all tasks', 'short', 'linux,windows', '["host"]', False, 'regular');
    call add_metric('mapreduce.job.elapsedTime', '服务', 'mapreduce', 'elapsed time since the application started', 'ms', 'linux,windows', '["host"]', False, 'regular');
    call add_metric('mapreduce.job.failedMapAttempts', '服务', 'mapreduce', 'Number of failed map attempts', 'short', 'linux,windows', '["host"]', True, 'regular');
    call add_metric('mapreduce.job.failedReduceAttempts', '服务', 'mapreduce', 'Number of failed reduce attempts', 'short', 'linux,windows', '["host"]', True, 'regular');
    call add_metric('mapreduce.job.killedMapAttempts', '服务', 'mapreduce', 'Number of killed map attempts', 'short', 'linux,windows', '["host"]', False, 'regular');
    call add_metric('mapreduce.job.killedReduceAttempts', '服务', 'mapreduce', 'Number of killed reduce attempts', 'short', 'linux,windows', '["host"]', False, 'regular');
    call add_metric('mapreduce.job.map.task.progress', '服务', 'mapreduce', '', 'none', 'linux,windows', '["host"]', False, 'regular');
    call add_metric('mapreduce.job.mapsCompleted', '服务', 'mapreduce', 'Number of completed maps', 'short', 'linux,windows', '["host"]', False, 'regular');
    call add_metric('mapreduce.job.mapsPending', '服务', 'mapreduce', 'Number of pending maps', 'short', 'linux,windows', '["host"]', False, 'regular');
    call add_metric('mapreduce.job.mapsRunning', '服务', 'mapreduce', 'Number of running maps', 'short', 'linux,windows', '["host"]', False, 'regular');
    call add_metric('mapreduce.job.mapsTotal', '服务', 'mapreduce', 'Total number of maps', 'short', 'linux,windows', '["host"]', True, 'regular');
    call add_metric('mapreduce.job.newMapAttempts', '服务', 'mapreduce', 'Number of new map attempts', 'short', 'linux,windows', '["host"]', False, 'regular');
    call add_metric('mapreduce.job.newReduceAttempts', '服务', 'mapreduce', 'Number of new reduce attempts', 'short', 'linux,windows', '["host"]', False, 'regular');
    call add_metric('mapreduce.job.reduce.task.progress', '服务', 'mapreduce', '', 'none', 'linux,windows', '["host"]', False, 'regular');
    call add_metric('mapreduce.job.reducesCompleted', '服务', 'mapreduce', 'Number of completed reduces', 'short', 'linux,windows', '["host"]', False, 'regular');
    call add_metric('mapreduce.job.reducesPending', '服务', 'mapreduce', 'Number of pending reduces', 'short', 'linux,windows', '["host"]', False, 'regular');
    call add_metric('mapreduce.job.reducesRunning', '服务', 'mapreduce', 'Number of running reduces', 'short', 'linux,windows', '["host"]', False, 'regular');
    call add_metric('mapreduce.job.reducesTotal', '服务', 'mapreduce', 'Number of reduces', 'short', 'linux,windows', '["host"]', True, 'regular');
    call add_metric('mapreduce.job.runningMapAttempts', '服务', 'mapreduce', 'Number of running map attempts', 'short', 'linux,windows', '["host"]', False, 'regular');
    call add_metric('mapreduce.job.runningReduceAttempts', '服务', 'mapreduce', 'Number of running reduce attempts', 'short', 'linux,windows', '["host"]', False, 'regular');
    call add_metric('mapreduce.job.successfulMapAttempts', '服务', 'mapreduce', 'Number of successful map attempts', 'short', 'linux,windows', '["host"]', True, 'regular');
    call add_metric('mapreduce.job.successfulReduceAttempts', '服务', 'mapreduce', 'Number of successful reduce attempts', 'short', 'linux,windows', '["host"]', True, 'regular');

--     sunying
    call add_metric('mongo.state', '服务', 'mongo3', '服务的当前状态（0表示正常，1表示异常）', 'none', 'linux', '["host"]', False, 'regular');
    call add_metric('mongo.asserts.msg','服务','mongo3','asserts出现的次数','short','linux','["host"]',True,'regular');
    call add_metric('mongo.asserts.regular','服务','mongo3','有规律的asserts出现的次数','short','linux','["host"]',True,'regular');
    call add_metric('mongo.asserts.rollovers','服务','mongo3','Numberoftimesthattherollovercountersrolloverpersecond.Thecountersrollovertozeroevery2tothe30assertions.','short','linux','["host"]',False,'regular');
    call add_metric('mongo.asserts.user','服务','mongo3','Numberofuserassertionsraisedpersecond.','short','linux','["host"]',True,'regular');
    call add_metric('mongo.asserts.warning','服务','mongo3','Warningsassert出现的次数','short','linux','["host"]',True,'regular');
    call add_metric('mongo.backgroundFlushing.average_ms','服务','mongo3','每次刷新到磁盘的平均时间。','none','linux','["host"]',False,'regular');
    call add_metric('mongo.backgroundFlushing.flushes','服务','mongo3','数据库刷新所有写入磁盘的次数。','none','linux','["host"]',False,'regular');
    call add_metric('mongo.backgroundFlushing.total_ms','服务','mongo3','"mongod" 进程用于写入磁盘 (如刷新) 数据的总时间数。','none','linux','["host"]',False,'regular');
    call add_metric('mongo.connections.available','服务','mongo3','可用连接数','short','linux','["host"]',True,'regular');
    call add_metric('mongo.connections.current','服务','mongo3','用户正在使用的连接数','short','linux','["host"]',True,'regular');
    call add_metric('mongo.cursors.clientCursors_size','服务','mongo3','客户端游标大小','none','linux','["host"]',False,'regular');
    call add_metric('mongo.cursors.timedOut','服务','mongo3','自服务器进程启动以来已超时的cursors总数。','none','linux','["host"]',False,'regular');
    call add_metric('mongo.cursors.totalOpen','服务','mongo3','MongoDB 为客户端维护的cursors数','none','linux','["host"]',False,'regular');
    call add_metric('mongo.dur.commits','服务','mongo3','在上一个日志组提交间隔期间写入日志的transactions数。','none','linux','["host"]',True,'regular');
    call add_metric('mongo.dur.commitsInWriteLock','服务','mongo3','保存写入锁定时发生的提交的计数。','none','linux','["host"]',False,'regular');
    call add_metric('mongo.dur.compression','服务','mongo3','写入日志的数据的压缩比率。','none','linux','["host"]',False,'regular');
    call add_metric('mongo.dur.earlyCommits','服务','mongo3','MongoDB 在计划的日志组提交间隔之前请求提交的次数。','none','linux','["host"]',False,'regular');
    call add_metric('mongo.dur.journaledMB','服务','mongo3','在上一个日志组提交间隔期间写入日志的数据量。','none','linux','["host"]',True,'regular');
    call add_metric('mongo.dur.timeMs.dt','服务','mongo3','MongoDB 收集 "dur.tisnmp.memS" 数据的时间量。','ms','linux','["host"]',False,'regular');
    call add_metric('mongo.dur.timeMs.prepLogBuffer','服务','mongo3','准备写入journal所用的时间量。','ms','linux','["host"]',False,'regular');
    call add_metric('mongo.dur.timeMs.remapPrivateView','服务','mongo3','重新映射copy-on-write 内存映射视图所用的时间量。','ms','linux','["host"]',False,'regular');
    call add_metric('mongo.dur.timeMs.writeToDataFiles','服务','mongo3','在日志记录后写入数据文件所用的时间量。','ms','linux','["host"]',False,'regular');
    call add_metric('mongo.dur.timeMs.writeToJournal','服务','mongo3','写入journal所用的时间量','ms','linux','["host"]',False,'regular');
    call add_metric('mongo.dur.writeToDataFilesMB','服务','mongo3','在上一个日志组提交间隔期间, 从日志写入数据文件的数据量。','none','linux','["host"]',False,'regular');
    call add_metric('mongo.extra_info.heap_usage_bytes','服务','mongo3','数据库进程使用的总的堆空间','none','linux','["host"]',False,'regular');
    call add_metric('mongo.extra_info.page_faults','服务','mongo3','页故障总数','short','linux','["host"]',False,'regular');
    call add_metric('mongo.globalLock.activeClients.readers','服务','mongo3','使用全局锁执行读取操作的客户端数目','short','linux','["host"]',True,'regular');
    call add_metric('mongo.globalLock.activeClients.total','服务','mongo3','使用全局锁的客户端总数(activeClients.readers+activeClients.writers)','short','linux','["host"]',False,'regular');
    call add_metric('mongo.globalLock.activeClients.writers','服务','mongo3','使用全局锁执行写操作的客户端数目','short','linux','["host"]',True,'regular');
    call add_metric('oracle.active','服务','oracle','是否运行。1:是0:否','none','linux','["host"]',False,'regular');
    call add_metric('oracle.activeusercount','服务','oracle','活跃用户量','none','linux','["host"]',False,'regular');
    call add_metric('oracle.bufbusywaits','服务','oracle','','none','linux','["host"]',False,'regular');
    call add_metric('oracle.commits','服务','oracle','Commit次数','none','linux','["host"]',False,'regular');
    call add_metric('oracle.dbfilesize','服务','oracle','所有文件大小','bytes','linux','["host"]',True,'regular');
    call add_metric('oracle.dbsize','服务','oracle','用户数据大小，不包括临时表','bytes','linux','["host"]',False,'regular');
    call add_metric('oracle.deadlocks','服务','oracle','死锁次数','none','linux','["host"]',True,'regular');
    call add_metric('oracle.dsksortratio','服务','oracle','','none','linux','["host"]',False,'regular');
    call add_metric('oracle.indexffs','服务','oracle','Numberoffastfullscansinitiatedforfullsegments','none','linux','["host"]',False,'regular');
    call add_metric('oracle.logfilesync','服务','oracle','','none','linux','["host"]',False,'regular');
    call add_metric('oracle.logonscurrent','服务','oracle','Totalnumberofcurrentlogons.目前登陆的用户量。','none','linux','["host"]',False,'regular');
    call add_metric('oracle.logprllwrite','服务','oracle','','none','linux','["host"]',False,'regular');
    call add_metric('oracle.netresv','服务','oracle','bytesreceivedviaSQL*Netfromclient（从客户端接受的流量）','bytes','linux','["host"]',False,'regular');
    call add_metric('oracle.netroundtrips','服务','oracle','SQL*Netroundtripsto/fromclient','bytes','linux','["host"]',False,'regular');
    call add_metric('oracle.netsent','服务','oracle','bytessentviaSQL*Nettoclient（发送给用户的流量）','bytes','linux','["host"]',False,'regular');
    call add_metric('oracle.rcachehit','服务','oracle','buffercache大小是否合适。比率值应该尽可能接近100','none','linux','["host"]',True,'regular');
    call add_metric('oracle.redowrites','服务','oracle','重写次数','none','linux','["host"]',False,'regular');
    call add_metric('oracle.rollbacks','服务','oracle','Rollback次数','none','linux','["host"]',False,'regular');
    call add_metric('oracle.state','服务','oracle','服务的当前状态（0表示正常，1表示异常）','none','linux','["host"]',False,'regular');
    call add_metric('oracle.tblrowsscans','服务','oracle','Scan处理的行数','none','linux','["host"]',False,'regular');
    call add_metric('oracle.tblscans','服务','oracle','过长的表的数量','none','linux','["host"]',False,'regular');
    call add_metric('oracle.uptime','服务','oracle','运行时间','s','linux','["host"]',False,'regular');
    call add_metric('oracle.disksortratio','服务','oracle','该项显示内存中完成的排序所占比例。最理想状态下，在OLTP系统中，大部分排序不仅小并且能够完全在内存里完成排序。比率值尽可能接近0.','none','linux','["host"]',False,'regular');
    call add_metric('oracle.hardparseratio','服务','oracle','硬解析／（硬解析+软解析）*100。越接近0越好。','none','linux','["host"]',False,'regular');
    call add_metric('oracle.lastarclog','服务','oracle','Lastarchivedlogsequence','none','linux','["host"]',False,'regular');
    call add_metric('oracle.lastapplarclog','服务','oracle','Lastappliedarchivelog(atstandby).Nextitemsrequires[timed_statistics=true]','none','linux','["host"]',False,'regular');
    call add_metric('oracle.event.freebufwaits','服务','oracle','等待freebuffer的次数（等待时间一般1秒）','none','linux','["host"]',False,'regular');
    call add_metric('oracle.event.bufbusywaits','服务','oracle','等待一个bufferavailable的次数。Waituntilabufferbecomesavailable.Thiseventhappensbecauseabufferiseitherbeingreadintothebuffercachebyanothersession(andthesessioniswaitingforthatreadtocomplete)orthebufferisthebuffercache,butinaincompatiblemode(thatis,someothersessionischangingthebuffer).','none','linux','["host"]',False,'regular');
    call add_metric('oracle.event.logfilesync','服务','oracle','等待Log文件sync的event次数','none','linux','["host"]',False,'regular');
    call add_metric('oracle.event.logparallelwrite','服务','oracle','等待Log文件并行写的event数量','none','linux','["host"]',False,'regular');
    call add_metric('oracle.event.enqueue','服务','oracle','等待localenqueue的events数量','none','linux','["host"]',False,'regular');
    call add_metric('oracle.event.dbseqread','服务','oracle','等待DBfilesequentialreadwaitsevents数量','none','linux','["host"]',False,'regular');
    call add_metric('oracle.event.dbscattread','服务','oracle','等待DBfilescatteredreadevents数量','none','linux','["host"]',False,'regular');
    call add_metric('oracle.event.dbsinglewrite','服务','oracle','等待DBfilesinglewriteevents数量','none','linux','["host"]',False,'regular');
    call add_metric('oracle.event.dbparallelwrite','服务','oracle','等待DBfileparallelwriteevents数量','none','linux','["host"]',False,'regular');
    call add_metric('oracle.event.directread','服务','oracle','等待directpathread的events数量','none','linux','["host"]',False,'regular');
    call add_metric('oracle.event.directwrite','服务','oracle','等待directpathwrite的events数量','none','linux','["host"]',False,'regular');
    call add_metric('oracle.event.latchfree','服务','oracle','等待latch变free的events的数量','none','linux','["host"]',False,'regular');
    call add_metric('oracle.query_sessions','服务','oracle','Querysessions','none','linux','["host"]',True,'regular');
    call add_metric('oracle.query_rollbacks','服务','oracle','Queryrollbacks','none','linux','["host"]',False,'regular');
    call add_metric('rabbitmq.aliveness','服务','rabbitmq','','','linux','["host"]',False,'regular');
    call add_metric('rabbitmq.connections','服务','rabbitmq','当前vhost连接数','short','linux','["host"]',False,'regular');
    call add_metric('rabbitmq.node.fd_used','服务','rabbitmq','已使用的FileDescriptors','short','linux','["host"]',False,'regular');
    call add_metric('rabbitmq.node.mem_used','服务','rabbitmq','占用内存大小','short','linux','["host"]',True,'regular');
    call add_metric('rabbitmq.node.partitions','服务','rabbitmq','该节点所监控的网段数量','short','linux','["host"]',False,'regular');
    call add_metric('rabbitmq.node.run_queue','服务','rabbitmq','等待运行的Erlang进程平均数量','short','linux','["host"]',False,'regular');
    call add_metric('rabbitmq.node.sockets_used','服务','rabbitmq','被用作socket的filedescriptor数量','short','linux','["host"]',False,'regular');
    call add_metric('rabbitmq.queue.consumers','服务','rabbitmq','用户数量','short','linux','["host"]',False,'regular');
    call add_metric('rabbitmq.queue.memory','服务','rabbitmq','队列所使用内存','short','linux','["host"]',True,'regular');
    call add_metric('rabbitmq.queue.messages','服务','rabbitmq','队列内总message数','short','linux','["host"]',False,'regular');
    call add_metric('rabbitmq.queue.messages.deliver_get.count','服务','rabbitmq','四种模式下的message总数','short','linux','["host"]',False,'regular');
    call add_metric('rabbitmq.queue.messages.deliver_get.rate','服务','rabbitmq','每秒四种模式下的message总数','short','linux','["host"]',False,'regular');
    call add_metric('rabbitmq.queue.messages.publish.count','服务','rabbitmq','已分发的message总数','short','linux','["host"]',False,'regular');
    call add_metric('rabbitmq.queue.messages.publish.rate','服务','rabbitmq','每秒已分发的message总数','short','linux','["host"]',False,'regular');
    call add_metric('rabbitmq.queue.messages.rate','服务','rabbitmq','队列内每秒总message数','short','linux','["host"]',True,'regular');
    call add_metric('rabbitmq.queue.messages_ready','服务','rabbitmq','准备发送给客户端的message总数','short','linux','["host"]',False,'regular');
    call add_metric('rabbitmq.queue.messages_ready.rate','服务','rabbitmq','每秒准备发送给客户端的message总数','short','linux','["host"]',False,'regular');
    call add_metric('rabbitmq.queue.messages_unacknowledged','服务','rabbitmq','未被承认的即将发送给客户端的message总数','short','linux','["host"]',False,'regular');
    call add_metric('rabbitmq.queue.messages_unacknowledged.rate','服务','rabbitmq','每秒未被承认的即将发送给客户端的message总数','short','linux','["host"]',False,'regular');
    call add_metric('rabbitmq.state','服务','rabbitmq','服务的当前状态（0表示正常，1表示异常）','none','linux','["host"]',False,'regular');
    call add_metric('rabbitmq.queue.active_consumers','服务','rabbitmq','活跃用户的数量活跃用户可以立即接收发送到队列中的message','short','linux','["host"]',False,'regular');
    call add_metric('rabbitmq.queue.consumer_utilisation','服务','rabbitmq','队列用户中可接收消息的时间比例','short','linux','["host"]',True,'regular');
    call add_metric('rabbitmq.queue.messages.ack.count','服务','rabbitmq','已承认,已发送的message总数','short','linux','["host"]',False,'regular');
    call add_metric('rabbitmq.queue.messages.ack.rate','服务','rabbitmq','每秒已承认,已发送的message总数','short','linux','["host"]',False,'regular');
    call add_metric('rabbitmq.queue.messages.deliver.count','服务','rabbitmq','acknowledgement模式下已发送的message','short','linux','["host"]',False,'regular');
    call add_metric('rabbitmq.queue.messages.deliver.rate','服务','rabbitmq','每acknowledgement模式下已发送的message','short','linux','["host"]',False,'regular');
    call add_metric('rabbitmq.queue.messages.redeliver.count','服务','rabbitmq','deliver_get中有redeliver标签的message数量','short','linux','["host"]',False,'regular');
    call add_metric('rabbitmq.queue.messages.redeliver.rate','服务','rabbitmq','每秒deliver_get中有redeliver标签的message数量','short','linux','["host"]',False,'regular');
    call add_metric('rabbitmq.connections.state','服务','rabbitmq','指定状态的vhost连接数','short','linux','["host"]',False,'regular');

--     zhognyang
    call add_metric('spark.executor.activeTasks', '服务', 'spark', 'Number of active tasks in the application', 'short', 'linux,windows', '["host"]', True,'regular');
    call add_metric('spark.executor.completedTasks', '服务', 'spark', 'Number of complete tasks in the application''s stages', 'short', 'linux,windows', '["host"]', False,'regular');
    call add_metric('spark.executor.count', '服务', 'spark', 'Number of executor', 'short', 'linux,windows', '["host"]', False,'regular');
    call add_metric('spark.executor.diskUsed', '服务', 'spark', 'Amount of disk used in the driver', 'bytes', 'linux,windows', '["host"]', False,'regular');
    call add_metric('spark.executor.failedTasks', '服务', 'spark', 'Number of faied tasks in the driver', 'short', 'linux,windows', '["host"]', True,'regular');
    call add_metric('spark.executor.maxMemory', '服务', 'spark', 'Maximum memory used in the driver', 'bytes', 'linux,windows', '["host"]', False,'regular');
    call add_metric('spark.executor.memoryUsed', '服务', 'spark', 'Amount of memory to use per executor process', 'bytes', 'linux,windows', '["host"]', False,'regular');
    call add_metric('spark.executor.rddBlocks', '服务', 'spark', 'Number of RDD blocks in the driver', 'short', 'linux,windows', '["host"]', False,'regular');
    call add_metric('spark.executor.totalDuration', '服务', 'spark', 'Fraction of time (ms/s) spent by the driver', 'ms', 'linux,windows', '["host"]', True,'regular');
    call add_metric('spark.executor.totalInputBytes', '服务', 'spark', 'Number of input bytes in the driver', 'bytes', 'linux,windows', '["host"]', False,'regular');
    call add_metric('spark.executor.totalShuffleRead', '服务', 'spark', 'Number of bytes read during a shuffle in the driver', 'bytes', 'linux,windows', '["host"]', False,'regular');
    call add_metric('spark.executor.totalShuffleWrite', '服务', 'spark', 'Number of shuffled bytes in the driver', 'bytes', 'linux,windows', '["host"]', False,'regular');
    call add_metric('spark.executor.totalTasks', '服务', 'spark', 'Number of total tasks in the driver', 'short', 'linux,windows', '["host"]', True,'regular');
    call add_metric('spark.job.count', '服务', 'spark', 'Number of job', 'short', 'linux,windows', '["host"]', False,'regular');
    call add_metric('spark.job.numActiveStages', '服务', 'spark', 'Number of active stages in the application', 'short', 'linux,windows', '["host"]', False,'regular');
    call add_metric('spark.job.numActiveTasks', '服务', 'spark', 'Number of active tasks in the application''s stages', 'short', 'linux,windows', '["host"]', False,'regular');
    call add_metric('spark.job.numCompletedStages', '服务', 'spark', 'Number of completed stages in the application', 'short', 'linux,windows', '["host"]', False,'regular');
    call add_metric('spark.job.numCompletedTasks', '服务', 'spark', 'Number of complete tasks in the application''s stages', 'short', 'linux,windows', '["host"]', False,'regular');
    call add_metric('spark.job.numFailedStages', '服务', 'spark', 'Number of failed stages in the application', 'short', 'linux,windows', '["host"]', True,'regular');
    call add_metric('spark.job.numFailedTasks', '服务', 'spark', 'Number of failed tasks in the application''s stages', 'short', 'linux,windows', '["host"]', True,'regular');
    call add_metric('spark.job.numSkippedStages', '服务', 'spark', 'Number of skipped stages in the application', 'short', 'linux,windows', '["host"]', False,'regular');
    call add_metric('spark.job.numSkippedTasks', '服务', 'spark', 'Number of skipped tasks in the application', 'short', 'linux,windows', '["host"]', False,'regular');
    call add_metric('spark.job.numTasks', '服务', 'spark', 'Number of tasks in the application', 'short', 'linux,windows', '["host"]', False,'regular');
    call add_metric('spark.rdd.count', '服务', 'spark', 'Number of red', 'short', 'linux,windows', '["host"]', False,'regular');
    call add_metric('spark.rdd.diskUsed', '服务', 'spark', 'Amount of disk space used by persisted RDDs in the application', 'short', 'linux,windows', '["host"]', True,'regular');
    call add_metric('spark.rdd.memoryUsed', '服务', 'spark', 'Amount of memory used in the application''s persisted RDDs', 'bytes', 'linux,windows', '["host"]', True,'regular');
    call add_metric('spark.rdd.numCachedPartitions', '服务', 'spark', 'Number of in-memory cached RDD partitions in the application', 'short', 'linux,windows', '["host"]', False,'regular');
    call add_metric('spark.rdd.numPartitions', '服务', 'spark', 'Number of persisted RDD partitions in the application', 'short', 'linux,windows', '["host"]', True,'regular');
    call add_metric('spark.stage.count', '服务', 'spark', 'Number ofstage', 'short', 'linux,windows', '["host"]', False,'regular');
    call add_metric('spark.stage.diskBytesSpilled', '服务', 'spark', 'Max size on disk of the spilled bytes in the application''s stages', 'bytes', 'linux,windows', '["host"]', False,'regular');
    call add_metric('spark.stage.executorRunTime', '服务', 'spark', 'Fraction of time (ms/s) spent by the executor in the application''s stages shown as fraction', 'ms', 'linux,windows', '["host"]', False,'regular');
    call add_metric('spark.stage.inputBytes', '服务', 'spark', 'Input bytes in the application''s stages', 'bytes', 'linux,windows', '["host"]', False,'regular');
    call add_metric('spark.stage.inputRecords', '服务', 'spark', 'Input records in the application''s stages shown as record', 'short', 'linux,windows', '["host"]', False,'regular');
    call add_metric('spark.stage.memoryBytesSpilled', '服务', 'spark', 'Number of bytes spilled to disk in the application''s stages', 'bytes', 'linux,windows', '["host"]', False,'regular');
    call add_metric('spark.stage.numActiveTasks', '服务', 'spark', 'Number of active tasks in the application''s stages', 'short', 'linux,windows', '["host"]', True,'regular');
    call add_metric('spark.stage.numCompleteTasks', '服务', 'spark', 'Number of complete tasks in the application''s stages', 'short', 'linux,windows', '["host"]', False,'regular');
    call add_metric('spark.stage.numFailedTasks', '服务', 'spark', 'Number of failed tasks in the application''s stages', 'short', 'linux,windows', '["host"]', True,'regular');
    call add_metric('spark.stage.outputBytes', '服务', 'spark', 'Output bytes in the application''s stages', 'bytes', 'linux,windows', '["host"]', False,'regular');
    call add_metric('spark.stage.outputRecords', '服务', 'spark', 'Output records in the application''s stages', 'short', 'linux,windows', '["host"]', False,'regular');
    call add_metric('spark.stage.shuffleReadBytes', '服务', 'spark', 'Number of bytes read during a shuffle in the application''s stages', 'bytes', 'linux,windows', '["host"]', False,'regular');
    call add_metric('spark.stage.shuffleReadRecords', '服务', 'spark', 'Number of records read during a shuffle in the application''s stages', 'short', 'linux,windows', '["host"]', False,'regular');
    call add_metric('spark.stage.shuffleWriteBytes', '服务', 'spark', 'Number of shuffled bytes in the application''s stages', 'bytes', 'linux,windows', '["host"]', False,'regular');
    call add_metric('spark.stage.shuffleWriteRecords', '服务', 'spark', 'Number of shuffled records in the application''s stages', 'short', 'linux,windows', '["host"]', False,'regular');

    call add_metric('storm.cluster.executorsTotal', '服务', 'storm', 'Total number of executors', 'short', 'linux,windows', '["host"]', True,'regular');
    call add_metric('storm.cluster.slotsFree', '服务', 'storm', 'Number of worker slots available', 'short', 'linux,windows', '["host"]', False,'regular');
    call add_metric('storm.cluster.slotsTotal', '服务', 'storm', 'Total number of available worker slots', 'short', 'linux,windows', '["host"]', False,'regular');
    call add_metric('storm.cluster.slotsUsed', '服务', 'storm', 'Number of worker slots used', 'short', 'linux,windows', '["host"]', True,'regular');
    call add_metric('storm.cluster.supervisors', '服务', 'storm', 'Number of supervisors running', 'short', 'linux,windows', '["host"]', False,'regular');
    call add_metric('storm.cluster.tasksTotal', '服务', 'storm', 'Total tasks', 'short', 'linux,windows', '["host"]', True,'regular');
    call add_metric('storm.supervisor.slotsTotal', '服务', 'storm', 'Total number of available worker slots for this supervisor', 'short', 'linux,windows', '["host"]', False,'regular');
    call add_metric('storm.supervisor.slotsUsed', '服务', 'storm', 'Number of worker slots used on this supervisor', 'short', 'linux,windows', '["host"]', True,'regular');
    call add_metric('storm.supervisor.totalCpu', '服务', 'storm', 'Total CPU capacity on this supervisor', 'none', 'linux,windows', '["host"]', False,'regular');
    call add_metric('storm.supervisor.totalMem', '服务', 'storm', 'Total memory capacity on this supervisor', 'none', 'linux,windows', '["host"]', False,'regular');
    call add_metric('storm.supervisor.uptimeSeconds', '服务', 'storm', 'Shows how long the supervisor is running in seconds', 's', 'linux,windows', '["host"]', False,'regular');
    call add_metric('storm.supervisor.usedCpu', '服务', 'storm', 'Used CPU capacity on this supervisor', 'none', 'linux,windows', '["host"]', True,'regular');
    call add_metric('storm.supervisor.usedMem', '服务', 'storm', 'Used memory capacity on this supervisor', 'none', 'linux,windows', '["host"]', True,'regular');
    call add_metric('storm.topology.assignedCpu', '服务', 'storm', 'Assigned CPU by Scheduler (%)', 'percent', 'linux,windows', '["host"]', False,'regular');
    call add_metric('storm.topology.assignedMemOffHeap', '服务', 'storm', 'Assigned Off-Heap Memory by Scheduler (MB)', 'mbytes', 'linux,windows', '["host"]', False,'regular');
    call add_metric('storm.topology.assignedMemOnHeap', '服务', 'storm', 'Assigned On-Heap Memory by Scheduler (MB)', 'mbytes', 'linux,windows', '["host"]', False,'regular');
    call add_metric('storm.topology.assignedTotalMem', '服务', 'storm', 'Assigned Total Memory by Scheduler (MB)', 'mbytes', 'linux,windows', '["host"]', False,'regular');
    call add_metric('storm.topology.executorsTotal', '服务', 'storm', 'Number of executors used for this topology', 'short', 'linux,windows', '["host"]', False,'regular');
    call add_metric('storm.topology.replicationCount', '服务', 'storm', 'Number of nimbus hosts on which this topology code is replicated', 'short', 'linux,windows', '["host"]', False,'regular');
    call add_metric('storm.topology.requestedCpu', '服务', 'storm', 'Requested CPU by User (%)', 'percent', 'linux,windows', '["host"]', False,'regular');
    call add_metric('storm.topology.requestedMemOffHeap', '服务', 'storm', 'Requested Off-Heap Memory by User (MB)', 'mbytes', 'linux,windows', '["host"]', False,'regular');
    call add_metric('storm.topology.requestedMemOnHeap', '服务', 'storm', 'Requested On-Heap Memory by User (MB)', 'mbytes', 'linux,windows', '["host"]', False,'regular');
    call add_metric('storm.topology.requestedTotalMem', '服务', 'storm', 'Requested Total Memory by User (MB)', 'mbytes', 'linux,windows', '["host"]', False,'regular');
    call add_metric('storm.topology.tasksTotal', '服务', 'storm', 'Total number of tasks for this topology', 'short', 'linux,windows', '["host"]', False,'regular');
    call add_metric('storm.topology.uptimeSeconds', '服务', 'storm', 'Shows how long the topology is running in seconds', 's', 'linux,windows', '["host"]', False,'regular');
    call add_metric('storm.topology.workersTotal', '服务', 'storm', 'Number of workers used for this topology', 'short', 'linux,windows', '["host"]', False,'regular');

    call add_metric('yarn.apps.allocatedMB', '服务', 'yarn', 'The sum of memory in MB allocated to the applications running containers', 'short', 'linux,windows', '["host"]', False,'regular');
    call add_metric('yarn.apps.allocatedVCores', '服务', 'yarn', 'The sum of virtual cores allocated to the applications running containers', 'short', 'linux,windows', '["host"]', False,'regular');
    call add_metric('yarn.apps.elapsedTime', '服务', 'yarn', 'The elapsed time since the application started', 'ms', 'linux,windows', '["host"]', False,'regular');
    call add_metric('yarn.apps.finishedTime', '服务', 'yarn', 'The time in which the application finished', 'ms', 'linux,windows', '["host"]', False,'regular');
    call add_metric('yarn.apps.memorySeconds', '服务', 'yarn', 'The amount of memory the application has allocated', 'ms', 'linux,windows', '["host"]', False,'regular');
    call add_metric('yarn.apps.progress', '服务', 'yarn', 'The progress of the application as a percent', 'percent', 'linux,windows', '["host"]', False,'regular');
    call add_metric('yarn.apps.runningContainers', '服务', 'yarn', 'The number of containers currently running for the application', 'short', 'linux,windows', '["host"]', False,'regular');
    call add_metric('yarn.apps.startedTime', '服务', 'yarn', 'The time in which application started', 'ms', 'linux,windows', '["host"]', False,'regular');
    call add_metric('yarn.apps.vcoreSeconds', '服务', 'yarn', 'The amount of CPU resources the application has allocated', 'short', 'linux,windows', '["host"]', False,'regular');
    call add_metric('yarn.metrics.activeNodes', '服务', 'yarn', 'The number of active nodes', 'short', 'linux,windows', '["host"]', True,'regular');
    call add_metric('yarn.metrics.allocatedMB', '服务', 'yarn', 'The amount of memory allocated in MB. If this is closed to totalMB, it is bad.', 'short', 'linux,windows', '["host"]', True,'regular');
    call add_metric('yarn.metrics.allocatedVirtualCores', '服务', 'yarn', 'The number of allocated virtual cores', 'short', 'linux,windows', '["host"]', False,'regular');
    call add_metric('yarn.metrics.appsCompleted', '服务', 'yarn', 'The number of applications completed', 'short', 'linux,windows', '["host"]', False,'regular');
    call add_metric('yarn.metrics.appsFailed', '服务', 'yarn', 'The number of applications failed', 'short', 'linux,windows', '["host"]', True,'regular');
    call add_metric('yarn.metrics.appsKilled', '服务', 'yarn', 'The number of applications killed', 'short', 'linux,windows', '["host"]', False,'regular');
    call add_metric('yarn.metrics.appsPending', '服务', 'yarn', 'The number of applications pending', 'short', 'linux,windows', '["host"]', False,'regular');
    call add_metric('yarn.metrics.appsRunning', '服务', 'yarn', 'The number of applications running', 'short', 'linux,windows', '["host"]', False,'regular');
    call add_metric('yarn.metrics.appsSubmitted', '服务', 'yarn', 'The number of applications submitted', 'short', 'linux,windows', '["host"]', False,'regular');
    call add_metric('yarn.metrics.availableMB', '服务', 'yarn', 'The amount of memory available in MB', 'mbytes', 'linux,windows', '["host"]', False,'regular');
    call add_metric('yarn.metrics.availableVirtualCores', '服务', 'yarn', 'The number of available virtual cores', 'short', 'linux,windows', '["host"]', False,'regular');
    call add_metric('yarn.metrics.containersAllocated', '服务', 'yarn', 'The number of containers allocated', 'short', 'linux,windows', '["host"]', False,'regular');
    call add_metric('yarn.metrics.containersPending', '服务', 'yarn', 'The number of containers pending', 'short', 'linux,windows', '["host"]', False,'regular');
    call add_metric('yarn.metrics.containersReserved', '服务', 'yarn', 'The number of containers reserved', 'short', 'linux,windows', '["host"]', False,'regular');
    call add_metric('yarn.metrics.decommissionedNodes', '服务', 'yarn', 'The number of nodes decommissioned', 'short', 'linux,windows', '["host"]', False,'regular');
    call add_metric('yarn.metrics.lostNodes', '服务', 'yarn', 'The number of lost nodes', 'short', 'linux,windows', '["host"]', True,'regular');
    call add_metric('yarn.metrics.rebootedNodes', '服务', 'yarn', 'The number of nodes rebooted', 'short', 'linux,windows', '["host"]', True,'regular');
    call add_metric('yarn.metrics.reservedMB', '服务', 'yarn', 'The amount of memory reserved in MB', 'mbytes', 'linux,windows', '["host"]', False,'regular');
    call add_metric('yarn.metrics.reservedVirtualCores', '服务', 'yarn', 'The number of reserved virtual cores', 'short', 'linux,windows', '["host"]', False,'regular');
    call add_metric('yarn.metrics.totalMB', '服务', 'yarn', 'The amount of total memory in MB', 'mbytes', 'linux,windows', '["host"]', False,'regular');
    call add_metric('yarn.metrics.totalNodes', '服务', 'yarn', 'The total number of nodes', 'short', 'linux,windows', '["host"]', False,'regular');
    call add_metric('yarn.metrics.totalVirtualCores', '服务', 'yarn', 'The total number of virtual cores', 'short', 'linux,windows', '["host"]', False,'regular');
    call add_metric('yarn.metrics.unhealthyNodes', '服务', 'yarn', 'The number of unhealthy nodes', 'short', 'linux,windows', '["host"]', True,'regular');
    call add_metric('yarn.nodes.availMemoryMB', '服务', 'yarn', 'The total amount of memory currently available on the node (in MB)', 'mbytes', 'linux,windows', '["host"]', False,'regular');
    call add_metric('yarn.nodes.availableVirtualCores', '服务', 'yarn', 'The total number of vCores available on the node', 'short', 'linux,windows', '["host"]', False,'regular');
    call add_metric('yarn.nodes.lastHealthUpdate', '服务', 'yarn', 'The last time the node reported its health (in ms since epoch)', 'ms', 'linux,windows', '["host"]', False,'regular');
    call add_metric('yarn.nodes.numContainers', '服务', 'yarn', 'The total number of containers currently running on the node', 'short', 'linux,windows', '["host"]', False,'regular');
    call add_metric('yarn.nodes.usedMemoryMB', '服务', 'yarn', 'The total amount of memory currently used on the node (in MB)', 'mbytes', 'linux,windows', '["host"]', True,'regular');
    call add_metric('yarn.nodes.usedVirtualCores', '服务', 'yarn', 'The total number of vCores currently used on the node', 'short', 'linux,windows', '["host"]', False,'regular');

    call add_metric('apache.conns_async_closing', '服务', 'apache', '异步关闭连接数','short','linux,windows', '["host"]', True,'regular');
    call add_metric('apache.conns_async_keep_alive', '服务', 'apache', '异步保持活动连接数','none','linux,windows', '["host"]', True,'regular');
    call add_metric('apache.conns_async_writing', '服务', 'apache', '异步写入连接数','none','linux,windows', '["host"]', True,'regular');
    call add_metric('apache.conns_total', '服务', 'apache', '执行的连接总数','none','linux,windows', '["host"]', True,'regular');
    call add_metric('apache.net.bytes', '服务', 'apache', '传输的总数据量','none','linux,windows', '["host"]', True,'regular');
    call add_metric('apache.net.hits', '服务', 'apache', '接收到的请求连接总数','none','linux,windows', '["host"]', False,'regular');
    call add_metric('apache.performance.busy_workers', '服务', 'apache', '正在运行的进程数','none','linux,windows', '["host"]', True,'regular');
    call add_metric('apache.performance.cpu_load', '服务', 'apache', 'apache负荷','none','linux,windows', '["host"]', False,'regular');
    call add_metric('apache.performance.idle_workers', '服务', 'apache', '空闲的进程数','none','linux,windows', '["host"]', True,'regular');
    call add_metric('apache.performance.uptime', '服务', 'apache', '运行时间','none','linux,windows', '["host"]', False,'regular');

    call add_metric('docker.status', '服务', 'docker', '','none','linux', '["host"]', False,'regular');

    call add_metric('weblogic.runtime.Uptime', '服务', 'weblogic', 'web服务器所属的JVM在线时长','none', 'linux', '["host"]', False,'regular');
    call add_metric('weblogic.thread.CurrentThreadCpuTime', '服务', 'weblogic', '当前线程所占用的CPU总时长','none', 'linux', '["host"]', False,'regular');
    call add_metric('weblogic.thread.PeakThreadCount', '服务', 'weblogic', 'web服务器所属的JVM开启的最大线程数量（从最近一次服务启动或计数器重置计算）','none', 'linux', '["host"]', False,'regular');
    call add_metric('weblogic.thread.DaemonThreadCount', '服务', 'weblogic', '当前活跃的守护线程数量','none', 'linux', '["host"]', False,'regular');
    call add_metric('weblogic.thread.TotalStartedThreadCount', '服务', 'weblogic', '创建并启动的线程总数（从最近一次JVM启动计算）','none', 'linux', '["host"]', False,'regular');
    call add_metric('weblogic.thread.CurrentThreadUserTime', '服务', 'weblogic', '当前线程在用户模式下所占用的CPU总时长','none', 'linux', '["host"]', False,'regular');
    call add_metric('weblogic.thread.ThreadCount', '服务', 'weblogic', '当前活跃的线程数量','none', 'linux', '["host"]', False,'regular');
    call add_metric('weblogic.thread.deadlockedThreadsCount', '服务', 'weblogic', '死锁状态的线程数量','none', 'linux', '["host"]', False,'regular');
    call add_metric('weblogic.classloading.LoadedClassCount', '服务', 'weblogic', '当前已经载入JVM的类的数量','none', 'linux', '["host"]', False,'regular');
    call add_metric('weblogic.classloading.UnloadedClassCount', '服务', 'weblogic', '卸载的类的总数（从最近一次JVM启动计算）','none', 'linux', '["host"]', False,'regular');
    call add_metric('weblogic.threadpool.HoggingThreadCount', '服务', 'weblogic', '当前被请求独占的线程数量','none', 'linux', '["host"]', False,'regular');
    call add_metric('weblogic.threadpool.ExecuteThreadIdleCount', '服务', 'weblogic', '线程池中处于空闲状态的线程数量','none', 'linux', '["host"]', False,'regular');
    call add_metric('weblogic.threadpool.StandbyThreadCount', '服务', 'weblogic', '线程池中处于等待状态的线程数量','none', 'linux', '["host"]', False,'regular');
    call add_metric('weblogic.os.FreePhysicalMemorySize', '服务', 'weblogic', '未使用的物理内存大小','none', 'linux', '["host"]', False,'regular');
    call add_metric('weblogic.os.FreeSwapSpaceSize', '服务', 'weblogic', '未使用的交换区大小','none', 'linux', '["host"]', False,'regular');
    call add_metric('weblogic.os.AvailableProcessors', '服务', 'weblogic', '可使用的处理器数量','none', 'linux', '["host"]', False,'regular');
    call add_metric('weblogic.os.ProcessCpuLoad', '服务', 'weblogic', 'JVM进程的CPU使用率','none', 'linux', '["host"]', False,'regular');
    call add_metric('weblogic.os.TotalSwapSpaceSize', '服务', 'weblogic', '交换空间总大小','none', 'linux', '["host"]', False,'regular');
    call add_metric('weblogic.os.ProcessCpuTime', '服务', 'weblogic', 'JVM进程占用的CPU时间','none', 'linux', '["host"]', False,'regular');
    call add_metric('weblogic.os.SystemLoadAverage', '服务', 'weblogic', '过去一分钟内的系统平均负载','none', 'linux', '["host"]', False,'regular');
    call add_metric('weblogic.os.OpenFileDescriptorCount', '服务', 'weblogic', '打开的文件描述符个数','none', 'linux', '["host"]', False,'regular');
    call add_metric('weblogic.os.MaxFileDescriptorCount', '服务', 'weblogic', '文件描述符最大数量','none', 'linux', '["host"]', False,'regular');
    call add_metric('weblogic.os.TotalPhysicalMemorySize', '服务', 'weblogic', '物理内存大小','none', 'linux', '["host"]', False,'regular');
    call add_metric('weblogic.os.CommittedVirtualMemorySize', '服务', 'weblogic', '预分配的虚拟内存大小','none', 'linux', '["host"]', False,'regular');
    call add_metric('weblogic.os.SystemCpuLoad', '服务', 'weblogic', '系统CPU使用率','none', 'linux', '["host"]', False,'regular');
    call add_metric('weblogic.memory.nonheap.max', '服务', 'weblogic', 'JVM使用的非堆内存最大值','none', 'linux', '["host"]', False,'regular');
    call add_metric('weblogic.memory.nonheap.committed', '服务', 'weblogic', 'JVM使用的预分配的非堆内存大小','none', 'linux', '["host"]', False,'regular');
    call add_metric('weblogic.memory.nonheap.init', '服务', 'weblogic', 'JVM使用的非堆内存初始值','none', 'linux', '["host"]', False,'regular');
    call add_metric('weblogic.memory.nonheap.used', '服务', 'weblogic', 'JVM当前使用的非堆内存大小','none', 'linux', '["host"]', False,'regular');
    call add_metric('weblogic.memory.nonheap.percent_used', '服务', 'weblogic', 'JVM当前使用的非堆内存百分比','none', 'linux', '["host"]', False,'regular');
    call add_metric('weblogic.memory.heap.max', '服务', 'weblogic', 'JVM使用的堆内存最大值','none', 'linux', '["host"]', False,'regular');
    call add_metric('weblogic.memory.heap.committed', '服务', 'weblogic', 'JVM使用的预分配的堆内存大小','none', 'linux', '["host"]', False,'regular');
    call add_metric('weblogic.memory.heap.init', '服务', 'weblogic', 'JVM使用的堆内存初始值','none', 'linux', '["host"]', False,'regular');
    call add_metric('weblogic.memory.heap.used', '服务', 'weblogic', 'JVM当前使用的堆内存大小','none', 'linux', '["host"]', False,'regular');
    call add_metric('weblogic.memory.heap.percent_used', '服务', 'weblogic', 'JVM当前使用的堆内存百分比','none', 'linux', '["host"]', False,'regular');
    call add_metric('weblogic.server.ActivationTime', '服务', 'weblogic', 'web服务启动时间','none', 'linux', '["host"]', False,'regular');
    call add_metric('weblogic.server.AdminServer', '服务', 'weblogic', '该服务器是否为管理服务器，1：是；0：否','none', 'linux', '["host"]', False,'regular');
    call add_metric('weblogic.server.AdminServerListenPort', '服务', 'weblogic', '管理服务器监听的端口号','none', 'linux', '["host"]', False,'regular');
    call add_metric('weblogic.server.AdminServerListenPortSecure', '服务', 'weblogic', '该服务器是否使用安全协议建立管理链接，1：是；0：否','none', 'linux', '["host"]', False,'regular');
    call add_metric('weblogic.server.AdministrationPort', '服务', 'weblogic', '管理请求监听端口号','none', 'linux', '["host"]', False,'regular');
    call add_metric('weblogic.server.ClusterMaster', '服务', 'weblogic', '该服务器是否为集群主服务器，1：是；0：否','none', 'linux', '["host"]', False,'regular');
    call add_metric('weblogic.server.HealthState          ', '服务', 'weblogic', '服务器的健康状态','none', 'linux', '["host"]', False,'regular');
    call add_metric('weblogic.server.ListenPort', '服务', 'weblogic', '服务器监听的端口号','none', 'linux', '["host"]', False,'regular');
    call add_metric('weblogic.server.ListenPortEnabled', '服务', 'weblogic', '默认端口号是否打开，1：是；0：否','none', 'linux', '["host"]', False,'regular');
    call add_metric('weblogic.server.OpenSocketsCurrentCount', '服务', 'weblogic', '当前开启的SOCKET数量','none', 'linux', '["host"]', False,'regular');
    call add_metric('weblogic.server.OverallHealthState', '服务', 'weblogic', '服务器整体健康值','none', 'linux', '["host"]', False,'regular');
    call add_metric('weblogic.server.RestartRequired', '服务', 'weblogic', '当前服务器是否需要重启以应用配置改变，1：是；0：否','none', 'linux', '["host"]', False,'regular');
    call add_metric('weblogic.server.RestartsTotalCount', '服务', 'weblogic', '服务器重启总次数（从集群上次启动计算）','none', 'linux', '["host"]', False,'regular');
    call add_metric('weblogic.server.ServerStartupTime', '服务', 'weblogic', '服务器启动时间','none', 'linux', '["host"]', False,'regular');
    call add_metric('weblogic.server.StableState', '服务', 'weblogic', '当前服务器是否处于stable状态，1：是；0：否','none', 'linux', '["host"]', False,'regular');
    call add_metric('weblogic.server.State', '服务', 'weblogic', '当前服务器状态','none', 'linux', '["host"]', False,'regular');
    call add_metric('weblogic.jta.TransactionTotalCount', '服务', 'weblogic', '服务器处理的全部事务数量（从上次服务器启动计算）','none', 'linux', '["host"]', False,'regular');
    call add_metric('weblogic.jta.TransactionCommittedTotalCount', '服务', 'weblogic', '服务器提交的全部事务数量（从上次服务器启动计算）','none', 'linux', '["host"]', False,'regular');
    call add_metric('weblogic.jta.TransactionRolledBackTotalCount', '服务', 'weblogic', '服务器回滚的全部事务数量（从上次服务器启动计算）','none', 'linux', '["host"]', False,'regular');
    call add_metric('weblogic.jta.TransactionAbandonedTotalCount', '服务', 'weblogic', '服务器放弃的全部事务数量（从上次服务器启动计算）','none', 'linux', '["host"]', False,'regular');
    call add_metric('weblogic.jvm.HeapFreeCurrent', '服务', 'weblogic', '当前JVM堆中可用内存大小','none', 'linux', '["host"]', False,'regular');
    call add_metric('weblogic.jvm.HeapFreePercent', '服务', 'weblogic', '当前JVM堆中可用内存百分比','none', 'linux', '["host"]', False,'regular');
    call add_metric('weblogic.jvm.HeapSizeCurrent', '服务', 'weblogic', '当前JVM堆大小','none', 'linux', '["host"]', False,'regular');
    call add_metric('weblogic.jvm.HeapSizeMax', '服务', 'weblogic', 'JVM配置的最大内存大小','none', 'linux', '["host"]', False,'regular');
    call add_metric('weblogic.jvm.Uptime', '服务', 'weblogic', '当前JVM运行时间','none', 'linux', '["host"]', False,'regular');
    call add_metric('weblogic.datasource.NumAvailable', '服务', 'weblogic', '数据源中可被应用使用的数据库连接数','none', 'linux', '["host"]', False,'regular');
    call add_metric('weblogic.datasource.CurrCapacity', '服务', 'weblogic', '数据源中JDBC连接数','none', 'linux', '["host"]', False,'regular');
    call add_metric('weblogic.datasource.ConnectionsTotalCount', '服务', 'weblogic', '数据源总共建立的数据库连接数（从数据源部署计算）','none', 'linux', '["host"]', False,'regular');
    call add_metric('weblogic.datasource.ActiveConnectionsCurrentCount', '服务', 'weblogic', '当前正在使用的连接数','none', 'linux', '["host"]', False,'regular');
    call add_metric('weblogic.datasource.LeakedConnectionCount', '服务', 'weblogic', '泄露的连接数','none', 'linux', '["host"]', False,'regular');
    call add_metric('weblogic.datasource.PrepStmtCacheCurrentSize', '服务', 'weblogic', '缓存中已经就绪可调用的SQL语句个数','none', 'linux', '["host"]', False,'regular');
    call add_metric('weblogic.datasource.WaitingForConnectionCurrentCount', '服务', 'weblogic', '当前正在等待数据库连接的请求数','none', 'linux', '["host"]', False,'regular');
    call add_metric('weblogic.datasource.WaitingForConnectionTotal', '服务', 'weblogic', '曾经等待过数据库连接的请求总数（从数据源部署计算）','none', 'linux', '["host"]', False,'regular');
    call add_metric('weblogic.datasource.WaitingForConnectionSuccessTotal', '服务', 'weblogic', '曾经等待过数据库连接，并且最终成功的请求总数（从数据源部署计算）','none', 'linux', '["host"]', False,'regular');
    call add_metric('weblogic.datasource.WaitingForConnectionFailureTotal', '服务', 'weblogic', '曾经等待过数据库连接，并且最终失败的请求总数（从数据源部署计算）','none', 'linux', '["host"]', False,'regular');
    call add_metric('weblogic.ejb.AccessTotalCount', '服务', 'weblogic', '尝试从EJB池中获得实例的次数','none', 'linux', '["host"]', False,'regular');
    call add_metric('weblogic.ejb.DestroyedTotalCount', '服务', 'weblogic', 'Bean实例因非应用异常销毁的次数','none', 'linux', '["host"]', False,'regular');
    call add_metric('weblogic.ejb.IdleBeansCount', '服务', 'weblogic', 'EJB池中可用的Bean数量','none', 'linux', '["host"]', False,'regular');
    call add_metric('weblogic.ejb.MissTotalCount', '服务', 'weblogic', '尝试从EJB池中获得实例并失败的次数','none', 'linux', '["host"]', False,'regular');
    call add_metric('weblogic.ejb.PooledBeansCurrentCount', '服务', 'weblogic', 'EJB池中使用的Bean实例数量','none', 'linux', '["host"]', False,'regular');
    call add_metric('weblogic.ejb.WaiterCurrentCount', '服务', 'weblogic', '正在等待从EJB池中获得实例的线程数','none', 'linux', '["host"]', False,'regular');
    call add_metric('weblogic.ejb.TransactionsCommittedTotalCount', '服务', 'weblogic', 'EJB提交的事务数量','none', 'linux', '["host"]', False,'regular');
    call add_metric('weblogic.ejb.TransactionsRolledBackTotalCount', '服务', 'weblogic', 'EJB回滚的事务数量','none', 'linux', '["host"]', False,'regular');
    call add_metric('weblogic.ejb.TransactionsTimedOutTotalCount', '服务', 'weblogic', 'EJB超时的事务数量','none', 'linux', '["host"]', False,'regular');
    call add_metric('weblogic.application.ActiveVersionState', '服务', 'weblogic', '当前已激活应用的版本号','none', 'linux', '["host"]', False,'regular');
    call add_metric('weblogic.application.HealthState', '服务', 'weblogic', '当前应用的健康状况','none', 'linux', '["host"]', False,'regular');
    call add_metric('weblogic.threadpool.CompletedRequestCount', '服务', 'weblogic', '队列中完成的请求数','none', 'linux', '["host"]', False,'regular');
    call add_metric('weblogic.threadpool.ExecuteThreadIdleCount', '服务', 'weblogic', '线程池中空闲的线程数','none', 'linux', '["host"]', False,'regular');
    call add_metric('weblogic.threadpool.ExecuteThreadTotalCount', '服务', 'weblogic', '线程池中的线程总数','none', 'linux', '["host"]', False,'regular');
    call add_metric('weblogic.threadpool.ExecuteThreads', '服务', 'weblogic', '线程池中正在工作的线程数','none', 'linux', '["host"]', False,'regular');
    call add_metric('weblogic.threadpool.HealthState', '服务', 'weblogic', '线程池的健康状态','none', 'linux', '["host"]', False,'regular');
    call add_metric('weblogic.threadpool.HoggingThreadCount', '服务', 'weblogic', '线程池中当前被独占的线程数量','none', 'linux', '["host"]', False,'regular');
    call add_metric('weblogic.threadpool.MinThreadsConstraintsCompleted', '服务', 'weblogic', '由于无法满足最小线程数要求，具有最小线程约束的请求被立即执行的数','none', 'linux', '["host"]', False,'regular');
    call add_metric('weblogic.threadpool.MinThreadsConstraintsPending', '服务', 'weblogic', '为了满足最小线程数要求需要被执行的请求数','none', 'linux', '["host"]', False,'regular');
    call add_metric('weblogic.threadpool.PendingUserRequestCount', '服务', 'weblogic', '队列中正在等待的用户请求数','none', 'linux', '["host"]', False,'regular');
    call add_metric('weblogic.threadpool.QueueLength', '服务', 'weblogic', '队列中正在等待的所有请求数','none', 'linux', '["host"]', False,'regular');
    call add_metric('weblogic.threadpool.SharedCapacityForWorkManagers', '服务', 'weblogic', '队列中可接受的最大请求数','none', 'linux', '["host"]', False,'regular');
    call add_metric('weblogic.threadpool.StandbyThreadCount', '服务', 'weblogic', '等待线程池中的线程数','none', 'linux', '["host"]', False,'regular');
    call add_metric('weblogic.threadpool.Throughput', '服务', 'weblogic', '平均每秒完成的请求数','none', 'linux', '["host"]', False,'regular');
    call add_metric('weblogic.webapp.component.DeploymentState', '服务', 'weblogic', '当前模块的部署状况','none', 'linux', '["host"]', False,'regular');
    call add_metric('weblogic.webapp.component.JSPPageCheckSecs', '服务', 'weblogic', '在weblogic.xml中定义的JSP的PageCheckSecs值','none', 'linux', '["host"]', False,'regular');
    call add_metric('weblogic.webapp.component.OpenSessionsCurrentCount', '服务', 'weblogic', '当前开启的会话数','none', 'linux', '["host"]', False,'regular');
    call add_metric('weblogic.webapp.component.OpenSessionsHighCount', '服务', 'weblogic', '开启会话数的最大值（从服务器启动计算）','none', 'linux', '["host"]', False,'regular');
    call add_metric('weblogic.webapp.component.ServletReloadCheckSecs', '服务', 'weblogic', '在weblogic.xml中定义的servlet check seconds值','none', 'linux', '["host"]', False,'regular');
    call add_metric('weblogic.webapp.component.Servlets', '服务', 'weblogic', '当前的servlet数量','none', 'linux', '["host"]', False,'regular');
    call add_metric('weblogic.webapp.component.SessionCookieMaxAgeSecs', '服务', 'weblogic', 'Cookie的有效期','none', 'linux', '["host"]', False,'regular');
    call add_metric('weblogic.webapp.component.SessionIDLength', '服务', 'weblogic', 'HTTP会话id长度','none', 'linux', '["host"]', False,'regular');
    call add_metric('weblogic.webapp.component.SessionInvalidationIntervalSecs', '服务', 'weblogic', 'HTTP会话有效性检查间隔时间','none', 'linux', '["host"]', False,'regular');
    call add_metric('weblogic.webapp.component.SessionTimeoutSecs', '服务', 'weblogic', 'HTTP会话超时时间设置','none', 'linux', '["host"]', False,'regular');
    call add_metric('weblogic.webapp.component.SessionsOpenedTotalCount', '服务', 'weblogic', '开启的会话总数','none', 'linux', '["host"]', False,'regular');
    call add_metric('weblogic.webapp.component.SingleThreadedServletPoolSize', '服务', 'weblogic', '在weblogic.xml中定义的单线程servlet线程池大小','none', 'linux', '["host"]', False,'regular');
    call add_metric('weblogic.webapp.component.Status', '服务', 'weblogic', 'WebApp模块的健康状况','none', 'linux', '["host"]', False,'regular');
    call add_metric('weblogic.request.class.CompletedCount', '服务', 'weblogic', '任务完成总数（从服务器启动计算）','none', 'linux', '["host"]', False,'regular');
    call add_metric('weblogic.request.class.PendingRequestCount', '服务', 'weblogic', '正在等待可用线程的请求数','none', 'linux', '["host"]', False,'regular');
    call add_metric('weblogic.request.class.TotalThreadUse', '服务', 'weblogic', '所有请求的线程使用时间（从服务器启动计算）','none', 'linux', '["host"]', False,'regular');
    call add_metric('weblogic.request.class.VirtualTimeIncrement', '服务', 'weblogic', '当前请求的优先级','none', 'linux', '["host"]', False,'regular');
    call add_metric('weblogic.servlet.ExecutionTimeAverage', '服务', 'weblogic', '执行的所有servlet调用的平均时间（从servlet创建计算）','none', 'linux', '["host"]', False,'regular');
    call add_metric('weblogic.servlet.ExecutionTimeHigh', '服务', 'weblogic', '执行的所有servlet调用的最长时间（从servlet创建计算）','none', 'linux', '["host"]', False,'regular');
    call add_metric('weblogic.servlet.ExecutionTimeLow', '服务', 'weblogic', '执行的所有servlet调用的最短时间（从servlet创建计算）','none', 'linux', '["host"]', False,'regular');
    call add_metric('weblogic.servlet.ExecutionTimeTotal', '服务', 'weblogic', '执行的所有servlet调用的总花费时间（从servlet创建计算）','none', 'linux', '["host"]', False,'regular');
    call add_metric('weblogic.servlet.InvocationTotalCount', '服务', 'weblogic', '执行servlet调用的总次数（从servlet创建计算）','none', 'linux', '["host"]', False,'regular');
    call add_metric('weblogic.servlet.PoolMaxCapacity', '服务', 'weblogic', '单线程模型 servlet的最大线程数','none', 'linux', '["host"]', False,'regular');
    call add_metric('weblogic.servlet.ReloadTotalCount', '服务', 'weblogic', 'servlet重载入的总次数（从servlet创建计算）','none', 'linux', '["host"]', False,'regular');
    call add_metric('weblogic.connector.service.ActiveRACount', '服务', 'weblogic', '活跃的资源适配器个数','none', 'linux', '["host"]', False,'regular');
    call add_metric('weblogic.connector.service.RACount', '服务', 'weblogic', '服务器上的资源适配器总数','none', 'linux', '["host"]', False,'regular');
    call add_metric('weblogic.server.channel.AcceptCount', '服务', 'weblogic', '通道接受的SOCKET总数','none', 'linux', '["host"]', False,'regular');
    call add_metric('weblogic.server.channel.BytesReceivedCount', '服务', 'weblogic', '通道接收的字节数','none', 'linux', '["host"]', False,'regular');
    call add_metric('weblogic.server.channel.BytesSentCount', '服务', 'weblogic', '通道发送的字节数','none', 'linux', '["host"]', False,'regular');
    call add_metric('weblogic.server.channel.ConnectionsCount', '服务', 'weblogic', '通道的活动连接及SOCKET总数','none', 'linux', '["host"]', False,'regular');
    call add_metric('weblogic.server.channel.MessagesReceivedCount', '服务', 'weblogic', '通道接收的消息条数','none', 'linux', '["host"]', False,'regular');
    call add_metric('weblogic.server.channel.MessagesSentCount', '服务', 'weblogic', '通道发送的消息条数','none', 'linux', '["host"]', False,'regular');
    call add_metric('weblogic.persistent.store.AllocatedIoBufferBytes', '服务', 'weblogic', '文件存储使用的原生内存大小','none', 'linux', '["host"]', False,'regular');
    call add_metric('weblogic.persistent.store.AllocatedWindowBufferBytes', '服务', 'weblogic', '文件存储的窗口缓存使用的原生内存大小','none', 'linux', '["host"]', False,'regular');
    call add_metric('weblogic.persistent.store.CreateCount', '服务', 'weblogic', '当前存储发起的创建请求数量','none', 'linux', '["host"]', False,'regular');
    call add_metric('weblogic.persistent.store.DeleteCount', '服务', 'weblogic', '当前存储发起的删除请求数量','none', 'linux', '["host"]', False,'regular');
    call add_metric('weblogic.persistent.store.ObjectCount', '服务', 'weblogic', '当前存储的对象总数量','none', 'linux', '["host"]', False,'regular');
    call add_metric('weblogic.persistent.store.PhysicalWriteCount', '服务', 'weblogic', '数据写入持久化存储的次数','none', 'linux', '["host"]', False,'regular');
    call add_metric('weblogic.persistent.store.ReadCount', '服务', 'weblogic', '当前存储发起的读请求数量','none', 'linux', '["host"]', False,'regular');
    call add_metric('weblogic.persistent.store.UpdateCount', '服务', 'weblogic', '当前存储发起的更新请求数量','none', 'linux', '["host"]', False,'regular');
    call add_metric('weblogic.state', '服务', 'weblogic', '服务的当前状态（0表示正常，1表示异常）','none', 'linux', '["host"]', False,'regular');

    call add_metric('mysql.aborted_clients', '服务', 'mysql', '因为客户端下线但是没有正确的关闭连接而被遗弃的连接数量','none', 'linux,windows', '["host"]', False,'regular');
    call add_metric('mysql.aborted_connects', '服务', 'mysql', '尝试连接MySQL失败的次数','none', 'linux,windows', '["host"]', True,'regular');
    call add_metric('mysql.binlog_cache_disk_use', '服务', 'mysql', '交换的数量','none', 'linux,windows', '["host"]', False,'regular');
    call add_metric('mysql.binlog_cache_use', '服务', 'mysql', '使用二进制的log缓存交换的数量','none', 'linux,windows', '["host"]', False,'regular');
    call add_metric('mysql.binlog_stmt_cache_disk_use', '服务', 'mysql', '非交换的数量','none', 'linux,windows', '["host"]', False,'regular');
    call add_metric('mysql.binlog_stmt_cache_use', '服务', 'mysql', '使用二进制log缓存的非交换数量','none', 'linux,windows', '["host"]', False,'regular');
    call add_metric('mysql.bytes_received', '服务', 'mysql', '收取到来自所有客户端的byte总数','none', 'linux,windows', '["host"]', False,'regular');
    call add_metric('mysql.bytes_sent', '服务', 'mysql', '发送到所有客户端的byte总数','none', 'linux,windows', '["host"]', False,'regular');
    call add_metric('mysql.com_admin_commands', '服务', 'mysql', '每个命令被执行的次数','none', 'linux,windows', '["host"]', False,'regular');
    call add_metric('mysql.com_alter_db', '服务', 'mysql', '每个警报所执行的次数','none', 'linux,windows', '["host"]', False,'regular');
    call add_metric('mysql.com_alter_db_upgrade', '服务', 'mysql', '每个警报更新所执行的次数','none', 'linux,windows', '["host"]', False,'regular');
    call add_metric('mysql.com_alter_event', '服务', 'mysql', '每个事件被执行的次数','none', 'linux,windows', '["host"]', False,'regular');
    call add_metric('mysql.com_alter_function', '服务', 'mysql', '每个警报功能被执行的次数','none', 'linux,windows', '["host"]', False,'regular');
    call add_metric('mysql.com_alter_instance', '服务', 'mysql', '每个警报事例被执行的次数','none', 'linux,windows', '["host"]', False,'regular');
    call add_metric('mysql.com_alter_procedure', '服务', 'mysql', '每个警报步骤被执行的次数','none', 'linux,windows', '["host"]', False,'regular');
    call add_metric('mysql.com_alter_server', '服务', 'mysql', '每个警报服务器被执行的次数','none', 'linux,windows', '["host"]', False,'regular');
    call add_metric('mysql.com_alter_table', '服务', 'mysql', '每个警报表被执行的次数','none', 'linux,windows', '["host"]', False,'regular');
    call add_metric('mysql.com_alter_tablespace', '服务', 'mysql', '每个报警表空间被执行的次数','none', 'linux,windows', '["host"]', False,'regular');
    call add_metric('mysql.com_alter_user', '服务', 'mysql', '每个警报用户被执行的次数','none', 'linux,windows', '["host"]', False,'regular');
    call add_metric('mysql.com_analyze', '服务', 'mysql', '每个分析被执行的次数','none', 'linux,windows', '["host"]', False,'regular');
    call add_metric('mysql.com_assign_to_keycache', '服务', 'mysql', '每个分配到关键缓存被执行的次数','none', 'linux,windows', '["host"]', False,'regular');
    call add_metric('mysql.com_begin', '服务', 'mysql', '每个开始命令被执行的次数','none', 'linux,windows', '["host"]', False,'regular');
    call add_metric('mysql.com_binlog', '服务', 'mysql', '每个binlog被执行的次数','none', 'linux,windows', '["host"]', False,'regular');
    call add_metric('mysql.com_call_procedure', '服务', 'mysql', '每个call_procedure被执行的次数','none', 'linux,windows', '["host"]', False,'regular');
    call add_metric('mysql.com_change_db', '服务', 'mysql', '每个change_db被执行的次数','none', 'linux,windows', '["host"]', False,'regular');
    call add_metric('mysql.com_change_master', '服务', 'mysql', '每个change_master 被执行的次数','none', 'linux,windows', '["host"]', False,'regular');
    call add_metric('mysql.com_change_repl_filter', '服务', 'mysql', '每个change_repl_filter 被执行的次数','none', 'linux,windows', '["host"]', False,'regular');
    call add_metric('mysql.com_check', '服务', 'mysql', '每个检查命令 被执行的次数','none', 'linux,windows', '["host"]', False,'regular');
    call add_metric('mysql.com_checksum', '服务', 'mysql', '每个检查总数命令 被执行的次数','none', 'linux,windows', '["host"]', False,'regular');
    call add_metric('mysql.com_commit', '服务', 'mysql', '每个保证命令 被执行的次数','none', 'linux,windows', '["host"]', False,'regular');
    call add_metric('mysql.com_create_db', '服务', 'mysql', '每个create_db 被执行的次数','none', 'linux,windows', '["host"]', False,'regular');
    call add_metric('mysql.com_create_event', '服务', 'mysql', '每个create_event 被执行的次数','none', 'linux,windows', '["host"]', False,'regular');
    call add_metric('mysql.com_create_function', '服务', 'mysql', '每个create_function 被执行的次数','none', 'linux,windows', '["host"]', False,'regular');
    call add_metric('mysql.com_create_index', '服务', 'mysql', '每个create_index 被执行的次数','none', 'linux,windows', '["host"]', False,'regular');
    call add_metric('mysql.com_create_procedure', '服务', 'mysql', '每个create_procedure 被执行的次数','none', 'linux,windows', '["host"]', False,'regular');
    call add_metric('mysql.com_create_server', '服务', 'mysql', '每个create_server 被执行的次数','none', 'linux,windows', '["host"]', False,'regular');
    call add_metric('mysql.com_create_table', '服务', 'mysql', '每个create_table 被执行的次数','none', 'linux,windows', '["host"]', False,'regular');
    call add_metric('mysql.com_create_trigger', '服务', 'mysql', '每个create_trigger 被执行的次数','none', 'linux,windows', '["host"]', False,'regular');
    call add_metric('mysql.com_create_udf', '服务', 'mysql', '每个create_udf 被执行的次数','none', 'linux,windows', '["host"]', False,'regular');
    call add_metric('mysql.com_create_user', '服务', 'mysql', '每个create_user 被执行的次数','none', 'linux,windows', '["host"]', False,'regular');
    call add_metric('mysql.com_create_view', '服务', 'mysql', '每个create_view 被执行的次数','none', 'linux,windows', '["host"]', False,'regular');
    call add_metric('mysql.com_dealloc_sql', '服务', 'mysql', 'com_xxx 是指 xxxstatement被执行的次数','none', 'linux,windows', '["host"]', False,'regular');
    call add_metric('mysql.com_delete', '服务', 'mysql', 'com_xxx 是指 xxxstatement被执行的次数','none', 'linux,windows', '["host"]', True,'regular');
    call add_metric('mysql.com_delete_multi', '服务', 'mysql', 'com_xxx 是指 xxxstatement被执行的次数','none', 'linux,windows', '["host"]', False,'regular');
    call add_metric('mysql.com_do', '服务', 'mysql', 'com_xxx 是指 xxxstatement被执行的次数','none', 'linux,windows', '["host"]', False,'regular');
    call add_metric('mysql.com_drop_db', '服务', 'mysql', 'com_xxx 是指 xxxstatement被执行的次数','none', 'linux,windows', '["host"]', False,'regular');
    call add_metric('mysql.com_drop_event', '服务', 'mysql', 'com_xxx 是指 xxxstatement被执行的次数','none', 'linux,windows', '["host"]', False,'regular');
    call add_metric('mysql.com_drop_function', '服务', 'mysql', 'com_xxx 是指 xxxstatement被执行的次数','none', 'linux,windows', '["host"]', False,'regular');
    call add_metric('mysql.com_drop_index', '服务', 'mysql', 'com_xxx 是指 xxxstatement被执行的次数','none', 'linux,windows', '["host"]', False,'regular');
    call add_metric('mysql.com_drop_procedure', '服务', 'mysql', 'com_xxx 是指 xxxstatement被执行的次数','none', 'linux,windows', '["host"]', False,'regular');
    call add_metric('mysql.com_drop_server', '服务', 'mysql', 'com_xxx 是指 xxxstatement被执行的次数','none', 'linux,windows', '["host"]', False,'regular');
    call add_metric('mysql.com_drop_table', '服务', 'mysql', 'com_xxx 是指 xxxstatement被执行的次数','none', 'linux,windows', '["host"]', False,'regular');
    call add_metric('mysql.com_drop_trigger', '服务', 'mysql', 'com_xxx 是指 xxxstatement被执行的次数','none', 'linux,windows', '["host"]', False,'regular');
    call add_metric('mysql.com_drop_user', '服务', 'mysql', 'com_xxx 是指 xxxstatement被执行的次数','none', 'linux,windows', '["host"]', False,'regular');
    call add_metric('mysql.com_drop_view', '服务', 'mysql', 'com_xxx 是指 xxxstatement被执行的次数','none', 'linux,windows', '["host"]', False,'regular');
    call add_metric('mysql.com_empty_query', '服务', 'mysql', 'com_xxx 是指 xxxstatement被执行的次数','none', 'linux,windows', '["host"]', False,'regular');
    call add_metric('mysql.com_execute_sql', '服务', 'mysql', 'com_xxx 是指 xxxstatement被执行的次数','none', 'linux,windows', '["host"]', False,'regular');
    call add_metric('mysql.com_explain_other', '服务', 'mysql', 'com_xxx 是指 xxxstatement被执行的次数','none', 'linux,windows', '["host"]', False,'regular');
    call add_metric('mysql.com_flush', '服务', 'mysql', 'com_xxx 是指 xxxstatement被执行的次数','none', 'linux,windows', '["host"]', False,'regular');
    call add_metric('mysql.com_get_diagnostics', '服务', 'mysql', 'com_xxx 是指 xxxstatement被执行的次数','none', 'linux,windows', '["host"]', False,'regular');
    call add_metric('mysql.com_grant', '服务', 'mysql', 'com_xxx 是指 xxxstatement被执行的次数','none', 'linux,windows', '["host"]', False,'regular');
    call add_metric('mysql.com_group_replication_start', '服务', 'mysql', 'com_xxx 是指 xxxstatement被执行的次数','none', 'linux,windows', '["host"]', False,'regular');
    call add_metric('mysql.com_group_replication_stop', '服务', 'mysql', 'com_xxx 是指 xxxstatement被执行的次数','none', 'linux,windows', '["host"]', False,'regular');
    call add_metric('mysql.com_ha_close', '服务', 'mysql', 'com_xxx 是指 xxxstatement被执行的次数','none', 'linux,windows', '["host"]', False,'regular');
    call add_metric('mysql.com_ha_open', '服务', 'mysql', 'com_xxx 是指 xxxstatement被执行的次数','none', 'linux,windows', '["host"]', False,'regular');
    call add_metric('mysql.com_ha_read', '服务', 'mysql', 'com_xxx 是指 xxxstatement被执行的次数','none', 'linux,windows', '["host"]', False,'regular');
    call add_metric('mysql.com_help', '服务', 'mysql', 'com_xxx 是指 xxxstatement被执行的次数','none', 'linux,windows', '["host"]', False,'regular');
    call add_metric('mysql.com_insert', '服务', 'mysql', 'com_xxx 是指 xxxstatement被执行的次数','none', 'linux,windows', '["host"]', True,'regular');
    call add_metric('mysql.com_insert_select', '服务', 'mysql', 'com_xxx 是指 xxxstatement被执行的次数','none', 'linux,windows', '["host"]', False,'regular');
    call add_metric('mysql.com_install_plugin', '服务', 'mysql', 'com_xxx 是指 xxxstatement被执行的次数','none', 'linux,windows', '["host"]', False,'regular');
    call add_metric('mysql.com_kill', '服务', 'mysql', 'com_xxx 是指 xxxstatement被执行的次数','none', 'linux,windows', '["host"]', False,'regular');
    call add_metric('mysql.com_load', '服务', 'mysql', 'com_xxx 是指 xxxstatement被执行的次数','none', 'linux,windows', '["host"]', False,'regular');
    call add_metric('mysql.com_lock_tables', '服务', 'mysql', 'com_xxx 是指 xxxstatement被执行的次数','none', 'linux,windows', '["host"]', False,'regular');
    call add_metric('mysql.com_optimize', '服务', 'mysql', 'com_xxx 是指 xxxstatement被执行的次数','none', 'linux,windows', '["host"]', False,'regular');
    call add_metric('mysql.com_preload_keys', '服务', 'mysql', 'com_xxx 是指 xxxstatement被执行的次数','none', 'linux,windows', '["host"]', False,'regular');
    call add_metric('mysql.com_prepare_sql', '服务', 'mysql', 'com_xxx 是指 xxxstatement被执行的次数','none', 'linux,windows', '["host"]', False,'regular');
    call add_metric('mysql.com_purge', '服务', 'mysql', 'com_xxx 是指 xxxstatement被执行的次数','none', 'linux,windows', '["host"]', False,'regular');
    call add_metric('mysql.com_purge_before_date', '服务', 'mysql', 'com_xxx 是指 xxxstatement被执行的次数','none', 'linux,windows', '["host"]', False,'regular');
    call add_metric('mysql.com_release_savepoint', '服务', 'mysql', 'com_xxx 是指 xxxstatement被执行的次数','none', 'linux,windows', '["host"]', False,'regular');
    call add_metric('mysql.com_rename_table', '服务', 'mysql', 'com_xxx 是指 xxxstatement被执行的次数','none', 'linux,windows', '["host"]', False,'regular');
    call add_metric('mysql.com_rename_user', '服务', 'mysql', 'com_xxx 是指 xxxstatement被执行的次数','none', 'linux,windows', '["host"]', False,'regular');
    call add_metric('mysql.com_repair', '服务', 'mysql', 'com_xxx 是指 xxxstatement被执行的次数','none', 'linux,windows', '["host"]', False,'regular');
    call add_metric('mysql.com_replace', '服务', 'mysql', 'com_xxx 是指 xxxstatement被执行的次数','none', 'linux,windows', '["host"]', False,'regular');
    call add_metric('mysql.com_replace_select', '服务', 'mysql', 'com_xxx 是指 xxxstatement被执行的次数','none', 'linux,windows', '["host"]', False,'regular');
    call add_metric('mysql.com_reset', '服务', 'mysql', 'com_xxx 是指 xxxstatement被执行的次数','none', 'linux,windows', '["host"]', False,'regular');
    call add_metric('mysql.com_resignal', '服务', 'mysql', 'com_xxx 是指 xxxstatement被执行的次数','none', 'linux,windows', '["host"]', False,'regular');
    call add_metric('mysql.com_revoke', '服务', 'mysql', 'com_xxx 是指 xxxstatement被执行的次数','none', 'linux,windows', '["host"]', False,'regular');
    call add_metric('mysql.com_revoke_all', '服务', 'mysql', 'com_xxx 是指 xxxstatement被执行的次数','none', 'linux,windows', '["host"]', False,'regular');
    call add_metric('mysql.com_rollback', '服务', 'mysql', 'com_xxx 是指 xxxstatement被执行的次数','none', 'linux,windows', '["host"]', False,'regular');
    call add_metric('mysql.com_rollback_to_savepoint', '服务', 'mysql', 'com_xxx 是指 xxxstatement被执行的次数','none', 'linux,windows', '["host"]', False,'regular');
    call add_metric('mysql.com_savepoint', '服务', 'mysql', 'com_xxx 是指 xxxstatement被执行的次数','none', 'linux,windows', '["host"]', False,'regular');
    call add_metric('mysql.com_select', '服务', 'mysql', 'com_xxx 是指 xxxstatement被执行的次数','none', 'linux,windows', '["host"]', True,'regular');
    call add_metric('mysql.com_set_option', '服务', 'mysql', 'com_xxx 是指 xxxstatement被执行的次数','none', 'linux,windows', '["host"]', False,'regular');
    call add_metric('mysql.com_show_binlog_events', '服务', 'mysql', 'com_xxx 是指 xxxstatement被执行的次数','none', 'linux,windows', '["host"]', False,'regular');
    call add_metric('mysql.com_show_binlogs', '服务', 'mysql', 'com_xxx 是指 xxxstatement被执行的次数','none', 'linux,windows', '["host"]', False,'regular');
    call add_metric('mysql.com_show_charsets', '服务', 'mysql', 'com_xxx 是指 xxxstatement被执行的次数','none', 'linux,windows', '["host"]', False,'regular');
    call add_metric('mysql.com_show_collations', '服务', 'mysql', 'com_xxx 是指 xxxstatement被执行的次数','none', 'linux,windows', '["host"]', False,'regular');
    call add_metric('mysql.com_show_create_db', '服务', 'mysql', 'com_xxx 是指 xxxstatement被执行的次数','none', 'linux,windows', '["host"]', False,'regular');
    call add_metric('mysql.com_show_create_event', '服务', 'mysql', 'com_xxx 是指 xxxstatement被执行的次数','none', 'linux,windows', '["host"]', False,'regular');
    call add_metric('mysql.com_show_create_func', '服务', 'mysql', 'com_xxx 是指 xxxstatement被执行的次数','none', 'linux,windows', '["host"]', False,'regular');
    call add_metric('mysql.com_show_create_proc', '服务', 'mysql', 'com_xxx 是指 xxxstatement被执行的次数','none', 'linux,windows', '["host"]', False,'regular');
    call add_metric('mysql.com_show_create_table', '服务', 'mysql', 'com_xxx 是指 xxxstatement被执行的次数','none', 'linux,windows', '["host"]', False,'regular');
    call add_metric('mysql.com_show_create_trigger', '服务', 'mysql', 'com_xxx 是指 xxxstatement被执行的次数','none', 'linux,windows', '["host"]', False,'regular');
    call add_metric('mysql.com_show_create_user', '服务', 'mysql', 'com_xxx 是指 xxxstatement被执行的次数','none', 'linux,windows', '["host"]', False,'regular');
    call add_metric('mysql.com_show_databases', '服务', 'mysql', 'com_xxx 是指 xxxstatement被执行的次数','none', 'linux,windows', '["host"]', False,'regular');
    call add_metric('mysql.com_show_engine_logs', '服务', 'mysql', 'com_xxx 是指 xxxstatement被执行的次数','none', 'linux,windows', '["host"]', False,'regular');
    call add_metric('mysql.com_show_engine_mutex', '服务', 'mysql', 'com_xxx 是指 xxxstatement被执行的次数','none', 'linux,windows', '["host"]', False,'regular');
    call add_metric('mysql.com_show_engine_status', '服务', 'mysql', 'com_xxx 是指 xxxstatement被执行的次数','none', 'linux,windows', '["host"]', False,'regular');
    call add_metric('mysql.com_show_errors', '服务', 'mysql', 'com_xxx 是指 xxxstatement被执行的次数','none', 'linux,windows', '["host"]', False,'regular');
    call add_metric('mysql.com_show_events', '服务', 'mysql', 'com_xxx 是指 xxxstatement被执行的次数','none', 'linux,windows', '["host"]', False,'regular');
    call add_metric('mysql.com_show_fields', '服务', 'mysql', 'com_xxx 是指 xxxstatement被执行的次数','none', 'linux,windows', '["host"]', False,'regular');
    call add_metric('mysql.com_show_function_code', '服务', 'mysql', 'com_xxx 是指 xxxstatement被执行的次数','none', 'linux,windows', '["host"]', False,'regular');
    call add_metric('mysql.com_show_function_status', '服务', 'mysql', 'com_xxx 是指 xxxstatement被执行的次数','none', 'linux,windows', '["host"]', False,'regular');
    call add_metric('mysql.com_show_grants', '服务', 'mysql', 'com_xxx 是指 xxxstatement被执行的次数','none', 'linux,windows', '["host"]', False,'regular');
    call add_metric('mysql.com_show_keys', '服务', 'mysql', 'com_xxx 是指 xxxstatement被执行的次数','none', 'linux,windows', '["host"]', False,'regular');
    call add_metric('mysql.com_show_master_status', '服务', 'mysql', 'com_xxx 是指 xxxstatement被执行的次数','none', 'linux,windows', '["host"]', False,'regular');
    call add_metric('mysql.com_show_open_tables', '服务', 'mysql', 'com_xxx 是指 xxxstatement被执行的次数','none', 'linux,windows', '["host"]', False,'regular');
    call add_metric('mysql.com_show_plugins', '服务', 'mysql', 'com_xxx 是指 xxxstatement被执行的次数','none', 'linux,windows', '["host"]', False,'regular');
    call add_metric('mysql.com_show_privileges', '服务', 'mysql', 'com_xxx 是指 xxxstatement被执行的次数','none', 'linux,windows', '["host"]', False,'regular');
    call add_metric('mysql.com_show_procedure_code', '服务', 'mysql', 'com_xxx 是指 xxxstatement被执行的次数','none', 'linux,windows', '["host"]', False,'regular');
    call add_metric('mysql.com_show_procedure_status', '服务', 'mysql', 'com_xxx 是指 xxxstatement被执行的次数','none', 'linux,windows', '["host"]', False,'regular');
    call add_metric('mysql.com_show_processlist', '服务', 'mysql', 'com_xxx 是指 xxxstatement被执行的次数','none', 'linux,windows', '["host"]', False,'regular');
    call add_metric('mysql.com_show_profile', '服务', 'mysql', 'com_xxx 是指 xxxstatement被执行的次数','none', 'linux,windows', '["host"]', False,'regular');
    call add_metric('mysql.com_show_profiles', '服务', 'mysql', 'com_xxx 是指 xxxstatement被执行的次数','none', 'linux,windows', '["host"]', False,'regular');
    call add_metric('mysql.com_show_relaylog_events', '服务', 'mysql', 'com_xxx 是指 xxxstatement被执行的次数','none', 'linux,windows', '["host"]', False,'regular');
    call add_metric('mysql.com_show_slave_hosts', '服务', 'mysql', 'com_xxx 是指 xxxstatement被执行的次数','none', 'linux,windows', '["host"]', False,'regular');
    call add_metric('mysql.com_show_slave_status', '服务', 'mysql', 'com_xxx 是指 xxxstatement被执行的次数','none', 'linux,windows', '["host"]', False,'regular');
    call add_metric('mysql.com_show_status', '服务', 'mysql', 'com_xxx 是指 xxxstatement被执行的次数','none', 'linux,windows', '["host"]', False,'regular');
    call add_metric('mysql.com_show_storage_engines', '服务', 'mysql', 'com_xxx 是指 xxxstatement被执行的次数','none', 'linux,windows', '["host"]', False,'regular');
    call add_metric('mysql.com_show_table_status', '服务', 'mysql', 'com_xxx 是指 xxxstatement被执行的次数','none', 'linux,windows', '["host"]', False,'regular');
    call add_metric('mysql.com_show_tables', '服务', 'mysql', 'com_xxx 是指 xxxstatement被执行的次数','none', 'linux,windows', '["host"]', False,'regular');
    call add_metric('mysql.com_show_triggers', '服务', 'mysql', 'com_xxx 是指 xxxstatement被执行的次数','none', 'linux,windows', '["host"]', False,'regular');
    call add_metric('mysql.com_show_variables', '服务', 'mysql', 'com_xxx 是指 xxxstatement被执行的次数','none', 'linux,windows', '["host"]', False,'regular');
    call add_metric('mysql.com_show_warnings', '服务', 'mysql', 'com_xxx 是指 xxxstatement被执行的次数','none', 'linux,windows', '["host"]', False,'regular');
    call add_metric('mysql.com_shutdown', '服务', 'mysql', 'com_xxx 是指 xxxstatement被执行的次数','none', 'linux,windows', '["host"]', False,'regular');
    call add_metric('mysql.com_signal', '服务', 'mysql', 'com_xxx 是指 xxxstatement被执行的次数','none', 'linux,windows', '["host"]', False,'regular');
    call add_metric('mysql.com_slave_start', '服务', 'mysql', 'com_xxx 是指 xxxstatement被执行的次数','none', 'linux,windows', '["host"]', False,'regular');
    call add_metric('mysql.com_slave_stop', '服务', 'mysql', 'com_xxx 是指 xxxstatement被执行的次数','none', 'linux,windows', '["host"]', False,'regular');
    call add_metric('mysql.com_stmt_close', '服务', 'mysql', 'com_xxx 是指 xxxstatement被执行的次数','none', 'linux,windows', '["host"]', False,'regular');
    call add_metric('mysql.com_stmt_execute', '服务', 'mysql', 'com_xxx 是指 xxxstatement被执行的次数','none', 'linux,windows', '["host"]', False,'regular');
    call add_metric('mysql.com_stmt_fetch', '服务', 'mysql', 'com_xxx 是指 xxxstatement被执行的次数','none', 'linux,windows', '["host"]', False,'regular');
    call add_metric('mysql.com_stmt_prepare', '服务', 'mysql', 'com_xxx 是指 xxxstatement被执行的次数','none', 'linux,windows', '["host"]', False,'regular');
    call add_metric('mysql.com_stmt_reprepare', '服务', 'mysql', 'com_xxx 是指 xxxstatement被执行的次数','none', 'linux,windows', '["host"]', False,'regular');
    call add_metric('mysql.com_stmt_reset', '服务', 'mysql', 'com_xxx 是指 xxxstatement被执行的次数','none', 'linux,windows', '["host"]', False,'regular');
    call add_metric('mysql.com_stmt_send_long_data', '服务', 'mysql', 'com_xxx 是指 xxxstatement被执行的次数','none', 'linux,windows', '["host"]', False,'regular');
    call add_metric('mysql.com_truncate', '服务', 'mysql', 'com_xxx 是指 xxxstatement被执行的次数','none', 'linux,windows', '["host"]', False,'regular');
    call add_metric('mysql.com_uninstall_plugin', '服务', 'mysql', 'com_xxx 是指 xxxstatement被执行的次数','none', 'linux,windows', '["host"]', False,'regular');
    call add_metric('mysql.com_unlock_tables', '服务', 'mysql', 'com_xxx 是指 xxxstatement被执行的次数','none', 'linux,windows', '["host"]', False,'regular');
    call add_metric('mysql.com_update', '服务', 'mysql', 'com_xxx 是指 xxxstatement被执行的次数','none', 'linux,windows', '["host"]', True,'regular');
    call add_metric('mysql.com_update_multi', '服务', 'mysql', 'com_xxx 是指 xxxstatement被执行的次数','none', 'linux,windows', '["host"]', False,'regular');
    call add_metric('mysql.com_xa_commit', '服务', 'mysql', 'com_xxx 是指 xxxstatement被执行的次数','none', 'linux,windows', '["host"]', False,'regular');
    call add_metric('mysql.com_xa_end', '服务', 'mysql', 'com_xxx 是指 xxxstatement被执行的次数','none', 'linux,windows', '["host"]', False,'regular');
    call add_metric('mysql.com_xa_prepare', '服务', 'mysql', 'com_xxx 是指 xxxstatement被执行的次数','none', 'linux,windows', '["host"]', False,'regular');
    call add_metric('mysql.com_xa_recover', '服务', 'mysql', 'com_xxx 是指 xxxstatement被执行的次数','none', 'linux,windows', '["host"]', False,'regular');
    call add_metric('mysql.com_xa_rollback', '服务', 'mysql', 'com_xxx 是指 xxxstatement被执行的次数','none', 'linux,windows', '["host"]', False,'regular');
    call add_metric('mysql.com_xa_start', '服务', 'mysql', 'com_xxx 是指 xxxstatement被执行的次数','none', 'linux,windows', '["host"]', False,'regular');
    call add_metric('mysql.connection_errors_accept', '服务', 'mysql', '在使用accpet()方法中错误出现的次数','none', 'linux,windows', '["host"]', False,'regular');
    call add_metric('mysql.connection_errors_internal', '服务', 'mysql', '因为服务器的内部错误(such as 创建新线程失败或者内存不足状态)而被拒绝的连接的数量','none', 'linux,windows', '["host"]', True,'regular');
    call add_metric('mysql.connection_errors_max_connections', '服务', 'mysql', '因为服务器已经达到最大可连接数量而被拒绝的连接数量','none', 'linux,windows', '["host"]', True,'regular');
    call add_metric('mysql.connection_errors_peer_address', '服务', 'mysql', '在寻找连接客户的IP地址时产生的错误','none', 'linux,windows', '["host"]', False,'regular');
    call add_metric('mysql.connection_errors_select', '服务', 'mysql', '在聆听端口调用select 或者pull的方法时产生的错误数量','none', 'linux,windows', '["host"]', False,'regular');
    call add_metric('mysql.connection_errors_tcpwrap', '服务', 'mysql', '被libwarp库所拒绝的连接的数量','none', 'linux,windows', '["host"]', False,'regular');
    call add_metric('mysql.connection_states', '服务', 'mysql', '对MySQL服务器的连接尝试次数(成功与否)', 'short', 'linux,windows', '["host"]', False,'regular');
    call add_metric('mysql.connections', '服务', 'mysql', '无论成功与否尝试连接 MySQL的链接数量','none', 'linux,windows', '["host"]', False,'regular');
    call add_metric('mysql.created_tmp_disk_tables', '服务', 'mysql', '在执行命令时，内服务器在内部在磁盘上的暂时的表被创建的数量','none', 'linux,windows', '["host"]', False,'regular');
    call add_metric('mysql.created_tmp_files', '服务', 'mysql', '被MySQLd所创建的暂时性的文件的数量','none', 'linux,windows', '["host"]', False,'regular');
    call add_metric('mysql.created_tmp_tables', '服务', 'mysql', '在执行命令时，被服务器在内部所创建的暂时的表被创建的数量','none', 'linux,windows', '["host"]', False,'regular');
    call add_metric('mysql.delayed_errors', '服务', 'mysql', '这个变量是被反对的而且在未来的版本中将会被移除掉','none', 'linux,windows', '["host"]', False,'regular');
    call add_metric('mysql.delayed_insert_threads', '服务', 'mysql', '这个变量是被反对的而且在未来的版本中将会被移除掉','none', 'linux,windows', '["host"]', False,'regular');
    call add_metric('mysql.delayed_writes', '服务', 'mysql', '这个变量是被反对的而且在未来的版本中将会被移除掉','none', 'linux,windows', '["host"]', False,'regular');
    call add_metric('mysql.flush_commands', '服务', 'mysql', '被服务器所清洗的表的数量','none', 'linux,windows', '["host"]', False,'regular');
    call add_metric('mysql.handler_commit', '服务', 'mysql', '内部提交的命令数量','none', 'linux,windows', '["host"]', False,'regular');
    call add_metric('mysql.handler_delete', '服务', 'mysql', '在表中被移除的行的数量','none', 'linux,windows', '["host"]', False,'regular');
    call add_metric('mysql.handler_discover', '服务', 'mysql', '','none', 'linux,windows', '["host"]', False,'regular');
    call add_metric('mysql.handler_external_lock', '服务', 'mysql', '每次当服务器调用external_lock方法时，这个变量将会随之增加','none', 'linux,windows', '["host"]', False,'regular');
    call add_metric('mysql.handler_mrr_init', '服务', 'mysql', '服务器使用储存引擎的多范围读取的次数','none', 'linux,windows', '["host"]', False,'regular');
    call add_metric('mysql.handler_prepare', '服务', 'mysql', '两阶段的准备阶段的计数器','none', 'linux,windows', '["host"]', False,'regular');
    call add_metric('mysql.handler_read_first', '服务', 'mysql', '第一个被读出的索引数的次数','none', 'linux,windows', '["host"]', False,'regular');
    call add_metric('mysql.handler_read_key', '服务', 'mysql', '需要通过一个关键变量来读取行的次数','none', 'linux,windows', '["host"]', False,'regular');
    call add_metric('mysql.handler_read_last', '服务', 'mysql', '在一个索引中读取最后一个关键变量的请求次数','none', 'linux,windows', '["host"]', False,'regular');
    call add_metric('mysql.handler_read_next', '服务', 'mysql', '通过关键变量顺序来读取下一行的请求次数','none', 'linux,windows', '["host"]', False,'regular');
    call add_metric('mysql.handler_read_prev', '服务', 'mysql', '通过关键变量顺序来读取前一行的请求次数','none', 'linux,windows', '["host"]', False,'regular');
    call add_metric('mysql.handler_read_rnd', '服务', 'mysql', '通过指定位置顺序来读取一行的请求次数','none', 'linux,windows', '["host"]', False,'regular');
    call add_metric('mysql.handler_read_rnd_next', '服务', 'mysql', '在一个数据文件中来读取下一行的请求次数','none', 'linux,windows', '["host"]', False,'regular');
    call add_metric('mysql.handler_rollback', '服务', 'mysql', '储存引擎来执行回滚的请求次数','none', 'linux,windows', '["host"]', False,'regular');
    call add_metric('mysql.handler_savepoint', '服务', 'mysql', '储存引擎来放置一个保存点的请求的次数','none', 'linux,windows', '["host"]', False,'regular');
    call add_metric('mysql.handler_savepoint_rollback', '服务', 'mysql', '储存引擎来回滚到之前的储存点的请求次数','none', 'linux,windows', '["host"]', False,'regular');
    call add_metric('mysql.handler_update', '服务', 'mysql', '在一个表中，请求更新一行的次数','none', 'linux,windows', '["host"]', False,'regular');
    call add_metric('mysql.handler_write', '服务', 'mysql', '在一个表中，请求插入一行的次数','none', 'linux,windows', '["host"]', False,'regular');
    call add_metric('mysql.innodb.history_list_length', '服务', 'mysql', '历史记录的长度，即位于innodb数据文件的撤销空间里的页面的数目', 'short', 'linux,windows', '["host"]', False,'regular');
    call add_metric('mysql.innodb.ibuf.free_list_len', '服务', 'mysql', '表示ibuf树的空闲链表长度', 'short', 'linux,windows', '["host"]', False,'regular');
    call add_metric('mysql.innodb.ibuf.seg_size', '服务', 'mysql', '包含ibuf header页和ibuf tree的segment的Page数', 'short', 'linux,windows', '["host"]', False,'regular');
    call add_metric('mysql.innodb.ibuf.size', '服务', 'mysql', '表示Ibuf 索引树的page数', 'short', 'linux,windows', '["host"]', False,'regular');
    call add_metric('mysql.innodb.locks.os_waits', '服务', 'mysql', '线程放弃spin wait尝试，直接进入sleep状态的次数', 'short', 'linux,windows', '["host"]', True,'regular');
    call add_metric('mysql.innodb.locks.rounds', '服务', 'mysql', '线程进入spin wait循环的次数，也就是检查mutex锁的次数', 'short', 'linux,windows', '["host"]', False,'regular');
    call add_metric('mysql.innodb.locks.spin_waits', '服务', 'mysql', '线程尝试获取spin锁而不可得的次数，也就是 spin-wait 的次数', 'short', 'linux,windows', '["host"]', True,'regular');
    call add_metric('mysql.innodb.opened_read_views', '服务', 'mysql', '显示只读视图的数量', 'short', 'linux,windows', '["host"]', False,'regular');
    call add_metric('mysql.innodb.queries_queued', '服务', 'mysql', '有多少个正在查询操作个数', 'short', 'linux,windows', '["host"]', False,'regular');
    call add_metric('mysql.innodb_available_undo_logs', '服务', 'mysql', '每个表格空间可用的回滚碎片的数量','none', 'linux,windows', '["host"]', False,'regular');
    call add_metric('mysql.innodb_buffer_pool_bytes_data', '服务', 'mysql', '在用来收集数据的innodb buffer池中的总byte数量','none', 'linux,windows', '["host"]', False,'regular');
    call add_metric('mysql.innodb_buffer_pool_bytes_dirty', '服务', 'mysql', '在innodb buffer池中的dirty pages所暂存的总byte数量','none', 'linux,windows', '["host"]', False,'regular');
    call add_metric('mysql.innodb_buffer_pool_pages_data', '服务', 'mysql', '在用来收集数据的innodb buffer池中的总byte数量','none', 'linux,windows', '["host"]', False,'regular');
    call add_metric('mysql.innodb_buffer_pool_pages_dirty', '服务', 'mysql', '在innodb buffer池中的dirty pages所暂存的总byte数量','none', 'linux,windows', '["host"]', False,'regular');
    call add_metric('mysql.innodb_buffer_pool_pages_flushed', '服务', 'mysql', '请求清洗在innodb buffer 池中的页表次数','none', 'linux,windows', '["host"]', False,'regular');
    call add_metric('mysql.innodb_buffer_pool_pages_free', '服务', 'mysql', '在innodb buffer池中的可用页表数量','none', 'linux,windows', '["host"]', False,'regular');
    call add_metric('mysql.innodb_buffer_pool_pages_misc', '服务', 'mysql', '在innodb buffer 池中页表的数量','none', 'linux,windows', '["host"]', False,'regular');
    call add_metric('mysql.innodb_buffer_pool_pages_total', '服务', 'mysql', '在innodb buffer 池中的页表的总大小','none', 'linux,windows', '["host"]', True,'regular');
    call add_metric('mysql.innodb_buffer_pool_read_ahead', '服务', 'mysql', '在innodb buffer 池中通过提前后台阅读线程来读取的表的数量','none', 'linux,windows', '["host"]', False,'regular');
    call add_metric('mysql.innodb_buffer_pool_read_ahead_evicted', '服务', 'mysql', '在innodb buffer 池中通过提前后台阅读线程来读取的表的数量','none', 'linux,windows', '["host"]', False,'regular');
    call add_metric('mysql.innodb_buffer_pool_read_ahead_rnd', '服务', 'mysql', '通过innodb所启动的随机提前阅读的数量','none', 'linux,windows', '["host"]', False,'regular');
    call add_metric('mysql.innodb_buffer_pool_read_requests', '服务', 'mysql', '逻辑阅读请求的数量','none', 'linux,windows', '["host"]', True,'regular');
    call add_metric('mysql.innodb_buffer_pool_reads', '服务', 'mysql', '来自buffer池中不能被innodb所满足的逻辑阅读的数量','none', 'linux,windows', '["host"]', True,'regular');
    call add_metric('mysql.innodb_buffer_pool_wait_free', '服务', 'mysql', '实例等待的计数器','none', 'linux,windows', '["host"]', False,'regular');
    call add_metric('mysql.innodb_buffer_pool_write_requests', '服务', 'mysql', '写入到innodb buffer池完成的数量','none', 'linux,windows', '["host"]', False,'regular');
    call add_metric('mysql.innodb_data_fsyncs', '服务', 'mysql', 'fsync()方法被运行的次数','none', 'linux,windows', '["host"]', False,'regular');
    call add_metric('mysql.innodb_data_pending_fsyncs', '服务', 'mysql', '目前在等待中状态的fsync()的数量','none', 'linux,windows', '["host"]', False,'regular');
    call add_metric('mysql.innodb_data_pending_reads', '服务', 'mysql', '目前在等待中的读取的数量','none', 'linux,windows', '["host"]', False,'regular');
    call add_metric('mysql.innodb_data_pending_writes', '服务', 'mysql', '目前在等待中的写入的数量','none', 'linux,windows', '["host"]', False,'regular');
    call add_metric('mysql.innodb_data_read', '服务', 'mysql', '从服务器启动以来以bytes为单位的被读取的数据大小','none', 'linux,windows', '["host"]', False,'regular');
    call add_metric('mysql.innodb_data_reads', '服务', 'mysql', '被阅读的数据的总大小','none', 'linux,windows', '["host"]', False,'regular');
    call add_metric('mysql.innodb_data_writes', '服务', 'mysql', '被写入的数据的总大小','none', 'linux,windows', '["host"]', False,'regular');
    call add_metric('mysql.innodb_data_written', '服务', 'mysql', '截止到目前被写入的数据的大小','none', 'linux,windows', '["host"]', False,'regular');
    call add_metric('mysql.innodb_dblwr_pages_written', '服务', 'mysql', '被写入到doublewrite buffer中的页表数量','none', 'linux,windows', '["host"]', False,'regular');
    call add_metric('mysql.innodb_dblwr_writes', '服务', 'mysql', 'Doublewrite 进程被执行的次数','none', 'linux,windows', '["host"]', False,'regular');
    call add_metric('mysql.innodb_log_waits', '服务', 'mysql', 'log buffer过小的次数','none', 'linux,windows', '["host"]', False,'regular');
    call add_metric('mysql.innodb_log_write_requests', '服务', 'mysql', '为innodb redo log所请求的写入的次数','none', 'linux,windows', '["host"]', False,'regular');
    call add_metric('mysql.innodb_log_writes', '服务', 'mysql', '物理写入到innodb redo log 的次数','none', 'linux,windows', '["host"]', False,'regular');
    call add_metric('mysql.innodb_num_open_files', '服务', 'mysql', '目前在innodb中被保持开启状态的文件的数量','none', 'linux,windows', '["host"]', False,'regular');
    call add_metric('mysql.innodb_os_log_fsyncs', '服务', 'mysql', 'fsync()写入被完成的次数','none', 'linux,windows', '["host"]', False,'regular');
    call add_metric('mysql.innodb_os_log_pending_fsyncs', '服务', 'mysql', 'fsync()写入在等待中的次数','none', 'linux,windows', '["host"]', False,'regular');
    call add_metric('mysql.innodb_os_log_pending_writes', '服务', 'mysql', '在等待中的写入的数量','none', 'linux,windows', '["host"]', False,'regular');
    call add_metric('mysql.innodb_os_log_written', '服务', 'mysql', '写入到innodb redo log 文件中的byte数量','none', 'linux,windows', '["host"]', False,'regular');
    call add_metric('mysql.innodb_page_size', '服务', 'mysql', 'Innodb 页表大小','none', 'linux,windows', '["host"]', False,'regular');
    call add_metric('mysql.innodb_pages_created', '服务', 'mysql', '在innodb 表中被创建的页表数量','none', 'linux,windows', '["host"]', False,'regular');
    call add_metric('mysql.innodb_pages_read', '服务', 'mysql', '在innodb 表中通过innodb buffer池读取的页表的数量','none', 'linux,windows', '["host"]', False,'regular');
    call add_metric('mysql.innodb_pages_written', '服务', 'mysql', '在innodb 表中被写入的页表的数量','none', 'linux,windows', '["host"]', False,'regular');
    call add_metric('mysql.innodb_row_lock_current_waits', '服务', 'mysql', '行锁的数量','none', 'linux,windows', '["host"]', False,'regular');
    call add_metric('mysql.innodb_row_lock_time', '服务', 'mysql', '得到一个行锁的总时间','none', 'linux,windows', '["host"]', False,'regular');
    call add_metric('mysql.innodb_row_lock_time_avg', '服务', 'mysql', '得到一个行锁的平均时间','none', 'linux,windows', '["host"]', False,'regular');
    call add_metric('mysql.innodb_row_lock_time_max', '服务', 'mysql', '得到一个行锁的最大时间','none', 'linux,windows', '["host"]', False,'regular');
    call add_metric('mysql.innodb_row_lock_waits', '服务', 'mysql', '等待一个行锁的时间','none', 'linux,windows', '["host"]', False,'regular');
    call add_metric('mysql.innodb_rows_deleted', '服务', 'mysql', '从innodb 表中删除掉的行数','none', 'linux,windows', '["host"]', False,'regular');
    call add_metric('mysql.innodb_rows_inserted', '服务', 'mysql', '从innodb 表中插入掉的行数','none', 'linux,windows', '["host"]', False,'regular');
    call add_metric('mysql.innodb_rows_read', '服务', 'mysql', '从innodb 表中读取掉的行数','none', 'linux,windows', '["host"]', False,'regular');
    call add_metric('mysql.innodb_rows_updated', '服务', 'mysql', '从innodb 表中更新掉的行数','none', 'linux,windows', '["host"]', False,'regular');
    call add_metric('mysql.innodb_truncated_status_writes', '服务', 'mysql', '输出被t缩短了的次数','none', 'linux,windows', '["host"]', False,'regular');
    call add_metric('mysql.key_blocks_not_flushed', '服务', 'mysql', 'key block 的数量','none', 'linux,windows', '["host"]', False,'regular');
    call add_metric('mysql.key_blocks_unused', '服务', 'mysql', '没被保存key block 的数量','none', 'linux,windows', '["host"]', False,'regular');
    call add_metric('mysql.key_blocks_used', '服务', 'mysql', '没被保存key block 的数量','none', 'linux,windows', '["host"]', False,'regular');
    call add_metric('mysql.key_read_requests', '服务', 'mysql', '读取一个Key block 的次数','none', 'linux,windows', '["host"]', False,'regular');
    call add_metric('mysql.key_reads', '服务', 'mysql', '物理读取一个Key block 的次数','none', 'linux,windows', '["host"]', False,'regular');
    call add_metric('mysql.key_write_requests', '服务', 'mysql', '写入一个Key block 的次数','none', 'linux,windows', '["host"]', False,'regular');
    call add_metric('mysql.key_writes', '服务', 'mysql', '物理写入一个Key block 的次数','none', 'linux,windows', '["host"]', False,'regular');
    call add_metric('mysql.last_query_cost', '服务', 'mysql', '最后一个被编辑的query的花费','none', 'linux,windows', '["host"]', False,'regular');
    call add_metric('mysql.last_query_partial_plans', '服务', 'mysql', '有多少个正在查询操作个数', 'short', 'linux,windows', '["host"]', False,'regular');
    call add_metric('mysql.locked_connects', '服务', 'mysql', '企图连接一个被锁定的用户的次数','none', 'linux,windows', '["host"]', False,'regular');
    call add_metric('mysql.locks.os_waits', '服务', 'mysql', '','none', 'linux,windows', '["host"]', False,'regular');
    call add_metric('mysql.locks.rounds', '服务', 'mysql', '','none', 'linux,windows', '["host"]', False,'regular');
    call add_metric('mysql.locks.spin_waits', '服务', 'mysql', '','none', 'linux,windows', '["host"]', False,'regular');
    call add_metric('mysql.max_execution_time_exceeded', '服务', 'mysql', 'select statement在执行中超时的次数','none', 'linux,windows', '["host"]', False,'regular');
    call add_metric('mysql.max_execution_time_set', '服务', 'mysql', 'select statement在执行中超时的次数','none', 'linux,windows', '["host"]', False,'regular');
    call add_metric('mysql.max_execution_time_set_failed', '服务', 'mysql', 'select statement在执行中超时的次数','none', 'linux,windows', '["host"]', False,'regular');
    call add_metric('mysql.max_used_connections', '服务', 'mysql', '同时使用的连接的最大数目', 'short', 'linux,windows', '["host"]', True,'regular');
    call add_metric('mysql.not_flushed_delayed_rows', '服务', 'mysql', '在INSERT DELAY队列中等待写入的行的数量', 'short', 'linux,windows', '["host"]', False,'regular');
    call add_metric('mysql.ongoing_anonymous_transaction_count', '服务', 'mysql', '缓存的表的数量','none', 'linux,windows', '["host"]', False,'regular');
    call add_metric('mysql.open_files', '服务', 'mysql', '打开文件的数量', 'short', 'linux,windows', '["host"]', False,'regular');
    call add_metric('mysql.open_streams', '服务', 'mysql', '打开流的数量(主要用于日志记载)', 'short', 'linux,windows', '["host"]', False,'regular');
    call add_metric('mysql.open_table_definitions', '服务', 'mysql', '缓存的表的数量','none', 'linux,windows', '["host"]', False,'regular');
    call add_metric('mysql.open_tables', '服务', 'mysql', '已经打开的表的数量', 'short', 'linux,windows', '["host"]', True,'regular');
    call add_metric('mysql.opened_files', '服务', 'mysql', '通过my_open()执行的文件的数量','none', 'linux,windows', '["host"]', False,'regular');
    call add_metric('mysql.opened_table_definitions', '服务', 'mysql', '缓存的表的数量','none', 'linux,windows', '["host"]', False,'regular');
    call add_metric('mysql.opened_tables', '服务', 'mysql', '被打开的表的数量','none', 'linux,windows', '["host"]', False,'regular');
    call add_metric('mysql.performance_schema_accounts_lost', '服务', 'mysql', '因为已经满了，导致不能将一行添加到帐户表中的次数', 'short', 'linux,windows', '["host"]', False,'regular');
    call add_metric('mysql.performance_schema_cond_classes_lost', '服务', 'mysql', 'How many condition instruments could not be loaded', 'short', 'linux,windows', '["host"]', False,'regular');
    call add_metric('mysql.performance_schema_cond_instances_lost', '服务', 'mysql', 'How many condition instrument instances could not be created', 'short', 'linux,windows', '["host"]', False,'regular');
    call add_metric('mysql.performance_schema_digest_lost', '服务', 'mysql', 'The number of digest instances that could not be instrumented in theevents_statements_summary_by_digest table. This can be nonzero if the value ofperformance_schema_digests_size is too small', 'short', 'linux,windows', '["host"]', False,'regular');
    call add_metric('mysql.performance_schema_file_classes_lost', '服务', 'mysql', 'How many file instruments could not be loaded', 'short', 'linux,windows', '["host"]', False,'regular');
    call add_metric('mysql.performance_schema_file_handles_lost', '服务', 'mysql', 'How many file instrument instances could not be opened', 'short', 'linux,windows', '["host"]', False,'regular');
    call add_metric('mysql.performance_schema_file_instances_lost', '服务', 'mysql', 'How many file instrument instances could not be created', 'short', 'linux,windows', '["host"]', False,'regular');
    call add_metric('mysql.performance_schema_hosts_lost', '服务', 'mysql', 'The number of times a row could not be added to the hosts table because it was full', 'short', 'linux,windows', '["host"]', False,'regular');
    call add_metric('mysql.performance_schema_index_stat_lost', '服务', 'mysql', '','none', 'linux,windows', '["host"]', False,'regular');
    call add_metric('mysql.performance_schema_locker_lost', '服务', 'mysql', 'How many events are “lost” or not recorded, due to the following conditions:Events are recursive. The depth of the nested events stack is greater than the limit imposed by the implementation. Events recorded by the Performance Schema are not recursive, so this variable should always be 0.', 'short', 'linux,windows','["host"]', False,'regular');
    call add_metric('mysql.performance_schema_memory_classes_lost', '服务', 'mysql', '','none', 'linux,windows', '["host"]', False,'regular');
    call add_metric('mysql.performance_schema_metadata_lock_lost', '服务', 'mysql', '','none', 'linux,windows', '["host"]', False,'regular');
    call add_metric('mysql.performance_schema_mutex_classes_lost', '服务', 'mysql', 'The number of times a memory instrument could not be loaded', 'short', 'linux,windows', '["host"]', False,'regular');
    call add_metric('mysql.performance_schema_mutex_instances_lost', '服务', 'mysql', 'How many mutex instrument instances could not be created', 'short', 'linux,windows', '["host"]', False,'regular');
    call add_metric('mysql.performance_schema_nested_statement_lost', '服务', 'mysql', '','none', 'linux,windows', '["host"]', False,'regular');
    call add_metric('mysql.performance_schema_prepared_statements_lost', '服务', 'mysql', '','none', 'linux,windows', '["host"]', False,'regular');
    call add_metric('mysql.performance_schema_program_lost', '服务', 'mysql', '','none', 'linux,windows', '["host"]', False,'regular');
    call add_metric('mysql.performance_schema_rwlock_classes_lost', '服务', 'mysql', 'How many rwlock instruments could not be loaded', 'short', 'linux,windows', '["host"]', False,'regular');
    call add_metric('mysql.performance_schema_rwlock_instances_lost', '服务', 'mysql', 'How many rwlock instrument instances could not be created', 'short', 'linux,windows', '["host"]', False,'regular');
    call add_metric('mysql.performance_schema_session_connect_attrs_lost', '服务', 'mysql', 'The number of connections for which connection attribute truncation has occurred.', 'short', 'linux,windows', '["host"]', False,'regular');
    call add_metric('mysql.performance_schema_socket_classes_lost', '服务', 'mysql', 'How many socket instruments could not be loaded', 'short', 'linux,windows', '["host"]', False,'regular');
    call add_metric('mysql.performance_schema_socket_instances_lost', '服务', 'mysql', 'How many socket instrument instances could not be created', 'short', 'linux,windows', '["host"]', False,'regular');
    call add_metric('mysql.performance_schema_stage_classes_lost', '服务', 'mysql', 'How many stage instruments could not be loaded', 'short', 'linux,windows', '["host"]', False,'regular');
    call add_metric('mysql.performance_schema_statement_classes_lost', '服务', 'mysql', 'How many statement instruments could not be loaded', 'short', 'linux,windows', '["host"]', False,'regular');
    call add_metric('mysql.performance_schema_table_handles_lost', '服务', 'mysql', 'How many table instrument instances could not be opened', 'short', 'linux,windows', '["host"]', False,'regular');
    call add_metric('mysql.performance_schema_table_instances_lost', '服务', 'mysql', 'How many table instrument instances could not be created', 'short', 'linux,windows', '["host"]', False,'regular');
    call add_metric('mysql.performance_schema_table_lock_stat_lost', '服务', 'mysql', '','none', 'linux,windows', '["host"]', False,'regular');
    call add_metric('mysql.performance_schema_thread_classes_lost', '服务', 'mysql', 'How many thread instruments could not be loaded', 'short', 'linux,windows', '["host"]', False,'regular');
    call add_metric('mysql.performance_schema_thread_instances_lost', '服务', 'mysql', 'The number of thread instances that could not be instrumented in the threads table', 'short', 'linux,windows', '["host"]', False,'regular');
    call add_metric('mysql.performance_schema_users_lost', '服务', 'mysql', 'The number of times a row could not be added to the users table because it was full', 'short', 'linux,windows', '["host"]', False,'regular');
    call add_metric('mysql.prepared_stmt_count', '服务', 'mysql', 'The current number of prepared statements.', 'short', 'linux,windows', '["host"]', False,'regular');
    call add_metric('mysql.qcache_free_blocks', '服务', 'mysql', 'Query Cache 中目前还有多少剩余的blocks。如果该值显示较大，则说明Query Cache 中的内存碎片较多了，可能需要寻找合适的机会进行整理。', 'short', 'linux,windows', '["host"]', False,'regular');
    call add_metric('mysql.qcache_free_memory', '服务', 'mysql', 'Query Cache 中目前剩余的内存大小。通过这个参数我们可以较为准确的观察出当前系统中的Query Cache 内存大小是否足够，是需要增加还是过多了。', 'bytes', 'linux,windows', '["host"]', False,'regular');
    call add_metric('mysql.qcache_hits', '服务', 'mysql', '多少次命中。通过这个参数我们可以查看到Query Cache 的基本效果。', 'short', 'linux,windows', '["host"]', False,'regular');
    call add_metric('mysql.qcache_inserts', '服务', 'mysql', '多少次未命中然后插入。通过“Qcache_hits”和“Qcache_inserts”两个参数我们就可以算出Query Cache 的命中率了。', 'short', 'linux,windows', '["host"]', False,'regular');
    call add_metric('mysql.qcache_lowmem_prunes', '服务', 'mysql', '多少条Query 因为内存不足而被清除出Query Cache。通过“Qcache_lowmem_prunes”和“Qcache_free_memory”相互结合，能够更清楚的了解到我们系统中Query Cache 的内存大小是否真的足够，是否非常频繁的出现因为内存不足而有Query 被换出', 'short', 'linux,windows', '["host"]', False,'regular');
    call add_metric('mysql.qcache_not_cached', '服务', 'mysql', '因为query_cache_type 的设置或者不能被cache 的Query 的数量', 'short', 'linux,windows', '["host"]', False,'regular');
    call add_metric('mysql.qcache_queries_in_cache', '服务', 'mysql', '当前Query Cache 中cache 的Query 数量', 'short', 'linux,windows', '["host"]', False,'regular');
    call add_metric('mysql.qcache_total_blocks', '服务', 'mysql', '当前Query Cache 中的block 数量', 'short', 'linux,windows', '["host"]', False,'regular');
    call add_metric('mysql.queries', '服务', 'mysql', 'The number of statements executed by the server. This variable includes statements executed within stored programs, unlike the Questions variable. It does not count COM_PING or COM_STATISTICS commands.', '', 'linux,windows', '["host"]', True ,'regular');
    call add_metric('mysql.questions', '服务', 'mysql', 'The number of statements executed by the server. This includes only statements sent to the server by clients and not statements executed within stored programs, unlike the Queries variable. This variable does not count COM_PING, COM_STATISTICS, COM_STMT_PREPARE, COM_STMT_CLOSE, or COM_STMT_RESET commands.', 'short', 'linux,windows', '["host"]', False,'regular');

    call add_metric('mysql.select_full_join', '服务', 'mysql', 'Number of full joins needed to answer queries. If too high, improve your indexing or database schema', 'short', 'linux,windows', '["host"]', False,'regular');
    call add_metric('mysql.select_full_range_join', '服务', 'mysql', 'The number of joins that used a range search on a reference table', 'short', 'linux,windows', '["host"]', False,'regular');
    call add_metric('mysql.select_range', '服务', 'mysql', 'The number of joins that used ranges on the first table. This is normally not a critical issue even if the value is quite large', 'short', 'linux,windows', '["host"]', False,'regular');
    call add_metric('mysql.select_range_check', '服务', 'mysql', 'The number of joins without keys that check for key usage after each row. If this is not 0, you should carefully check the indexes of your tables', 'short', 'linux,windows', '["host"]', False,'regular');
    call add_metric('mysql.select_scan', '服务', 'mysql', 'The number of joins that did a full scan of the first table', 'short', 'linux,windows', '["host"]', False,'regular');
    call add_metric('mysql.slave_open_temp_tables', '服务', 'mysql', 'The number of temporary tables that the slave SQL thread currently has open.', 'short', 'linux,windows', '["host"]', False,'regular');
    call add_metric('mysql.slave.bytes_executed','服务','mysql','slave处理字节量','short', 'linux,windows','["host"]',False,'Regular');
    call add_metric('mysql.slave.bytes_relayed','服务','mysql','slave接收字节量','short', 'linux,windows','["host"]',False,'Regular');
    call add_metric('mysql.slave.seconds_behind_master','服务','mysql','slave延迟状态','short', 'linux,windows','["host"]',True,'Regular');
    call add_metric('mysql.slave.thread_io_running','服务','mysql','IO通信状态','short', 'linux,windows','["host"]',False,'Regular');
    call add_metric('mysql.slave.thread_sql_running','服务','mysql','slave进程状态','short', 'linux,windows','["host"]',False,'Regular');
    call add_metric('mysql.slow_launch_threads', '服务', 'mysql', 'The number of threads that have taken more than slow_launch_time seconds to create', 'short', 'linux,windows', '["host"]', False,'regular');
    call add_metric('mysql.slow_queries', '服务', 'mysql', 'Number of queries that took more than long_query_time seconds to execute. Slow queries generate excessive disk reads, memory and CPU usage. Check slow_query_log to find them', 'short', 'linux,windows', '["host"]', True,'regular');
    call add_metric('mysql.sort_merge_passes', '服务', 'mysql', 'The number of merge passes that the sort algorithm has had to do','none', 'linux,windows', '["host"]', False,'regular');
    call add_metric('mysql.sort_range', '服务', 'mysql', 'The number of sorts that were done using ranges','none', 'linux,windows', '["host"]', False,'regular');
    call add_metric('mysql.sort_rows', '服务', 'mysql', 'The number of sorted rows','none', 'linux,windows', '["host"]', False,'regular');
    call add_metric('mysql.sort_scan', '服务', 'mysql', 'The number of sorts that were done by scanning the table','none', 'linux,windows', '["host"]', False,'regular');
    call add_metric('mysql.ssl_accept_renegotiates', '服务', 'mysql', 'The number of negotiates needed to establish the connection','none', 'linux,windows', '["host"]', False,'regular');
    call add_metric('mysql.ssl_accepts', '服务', 'mysql', 'The number of accepted SSL connections','none', 'linux,windows', '["host"]', False,'regular');
    call add_metric('mysql.ssl_callback_cache_hits', '服务', 'mysql', 'The number of callback cache hits','none', 'linux,windows', '["host"]', False,'regular');
    call add_metric('mysql.ssl_client_connects', '服务', 'mysql', 'The number of SSL connection attempts to an SSL-enabled master.','none', 'linux,windows', '["host"]', False,'regular');
    call add_metric('mysql.ssl_connect_renegotiates', '服务', 'mysql', 'The number of negotiates needed to establish the connection to an SSL-enabled master','none', 'linux,windows', '["host"]', False,'regular');
    call add_metric('mysql.ssl_ctx_verify_depth', '服务', 'mysql', 'The SSL context verification depth (how many certificates in the chain are tested)','none', 'linux,windows', '["host"]', False,'regular');
    call add_metric('mysql.ssl_ctx_verify_mode', '服务', 'mysql', 'The SSL context verification mode','none', 'linux,windows', '["host"]', False,'regular');
    call add_metric('mysql.ssl_default_timeout', '服务', 'mysql', 'The default SSL timeout','none', 'linux,windows', '["host"]', False,'regular');
    call add_metric('mysql.ssl_finished_accepts', '服务', 'mysql', 'The number of successful SSL connections to the server','none', 'linux,windows', '["host"]', False,'regular');
    call add_metric('mysql.ssl_finished_connects', '服务', 'mysql', 'The number of successful slave connections to an SSL-enabled master','none', 'linux,windows', '["host"]', False,'regular');
    call add_metric('mysql.ssl_session_cache_hits', '服务', 'mysql', 'The number of SSL session cache hits','none', 'linux,windows', '["host"]', False,'regular');
    call add_metric('mysql.ssl_session_cache_misses', '服务', 'mysql', 'The number of SSL session cache misses','none', 'linux,windows', '["host"]', False,'regular');
    call add_metric('mysql.ssl_session_cache_overflows', '服务', 'mysql', 'The number of SSL session cache overflows','none', 'linux,windows', '["host"]', False,'regular');
    call add_metric('mysql.ssl_session_cache_size', '服务', 'mysql', 'The SSL session cache size','none', 'linux,windows', '["host"]', False,'regular');
    call add_metric('mysql.ssl_session_cache_timeouts', '服务', 'mysql', 'The number of SSL session cache timeouts','none', 'linux,windows', '["host"]', False,'regular');
    call add_metric('mysql.ssl_sessions_reused', '服务', 'mysql', 'How many SSL connections were reused from the cache','none', 'linux,windows', '["host"]', False,'regular');
    call add_metric('mysql.ssl_used_session_cache_entries', '服务', 'mysql', 'How many SSL session cache entries were used','none', 'linux,windows', '["host"]', False,'regular');
    call add_metric('mysql.ssl_verify_depth', '服务', 'mysql', 'The verification depth for replication SSL connections','none', 'linux,windows', '["host"]', False,'regular');
    call add_metric('mysql.ssl_verify_mode', '服务', 'mysql', 'The verification mode used by the server for a connection that uses SSL','none', 'linux,windows', '["host"]', False,'regular');
    call add_metric('mysql.state', '服务', 'mysql', '服务的当前状态（0表示正常，1表示异常）','none', 'linux,windows', '["host", "service"]', False,'regular');
    call add_metric('mysql.table_locks_immediate', '服务', 'mysql', 'The number of times that a request for a table lock could be granted immediately','none', 'linux,windows', '["host"]', False,'regular');
    call add_metric('mysql.table_locks_waited', '服务', 'mysql', 'The number of times that a request for a table lock could not be granted immediately and a wait was needed','none', 'linux,windows', '["host"]', False,'regular');
    call add_metric('mysql.table_open_cache_hits', '服务', 'mysql', 'The number of hits for open tables cache lookups','none', 'linux,windows', '["host"]', False,'regular');
    call add_metric('mysql.table_open_cache_misses', '服务', 'mysql', 'The number of misses for open tables cache lookups','none', 'linux,windows', '["host"]', False,'regular');
    call add_metric('mysql.table_open_cache_overflows', '服务', 'mysql', 'The number of overflows for the open tables cache','none', 'linux,windows', '["host"]', False,'regular');
    call add_metric('mysql.tc_log_max_pages_used', '服务', 'mysql', 'For the memory-mapped implementation of the log that is used by mysqld when it acts as the transaction coordinator for recovery of internal XA transactions, this variable indicates the largest number of pages used for the log since the server started', 'none', 'linux,windows', '["host"]', False,'regular');
    call add_metric('mysql.tc_log_page_size', '服务', 'mysql', 'The page size used for the memory-mapped implementation of the XA recovery log. The default value is determined using getpagesize(). This variable is unused for the same reasons as described forTc_log_max_pages_used.','none', 'linux,windows', '["host"]', False,'regular');
    call add_metric('mysql.tc_log_page_waits', '服务', 'mysql', '','none', 'linux,windows', '["host"]', False,'regular');
    call add_metric('mysql.threads_cached', '服务', 'mysql', '','none', 'linux,windows', '["host"]', False,'regular');
    call add_metric('mysql.threads_connected', '服务', 'mysql', 'Number of clients currently connected. If none or too high, something is wrong', 'short', 'linux,windows', '["host"]', True,'regular');
    call add_metric('mysql.threads_created', '服务', 'mysql', '','none', 'linux,windows', '["host"]', False,'regular');
    call add_metric('mysql.threads_running', '服务', 'mysql', '','none', 'linux,windows', '["host"]', False,'regular');
    call add_metric('mysql.uptime', '服务', 'mysql', 'Seconds since the server was started. We can use this to detect respawns.', 'second', 'linux,windows', '["host"]', True,'regular');
    call add_metric('mysql.uptime_since_flush_status', '服务', 'mysql', '','none', 'linux,windows', '["host"]', False,'regular');

--     xinyu
    call add_metric('tomcat.state', '服务', 'tomcat', '服务的当前状态（0表示正常，1表示异常）', 'none', 'linux,windows', '["host"]', False, 'regular');
    call add_metric('tomcat.jsp.jspCount', '服务', 'tomcat', 'The number of JSPs per second that have been loaded in the web module.', 'short', 'linux,windows', '["host"]', True, 'regular');
    call add_metric('tomcat.jsp.jspQueueLength', '服务', 'tomcat', 'The length of the JSP queue (if enabled via maxLoadedJsps).', 'short', 'linux,windows', '["host"]', True, 'regular');
    call add_metric('tomcat.jsp.jspReloadCount', '服务', 'tomcat', 'The number of JSPs per second that have been reloaded in the web module.', 'short', 'linux,windows', '["host"]', False, 'regular');
    call add_metric('tomcat.jsp.jspUnloadCount', '服务', 'tomcat', 'The number of JSPs per second that have been unloaded in the web module.', 'short', 'linux,windows', '["host"]', False, 'regular');
    call add_metric('tomcat.memory.heap.committed', '服务', 'tomcat', 'The total Java heap memory committed to be used.', 'bytes', 'linux,windows', '["host"]', False, 'regular');
    call add_metric('tomcat.memory.heap.init', '服务', 'tomcat', 'The initial Java heap memory allocated.', 'bytes', 'linux,windows', '["host"]', False, 'regular');
    call add_metric('tomcat.memory.heap.max', '服务', 'tomcat', 'The maximum Java heap memory available.', 'bytes', 'linux,windows', '["host"]', False, 'regular');
    call add_metric('tomcat.memory.heap.used', '服务', 'tomcat', 'The total Java heap memory used.', 'bytes', 'linux,windows', '["host"]', True, 'regular');
    call add_metric('tomcat.memory.nonheap.committed', '服务', 'tomcat', 'The total Java non-heap memory committed to be used.', 'bytes', 'linux,windows', '["host"]', False, 'regular');
    call add_metric('tomcat.memory.nonheap.init', '服务', 'tomcat', 'The initial Java non-heap memory allocated.', 'bytes', 'linux,windows', '["host"]', False, 'regular');
    call add_metric('tomcat.memory.nonheap.max', '服务', 'tomcat', 'The maximum Java non-heap memory available.', 'bytes', 'linux,windows', '["host"]', False, 'regular');
    call add_metric('tomcat.memory.nonheap.used', '服务', 'tomcat', 'The total Java non-heap memory used.', 'bytes', 'linux,windows', '["host"]', False, 'regular');
    call add_metric('tomcat.os.AvailableProcessors', '服务', 'tomcat', 'the number of available processors.', 'none', 'linux,windows', '["host"]', False, 'regular');
    call add_metric('tomcat.os.CommittedVirtualMemorySize', '服务', 'tomcat', 'the current number of megabytes of memory allocated.', 'none', 'linux,windows', '["host"]', False, 'regular');
    call add_metric('tomcat.os.FreePhysicalMemorySize', '服务', 'tomcat', 'the number of megabytes of free memory available to the operating system.', 'none', 'linux,windows', '["host"]', False, 'regular');
    call add_metric('tomcat.os.FreeSwapSpaceSize', '服务', 'tomcat', 'the number of megabytes of free swap space.', 'none', 'linux,windows', '["host"]', False, 'regular');
    call add_metric('tomcat.os.MaxFileDescriptorCount', '服务', 'tomcat', 'the maximum number of open file descriptors allowed by the operating system.', 'none', 'linux,windows', '["host"]', False, 'regular');
    call add_metric('tomcat.os.OpenFileDescriptorCount', '服务', 'tomcat', 'the current number of open file descriptors.', 'none', 'linux,windows', '["host"]', False, 'regular');
    call add_metric('tomcat.os.ProcessCpuLoad', '服务', 'tomcat', 'the "recent cpu usage" for the Java Virtual Machine process.', 'none', 'linux,windows', '["host"]', False, 'regular');
    call add_metric('tomcat.os.ProcessCpuTime', '服务', 'tomcat', 'the amount of time (in nanoseconds) used by the member''s process.', 'ns', 'linux,windows', '["host"]', False, 'regular');
    call add_metric('tomcat.os.SystemCpuLoad', '服务', 'tomcat', 'the "recent cpu usage" for the whole system.', 'ns', 'linux,windows', '["host"]', False, 'regular');
    call add_metric('tomcat.os.SystemLoadAverage', '服务', 'tomcat', 'the system load average.', 'none', 'linux,windows', '["host"]', False, 'regular');
    call add_metric('tomcat.os.TotalPhysicalMemorySize', '服务', 'tomcat', 'the number of megabytes of memory available to the operating system.', 'mbytes', 'linux,windows', '["host"]', False, 'regular');
    call add_metric('tomcat.os.TotalSwapSpaceSize', '服务', 'tomcat', 'the number of megabytes of swap space allocated.', 'mbytes', 'linux,windows', '["host"]', False, 'regular');
    call add_metric('tomcat.requests.bytesReceived', '服务', 'tomcat', 'Bytes per second received by all request processors.', 'Bps', 'linux,windows', '["host"]', False, 'regular');
    call add_metric('tomcat.requests.bytesSent', '服务', 'tomcat', 'Bytes per second sent by all request processors.', 'Bps', 'linux,windows', '["host"]', False, 'regular');
    call add_metric('tomcat.requests.errorCount', '服务', 'tomcat', 'The number of errors per second on all request processors.', 'none', 'linux,windows', '["host"]', True, 'regular');
    call add_metric('tomcat.requests.maxTime', '服务', 'tomcat', 'The longest request processing time (in milliseconds).', 'ms', 'linux,windows', '["host"]', True, 'regular');
    call add_metric('tomcat.requests.processingTime', '服务', 'tomcat', 'The sum of request processing times across all requests handled by the request processors (in milliseconds) per second.', 'ms', 'linux,windows', '["host"]', True, 'regular');
    call add_metric('tomcat.requests.requestCount', '服务', 'tomcat', 'The number of requests per second across all request processors.', 'none', 'linux,windows', '["host"]', True, 'regular');
    call add_metric('tomcat.servlet.errorCount', '服务', 'tomcat', 'The number of errors per second on all request processors.', 'long', 'linux,windows', '["host"]', True, 'regular');
    call add_metric('tomcat.servlet.processingTime', '服务', 'tomcat', 'The sum of request processing times across all requests handled by the request processors (in milliseconds) per second.', 'ms', 'linux,windows', '["host"]', True, 'regular');
    call add_metric('tomcat.servlet.requestCount', '服务', 'tomcat', 'The number of requests received by the servlet per second.', 'none', 'linux,windows', '["host"]', True, 'regular');
    call add_metric('tomcat.threading.CurrentThreadCpuTime', '服务', 'tomcat', 'the total CPU time for the current thread.', 'ns', 'linux,windows', '["host"]', False, 'regular');
    call add_metric('tomcat.threading.CurrentThreadUserTime', '服务', 'tomcat', 'the CPU time that the current thread has executed in user mode.', 'ns', 'linux,windows', '["host"]', False, 'regular');
    call add_metric('tomcat.threading.DaemonThreadCount', '服务', 'tomcat', 'the current number of live daemon threads.', 'none', 'linux,windows', '["host"]', False, 'regular');
    call add_metric('tomcat.threading.PeakThreadCount', '服务', 'tomcat', 'The maximum number of allowed worker threads.', 'none', 'linux,windows', '["host"]', False, 'regular');
    call add_metric('tomcat.threading.ThreadCount', '服务', 'tomcat', 'The number of threads managed by the thread pool.', 'none', 'linux,windows', '["host"]', False, 'regular');
    call add_metric('tomcat.threading.TotalStartedThreadCount', '服务', 'tomcat', 'the total number of threads created and also started since the Java virtual machine started.', 'none', 'linux,windows', '["host"]', False, 'regular');
    call add_metric('tomcat.threading.connectionCount', '服务', 'tomcat', 'the number of connection.', 'none', 'linux,windows', '["host"]', False, 'regular');
    call add_metric('tomcat.threading.currentThreadCount', '服务', 'tomcat', 'The number of threads that are in use.', 'none', 'linux,windows', '["host"]', False, 'regular');

    call add_metric('zk_approximate_data_size', '服务', 'zookeeper', '所有znodes的大致内存消耗', 'mbytes', 'linux,windows', '["host", "port"]', False, 'regular');
    call add_metric('zk_avg_latency', '服务', 'zookeeper', '响应一个客户端请求的平均时间', 'ms', 'linux,windows', '["host", "port"]', True, 'regular');
    call add_metric('zk_ephemerals_count', '服务', 'zookeeper', '临时节点数量', 'none', 'linux,windows', '["host", "port"]', False, 'regular');
    call add_metric('zk_max_latency', '服务', 'zookeeper', '响应一个客户端请求的最大时间', 'ms', 'linux,windows', '["host", "port"]', False, 'regular');
    call add_metric('zk_min_latency', '服务', 'zookeeper', '响应一个客户端请求的最小时间', 'ms', 'linux,windows', '["host", "port"]', False, 'regular');
    call add_metric('zk_num_alive_connections', '服务', 'zookeeper', '连接到Zookeeper的客户端数量', 'none', 'linux,windows', '["host", "port"]', True, 'regular');
    call add_metric('zk_open_file_descriptor_count', '服务', 'zookeeper', '打开文件数量', 'none', 'linux,windows', '["host", "port"]', True, 'regular');
    call add_metric('zk_outstanding_requests', '服务', 'zookeeper', '排队请求的数量', 'none', 'linux,windows', '["host", "port"]', True, 'regular');
    call add_metric('zk_packets_received', '服务', 'zookeeper', '接收到客户端请求的包数量', 'none', 'linux,windows', '["host", "port"]', False, 'regular');
    call add_metric('zk_packets_sent', '服务', 'zookeeper', '发送给客户单的包数量，主要是响应和通知', 'none', 'linux,windows', '["host", "port"]', False, 'regular');
    call add_metric('zk_server_state', '服务', 'zookeeper', '', 'none', 'linux,windows', '["host", "port"]', False, 'regular');
    call add_metric('zk_watch_count', '服务', 'zookeeper', 'watches的数量', 'none', 'linux,windows', '["host", "port"]', False, 'regular');
    call add_metric('zk_znode_count', '服务', 'zookeeper', 'znodes的数量', 'none', 'linux,windows', '["host", "port"]', False, 'regular');
    call add_metric('zookeeper.state', '服务', 'zookeeper', '服务的当前状态（0表示正常，1表示异常）', 'none', 'linux,windows', '["host", "service"]', False, 'regular');


--     yinghao

    call add_metric('kafka.bytesrate.BytesInPerSec.Count', '服务', 'kafka', 'Aggregate incoming byte count', 'short', 'linux,windows', '["host"]', False, 'regular');
    call add_metric('kafka.bytesrate.BytesInPerSec.FifteenMinuteRate', '服务', 'kafka', 'Aggregate incoming byte rate in fifteen minute', 'short', 'linux,windows', '["host"]', True, 'regular');
    call add_metric('kafka.bytesrate.BytesInPerSec.FiveMinuteRate', '服务', 'kafka', 'Aggregate incoming byte rate in five minute', 'short', 'linux,windows', '["host"]', False, 'regular');
    call add_metric('kafka.bytesrate.BytesInPerSec.MeanRate', '服务', 'kafka', 'Mean aggregate incoming byte rate', 'short', 'linux,windows', '["host"]', True, 'regular');
    call add_metric('kafka.bytesrate.BytesInPerSec.OneMinuteRate', '服务', 'kafka', 'Aggregate incoming byte rate in one minute', 'short', 'linux,windows', '["host"]', False, 'regular');
    call add_metric('kafka.bytesrate.BytesOutPerSec.Count', '服务', 'kafka', 'Aggregate coutcoming byte count', 'short', 'linux,windows', '["host"]', False, 'regular');
    call add_metric('kafka.bytesrate.BytesOutPerSec.FifteenMinuteRate', '服务', 'kafka', 'Aggregate coutcoming byte rate in fifteen minute', 'short', 'linux,windows', '["host"]', True, 'regular');
    call add_metric('kafka.bytesrate.BytesOutPerSec.FiveMinuteRate', '服务', 'kafka', 'Aggregate coutcoming byte rate in fifteen minute', 'short', 'linux,windows', '["host"]', False, 'regular');
    call add_metric('kafka.bytesrate.BytesOutPerSec.MeanRate', '服务', 'kafka', 'Mean aggregate coutcoming byte rate', 'short', 'linux,windows', '["host"]', True, 'regular');
    call add_metric('kafka.bytesrate.BytesOutPerSec.OneMinuteRate', '服务', 'kafka', 'Aggregate coutcoming byte rate in one minute', 'short', 'linux,windows', '["host"]', False, 'regular');
    call add_metric('kafka.controller.ActiveControllerCount', '服务', 'kafka', 'Number of active controllers in cluster', 'short', 'linux,windows', '["host"]', True, 'regular');
    call add_metric('kafka.controller.OfflinePartitionsCount', '服务', 'kafka', 'Number of offline partitions', 'short', 'linux,windows', '["host"]', True, 'regular');
    call add_metric('kafka.leaderelection.50thPercentile', '服务', 'kafka', 'Time for leaderelection to reach 50thPercentile', 'ms', 'linux,windows', '["host"]', False, 'regular');
    call add_metric('kafka.leaderelection.75thPercentile', '服务', 'kafka', 'Time for leaderelection to reach 75thPercentile', 'ms', 'linux,windows', '["host"]', False, 'regular');
    call add_metric('kafka.leaderelection.95thPercentile', '服务', 'kafka', 'Time for leaderelection to reach 95thPercentile', 'ms', 'linux,windows', '["host"]', False, 'regular');
    call add_metric('kafka.leaderelection.98thPercentile', '服务', 'kafka', 'Time for leaderelection to reach 98thPercentile', 'ms', 'linux,windows', '["host"]', False, 'regular');
    call add_metric('kafka.leaderelection.999thPercentile', '服务', 'kafka', 'Time for leaderelection to reach 999thPercentile', 'ms', 'linux,windows', '["host"]', False, 'regular');
    call add_metric('kafka.leaderelection.99thPercentile', '服务', 'kafka', 'Time for leaderelection to reach 99thPercentile', 'ms', 'linux,windows', '["host"]', False, 'regular');
    call add_metric('kafka.leaderelection.Count', '服务', 'kafka', 'Leader election count', 'short', 'linux,windows', '["host"]', False, 'regular');
    call add_metric('kafka.leaderelection.FifteenMinuteRate', '服务', 'kafka', 'Leader election rate in fifteen minute', 'short', 'linux,windows', '["host"]', False, 'regular');
    call add_metric('kafka.leaderelection.FiveMinuteRate', '服务', 'kafka', 'Mean leader election rate in five minute', 'short', 'linux,windows', '["host"]', False, 'regular');
    call add_metric('kafka.leaderelection.Max', '服务', 'kafka', 'Max leader election count', 'short', 'linux,windows', '["host"]', False, 'regular');
    call add_metric('kafka.leaderelection.Mean', '服务', 'kafka', 'Mean leader election count', 'short', 'linux,windows', '["host"]', False, 'regular');
    call add_metric('kafka.leaderelection.MeanRate', '服务', 'kafka', 'Mean leader election rate', 'short', 'linux,windows', '["host"]', True, 'regular');
    call add_metric('kafka.leaderelection.Min', '服务', 'kafka', 'Min leader election count', 'short', 'linux,windows', '["host"]', False, 'regular');
    call add_metric('kafka.leaderelection.OneMinuteRate', '服务', 'kafka', 'Mean leader election rate in one minute', 'short', 'linux,windows', '["host"]', False, 'regular');
    call add_metric('kafka.leaderelection.StdDev', '服务', 'kafka', 'Standard deviation of leader election', 'short', 'linux,windows', '["host"]', False, 'regular');
    call add_metric('kafka.server.UnderReplicatedPartitions', '服务', 'kafka', 'Number of under-replicated partitions', 'short', 'linux,windows', '["host"]', True, 'regular');
    call add_metric('kafka.server.expand.Count', '服务', 'kafka', 'Count at which the pool of in-sync replicas expands', 'short', 'linux,windows', '["host"]', False, 'regular');
    call add_metric('kafka.server.expand.FifteenMinuteRate', '服务', 'kafka', 'Fifteen minute rate at which the pool of in-sync replicas expands', 'short', 'linux,windows', '["host"]', False, 'regular');
    call add_metric('kafka.server.expand.FiveMinuteRate', '服务', 'kafka', 'Five minute rate at which the pool of in-sync replicas expands', 'short', 'linux,windows', '["host"]', False, 'regular');
    call add_metric('kafka.server.expand.MeanRate', '服务', 'kafka', 'Mean rate at which the pool of in-sync replicas expands', 'short', 'linux,windows', '["host"]', True, 'regular');
    call add_metric('kafka.server.expand.OneMinuteRate', '服务', 'kafka', 'One minute rate at which the pool of in-sync replicas expands', 'short', 'linux,windows', '["host"]', False, 'regular');
    call add_metric('kafka.server.fetch.PurgatorySize', '服务', 'kafka', '', 'none', 'linux,windows', '["host"]', True, 'regular');
    call add_metric('kafka.server.produce.PurgatorySize', '服务', 'kafka', '', 'none', 'linux,windows', '["host"]', True, 'regular');
    call add_metric('kafka.server.shrink.Count', '服务', 'kafka', 'Count at which the pool of in-sync replicas shrinks', 'short', 'linux,windows', '["host"]', False, 'regular');
    call add_metric('kafka.server.shrink.FifteenMinuteRate', '服务', 'kafka', 'Fifteen minute rate at which the pool of in-sync replicas shrinks', 'short', 'linux,windows', '["host"]', False, 'regular');
    call add_metric('kafka.server.shrink.FiveMinuteRate', '服务', 'kafka', 'Five minute rate at which the pool of in-sync replicas shrinks', 'short', 'linux,windows', '["host"]', False, 'regular');
    call add_metric('kafka.server.shrink.MeanRate', '服务', 'kafka', 'Mean rate at which the pool of in-sync replicas shrinks', 'short', 'linux,windows', '["host"]', True, 'regular');
    call add_metric('kafka.server.shrink.OneMinuteRate', '服务', 'kafka', 'One minute rate at which the pool of in-sync replicas shrinks', 'short', 'linux,windows', '["host"]', False, 'regular');
    call add_metric('kafka.state', '服务', 'kafka', '服务的当前状态（0表示正常，1表示异常）', 'none', 'linux,windows', '["host"]', False, 'regular');
    call add_metric('kafka.unclean_leaderelection.Count', '服务', 'kafka', 'Number of "unclean" elections', 'short', 'linux,windows', '["host"]', False, 'regular');
    call add_metric('kafka.unclean_leaderelection.FifteenMinuteRate', '服务', 'kafka', 'Number of "unclean" elections per fifteen minute', 'short', 'linux,windows', '["host"]', False, 'regular');
    call add_metric('kafka.unclean_leaderelection.FiveMinuteRate', '服务', 'kafka', 'Number of "unclean" elections per five minute', 'short', 'linux,windows', '["host"]', False, 'regular');
    call add_metric('kafka.unclean_leaderelection.MeanRate', '服务', 'kafka', 'Number of "unclean" elections per second', 'short', 'linux,windows', '["host"]', True, 'regular');
    call add_metric('kafka.unclean_leaderelection.OneMinuteRate', '服务', 'kafka', 'Number of "unclean" elections per minute', 'short', 'linux,windows', '["host"]', False, 'regular');
    call add_metric('kafka.broker_offset', '服务', 'kafka', 'kakfa生产量偏移量', 'short', 'linux,windows', '["host"]', True, 'regular');
    call add_metric('kafka.consumer_lag', '服务', 'kafka', 'kafka 消费延迟量', 'short', 'linux,windows', '["host"]', True, 'regular');
    call add_metric('kafka.consumer_offset', '服务', 'kafka', 'kafka 消费量偏移量', 'short', 'linux,windows', '["host"]', True, 'regular');

    call add_metric('tsd.compaction.count', '服务', 'opentsdb', 'The total number of complex compactions performed by the TSD.', 'none', 'linux', '["host"]', False,  'regular');
    call add_metric('tsd.compaction.deletes', '服务', 'opentsdb', 'The total number of delete calls made to storage to remove old data that has been compacted.', 'none', 'linux', '["host"]', False,  'regular');
    call add_metric('tsd.compaction.duplicates', '服务', 'opentsdb', 'The total number of data points found during compaction that were duplicates at the same time but with a different value.', 'none', 'linux', '["host"]', False,  'regular');
    call add_metric('tsd.compaction.errors', '服务', 'opentsdb', 'The total number of rows that could not be read from storage due to an error of some sort.', 'none', 'linux', '["host"]', False,  'regular');
    call add_metric('tsd.compaction.queue.size', '服务', 'opentsdb', 'How many rows of data are currently in the queue to be compacted.', 'none', 'linux', '["host"]', False,  'regular');
    call add_metric('tsd.compaction.writes', '服务', 'opentsdb', 'The total number of writes back to storage of compacted values.', 'none', 'linux', '["host"]', False,  'regular');
    call add_metric('tsd.connectionmgr.connections', '服务', 'opentsdb', 'he total number of connections made to OpenTSDB. This includes all Telnet and HTTP connections.', 'none', 'linux', '["host"]', False,  'regular');
    call add_metric('tsd.connectionmgr.exceptions', '服务', 'opentsdb', 'The total number of exceptions caused by a client disconnecting without closing the socket. This includes all Telnet and HTTP connections.', 'none', 'linux', '["host"]', False,  'regular');
    call add_metric('tsd.datapoints.added', '服务', 'opentsdb', 'The number of  currently metric datapoint added.', 'none', 'linux', '["host"]', True,  'regular');
    call add_metric('tsd.hbase.connections.created', '服务', 'opentsdb', 'The total number of connections made by the client to region servers.', 'none', 'linux', '["host"]', False,  'regular');
    call add_metric('tsd.hbase.connections.idle_closed', '服务', 'opentsdb', 'The total number of connections closed by hbase client .', 'none', 'linux', '["host"]', False,  'regular');
    call add_metric('tsd.hbase.flushes', '服务', 'opentsdb', 'The total number of flushes performed by the client.', 'none', 'linux', '["host"]', False,  'regular');
    call add_metric('tsd.hbase.latency_50pct', '服务', 'opentsdb', 'The time it took, in milliseconds, to execute a Put call for the 50th percentile cases.', 'none', 'linux', '["host"]', False,  'regular');
    call add_metric('tsd.hbase.latency_75pct', '服务', 'opentsdb', 'The time it took, in milliseconds, to execute a Scan call for the 75th percentile cases.', 'none', 'linux', '["host"]', False,  'regular');
    call add_metric('tsd.hbase.latency_90pct', '服务', 'opentsdb', 'The time it took, in milliseconds, to execute a Scan call for the 90th percentile cases.', 'none', 'linux', '["host"]', False,  'regular');
    call add_metric('tsd.hbase.latency_95pct', '服务', 'opentsdb', 'The time it took, in milliseconds, to execute a Scan call for the 95th percentile cases.', 'none', 'linux', '["host"]', False,  'regular');
    call add_metric('tsd.hbase.meta_lookups', '服务', 'opentsdb', 'The total number of uncontended meta table lookups performed by the client.', 'none', 'linux', '["host"]', False,  'regular');
    call add_metric('tsd.hbase.nsre', '服务', 'opentsdb', 'The total number of No Such Region Exceptions caught. These can happen when a region server crashes, is taken offline or when a region splits.', 'none', 'linux', '["host"]', False,  'regular');
    call add_metric('tsd.hbase.nsre.rpcs_delayed', '服务', 'opentsdb', 'The total number of calls delayed due to an NSRE that were later successfully executed.', 'none', 'linux', '["host"]', False,  'regular');
    call add_metric('tsd.hbase.region_clients.idle_closed', '服务', 'opentsdb', 'The total number of connections to region servers that were closed due to idle connections. This indicates nothing was read from or written to a server in some time and the TSD will reconnect when it needs to.', 'none', 'linux', '["host"]', False,  'regular');
    call add_metric('tsd.hbase.region_clients.open', '服务', 'opentsdb', 'The total number of connections opened to region servers since the TSD started. If this number is climbing the region servers may be crashing and restarting.', 'none', 'linux', '["host"]', False,  'regular');
    call add_metric('tsd.hbase.root_lookups', '服务', 'opentsdb', 'The total number of root lookups performed by the client.', 'none', 'linux', '["host"]', False,  'regular');
    call add_metric('tsd.hbase.rpcs', '服务', 'opentsdb', 'The total number of Scan requests performed by the client. These indicate a scan->next() call.', 'none', 'linux', '["host"]', False,  'regular');
    call add_metric('tsd.hbase.rpcs.batched', '服务', 'opentsdb', 'The total number of batched requests sent by the client.', 'none', 'linux', '["host"]', False,  'regular');
    call add_metric('tsd.http.graph.requests', '服务', 'opentsdb', 'The total number of graph requests satisfied from the disk cache.', 'none', 'linux', '["host"]', False,  'regular');
    call add_metric('tsd.http.latency_50pct', '服务', 'opentsdb', 'The time it took, in milliseconds, to answer HTTP requests for the 50th percentile cases.', 'none', 'linux', '["host"]', False,  'regular');
    call add_metric('tsd.http.latency_75pct', '服务', 'opentsdb', 'The time it took, in milliseconds, to answer HTTP requests for the 75th percentile cases.', 'none', 'linux', '["host"]', False,  'regular');
    call add_metric('tsd.http.latency_90pct', '服务', 'opentsdb', 'The time it took, in milliseconds, to answer HTTP requests for the 90th percentile cases.', 'none', 'linux', '["host"]', False,  'regular');
    call add_metric('tsd.http.latency_95pct', '服务', 'opentsdb', 'The time it took, in milliseconds, to answer HTTP requests for the 95th percentile cases.', 'none', 'linux', '["host"]', False,  'regular');
    call add_metric('tsd.http.query.exceptions', '服务', 'opentsdb', 'The total number data queries sent to the /api/query endpoint that threw an exception due to bad user input or an underlying error. See logs for details.', 'none', 'linux', '["host"]', False,  'regular');
    call add_metric('tsd.http.query.invalid_requests', '服务', 'opentsdb', 'The total number data queries sent to the /api/query endpoint that were invalid due to user errors such as using the wrong HTTP method, missing parameters or using metrics and tags without UIDs.', 'none', 'linux', '["host"]', False,  'regular');
    call add_metric('tsd.http.query.success', '服务', 'opentsdb', 'The total number data queries sent to the /api/query endpoint that completed successfully. Note that these may have returned an empty result.', 'none', 'linux', '["host"]', True,  'regular');
    call add_metric('tsd.jvm.ramfree', '服务', 'opentsdb', 'The number of bytes reported as free by the JVM Runtime.freeMemory.', 'none', 'linux', '["host"]', False,  'regular');
    call add_metric('tsd.jvm.ramused', '服务', 'opentsdb', 'The number of bytes reported as used by the JVM Runtime.totalMemory.', 'none', 'linux', '["host"]', False,  'regular');
    call add_metric('tsd.rpc.errors', '服务', 'opentsdb', 'The total number of RPC errors caused by exception.', 'none', 'linux', '["host"]', False,  'regular');
    call add_metric('tsd.rpc.exceptions', '服务', 'opentsdb', 'The total number exceptions caught during RPC calls. These may be user error or bugs.', 'none', 'linux', '["host"]', False,  'regular');
    call add_metric('tsd.rpc.received', '服务', 'opentsdb', 'The total number of put requests for writing data points.', 'none', 'linux', '["host"]', False,  'regular');
    call add_metric('tsd.uid.cache-hit', '服务', 'opentsdb', 'The total number of successful cache lookups for metric UIDs.', 'none', 'linux', '["host"]', False,  'regular');
    call add_metric('tsd.uid.cache-miss', '服务', 'opentsdb', 'The total number of failed cache lookups for metric UIDs that required a call to storage.', 'none', 'linux', '["host"]', False,  'regular');
    call add_metric('tsd.uid.cache-size', '服务', 'opentsdb', 'The current number of cached metric UIDs.', 'none', 'linux', '["host"]', False,  'regular');
    call add_metric('tsd.uid.filter.rejected', '服务', 'opentsdb', 'The current number of UIDs reject by filter.', 'none', 'linux', '["host"]', False,  'regular');
    call add_metric('tsd.uid.ids-available', '服务', 'opentsdb', 'The current number of available metric UIDs, decrements as UIDs are assigned.', 'none', 'linux', '["host"]', False,  'regular');
    call add_metric('tsd.uid.ids-used', '服务', 'opentsdb', 'The current number of assigned metric UIDs.', 'none', 'linux', '["host"]', False,  'regular');
    call add_metric('tsd.uid.random-collisions', '服务', 'opentsdb', 'How many times metric UIDs attempted a reassignment due to a collision with an existing UID.', 'none', 'linux', '["host"]', False,  'regular');
    call add_metric('tsd.uid.rejected-assignments', '服务', 'opentsdb', 'The current number of UIDs reject assignment. Maybe assigned overflowed.', 'none', 'linux', '["host"]', False,  'regular');

    call add_metric('redis.aof.buffer_length', '服务', 'redis', 'Size of the AOF buffer.', 'bytes', 'linux', '["host"]', False,  'regular');
    call add_metric('redis.aof.last_rewrite_time', '服务', 'redis', 'Duration of the last AOF rewrite. shown as second', 's', 'linux', '["host"]', False,  'regular');
    call add_metric('redis.aof.size', '服务', 'redis', 'AOF current file size (aof_current_size).', 'bytes', 'linux', '["host"]', False,  'regular');
    call add_metric('redis.aof.rewrite', '服务', 'redis', 'Flag indicating a AOF rewrite operation is on-going.', 'none', 'linux', '["host"]', False,  'regular');
    call add_metric('redis.can_connect', '服务', 'redis', '', 'none', 'linux', '["host"]', False,  'regular');
    call add_metric('redis.clients.biggest_input_buf', '服务', 'redis', 'The biggest input buffer among current client connections.', 'none', 'linux', '["host"]', False,  'regular');
    call add_metric('redis.clients.blocked', '服务', 'redis', 'The number of connections waiting on a blocking call.', 'none', 'linux', '["host"]', True,  'regular');
    call add_metric('redis.clients.longest_output_list', '服务', 'redis', 'The longest output list among current client connections.', 'none', 'linux', '["host"]', False,  'regular');
    call add_metric('redis.command.calls', '服务', 'redis', 'The number of times a redis command has been called, tagged by "command", e.g. "command:append". Enable in Agents redisdb.yaml with the command_stats option.', 'none', 'linux', '["host"]', False,  'regular');
    call add_metric('redis.command.usec_per_call', '服务', 'redis', 'The CPU time consumed per redis command call, tagged by "command", e.g. "command:append". Enable in Agents redisdb.yaml with the command_stats option.', 'none', 'linux', '["host"]', False,  'regular');
    call add_metric('redis.cpu.sys', '服务', 'redis', 'System CPU consumed by the Redis server.', 's', 'linux', '["host"]', False,  'regular');
    call add_metric('redis.cpu.sys_children', '服务', 'redis', 'System CPU consumed by the background processes.', 's', 'linux', '["host"]', False,  'regular');
    call add_metric('redis.cpu.user', '服务', 'redis', 'User CPU consumed by the Redis server.', 's', 'linux', '["host"]', False,  'regular');
    call add_metric('redis.cpu.user_children', '服务', 'redis', 'User CPU consumed by the background processes.', 's', 'linux', '["host"]', False,  'regular');
    call add_metric('redis.keys.evicted', '服务', 'redis', 'The total number of keys evicted due to the maxmemory limit.', 'none', 'linux', '["host"]', True,  'regular');
    call add_metric('redis.keys.expired', '服务', 'redis', 'The total number of keys expired from the db.', 'none', 'linux', '["host"]', False,  'regular');
    call add_metric('redis.mem.fragmentation_ratio', '服务', 'redis', 'Ratio between used_memory_rss and used_memory.', 'none', 'linux', '["host"]', True,  'regular');
    call add_metric('redis.mem.lua', '服务', 'redis', 'Amount of memory used by the Lua engine.', 'bytes', 'linux', '["host"]', False,  'regular');
    call add_metric('redis.mem.peak', '服务', 'redis', 'The peak amount of memory used by Redis.', 'bytes', 'linux', '["host"]', False,  'regular');
    call add_metric('redis.mem.rss', '服务', 'redis', 'Amount of memory that Redis allocated as seen by the os.', 'bytes', 'linux', '["host"]', False,  'regular');
    call add_metric('redis.mem.used', '服务', 'redis', 'Amount of memory allocated by Redis.', 'bytes', 'linux', '["host"]', True,  'regular');
    call add_metric('redis.net.clients', '服务', 'redis', 'The number of connected clients (excluding slaves).', 'none', 'linux', '["host"]', True,  'regular');
    call add_metric('redis.net.commands', '服务', 'redis', 'The number of commands processed by the server.', 'none', 'linux', '["host"]', False,  'regular');
    call add_metric('redis.net.rejected', '服务', 'redis', 'The number of rejected connections.', 'none', 'linux', '["host"]', False,  'regular');
    call add_metric('redis.net.slaves', '服务', 'redis', 'The number of connected slaves.', 'none', 'linux', '["host"]', False,  'regular');
    call add_metric('redis.perf.latest_fork_usec', '服务', 'redis', 'The duration of the latest fork.', 'µs', 'linux', '["host"]', False,  'regular');
    call add_metric('redis.persist', '服务', 'redis', 'The number of keys persisted (redis.keys - redis.expires).', 'none', 'linux', '["host"]', False,  'regular');
    call add_metric('redis.persist.percent', '服务', 'redis', 'Percentage of total keys that are persisted.', 'none', 'linux', '["host"]', False,  'regular');
    call add_metric('redis.pubsub.channels', '服务', 'redis', 'The number of active pubsub channels.', 'none', 'linux', '["host"]', False,  'regular');
    call add_metric('redis.pubsub.patterns', '服务', 'redis', 'The number of active pubsub patterns.', 'none', 'linux', '["host"]', False,  'regular');
    call add_metric('redis.rdb.bgsave', '服务', 'redis', 'One if a bgsave is in progress and zero otherwise.', 'none', 'linux', '["host"]', False,  'regular');
    call add_metric('redis.rdb.changes_since_last', '服务', 'redis', 'The number of changes since the last background save.', 'none', 'linux', '["host"]', True,  'regular');
    call add_metric('redis.rdb.last_bgsave_time', '服务', 'redis', 'Duration of the last bg_save operation.', 'none', 'linux', '["host"]', False,  'regular');
    call add_metric('redis.replication.backlog_histlen', '服务', 'redis', 'The amount of data in the backlog sync buffer.', 'bytes', 'linux', '["host"]', False,  'regular');
    call add_metric('redis.replication.delay', '服务', 'redis', 'The replication delay in offsets.', 'none', 'linux', '["host"]', False,  'regular');
    call add_metric('redis.replication.last_io_seconds_ago', '服务', 'redis', 'Amount of time since the last interaction with master.', 's', 'linux', '["host"]', True,  'regular');
    call add_metric('redis.replication.master_link_down_since_seconds', '服务', 'redis', 'Amount of time that the master link has been down.', 's', 'linux', '["host"]', True,  'regular');
    call add_metric('redis.replication.master_repl_offset', '服务', 'redis', 'The replication offset reported by the master.', 'none', 'linux', '["host"]', False,  'regular');
    call add_metric('redis.replication.slave_repl_offset', '服务', 'redis', 'The replication offset reported by the slave.', 'none', 'linux', '["host"]', False,  'regular');
    call add_metric('redis.replication.sync', '服务', 'redis', 'One if a sync is in progress and zero otherwise.', 'none', 'linux', '["host"]', False,  'regular');
    call add_metric('redis.replication.sync_left_bytes', '服务', 'redis', 'Amount of data left before syncing is complete.', 'bytes', 'linux', '["host"]', False,  'regular');
    call add_metric('redis.slowlog.micros.95percentile', '服务', 'redis', 'The 95th percentile of the duration of queries reported in the slow log.', 'µs', 'linux', '["host"]', False,  'regular');
    call add_metric('redis.slowlog.micros.avg', '服务', 'redis', 'The average duration of queries reported in the slow log.', 'µs', 'linux', '["host"]', True,  'regular');
    call add_metric('redis.slowlog.micros.count', '服务', 'redis', 'The rate of queries reported in the slow log.', 'none', 'linux', '["host"]', False,  'regular');
    call add_metric('redis.slowlog.micros.max', '服务', 'redis', 'The maximum duration of queries reported in the slow log.', 'µs', 'linux', '["host"]', False,  'regular');
    call add_metric('redis.slowlog.micros.median', '服务', 'redis', 'The median duration of queries reported in the slow log.', 'µs', 'linux', '["host"]', False,  'regular');
    call add_metric('redis.stats.keyspace_hits', '服务', 'redis', 'The total number of successful lookups in the db.', 'none', 'linux', '["host"]', True,  'regular');
    call add_metric('redis.stats.keyspace_misses', '服务', 'redis', 'The total number of missed lookups in the db.', 'none', 'linux', '["host"]', True,  'regular');
    call add_metric('redis.info.latency_ms', '服务', 'redis', '此次收集指标所花费的时间（毫秒）', 'ms', 'linux', '["host","redis_role"]', True,  'regular');
    call add_metric('redis.state', '服务', 'redis', '服务的当前状态（0表示正常，1表示异常）', 'none', 'linux', '["host"]', False,  'regular');

--     sqlserver
    call add_metric('sqlserver.access.page_splits',	'服务',	'sqlserver',	'每秒由于索引页溢出而发生的页拆分数',	'short',	'windows',	'["host"]',	TRUE,	'regular');
    call add_metric('sqlserver.alive',	'服务',	'sqlserver',	'运行状态',	'short',	'windows',	'["host"]',	TRUE,	'regular');
    call add_metric('sqlserver.buffer.cache_hit_ratio',	'服务',	'sqlserver',	'缓存读取百分比',	'short',	'windows',	'["host"]',	TRUE,	'regular');
    call add_metric('sqlserver.buffer.checkpoint_pages',	'服务',	'sqlserver',	'每秒刷新到磁盘的页数',	'short',	'windows',	'["host"]',	TRUE,	'regular');
    call add_metric('sqlserver.buffer.page_lsnmp.ife_expectancy',	'服务',	'sqlserver',	'页面在缓存中预期寿命',	'short',	'windows',	'["host"]',	TRUE,	'regular');
    call add_metric('sqlserver.stats.batch_requests',	'服务',	'sqlserver',	'每秒执行批处理数',	'short',	'windows',	'["host"]',	TRUE,	'regular');
    call add_metric('sqlserver.stats.connections',	'服务',	'sqlserver',	'用户连接数',	'short',	'windows',	'["host"]',	TRUE,	'regular');
    call add_metric('sqlserver.stats.lock_waits',	'服务',	'sqlserver',	'每秒要求调用者等待的锁请求数',	'short',	'windows',	'["host"]',	TRUE,	'regular');
    call add_metric('sqlserver.stats.procs_blocked',	'服务',	'sqlserver',	'被阻塞进程数',	'short',	'windows',	'["host"]',	TRUE,	'regular');
    call add_metric('sqlserver.stats.sql_compilations',	'服务',	'sqlserver',	'每秒的 SQL 编译数',	'short',	'windows',	'["host"]',	TRUE,	'regular');
    call add_metric('sqlserver.stats.sql_recompilations',	'服务',	'sqlserver',	'每秒的 SQL 重新编译数',	'short',	'windows',	'["host"]',	TRUE,	'regular');

--     azure
-- SQLServer
call add_metric('azure.sqlserver.dtu.percentage', '服务', 'azure.sqlserver', 'DTU percentage', 'percent', 'linux', '["host"]', TRUE,  'regular');
call add_metric('azure.sqlserver.storage.used', '服务', 'azure.sqlserver', 'Storage used', 'bytes', 'linux', '["host"]', TRUE,  'regular');

-- SQL database
call add_metric('azure.sqlserver.database.cpu.percentage', '服务', 'azure.sqlserver.database', 'CPU percentage', 'percent', 'linux', '["host"]', TRUE,  'regular');
call add_metric('azure.sqlserver.database.data.io.percentage', '服务', 'azure.sqlserver.database', 'data IO percentage', 'percent', 'linux', '["host"]', TRUE,  'regular');
call add_metric('azure.sqlserver.database.log.io.percentage', '服务', 'azure.sqlserver.database', 'log IO percentage', 'percent', 'linux', '["host"]', TRUE,  'regular');
call add_metric('azure.sqlserver.database.dtu.io.percentage', '服务', 'azure.sqlserver.database', 'DTU IO percentage', 'percent', 'linux', '["host"]', TRUE,  'regular');
call add_metric('azure.sqlserver.database.successful.connections', '服务', 'azure.sqlserver.database', 'Successful Connections', 'count', 'linux', '["host"]', TRUE,  'regular');
call add_metric('azure.sqlserver.database.failed.connections', '服务', 'azure.sqlserver.database', 'Failed Connections', 'count', 'linux', '["host"]', TRUE,  'regular');
call add_metric('azure.sqlserver.database.blocked.by.firewall', '服务', 'azure.sqlserver.database', 'Blocked by Firewall', 'count', 'linux', '["host"]', TRUE,  'regular');
call add_metric('azure.sqlserver.database.deadlocks', '服务', 'azure.sqlserver.database', 'Deadlocks', 'count', 'linux', '["host"]', TRUE,  'regular');
call add_metric('azure.sqlserver.database.database.size.percentage', '服务', 'azure.sqlserver.database', 'Database size percentage', 'percent', 'linux', '["host"]', TRUE,  'regular');
call add_metric('azure.sqlserver.database.database.in-memory.oltp.storage.percent', '服务', 'azure.sqlserver.database', 'In-Memory OLTP storage percent', 'percent', 'linux', '["host"]', TRUE,  'regular');
call add_metric('azure.sqlserver.database.database.workers.percentage', '服务', 'azure.sqlserver.database', 'Workers percentage', 'percent', 'linux', '["host"]', TRUE,  'regular');
call add_metric('azure.sqlserver.database.database.sessions.percentage', '服务', 'azure.sqlserver.database', 'Sessions percentage', 'percent', 'linux', '["host"]', TRUE,  'regular');
call add_metric('azure.sqlserver.database.database.dtu.limit', '服务', 'azure.sqlserver.database', 'DTU Limit', 'count', 'linux', '["host"]', TRUE,  'regular');
call add_metric('azure.sqlserver.database.database.dtu.used', '服务', 'azure.sqlserver.database', 'DTU Used', 'count', 'linux', '["host"]', TRUE,  'regular');

-- Redis
call add_metric('azure.redis.cache.connected.clients', '服务', 'azure.redis.cache', 'Connected clients', 'count', 'linux', '["host"]', TRUE,  'regular');
call add_metric('azure.redis.cache.total.commands.processed', '服务', 'azure.redis.cache', 'Total operations', 'count', 'linux', '["host"]', TRUE,  'regular');
call add_metric('azure.redis.cache.cache.hits', '服务', 'azure.redis.cache', 'Cache hits', 'count', 'linux', '["host"]', TRUE,  'regular');
call add_metric('azure.redis.cache.cache.misses', '服务', 'azure.redis.cache', 'Cache misses', 'count', 'linux', '["host"]', TRUE,  'regular');
call add_metric('azure.redis.cache.get.commands', '服务', 'azure.redis.cache', 'The number of get commands', 'count', 'linux', '["host"]', TRUE,  'regular');
call add_metric('azure.redis.cache.set.commands', '服务', 'azure.redis.cache', 'The number of set commands', 'count', 'linux', '["host"]', TRUE,  'regular');
call add_metric('azure.redis.cache.evicted.keys', '服务', 'azure.redis.cache', 'Evicted Keys', 'count', 'linux', '["host"]', TRUE,  'regular');
call add_metric('azure.redis.cache.total.keys', '服务', 'azure.redis.cache', 'Total Keys', 'count', 'linux', '["host"]', TRUE,  'regular');
call add_metric('azure.redis.cache.expired.keys', '服务', 'azure.redis.cache', 'Expired Keys', 'count', 'linux', '["host"]', TRUE,  'regular');
call add_metric('azure.redis.cache.used.memory', '服务', 'azure.redis.cache', 'Used Memory', 'Bytes', 'linux', '["host"]', TRUE,  'regular');
call add_metric('azure.redis.cache.used.memory.rss', '服务', 'azure.redis.cache', 'Used Memory RSS', 'Bytes', 'linux', '["host"]', TRUE,  'regular');
call add_metric('azure.redis.cache.server.load', '服务', 'azure.redis.cache', 'Server Load', 'Percent', 'linux', '["host"]', TRUE,  'regular');
call add_metric('azure.redis.cache.cache.write', '服务', 'azure.redis.cache', 'Cache Write', 'BytesPerSecond', 'linux', '["host"]', TRUE,  'regular');
call add_metric('azure.redis.cache.cache.read', '服务', 'azure.redis.cache', 'Cache Read', 'BytesPerSecond', 'linux', '["host"]', TRUE,  'regular');
call add_metric('azure.redis.cache.percent.processor.time', '服务', 'azure.redis.cache', 'Percent of cpu processor time', 'Percent', 'linux', '["host"]', TRUE,  'regular');

-- Server farm
call add_metric('azure.server.farm.cpu.percentage', '服务', 'azure.server.farm', 'CPU percentage', 'percent', 'linux', '["host"]', TRUE,  'regular');
call add_metric('azure.server.farm.memory.percentage', '服务', 'azure.server.farm', 'Memory percentage', 'percent', 'linux', '["host"]', TRUE,  'regular');
call add_metric('azure.server.farm.disk.queue.length', '服务', 'azure.server.farm', 'Disk queue length', 'count', 'linux', '["host"]', TRUE,  'regular');
call add_metric('azure.server.farm.http.queue.length', '服务', 'azure.server.farm', 'HTTP queue length', 'count', 'linux', '["host"]', TRUE,  'regular');
call add_metric('azure.server.farm.http.data.in', '服务', 'azure.server.farm', 'Inbound Data', 'Bytes', 'linux', '["host"]', TRUE,  'regular');
call add_metric('azure.server.farm.http.data.out', '服务', 'azure.server.farm', 'Outbound Data', 'Bytes', 'linux', '["host"]', TRUE,  'regular');

-- Web app
call add_metric('azure.web.application.site.cpu.time', '服务', 'azure.web.application', 'CPU time', 'seconds', 'linux', '["host"]', TRUE,  'regular');
call add_metric('azure.web.application.site.requests', '服务', 'azure.web.application', 'Requests', 'count', 'linux', '["host"]', TRUE,  'regular');
call add_metric('azure.web.application.site.data.in', '服务', 'azure.web.application', 'Inbound data', 'Bytes', 'linux', '["host"]', TRUE,  'regular');
call add_metric('azure.web.application.site.data.out', '服务', 'azure.web.application', 'Outbound data', 'Bytes', 'linux', '["host"]', TRUE,  'regular');
call add_metric('azure.web.application.site.http.101', '服务', 'azure.web.application', 'Http 101', 'count', 'linux', '["host"]', TRUE,  'regular');
call add_metric('azure.web.application.site.http.2xx', '服务', 'azure.web.application', 'Http 2xx', 'count', 'linux', '["host"]', TRUE,  'regular');
call add_metric('azure.web.application.site.http.3xx', '服务', 'azure.web.application', 'Http 3xx', 'count', 'linux', '["host"]', TRUE,  'regular');
call add_metric('azure.web.application.site.http.401', '服务', 'azure.web.application', 'Http 401', 'count', 'linux', '["host"]', TRUE,  'regular');
call add_metric('azure.web.application.site.http.403', '服务', 'azure.web.application', 'Http 403', 'count', 'linux', '["host"]', TRUE,  'regular');
call add_metric('azure.web.application.site.http.406', '服务', 'azure.web.application', 'Http 406', 'count', 'linux', '["host"]', TRUE,  'regular');
call add_metric('azure.web.application.site.http.4xx', '服务', 'azure.web.application', 'Http 4xx', 'count', 'linux', '["host"]', TRUE,  'regular');
call add_metric('azure.web.application.site.http.server.errors', '服务', 'azure.web.application', 'Http Server Errors', 'count', 'linux', '["host"]', TRUE,  'regular');
call add_metric('azure.web.application.site.memory.working.set', '服务', 'azure.web.application', 'Memory working set', 'Bytes', 'linux', '["host"]', TRUE,  'regular');
call add_metric('azure.web.application.site.average.memory.working.set', '服务', 'azure.web.application', 'Average memory working set', 'Bytes', 'linux', '["host"]', TRUE,  'regular');
call add_metric('azure.web.application.site.average.response.time', '服务', 'azure.web.application', 'Average Response Time', 'Seconds', 'linux', '["host"]', TRUE,  'regular');
call add_metric('azure.web.application.site.connections', '服务', 'azure.web.application', 'Connections', 'Count', 'linux', '["host"]', TRUE,  'regular');

-- Storage
-- blob
call add_metric('azure.storage.blob.total.ingress', '服务', 'azure.storage', 'The amount of ingress data, in bytes. This number includes ingress from an external client into Azure Storage as well as ingress within Azure.', 'bytes', 'linux', '["host"]', TRUE,  'regular');
call add_metric('azure.storage.blob.total.egress', '服务', 'azure.storage', 'The amount of egress data, in bytes. This number includes ingress from an external client into Azure Storage as well as ingress within Azure.', 'bytes', 'linux', '["host"]', TRUE,  'regular');
call add_metric('azure.storage.blob.total.requests', '服务', 'azure.storage', 'The number of requests made to a storage service or the specified API operation. This number includes successful and failed requests, as well as requests which produced errors.', 'Count', 'linux', '["host"]', TRUE,  'regular');
call add_metric('azure.storage.blob.availability', '服务', 'azure.storage', 'The percentage of availability for the storage service or the specified API operation.', 'Percent', 'linux', '["host"]', TRUE,  'regular');
call add_metric('azure.storage.blob.average.e2e.latency', '服务', 'azure.storage', 'The average end-to-end latency of successful requests made to a storage service or the specified API operation, in milliseconds. This value includes the required processing time within Azure Storage to read the request, send the response, and receive acknowledgment of the response.', 'milliseconds', 'linux', '["host"]', TRUE,  'regular');
call add_metric('azure.storage.blob.average.server.latency', '服务', 'azure.storage', 'The average latency used by Azure Storage to process a successful request, in milliseconds. This value does not include the network latency specified in AverageE2ELatency.', 'milliseconds', 'linux', '["host"]', TRUE,  'regular');
call add_metric('azure.storage.blob.percent.success', '服务', 'azure.storage', 'The percentage of successful requests.', 'Percent', 'linux', '["host"]', TRUE,  'regular');
call add_metric('azure.storage.blob.percent.throttling.error', '服务', 'azure.storage', 'The percentage of requests that failed with a throttling error.', 'Percent', 'linux', '["host"]', TRUE,  'regular');
call add_metric('azure.storage.blob.percent.timeout.error', '服务', 'azure.storage', 'The percentage of requests that failed with a timeout error.', 'Percent', 'linux', '["host"]', TRUE,  'regular');
call add_metric('azure.storage.blob.percent.server.other.error', '服务', 'azure.storage', 'The percentage of requests that failed with a ServerOtherError.', 'Percent', 'linux', '["host"]', TRUE,  'regular');
call add_metric('azure.storage.blob.percent.client.other.error', '服务', 'azure.storage', 'The percentage of requests that failed with a ClientOtherError.', 'Percent', 'linux', '["host"]', TRUE,  'regular');
call add_metric('azure.storage.blob.percent.authorization.error', '服务', 'azure.storage', 'The percentage of requests that failed with an AuthorizationError.', 'Percent', 'linux', '["host"]', TRUE,  'regular');
call add_metric('azure.storage.blob.percent.network.error', '服务', 'azure.storage', 'The percentage of requests that failed with a NetworkError.', 'Percent', 'linux', '["host"]', TRUE,  'regular');
call add_metric('azure.storage.blob.success', '服务', 'azure.storage', 'The number of successful requests made to a storage service or the specified API operation.', 'Count', 'linux', '["host"]', TRUE,  'regular');
call add_metric('azure.storage.blob.throttling.error', '服务', 'azure.storage', 'The number of authenticated requests to a storage service or the specified API operation that returned a ThrottlingError.', 'Count', 'linux', '["host"]', TRUE,  'regular');
call add_metric('azure.storage.blob.client.timeout.error', '服务', 'azure.storage', 'The number of authenticated requests to a storage service or the specified API operation that returned a ClientTimeoutError.', 'Count', 'linux', '["host"]', TRUE,  'regular');
call add_metric('azure.storage.blob.server.timeout.error', '服务', 'azure.storage', 'The number of authenticated requests to a storage service or the specified API operation that returned a ServerTimeoutError.', 'Count', 'linux', '["host"]', TRUE,  'regular');
call add_metric('azure.storage.blob.client.other.error', '服务', 'azure.storage', 'The number of authenticated requests to a storage service or the specified API operation that returned a ClientOtherError.', 'Count', 'linux', '["host"]', TRUE,  'regular');
call add_metric('azure.storage.blob.server.other.error', '服务', 'azure.storage', 'The number of authenticated requests to a storage service or the specified API operation that returned a ServerOtherError.', 'Count', 'linux', '["host"]', TRUE,  'regular');
call add_metric('azure.storage.blob.authorization.error', '服务', 'azure.storage', 'The number of authenticated requests to a storage service or the specified API operation that returned an AuthorizationError.', 'Count', 'linux', '["host"]', TRUE,  'regular');
call add_metric('azure.storage.blob.network.error', '服务', 'azure.storage', 'The number of authenticated requests to a storage service or the specified API operation that returned a NetworkError.', 'Count', 'linux', '["host"]', TRUE,  'regular');

-- file
call add_metric('azure.storage.file.total.ingress', '服务', 'azure.storage', 'The amount of ingress data, in bytes. This number includes ingress from an external client into Azure Storage as well as ingress within Azure.', 'bytes', 'linux', '["host"]', TRUE,  'regular');
call add_metric('azure.storage.file.total.egress', '服务', 'azure.storage', 'The amount of egress data, in bytes. This number includes ingress from an external client into Azure Storage as well as ingress within Azure.', 'bytes', 'linux', '["host"]', TRUE,  'regular');
call add_metric('azure.storage.file.total.requests', '服务', 'azure.storage', 'The number of requests made to a storage service or the specified API operation. This number includes successful and failed requests, as well as requests which produced errors.', 'Count', 'linux', '["host"]', TRUE,  'regular');
call add_metric('azure.storage.file.availability', '服务', 'azure.storage', 'The percentage of availability for the storage service or the specified API operation.', 'Percent', 'linux', '["host"]', TRUE,  'regular');
call add_metric('azure.storage.file.average.e2e.latency', '服务', 'azure.storage', 'The average end-to-end latency of successful requests made to a storage service or the specified API operation, in milliseconds. This value includes the required processing time within Azure Storage to read the request, send the response, and receive acknowledgment of the response.', 'milliseconds', 'linux', '["host"]', TRUE,  'regular');
call add_metric('azure.storage.file.average.server.latency', '服务', 'azure.storage', 'The average latency used by Azure Storage to process a successful request, in milliseconds. This value does not include the network latency specified in AverageE2ELatency.', 'milliseconds', 'linux', '["host"]', TRUE,  'regular');
call add_metric('azure.storage.file.percent.success', '服务', 'azure.storage', 'The percentage of successful requests.', 'Percent', 'linux', '["host"]', TRUE,  'regular');
call add_metric('azure.storage.file.percent.throttling.error', '服务', 'azure.storage', 'The percentage of requests that failed with a throttling error.', 'Percent', 'linux', '["host"]', TRUE,  'regular');
call add_metric('azure.storage.file.percent.timeout.error', '服务', 'azure.storage', 'The percentage of requests that failed with a timeout error.', 'Percent', 'linux', '["host"]', TRUE,  'regular');
call add_metric('azure.storage.file.percent.server.other.error', '服务', 'azure.storage', 'The percentage of requests that failed with a ServerOtherError.', 'Percent', 'linux', '["host"]', TRUE,  'regular');
call add_metric('azure.storage.file.percent.client.other.error', '服务', 'azure.storage', 'The percentage of requests that failed with a ClientOtherError.', 'Percent', 'linux', '["host"]', TRUE,  'regular');
call add_metric('azure.storage.file.percent.authorization.error', '服务', 'azure.storage', 'The percentage of requests that failed with an AuthorizationError.', 'Percent', 'linux', '["host"]', TRUE,  'regular');
call add_metric('azure.storage.file.percent.network.error', '服务', 'azure.storage', 'The percentage of requests that failed with a NetworkError.', 'Percent', 'linux', '["host"]', TRUE,  'regular');
call add_metric('azure.storage.file.success', '服务', 'azure.storage', 'The number of successful requests made to a storage service or the specified API operation.', 'Count', 'linux', '["host"]', TRUE,  'regular');
call add_metric('azure.storage.file.throttling.error', '服务', 'azure.storage', 'The number of authenticated requests to a storage service or the specified API operation that returned a ThrottlingError.', 'Count', 'linux', '["host"]', TRUE,  'regular');
call add_metric('azure.storage.file.client.timeout.error', '服务', 'azure.storage', 'The number of authenticated requests to a storage service or the specified API operation that returned a ClientTimeoutError.', 'Count', 'linux', '["host"]', TRUE,  'regular');
call add_metric('azure.storage.file.server.timeout.error', '服务', 'azure.storage', 'The number of authenticated requests to a storage service or the specified API operation that returned a ServerTimeoutError.', 'Count', 'linux', '["host"]', TRUE,  'regular');
call add_metric('azure.storage.file.client.other.error', '服务', 'azure.storage', 'The number of authenticated requests to a storage service or the specified API operation that returned a ClientOtherError.', 'Count', 'linux', '["host"]', TRUE,  'regular');
call add_metric('azure.storage.file.server.other.error', '服务', 'azure.storage', 'The number of authenticated requests to a storage service or the specified API operation that returned a ServerOtherError.', 'Count', 'linux', '["host"]', TRUE,  'regular');
call add_metric('azure.storage.file.authorization.error', '服务', 'azure.storage', 'The number of authenticated requests to a storage service or the specified API operation that returned an AuthorizationError.', 'Count', 'linux', '["host"]', TRUE,  'regular');
call add_metric('azure.storage.file.network.error', '服务', 'azure.storage', 'The number of authenticated requests to a storage service or the specified API operation that returned a NetworkError.', 'Count', 'linux', '["host"]', TRUE,  'regular');

-- queue
call add_metric('azure.storage.queue.total.ingress', '服务', 'azure.storage', 'The amount of ingress data, in bytes. This number includes ingress from an external client into Azure Storage as well as ingress within Azure.', 'bytes', 'linux', '["host"]', TRUE,  'regular');
call add_metric('azure.storage.queue.total.egress', '服务', 'azure.storage', 'The amount of egress data, in bytes. This number includes ingress from an external client into Azure Storage as well as ingress within Azure.', 'bytes', 'linux', '["host"]', TRUE,  'regular');
call add_metric('azure.storage.queue.total.requests', '服务', 'azure.storage', 'The number of requests made to a storage service or the specified API operation. This number includes successful and failed requests, as well as requests which produced errors.', 'Count', 'linux', '["host"]', TRUE,  'regular');
call add_metric('azure.storage.queue.availability', '服务', 'azure.storage', 'The percentage of availability for the storage service or the specified API operation.', 'Percent', 'linux', '["host"]', TRUE,  'regular');
call add_metric('azure.storage.queue.average.e2e.latency', '服务', 'azure.storage', 'The average end-to-end latency of successful requests made to a storage service or the specified API operation, in milliseconds. This value includes the required processing time within Azure Storage to read the request, send the response, and receive acknowledgment of the response.', 'milliseconds', 'linux', '["host"]', TRUE,  'regular');
call add_metric('azure.storage.queue.average.server.latency', '服务', 'azure.storage', 'The average latency used by Azure Storage to process a successful request, in milliseconds. This value does not include the network latency specified in AverageE2ELatency.', 'milliseconds', 'linux', '["host"]', TRUE,  'regular');
call add_metric('azure.storage.queue.percent.success', '服务', 'azure.storage', 'The percentage of successful requests.', 'Percent', 'linux', '["host"]', TRUE,  'regular');
call add_metric('azure.storage.queue.percent.throttling.error', '服务', 'azure.storage', 'The percentage of requests that failed with a throttling error.', 'Percent', 'linux', '["host"]', TRUE,  'regular');
call add_metric('azure.storage.queue.percent.timeout.error', '服务', 'azure.storage', 'The percentage of requests that failed with a timeout error.', 'Percent', 'linux', '["host"]', TRUE,  'regular');
call add_metric('azure.storage.queue.percent.server.other.error', '服务', 'azure.storage', 'The percentage of requests that failed with a ServerOtherError.', 'Percent', 'linux', '["host"]', TRUE,  'regular');
call add_metric('azure.storage.queue.percent.client.other.error', '服务', 'azure.storage', 'The percentage of requests that failed with a ClientOtherError.', 'Percent', 'linux', '["host"]', TRUE,  'regular');
call add_metric('azure.storage.queue.percent.authorization.error', '服务', 'azure.storage', 'The percentage of requests that failed with an AuthorizationError.', 'Percent', 'linux', '["host"]', TRUE,  'regular');
call add_metric('azure.storage.queue.percent.network.error', '服务', 'azure.storage', 'The percentage of requests that failed with a NetworkError.', 'Percent', 'linux', '["host"]', TRUE,  'regular');
call add_metric('azure.storage.queue.success', '服务', 'azure.storage', 'The number of successful requests made to a storage service or the specified API operation.', 'Count', 'linux', '["host"]', TRUE,  'regular');
call add_metric('azure.storage.queue.throttling.error', '服务', 'azure.storage', 'The number of authenticated requests to a storage service or the specified API operation that returned a ThrottlingError.', 'Count', 'linux', '["host"]', TRUE,  'regular');
call add_metric('azure.storage.queue.client.timeout.error', '服务', 'azure.storage', 'The number of authenticated requests to a storage service or the specified API operation that returned a ClientTimeoutError.', 'Count', 'linux', '["host"]', TRUE,  'regular');
call add_metric('azure.storage.queue.server.timeout.error', '服务', 'azure.storage', 'The number of authenticated requests to a storage service or the specified API operation that returned a ServerTimeoutError.', 'Count', 'linux', '["host"]', TRUE,  'regular');
call add_metric('azure.storage.queue.client.other.error', '服务', 'azure.storage', 'The number of authenticated requests to a storage service or the specified API operation that returned a ClientOtherError.', 'Count', 'linux', '["host"]', TRUE,  'regular');
call add_metric('azure.storage.queue.server.other.error', '服务', 'azure.storage', 'The number of authenticated requests to a storage service or the specified API operation that returned a ServerOtherError.', 'Count', 'linux', '["host"]', TRUE,  'regular');
call add_metric('azure.storage.queue.authorization.error', '服务', 'azure.storage', 'The number of authenticated requests to a storage service or the specified API operation that returned an AuthorizationError.', 'Count', 'linux', '["host"]', TRUE,  'regular');
call add_metric('azure.storage.queue.network.error', '服务', 'azure.storage', 'The number of authenticated requests to a storage service or the specified API operation that returned a NetworkError.', 'Count', 'linux', '["host"]', TRUE,  'regular');

-- table
call add_metric('azure.storage.table.total.ingress', '服务', 'azure.storage', 'The amount of ingress data, in bytes. This number includes ingress from an external client into Azure Storage as well as ingress within Azure.', 'bytes', 'linux', '["host"]', TRUE,  'regular');
call add_metric('azure.storage.table.total.egress', '服务', 'azure.storage', 'The amount of egress data, in bytes. This number includes ingress from an external client into Azure Storage as well as ingress within Azure.', 'bytes', 'linux', '["host"]', TRUE,  'regular');
call add_metric('azure.storage.table.total.requests', '服务', 'azure.storage', 'The number of requests made to a storage service or the specified API operation. This number includes successful and failed requests, as well as requests which produced errors.', 'Count', 'linux', '["host"]', TRUE,  'regular');
call add_metric('azure.storage.table.availability', '服务', 'azure.storage', 'The percentage of availability for the storage service or the specified API operation.', 'Percent', 'linux', '["host"]', TRUE,  'regular');
call add_metric('azure.storage.table.average.e2e.latency', '服务', 'azure.storage', 'The average end-to-end latency of successful requests made to a storage service or the specified API operation, in milliseconds. This value includes the required processing time within Azure Storage to read the request, send the response, and receive acknowledgment of the response.', 'milliseconds', 'linux', '["host"]', TRUE,  'regular');
call add_metric('azure.storage.table.average.server.latency', '服务', 'azure.storage', 'The average latency used by Azure Storage to process a successful request, in milliseconds. This value does not include the network latency specified in AverageE2ELatency.', 'milliseconds', 'linux', '["host"]', TRUE,  'regular');
call add_metric('azure.storage.table.percent.success', '服务', 'azure.storage', 'The percentage of successful requests.', 'Percent', 'linux', '["host"]', TRUE,  'regular');
call add_metric('azure.storage.table.percent.throttling.error', '服务', 'azure.storage', 'The percentage of requests that failed with a throttling error.', 'Percent', 'linux', '["host"]', TRUE,  'regular');
call add_metric('azure.storage.table.percent.timeout.error', '服务', 'azure.storage', 'The percentage of requests that failed with a timeout error.', 'Percent', 'linux', '["host"]', TRUE,  'regular');
call add_metric('azure.storage.table.percent.server.other.error', '服务', 'azure.storage', 'The percentage of requests that failed with a ServerOtherError.', 'Percent', 'linux', '["host"]', TRUE,  'regular');
call add_metric('azure.storage.table.percent.client.other.error', '服务', 'azure.storage', 'The percentage of requests that failed with a ClientOtherError.', 'Percent', 'linux', '["host"]', TRUE,  'regular');
call add_metric('azure.storage.table.percent.authorization.error', '服务', 'azure.storage', 'The percentage of requests that failed with an AuthorizationError.', 'Percent', 'linux', '["host"]', TRUE,  'regular');
call add_metric('azure.storage.table.percent.network.error', '服务', 'azure.storage', 'The percentage of requests that failed with a NetworkError.', 'Percent', 'linux', '["host"]', TRUE,  'regular');
call add_metric('azure.storage.table.success', '服务', 'azure.storage', 'The number of successful requests made to a storage service or the specified API operation.', 'Count', 'linux', '["host"]', TRUE,  'regular');
call add_metric('azure.storage.table.throttling.error', '服务', 'azure.storage', 'The number of authenticated requests to a storage service or the specified API operation that returned a ThrottlingError.', 'Count', 'linux', '["host"]', TRUE,  'regular');
call add_metric('azure.storage.table.client.timeout.error', '服务', 'azure.storage', 'The number of authenticated requests to a storage service or the specified API operation that returned a ClientTimeoutError.', 'Count', 'linux', '["host"]', TRUE,  'regular');
call add_metric('azure.storage.table.server.timeout.error', '服务', 'azure.storage', 'The number of authenticated requests to a storage service or the specified API operation that returned a ServerTimeoutError.', 'Count', 'linux', '["host"]', TRUE,  'regular');
call add_metric('azure.storage.table.client.other.error', '服务', 'azure.storage', 'The number of authenticated requests to a storage service or the specified API operation that returned a ClientOtherError.', 'Count', 'linux', '["host"]', TRUE,  'regular');
call add_metric('azure.storage.table.server.other.error', '服务', 'azure.storage', 'The number of authenticated requests to a storage service or the specified API operation that returned a ServerOtherError.', 'Count', 'linux', '["host"]', TRUE,  'regular');
call add_metric('azure.storage.table.authorization.error', '服务', 'azure.storage', 'The number of authenticated requests to a storage service or the specified API operation that returned an AuthorizationError.', 'Count', 'linux', '["host"]', TRUE,  'regular');
call add_metric('azure.storage.table.network.error', '服务', 'azure.storage', 'The number of authenticated requests to a storage service or the specified API operation that returned a NetworkError.', 'Count', 'linux', '["host"]', TRUE,  'regular');

-- Job scheduler
call add_metric('azure.scheduler.job.execution', '服务', 'azure.scheduler', 'The count of job execution.', 'count', 'linux', '["host"]', TRUE,  'regular');
call add_metric('azure.scheduler.job.failure', '服务', 'azure.scheduler', 'The count of jobs with failure.', 'count', 'linux', '["host"]', TRUE,  'regular');
call add_metric('azure.scheduler.job.faulted', '服务', 'azure.scheduler', 'The count of faulted jobs.', 'count', 'linux', '["host"]', TRUE,  'regular');

-- mysql
call add_metric('azure.mysqlserver.active.connections', '服务', 'azure.mysqlserver', '活动连接数', 'none', 'linux,windows', '["host", "server"]', True, 'regular');
call add_metric('azure.mysqlserver.failed.connections', '服务', 'azure.mysqlserver', '失败的连接数', 'none', 'linux,windows', '["host", "server"]', True, 'counter');
call add_metric('azure.mysqlserver.network.in', '服务', 'azure.mysqlserver', '网络传入', 'bytes', 'linux,windows', '["host", "server"]', True, 'counter');
call add_metric('azure.mysqlserver.network.out', '服务', 'azure.mysqlserver', '网络传出', 'bytes', 'linux,windows', '["host", "server"]', True, 'counter');
call add_metric('azure.mysqlserver.backup.storage.used', '服务', 'azure.mysqlserver', '已用的存储量', 'none', 'linux,windows', '["host", "server"]', True, 'regular');
call add_metric('azure.mysqlserver.cpu.percent', '服务', 'azure.mysqlserver', 'CPU 百分比', 'percentage', 'linux,windows', '["host", "server"]', True, 'regular');
call add_metric('azure.mysqlserver.io.percent', '服务', 'azure.mysqlserver', 'IO 百分比', 'percentage', 'linux,windows', '["host", "server"]', True, 'regular');
call add_metric('azure.mysqlserver.memory.percent', '服务', 'azure.mysqlserver', '内存百分比', 'percentage', 'linux,windows', '["host", "server"]', True, 'regular');
call add_metric('azure.mysqlserver.server.log.storage.limit', '服务', 'azure.mysqlserver', '服务器存储空间上限', 'none', 'linux,windows', '["host", "server"]', True, 'regular');
call add_metric('azure.mysqlserver.server.log.storage.percent', '服务', 'azure.mysqlserver', '服务器日志存储空间百分比', 'percentage', 'linux,windows', '["host", "server"]', True, 'regular');
call add_metric('azure.mysqlserver.server.log.storage.used', '服务', 'azure.mysqlserver', '服务器日志已用的存储量', 'none', 'linux,windows', '["host", "server"]', True, 'regular');
call add_metric('azure.mysqlserver.storage.limit', '服务', 'azure.mysqlserver', '存储限制', 'none', 'linux,windows', '["host", "server"]', True, 'regular');
call add_metric('azure.mysqlserver.storage.percent', '服务', 'azure.mysqlserver', '存储空间百分比', 'percentage', 'linux,windows', '["host", "server"]', True, 'regular');
call add_metric('azure.mysqlserver.storage.used', '服务', 'azure.mysqlserver', '已用的存储量', 'none', 'linux,windows', '["host", "server"]', True, 'regular');

-- application gateway
call add_metric('azure.application.gateway.connected', '服务', 'azure.application.gateway', 'Connected', 'none', 'linux,windows', '["host", "server"]', True, 'regular');
call add_metric('azure.application.gateway.current.capacity.units', '服务', 'azure.application.gateway', '已消耗的请求单位数', 'none', 'linux,windows', '["host", "server"]', True, 'regular');
call add_metric('azure.application.gateway.current.connections', '服务', 'azure.application.gateway', '使用应用程序网关建立的当前连接计数', 'none', 'linux,windows', '["host", "server"]', True, 'regular');
call add_metric('azure.application.gateway.failed.requests', '服务', 'azure.application.gateway', '应用程序网关已提供服务的失败请求计数', 'none', 'linux,windows', '["host", "server"]', True, 'counter');
call add_metric('azure.application.gateway.healthy.host.count', '服务', 'azure.application.gateway', '正常的后端主机数', 'none', 'linux,windows', '["host", "server"]', True, 'regular');
call add_metric('azure.application.gateway.response.status', '服务', 'azure.application.gateway', '应用程序网关返回的 Http 响应状态', 'none', 'linux,windows', '["host", "server"]', True, 'regular');
call add_metric('azure.application.gateway.throughput', '服务', 'azure.application.gateway', '应用程序网关每秒提供的字节数', 'none', 'linux,windows', '["host", "server"]', True, 'regular');
call add_metric('azure.application.gateway.total.requests', '服务', 'azure.application.gateway', '应用程序网关已提供服务的成功请求计数', 'none', 'linux,windows', '["host", "server"]', True, 'counter');
call add_metric('azure.application.gateway.unhealthy.host.count', '服务', 'azure.application.gateway', '不正常的后端主机数', 'none', 'linux,windows', '["host", "server"]', True, 'regular');
call add_metric('azure.application.gateway.web.application.firewall.matched.rules', '服务', 'azure.application.gateway', '应用程序规则的命中次数(需开启Firewalls)', 'none', 'linux,windows', '["host", "server"]', True, 'regular');
call add_metric('azure.application.gateway.state', '服务', 'azure.application.gateway', '实例状态', 'none', 'linux,windows', '["host", "server"]', True, 'regular');

call add_metric('azure.traffic.manager.state', '服务', 'azure.traffic.manager', '实例状态', 'none', 'linux,windows', '["host", "server"]', True, 'regular');


    IF t_error = 1 THEN
      ROLLBACK;
    ELSE
      COMMIT;
    END IF;

  END//

DELIMITER ;


CALL add_all_metrics();
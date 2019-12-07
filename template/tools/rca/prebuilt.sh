#!/bin/sh

if [[ "$#" -ne 2 ]]; then
        echo "bash prebuilt.sh <org> <sys>"
        echo "e.g., [Yis-MacBook-Pro alert-daemon (master)]$ bash ../tools/rca/prebuilt.sh 1 1" 
        exit 1
fi

alertdUrl='http://localhost:<:nginx_port:>/_alertd'
org=$1
sys=$2
token=<:token:>

<:install_root:>/tools/common/wait_for_url.sh "${alertdUrl}/healthsummary?token=${token}"

tsSec=$(date +%s)

# cpu.usr
resp=$(curl --write-out "%{http_code}\n" --silent --output /dev/null -s "${alertdUrl}/rca/feedback/json?token=${token}" -H "Content-Type: application/json" -d "{\"org\":${org},\"sys\":${sys},\"alertIds\":[],\"timestampInSec\":${tsSec},\"triggerMetric\":{\"name\":\"${org}.${sys}.cpu.usr\"},\"rootCauseMetrics\":[{\"name\":\"${org}.${sys}.Java GC\",\"confidenceLevel\":100,\"description\":\"如果占用CPU的进程是Java, 请查看Java进程是否有频繁的Full GC.\",\"type\":\"PREBUILT_SOLUTION\", \"solution\":\" \n1. 先去‘资源消耗’确认占用CPU的是否是Java进程。如果是，而且您已经收集到对应的GC的指标（jvm.jstat.gcutil.full.gc.count，hadoop.namenode.jvmmetrics.GcCount等), 请跳到4）\n2. 在‘探针管理’里开启Cloudwiz的Jvm探针；\n3. 更新Jvm collector config，加入对应的Java进程 (e.g., {\\\"name\\\":\\\"regionserver\\\",\\\"command\\\":\\\"HRegionServer\\\",\\\"threshold\\\":5});\n4. 查看指标jvm.jstat.gcutil.full.gc.count （添加标签process），是否最近有频繁的Full GC。\"}],\"relatedMetrics\":[]}")

if [[ $resp != 200 ]]; then echo "error in POST RCA/feedback cpu.usr"; exit $resp; else echo "succeed in POST RCA/feedback cpu.usr, resp=$resp"; fi

# cpu.usr English version
#curl -v -s 'http://centos24:5001/rca/feedback/json?token=xxxxxxxxx' -H "Content-Type: application/json" -d '{"org":2,"sys":2,"alertIds":[],"timestampInSec":1519964262,"triggerMetric":{"name":"2.2.cpu.usr"},"rootCauseMetrics":[{"name":"2.2.Java GC","confidenceLevel":100,"description":"If high CPU consumers are Java processes, frequent Java full GCs will exhaust host CPU.","type":"PREBUILT_SOLUTION", "solution":"If you know the related process GC metrics (like jvm.jstat.gcutil.full.gc.count or hadoop.namenode.jvmmetrics.GcCount etc) already, please go ahead to check the metrics. Otherwise:\n1. Try to get GC metrics by enabling cloudwiz Jvm collector in 探针管理；\n2. Update Jvm collector config by adding the Java process (e.g., {\"name\":\"regionserver\",\"command\":\"HRegionServer\",\"threshold\":5});\n3. Check metric jvm.jstat.gcutil.full.gc.count with process tag to see if there are frequent full GC lately."}],"relatedMetrics":[]}'

# proc.meminfo.percentused
resp=$(curl --write-out "%{http_code}\n" --silent --output /dev/null -s "${alertdUrl}/rca/feedback/json?token=${token}" -H "Content-Type: application/json" -d "{\"org\":${org},\"sys\":${sys},\"alertIds\":[],\"timestampInSec\":${tsSec},\"triggerMetric\":{\"name\":\"${org}.${sys}.proc.meminfo.percentused\"},\"rootCauseMetrics\":[{\"name\":\"${org}.${sys}.Java GC\",\"confidenceLevel\":100,\"description\":\"如果占用内存的进程是Java, 请查看Java进程是否有内存泄露。\",\"type\":\"PREBUILT_SOLUTION\", \"solution\":\"\n1. 先去‘资源消耗’确认占用内存高的是否是Java进程。如果是，而且您已经收集到对应的GC的指标（jvm.jstat.gcutil.full.gc.count，hadoop.namenode.jvmmetrics.GcCount等), 请跳到4）\n2. 在‘探针管理’里开启Cloudwiz的Jvm探针；\n3. 更新Jvm collector config，加入对应的Java进程 (e.g., {\\\"\n name\\\":\\\"regionserver\\\",\\\"\n command\\\":\\\"HRegionServer\\\",\\\"\n threshold\\\":5 \n});\n4. 查看JVM指标jvm.jstat.gcutil.full.gc.count等（添加标签process），是否最近有频繁的Full GC，有没有OutOfMemory。\"}],\"relatedMetrics\":[]}")

if [[ $resp != 200 ]]; then echo "error in POST RCA/feedback proc.meminfo.percentused"; exit $resp; else echo "succeed in POST RCA/feedback proc.meminfo.percentused, resp=$resp"; fi

# df.bytes.percentused 
resp=$(curl --write-out "%{http_code}\n" --silent --output /dev/null -s "${alertdUrl}/rca/feedback/json?token=${token}" -H "Content-Type: application/json" -d "{\"org\":${org},\"sys\":${sys},\"alertIds\":[],\"timestampInSec\":${tsSec},\"triggerMetric\":{\"name\":\"${org}.${sys}.df.bytes.percentused\"},\"rootCauseMetrics\":[{\"name\":\"${org}.${sys}.文件太多，空间不够\",\"confidenceLevel\":100,\"description\":\"请查看各个文件夹的大小。\",\"type\":\"PREBUILT_SOLUTION\", \"solution\":\"\n1. 首先确认是哪个mount路径下的磁盘空间不够，您可以从‘实时监控／指标／磁盘状态’的仪表盘里看到；\n2. 运行 du -h --max-depth=1 &lt;path&gt; 查看具体哪个文件夹占用的空间最大，选择无用的并删除。\"}],\"relatedMetrics\":[]}")

if [[ $resp != 200 ]]; then echo "error in POST RCA/feedback df.bytes.percentused <- 文件太多，空间不够"; exit $resp; else echo "succeed in POST RCA/feedback df.bytes.percentused <- 文件太多，空间不够, resp=$resp"; fi

resp=$(curl --write-out "%{http_code}\n" --silent --output /dev/null -s "${alertdUrl}/rca/feedback/json?token=${token}" -H "Content-Type: application/json" -d "{\"org\":${org},\"sys\":${sys},\"alertIds\":[],\"timestampInSec\":${tsSec},\"triggerMetric\":{\"name\":\"${org}.${sys}.df.bytes.percentused\"},\"rootCauseMetrics\":[{\"name\":\"${org}.${sys}.空间不够, df比du显示占用更多的空间\",\"confidenceLevel\":100,\"description\":\"磁盘空间占用过高。'df -h'比'du -h'显示了更高的空间占用。\",\"type\":\"PREBUILT_SOLUTION\", \"solution\":\"\n可能是由于某运行的进程在持续不断地删除文件造成。可以使用如下命令来找出此类进程：\n <code>lsof | grep deleted | awk '{print $1 \\\" \\\" $2}' | sort | uniq -c | sort -rn</code>\n 发现可疑进程后可以使用下面的命令来找到被删除的文件：\n <code>lsof | grep deleted | grep &lt;进程名&gt; | less</code>\n  停止或重启相关进程可以暂时解决此问题，但仍需要分析具体进程以便找出导致此问题的根本原因。\"}],\"relatedMetrics\":[]}")

if [[ $resp != 200 ]]; then echo "error in POST RCA/feedback df.bytes.percentused <- df比du显示占用更多的空间"; exit $resp; else echo "succeed in POST RCA/feedback df.bytes.percentused <- df比du显示占用更多的空间, resp=$resp"; fi

# iostat.percentage_util
resp=$(curl --write-out "%{http_code}\n" --silent --output /dev/null -s "${alertdUrl}/rca/feedback/json?token=${token}" -H "Content-Type: application/json" -d "{\"org\":${org},\"sys\":${sys},\"alertIds\":[],\"timestampInSec\":${tsSec},\"triggerMetric\":{\"name\":\"${org}.${sys}.iostat.percentage_util\"},\"rootCauseMetrics\":[{\"name\":\"${org}.${sys}.进程读写磁盘严重\",\"confidenceLevel\":100,\"description\":\"在以下三种情况下，说明产生的I/O请求太多，I/O系统已经满负荷，该磁盘可能存在瓶颈。1. iostat.percentage_util接近 100%；2. iostat.await 远大于iostat.svctm；（iostat.svctm是IO请求的真正处理时间，iostat.await=iostat.svctm + IO请求等待处理的时间。这说明等待时间太长）3. iostat.await 大于20毫秒；\",\"type\":\"PREBUILT_SOLUTION\", \"solution\":\"\n请检查各个进程的磁盘读写速度。\n1. 首先您可以从‘实时监控／机器／&lt;选中具体机器&gt;／进程状态’里找到读写磁盘严重的进程；\n2. 确认进程磁盘读写是否合理。\"}],\"relatedMetrics\":[]}")

if [[ $resp != 200 ]]; then echo "error in POST RCA/feedback iostat.percentage_util <- 进程读写磁盘严重"; exit $resp; else echo "succeed in POST RCA/feedback iostat.percentage_util <- 进程读写磁盘严重. resp=$resp"; fi

resp=$(curl --write-out "%{http_code}\n" --silent --output /dev/null -s "${alertdUrl}/rca/feedback/json?token=${token}" -H "Content-Type: application/json" -d "{\"org\":${org},\"sys\":${sys},\"alertIds\":[],\"timestampInSec\":${tsSec},\"triggerMetric\":{\"name\":\"${org}.${sys}.iostat.percentage_util\"},\"rootCauseMetrics\":[{\"name\":\"${org}.${sys}.磁盘损坏\",\"confidenceLevel\":100,\"description\":\"请查看磁盘是否有损坏的情况。\",\"type\":\"PREBUILT_SOLUTION\", \"solution\":\"\n1. 如果是Windows，请用Windows自带的磁盘检测工具，您也可以在cmd窗口运行 \n <code>chkdsk /r c: </code> \n2. 如果是Linux，您可以用SMART（Ubuntu16以上自带）或者badblocks（先用sudo fdisk -l 找Drive，然后sudo badblocks -nvs /dev/sdx (/dev/sdx 是其中一个drive)）\"}],\"relatedMetrics\":[]}")

if [[ $resp != 200 ]]; then echo "error in POST RCA/feedback iostat.percentage_util <- 磁盘损坏"; exit $resp; else echo "succeed in POST RCA/feedback iostat.percentage_util <- 磁盘损坏, resp=$resp"; fi

# iostat.await
resp=$(curl --write-out "%{http_code}\n" --silent --output /dev/null -s "${alertdUrl}/rca/feedback/json?token=${token}" -H "Content-Type: application/json" -d "{\"org\":${org},\"sys\":${sys},\"alertIds\":[],\"timestampInSec\":${tsSec},\"triggerMetric\":{\"name\":\"${org}.${sys}.iostat.await\"},\"rootCauseMetrics\":[{\"name\":\"${org}.${sys}.磁盘损坏\",\"confidenceLevel\":100,\"description\":\"请查看磁盘是否有损坏的情况。\",\"type\":\"PREBUILT_SOLUTION\", \"solution\":\"\n1. 如果是Windows，请用Windows自带的磁盘检测工具，您也可以在cmd窗口运行\n <code> chkdsk /r c: </code> \n2. 如果是Linux，您可以用SMART（Ubuntu16以上自带）或者badblocks（先用sudo fdisk -l 找Drive，然后sudo badblocks -nvs /dev/sdx (/dev/sdx 是其中一个drive)）\"}],\"relatedMetrics\":[]}")

if [[ $resp != 200 ]]; then echo "error in POST RCA/feedback iostat.await <- 磁盘损坏"; exit $resp; else echo "succeed in POST RCA/feedback iostat.await <- 磁盘损坏, resp=$resp"; fi

resp=$(curl --write-out "%{http_code}\n" --silent --output /dev/null -s "${alertdUrl}/rca/feedback/json?token=${token}" -H "Content-Type: application/json" -d "{\"org\":${org},\"sys\":${sys},\"alertIds\":[],\"timestampInSec\":${tsSec},\"triggerMetric\":{\"name\":\"${org}.${sys}.iostat.await\"},\"rootCauseMetrics\":[{\"name\":\"${org}.${sys}.进程读写磁盘严重\",\"confidenceLevel\":100,\"description\":\"在以下三种情况下，说明产生的I/O请求太多，I/O系统已经满负荷，该磁盘可能存在瓶颈。1. iostat.percentage_util接近 100%；2. iostat.await 远大于iostat.svctm；（iostat.svctm是IO请求的真正处理时间，iostat.await=iostat.svctm + IO请求等待处理的时间。这说明等待时间太长）3. iostat.await 大于20毫秒；\",\"type\":\"PREBUILT_SOLUTION\", \"solution\":\"\n请检查各个进程的磁盘读写速度。\n1. 首先您可以从‘实时监控／机器／&lt;选中具体机器&gt;／进程状态’里找到读写磁盘严重的进程；\n2. 确认进程磁盘读写是否合理。\"}],\"relatedMetrics\":[]}")

if [[ $resp != 200 ]]; then echo "error in POST RCA/feedback iostat.await <- 进程读写磁盘严重"; exit $resp; else echo "succeed in POST RCA/feedback iostat.await <- 进程读写磁盘严重, resp=$resp"; fi


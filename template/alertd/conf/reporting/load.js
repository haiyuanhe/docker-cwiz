var system = require('system');
var webpage = require('webpage');

var server = 'http://localhost:5012/chart';
var page = webpage.create();

// 获取第二个参数(即请求地址url).
var url = system.args[1];

// 获取第三个参数(需要保存的文件名)
var fileName = system.args[2];

//打开给定url的页面.
page.open(url, function(status) {
    if (status === 'success') {
        var data = page.evaluate(function () {
            console.log('调用echarts的下载图片功能.');
            return getImage();
        });

        console.log('upload to localhost');
        var page2 = webpage.create();
        var settings = {
            operation: "POST",
            encoding: "utf8",
            headers: {
                "Content-Type": "application/json"
            },
            data: JSON.stringify({
                fileName: fileName,
                data: data
            })
        };
        page2.open(server, settings, function (status) {
            if (status !== 'success') {
                console.log(JSON.stringify(server) + '\n')
                console.log('Unable to post to server, status=' + status + '\n');
            } else {
                console.log('Image posted to server.\n');
            }
        });
    } else {
        console.log('Page failed to load!');
    }

    // 10秒后再关闭浏览器.
    setTimeout(function () {
        phantom.exit();
    }, 10000);
});

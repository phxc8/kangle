[Kangle.ICU](https://kangle.icu)
=======
最低配置安装需求
本教程至少需要以下配置进行安装
CPU：单核
推荐内存：512M
推荐硬盘：5G或者以上
推荐网络：独立公网IP
操作系统：centos 6 x64
安装时间：普通VPS大约在10-20分钟左右

脚本官方网站:https://kangle.icu

默认登录密码是什么?
-------
easypanel控制面板管理员后台：ip:3312/admin
帐号：admin
密码：默认密码请输入代码查看
查看密码代码:
echo "默认密码:$(cat /root/kangle-pw)"

mysql数据库管理员后台：ip:3313/mysql
-------
帐号：root
密码：默认密码请输入代码查看
查看密码代码:
echo "默认密码:$(cat /root/kangle-pw)"

想要用mysql的话，一定要先进去3312/admin登录，左边有个服务器设置，把数据库帐号密码填入，并且初始化服务器后即可正常登录mysql使用。


一键安装包是什么?
-------
kangle web server一键安装包是一个用Linux Shell编写的可以为CentOS 6 VPS(VDS)或独立主机安装kangle web server(kangle,easypanel,proftpd,mariadb,php,apc)生产环境的Shell程序。


我们为什么需要它?
-------
编译安装需要输入大量的命令，如果是配置生产环境需要耗费大量的时间。
不会Linux的站长或Linux新手想使用Linux作为生产环境……


它有什么优势?
-------
无需一个一个的输入命令，无需值守，编译安装优化编译参数，提高性能，解决不必要的软件间依赖，特别针对VPS用户进行了优化。


特别鸣谢
-------
感谢小樱(ITZMX.COM)源提供Fork
基于点点Kangle.pw脚本修改


kangle web server 更新日志
-------
2018-08-22 kangle 3.5.14
修复无法和openssl 1.1.0编译的bug
linux下编译无需依赖libaio.h
增加请求控制中add_response_header模块，用于回应301，302时插入自定义的header
增加PROXY协议,四层代理时，可传递真实地址.
修复一些小问题。

2018-06-08 kangle 3.5.13.2
修复有限速的情况下会导致连接资源泄漏
修复在连接信息中无法查看到http2的连接

2018-06-04 kangle 3.5.13
linux的epoll改用边缘触发
域名解析增加缓存机制
网络事件和http2的代码改用无锁机制
移除cname绑定支持
修复freebsd上的编译bug
修复一处无缓存本地访问在http2下，流量大时会发送部分错误的内容

2017-12-26 kangle 3.5.12
缓存交换重构为异步io
linux使用系统原生异步io，并发宽带吞吐性能更高
修复缓存br压缩网页，会导致乱码.
linux支持SO_REUSEPORT
linux支持jemalloc内存管理
windows使用GetQueuedCompletionStatusEx

2017-07-28 kangle 3.5.11
修复限速的bug
修复windows版本ssl的bug
增加queue标记模块，可在访问控制中针对不同的url，进行工作者限制。
修改referer匹配模块，支持检测空来源(-表示).
2017-07-27 kangle 3.5.10
修复 ajp协议无法post提交数据的bug
kangle使用数据库存储虚拟主机配置时，sqlite驱动使用只读模式，去掉所有写入配置到数据库功能，提高稳定性。

2017-04-10 kangle 3.5.9
修复 windows版本一处死锁的bug
修复http2请求控制中重定向的bug
改进srcs匹配模块
修复gzip压缩缓存会被无gzip请求冲掉的bug

2016-06-27 kangle 3.5.8
修复 url_hash的bug
swap in/out 增加超时机制
修复http2的一些小问题

2016-04-13 kangle 3.5.7
支持arm架构
修复windows安装有些用户报缺少msvcr120.dll文件
修复多服务器扩展中节点为空的错误
如果kangle目录存在manage.sec文件时，禁用web管理(127.0.0.1例外)，可用于临时关闭web管理,增加安全。

2016-03-14 3.5.6 
增加HTTP/2协议的支持
支持反向代理使用ssl和上游通信(端口后面加s，如443s)
windows版openssl升级到1.0.2g
修复websocket代理的一处bug

2015-12-31 3.5.5 更新：
修复一个处理上游chunked的bug
删除重试次数设置，将更加智能的方式判断是否进行重试，针对上游新连接不进行重试，长连接则以新连接重试一次。
多节点服务器扩展，可以显示的节点统计数据。
多节点服务器扩展，在连续错误次数设置为0并且所有节点的权重设置为0的情况下，kangle将自动监控所有节点,并自动选择一个最快的节点。
修复websocket无法识别客户端发送Connection: keep-alive, Upgrade头的bug,即keep-alive和Upgrade同时存在于Connection中。

2015-11-26 3.5.4 更新：
支持chunked方式post数据
支持Etag方式缓存

2015-06-18 3.5.1 更新：
支持websocket
增加path_sign，防盗链签名模块。
增加try_file匹配模块
新增http10的标记模块
新增cname绑定模式(详细文档介绍之后介绍)

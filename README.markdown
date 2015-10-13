# PhpRedis

This is a modified version of phpredis in order to create an REAL connection pool, which will increase performance because of network io(connect to external host), I am writing an connection pool damon program(using erlang) which will be listening on loopback interface(127.0.0.1) and serve as redis proxy, I have added a redis method named Redis::connect_proxy(proxy_host, proxy_port, timeout, reserved_param = null, retry_interval, real_host, real_port), it will connect to proxy redis server, send real_host:real_port(6 bytes after connected) to proxy server, then it will connect to real redis identified by real_host:real_port, without any configuration you will get a flexible redis connection pool. 

Currently I only implemented redis client part ...


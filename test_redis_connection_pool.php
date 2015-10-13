<?php

//phpinfo(); exit;

ini_set('display_errors', 'on');
set_time_limit(0);

/*
class A {
  function f() {echo "A\n";}
}

$a = new A;
$a->f(1);
echo 1;
exit;
*/
$r = new Redis;

$t = microtime(true);

try {
  # using command 'nc -l 127.0.0.1 6380 | hexdump -C' to debug packets
  $x = $r->connect_proxy('127.0.0.1', 6380, 10, NULL, NULL, '127.0.0.1', 6379);
  // $x = $r->connect('127.0.0.1', 6380, 10);
  var_export($x);
} catch (Exception $e) {
  $r->close();
  throw $e;
}


echo floor((microtime(true) - $t) / 1000) . "\n";


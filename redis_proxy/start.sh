ERL=~/proxy/otp_src_17.4/bin/erl
ERL=erl

echo 'c(redis_proxy).' | $ERL
echo done
$ERL -noshell -s redis_proxy main -- "$@" # 8889 10.4.25.244:8887


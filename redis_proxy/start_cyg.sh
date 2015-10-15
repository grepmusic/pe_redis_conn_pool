ERL="/cygdrive/c/Program Files/erl6.4/bin/erl"

echo 'c(redis_proxy).' | "$ERL"
echo done
"$ERL" -noshell -s redis_proxy main -- "$@" # 8889 10.4.25.244:8887


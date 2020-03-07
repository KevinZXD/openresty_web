#!/bin/bash

prefix=$(readlink -m $(dirname $0));
echo $prefix
ngx_conf="$prefix/conf/openresty_web.conf";
echo $ngx_conf
# nginx 命令所在的位置
ngx="nginx";
pid=$(cat $prefix/logs/nginx.pid 2> /dev/null)

function func_init()
{
    if [[ ! -d "$prefix" ]]; then
        echo "$prefix: No such file or directory";
        exit 1;
    fi
    echo "初始化操作"
}
function func_test()
{
    ${ngx} -p ${prefix} -c ${ngx_conf} -t;
    if [[ $? -ne 0 ]]; then
        exit 1;
    fi
}
function func_start()
{
  if [[ "x$pid" != "x" ]]; then
        ps -ef |grep -v grep|grep -w "$pid" | grep master;
        if [[ $? -eq 0 ]]; then
            echo "process is running";
            exit 1;
        fi
    fi
    ${ngx} -p ${prefix} -c ${ngx_conf};
    if [[ $? -ne 0 ]]; then
        exit 1;
    fi
}

function func_ngx_signal()
{
    sig=$1
    echo "stop reload reopen" | grep -w $sig > /dev/null;
    if [[ $? -ne 0 ]]; then
        echo "sig: $sig is invalid.";
        exit 1;
    fi

    if [[ "x$pid" == "x" ]]; then
        echo "process is not running";
        exit 1;
    fi
    if [[ "x$pid" != "x" ]]; then
        ps -ef |grep -v grep|grep -w "$pid" | grep master >/dev/null;
        if [[ $? -ne 0 ]]; then
            echo "process is not running";
            exit 1;
        fi
    fi
    func_test;
    ${ngx} -p ${prefix} -c ${ngx_conf} -s $sig;
    if [[ $? -ne 0 ]]; then
        # exit 1
        return 1
    fi
}

function func_status()
{
    if [[ "x$pid" == "x" ]]; then
        return
    fi
    ps -ef |grep -v grep|grep -w "$pid";
    if [[ $? -ne 0 ]]; then
        return 0;
    fi
}

function func_stop()
{
    func_ngx_signal stop;
}

function func_fast_reload()
{
    func_ngx_signal reload;
}

function func_reload()
{
    # 随机休眠N秒以内，避免同一时刻批量重启带来的系统冲击
    seconds=$(($RANDOM%30));
    # sleep $seconds;
    func_fast_reload;
}

function func_reopen()
{
    func_ngx_signal reopen;
}

func_init;

case "$1" in
start)
    func_start;
    ;;
stop)
    func_stop;
    ;;
status)
    func_status;
    ;;
restart)
    func_stop;
    sleep 1;
    func_start;
    ;;
reload)
    func_reload;
    ;;
reopen)
    func_reopen;
    ;;
test)
    func_test;
    ;;
help)
    echo "Usage: $0 {start | stop | reopen | reload | help }"
    exit 0;
    ;;
*)
    echo "Usage: $0 {start | stop | reopen | reload | help }"
    exit 1;
    ;;
esac
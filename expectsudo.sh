#! /usr/bin/expect
#exp_internal 1
set server [lindex $argv 0]
set logname  [lindex $argv 1]
set password [lindex $argv 2]
spawn ssh -o StrictHostKeyChecking=no -t $server
expect "$ "
send "sudo su -\r"
expect "password for $logname: "
send "$password\r";
expect "# "
interact



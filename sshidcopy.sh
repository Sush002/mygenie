#! /usr/bin/expect
#exp_internal 1
# Run the script with arg1 as servername and arg2 with password
if { [llength $argv] < 3 } {
	puts "Please enter arg1:servername arg2:username arg3:password"
	exit
}
set server [lindex $argv 0]
set user   [lindex $argv 1]
set password [lindex $argv 2]
if { $server == "-h" } {
	puts "Please enter arg1:servername arg2:username arg3:password"
	exit
}
spawn ssh-copy-id $server
expect "$user@$server's password:"
send "$password\r"
interact


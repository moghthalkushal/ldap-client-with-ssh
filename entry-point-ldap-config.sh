#!/bin/sh
service nscd restart
/usr/sbin/sshd -D

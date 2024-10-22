#!/bin/bash
id=`ec2metadata --instance-id | cut -d ' ' -f 2`
sudo adduser $id
echo $id:FORTInet123! | sudo chpasswd

#!/bin/bash

if [ ! -c /dev/dax0.0 ]; then
	umount /mnt/pmem
	ndctl destroy-namespace all --force
	ndctl create-namespace -f -e namespace0.0 --mode=devdax
fi

if [ -c /dev/dax0.0 ]; then
	chown -R ldorau.ldorau /dev/dax0.0
	chmod a+rw /dev/dax0.0
	ls -al /dev/dax0.0
fi

killall webhackathon
docker stop $(docker ps -aq -f name=pmemuser)
docker rm $(docker ps -aq -f name=pmemuser)

set -e

# update /home/hackathon/
N_USERS=$(ls -1 /home/hackathon/workshops/test/ | wc -l)
[ ${N_USERS} -gt 1 ] && rm -rf /home/hackathon/workshops/test/*

# update /home/hackathon/2021-04-21
rm -rf /home/hackathon/2021-04-21
/bin/cp -r ../2021-04-21/ /home/hackathon/
rm -rf /home/hackathon/2021-04-21/examples/R/build

# update /home/hackathon/templates/examples/
rm -rf /home/hackathon/templates/examples/
/bin/cp -r ./templates/examples/ /home/hackathon/templates/ 

# rebuild docker
docker build -t pmemhackathon/pmemfc30:09 -f ./docker/Dockerfile-new ./docker/

# re-create users
echo -e "y\ny\ny\n" | ./scripts/delete_pmemusers
./scripts/create_pmemusers 1 1 2021-04-21
./scripts/enable_pmemusers 1 1 todayspasswd

# start www server
cd /home/hackathon/
./webhackathon 2021-04-21 & # _WEB
sleep 1
jobs
echo Done.

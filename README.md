# chfs-containers

## example
```bash
# explicitly pull the latest chfs image 
docker pull range3/chfs:master

git clone https://github.com/range3/chfs-containers
cd chfs-containers

# start servers
docker-compose up -d

# start another container for client
docker run -it --rm --network chfs_net --privileged range3/chfs:master bash
# set CHFS_SERVER env
export CHFS_SERVER=$(chlist -c -s ofi+sockets://172.30.0.3:50000)

# list chfs servers
chlist

# mount chfs via FUSE
mkdir /tmp/m
chmkdir /tmp/m
chfuse -o direct_io,modules=subdir,subdir="/tmp/m" /tmp/m

# <ctrl-D>
# the client container is removed

# stop and remove server containers
docker-compose down
```

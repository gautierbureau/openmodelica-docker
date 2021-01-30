#!/bin/bash

USER_NAME=$(whoami)
USER_ID=$(id -u $USER_NAME)
USER_GID=$(id -g $USER_NAME)

container_name=omc

ip=$(ifconfig en0 | grep inet | awk '$1=="inet" {print $2}')
xhost + $ip
#xhost + 127.0.0.1

docker run --privileged -it -d -h $container_name --name=$container_name \
  -v "$(pwd)":/omc \
  -u "$USER_ID:$USER_GID" \
  -e DISPLAY=$ip:0 -v /tmp/.X11-unix:/tmp/.X11-unix \
  -p 2222:22 \
  omc

docker exec -u root $container_name /usr/sbin/sshd
#docker exec -u root $container_name groupadd "$(id -u -n)" -g "$(id -g)"
#docker exec -u root $container_name adduser "$(id -u -n)" -u "$(id -u)" -g "$(id -g)" -m
#docker exec -u root $container_name usermod -aG wheel "$(id -u -n)"
#docker exec -u root $container_name bash -c "echo '$(id -u -n):$(id -u -n)' | chpasswd"
#docker exec -u root $container_name bash -c "echo 'Defaults    env_keep += \"http_proxy https_proxy ftp_proxy HTTP_PROXY HTTPS_PROXY no_proxy NO_PROXY\"' >> /etc/sudoers"

# ssh -p -X 2222 root@localhost

# -e DISPLAY=host.docker.internal:0
# https://gist.github.com/palmerj/315053c0d940f4c63dee7655ce037ade
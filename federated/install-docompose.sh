#!/bin/bash

# Download Docker Compose
curl -L https://github.com/docker/compose/releases/download/1.17.0/docker-compose-`uname -s`-`uname -m` -o /usr/local/bin/docker-compose

# Change Permissions:
chmod +x /usr/local/bin/docker-compose

# Print version:
docker-compose --version

if [[ $? -nq 0 ]]; then
    echo "Installation has been failed!!"
    exit 1
fi
echo "Installation complate successfully."
exit 0

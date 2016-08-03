#!/bin/bash

# Download stable release of xdebug 2.4.0
wget -c "http://xdebug.org/files/xdebug-2.4.0.tgz"
# Extract archive
tar -xf xdebug-2.4.0.tgz

cd xdebug-2.4.0/

# build extension
phpize
./configure
make && make install
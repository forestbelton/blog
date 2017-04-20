#!/bin/bash

set -e

if [ "$HOST" = "" ]; then
    echo "error: \$HOST not defined" 2>&1
    exit 1
fi

stack exec site clean
stack clean

stack build
stack exec site build

ssh $HOST "sudo rm -rf /tmp/_site"
scp -r _site $HOST:/tmp/_site

ssh $HOST <<EOF
    sudo ln -s /opt/pdf /tmp/_site/pdf \
    && sudo chown -R www-data:www-data /tmp/_site \
    && sudo rm -rf /opt/_site \
    && sudo mv /tmp/_site /opt/_site
EOF

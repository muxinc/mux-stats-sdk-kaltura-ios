#!/bin/bash

set -u

cat << EOF > ~/.netrc
machine trunk.cocoapods.org
  login $PODS_LOGIN
  password $PODS_PASS
EOF

chmod 0600 ~/.netrc

#pod trunk push --verbose --allow-warnings
pod trunk me

#!/bin/bash

###############################################################################
# diel
#
# This script is responsible for producing deb artifacts.
###############################################################################



### Load configuration
CONF=/etc/diel/make.conf
[[ -e $CONF ]] && source $CONF


### Constant variables
export MINIBUILD_DIR="/usr/local/lib/minibuild"  # Prefer manual installation
[[ ! -d "$MINIBUILD_DIR" ]] && export MINIBUILD_DIR="/usr/lib/minibuild"  # Fallback to distro-provided installation


### Runtime dynamic config



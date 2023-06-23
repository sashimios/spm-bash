#!/bin/bash

###############################################################################
# diel-fetch
#
# This script is responsible for collecting files for the `diel` script.
###############################################################################



### Load configuration
CONF=/etc/diel/make.conf
[[ -e $CONF ]] && source $CONF


### Constant variables
export MINIBUILD_DIR="/usr/local/lib/minibuild"  # Prefer manual installation
[[ ! -d "$MINIBUILD_DIR" ]] && export MINIBUILD_DIR="/usr/lib/minibuild"  # Fallback to distro-provided installation


### Runtime dynamic config



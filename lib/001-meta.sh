function die() {
    log_error "[FATAL] $*"
    exit 1
}

export -f die

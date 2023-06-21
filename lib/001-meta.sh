function die() {
    echo "[FATAL] $*"
    exit 1
}

export -f die

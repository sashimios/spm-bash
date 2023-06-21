function log_info() {
    echo "[INFO] $*"
}
function log_error() {
    echo "[ERROR] $*"
}
function log_warning() {
    echo "[WARNING] $*"
}

export -f log_info log_error log_warning

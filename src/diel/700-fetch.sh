function fetch_upstream_dist_file() {
    local remote="$1"
    local save_to="$2"
    case "$remote" in
        https://*)
            wget "$remote" -O "$save_to"
            ;;
        *)
            log_error "No support for remote spec '$remote'"
    esac
}




function alt_wget() {
    if [[ -n "$DIST_MIRRORS" ]]; then
        for mirror_prefix in $DIST_MIRRORS; do
            alt_remote="$mirror_prefix/$pkg_id/$(basename "$remote")"
            if wget -q --spider "$alt_remote"; then
                if wget -O "$2" "$alt_remote"; then
                    log_info "Successfully downloaded $(basename "$2") from ${alt_remote}"
                    return 0
                fi
            fi
        done
    fi
    ### But if no cache dist file is available in any mirror site...
    wget "$1" -O "$2"
}

function fetch_upstream_dist_file() {
    local remote="$1"
    local save_to="$2"
    cd "$MASTER_DIR"
    case "$remote" in
        https://*)
            alt_wget "$remote" "$save_to"
            ;;
        tbl::https://*)
            remote="$(sed 's|^tbl::||' <<< "$remote")"
            alt_wget "$remote" "$save_to"
            ;;
        "git::rename="*";commit="*"::https://"*)
            # Sample data: git::rename=nanorc;commit=dc2a35ac3c3bfae5ba27caad52d303fee16fd4d2::https://github.com/Quentium-Forks/nanorc
            cd "$MASTER_DIR/work"
            val_rename="$(cut -d';' -f1 <<< "$remote" | cut -d= -f2)"
            val_commit="$(cut -d';' -f2 <<< "$remote" | cut -d: -f1 | cut -d= -f2)"
            val_uri="$(sed 's/::/|/g' <<< "$remote" | cut -d'|' -f3)"
            git clone "$val_uri" "$val_rename"
            cd "$val_rename"
            git checkout "$val_commit"
            cd "$MASTER_DIR"
            ;;
        *)
            log_error "No support for remote spec '$remote'"
    esac
}



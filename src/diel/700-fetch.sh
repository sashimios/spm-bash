function fetch_upstream_dist_file() {
    local remote="$1"
    local save_to="$2"
    case "$remote" in
        https://*)
            wget "$remote" -O "$save_to"
            ;;
        tbl::https://*)
            remote="$(sed 's|^tbl::||' <<< "$remote")"
            wget "$remote" -O "$save_to"
            ;;
        "git::rename="*";commit="*"::https://"*)
            # Sample data: git::rename=nanorc;commit=dc2a35ac3c3bfae5ba27caad52d303fee16fd4d2::https://github.com/Quentium-Forks/nanorc
            val_rename="$(cut -d';' -f1 <<< "$remote" | cut -d= -f2)"
            val_commit="$(cut -d';' -f2 <<< "$remote" | cut -d: -f1 | cut -d= -f2)"
            val_uri="$(sed 's/::/|/g' <<< "$remote" | cut -d'|' -f3)"
            git clone "$val_uri" "$val_rename"
            cd "$val_rename"
            git checkout "$val_commit"
            cd ..
            ;;
        *)
            log_error "No support for remote spec '$remote'"
    esac
}




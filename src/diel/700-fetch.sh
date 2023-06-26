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

function set_git_https_proxy() {
    source /etc/diel/make.conf
    if [[ -n "$GITPROXY" ]]; then
        log_info "Setting git proxy: $GITPROXY"
        git config http.proxy "$GITPROXY"
        return 0
    fi
    log_info "Did not find GITPROXY setting"

}

function fetch_upstream_dist_file() {
    local remote="$1"
    local save_to="$2"
    cd "$MASTER_DIR"
    case "$remote" in
        https://* | http://*)
            alt_wget "$remote" "$save_to"
            ;;
        tbl::https://* | tbl::http://*)
            remote="$(sed 's|^tbl::||' <<< "$remote")"
            alt_wget "$remote" "$save_to"
            ;;
        "git::commit="*"::https://"* | "git::commit="*"::git://"*)
            # Sample data: git::commit=tags/sscg-3.0.2::https://github.com/sgallagher/sscg.git
            cd "$MASTER_DIR/work"
            val_commit="$(cut -d';' -f1 <<< "$remote" | cut -d: -f1 | cut -d= -f2)"
            val_uri="$(sed 's/::/|/g' <<< "$remote" | cut -d'|' -f3)"
            val_rename="$(basename "$val_uri" | sed 's|.git$||')"
            git clone "$val_uri"
            cd "$val_rename"
            git checkout "$val_commit"
            set_git_https_proxy
            cd "$MASTER_DIR"
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
            set_git_https_proxy
            cd "$MASTER_DIR"
            ;;
        *)
            die "No support for remote spec '$remote'"
    esac
}




function SUBCMD_fetch() {
    spec_path="$1"
    function find_hash_entry_line() {
        source "$spec_path"
        local arr=($CHKSUMS)
        echo "${arr[$index_counter]}"
    }
    source "$spec_path"
    index_counter=0
    for src_url in $SRCS; do
        cd "$MASTER_DIR"
        ### Download upstream dist files
        log_info "Fetching source file [#$index_counter] '$src_url'..."
        tmpfilepath="$FETCH_DIR/$(basename "$src_url")"
        if [[ ! -e "$tmpfilepath" ]]; then
            fetch_upstream_dist_file "$src_url" "$tmpfilepath"
        fi

        ### Check hash
        hashspec="$(index_counter="$index_counter" spec_path="$spec_path" find_hash_entry_line | sed 's|::|@|')"

        if [[ "$hashspec" != SKIP ]] && [[ "$hashspec" != 'anitya'* ]]; then
            hash_type="$(cut -d@ -f1 <<< "$hashspec")"
            hash_value="$(cut -d@ -f2 <<< "$hashspec")"
            log_info "Expecting hash $hash_type : $hash_value"
            if "${hash_type}sum" "$tmpfilepath" | grep -oqs "$hash_value"; then
                log_info "NICE! Hash matched!"
            else
                log_error "Hash not matching!"
                log_info "Real hash output:"
                "${hash_type}sum" "$tmpfilepath"
                log_info "Other helpful information:"
                du -h "$tmpfilepath"
                file "$tmpfilepath"
                die "Please either edit the spec file or investigate MITM attacks."
            fi
        fi
        ### Next file...
        index_counter=$((index_counter+1))
    done
}

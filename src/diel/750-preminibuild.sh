function preminibuild_src_unpack() {
    log_info "Entering 'src_unpack'"
    cd "$MASTER_DIR/work"
    function die_for_unpack_fail() {
        die "Failed unpacking dist file: $dfn"
    }
    find "$FETCH_DIR" -name '*.tar*' | while read -r dfn; do
        tar -xvf "$dfn" || die_for_unpack_fail
    done
    find "$FETCH_DIR" -name '*.tgz' | while read -r dfn; do
        tar -xvzf "$dfn" || die_for_unpack_fail
    done
    chown -R $safe_user:$safe_user .
}



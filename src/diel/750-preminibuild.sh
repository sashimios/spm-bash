function preminibuild_src_unpack() {
    log_info "Entering 'src_unpack'"
    cd "$MASTER_DIR/work"
    for tar in "$FETCH_DIR"/*.tar*; do
        tar -xvf "$tar"
    done
    chown -R $safe_user:$safe_user .
}



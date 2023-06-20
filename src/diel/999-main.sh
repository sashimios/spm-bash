function SUBCMD_build() {
    export spec_path="$1"
    export pkg_cat="$(basename "$(dirname "$(dirname "$spec_path")")")"
    export pkg_name="$(basename "$(dirname "$spec_path")")"
    export pkg_id="$pkg_cat/$pkg_name"
    log_info "spec_path=$spec_path"
    log_info "pkg_cat=$pkg_cat"
    log_info "pkg_name=$pkg_name"
    ### Create working directory
    export MASTER_DIR="/var/tmp/dielws/$pkg_id"
    sudo mkdir -p "$MASTER_DIR"/{meta,fetch,work,output}
    sudo chmod 777 "$MASTER_DIR"/{meta,fetch,work,output}
    ### Download upstream dist files
    (
        function find_hash_entry_line() {
            source "$spec_path"
            local arr=("$CHKSUMS")
            echo "${arr[$index_counter]}"
        }
        source "$spec_path"  # Security implications...
        index_counter=0
        for src_url in $SRCS; do
            ### Download upstream dist files
            log_info "Fetching source file [#$index_counter] '$src_url'..."
            tmpfilepath="$MASTER_DIR/fetch/$(basename "$src_url")"
            if [[ ! -e "$tmpfilepath" ]]; then
                fetch_upstream_dist_file "$src_url" "$tmpfilepath"
            fi
            ### Check hash
            hash_entry_line="$(index_counter="$index_counter" spec_path="$spec_path" find_hash_entry_line | sed 's|::|@|')"
            hash_type="$(cut -d@ -f1 <<< "$hash_entry_line")"
            hash_value="$(cut -d@ -f2 <<< "$hash_entry_line")"
            log_info "Expecting hash $hash_type : $hash_value"
            if "${hash_type}sum" "$tmpfilepath" | grep -oqs "$hash_value"; then
                log_info "NICE! Hash matched!"
            else
                log_error "Hash not matching!"
                log_info "Real hash output:"
                "${hash_type}sum" "$tmpfilepath"
                log_info "Please either edit the spec file or investigate MITM attacks."
            fi
            ### Next file...
            index_counter=$((index_counter+1))
        done
    )
    ### Preparation works
    # Apply patches...
    ### Start actual building
    (
        if [[ -e /etc/diel/make.conf ]]; then
            source /etc/diel/make.conf
        fi
        cd "$MASTER_DIR"
        export DESTDIR="$MASTER_DIR/output"
        source "$spec_path"  # Security implications...
        source "$(dirname "$spec_path")"/autobuild/defines
        source "$(dirname "$spec_path")"/dbuild.sh
        log_info "Ready to build package $pkg_id"
        ### Use defined functions
        cd "$MASTER_DIR/work"
        start_building
        mkdir -p "$MASTER_DIR/output/DEBIAN"
    )
    ### Generate deb artifact
    (
        source "$spec_path"  # Security implications...
        source "$(dirname "$spec_path")"/autobuild/defines
        if [ -z "$REL" ]; then
            REL=0
        fi
        log_info "Writing meta info into '$MASTER_DIR/output/DEBIAN/control'"
        dpkgctrl
        dpkgctrl > "$MASTER_DIR/output/DEBIAN/control"
    )
    VER="$(grep Version "$MASTER_DIR/output/DEBIAN/control" | cut -d' ' -f2)"
    deb_name="$pkg_name--$VER.deb"
    deb_artifact_dir="/var/cache/spm-deb/$pkg_id"
    sudo mkdir -p "$deb_artifact_dir"
    dpkg-deb --build "$MASTER_DIR/output" "$deb_artifact_dir/$deb_name"
}





case "$1" in
    build)
        spec_path="$2"
        SUBCMD_build "$spec_path"
        ;;
esac



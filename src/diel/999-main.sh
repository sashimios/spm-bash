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
    mkdir -p "$MASTER_DIR"/{meta,fetch,work,output}
    rm -rf "$MASTER_DIR"/{meta,work,output}
    rsync -a --delete --mkpath "$(dirname "$spec_path")/" "$MASTER_DIR"/meta/
    mkdir -p "$MASTER_DIR"/{meta,fetch,work,output}
    chmod 755 "$MASTER_DIR"/{meta,fetch,work,output}
    chown nobody:root "$MASTER_DIR"/{meta,fetch,work,output}

    ### Download upstream dist files
    (
        function find_hash_entry_line() {
            source "$spec_path"
            local arr=($CHKSUMS)
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

            if [[ "$hash_entry_line" != SKIP ]]; then
                hash_type="$(cut -d@ -f1 <<< "$hash_entry_line")"
                hash_value="$(cut -d@ -f2 <<< "$hash_entry_line")"
                log_info "Expecting hash $hash_type : $hash_value"
                if "${hash_type}sum" "$tmpfilepath" | grep -oqs "$hash_value"; then
                    log_info "NICE! Hash matched!"
                else
                    log_error "Hash not matching!"
                    log_info "Real hash output:"
                    "${hash_type}sum" "$tmpfilepath"
                    die "Please either edit the spec file or investigate MITM attacks."
                fi
            fi
            ### Next file...
            index_counter=$((index_counter+1))
        done
    ) || die "Dist download phase failed."

    ### Preparation works
    # Apply patches...

    ### Start actual building
    buildlogfile="$MASTER_DIR/meta/build.log"
    log_info "Saving build log to file: $buildlogfile"
    (sudo -E -u nobody bash "$MINIBUILD_DIR/static/build.sh" | tee "$buildlogfile") || die "Build phase failed."

    ### Generate deb artifact
    sudo -E -u nobody bash "$MINIBUILD_DIR/static/gen-deb.sh"
    VER="$(grep Version "$MASTER_DIR/output/DEBIAN/control" | cut -d' ' -f2)"
    deb_name="$pkg_name--$VER.deb"
    deb_artifact_dir="/var/cache/spm-deb/$pkg_id"
    sudo mkdir -p "$deb_artifact_dir"
    dpkg-deb --build "$MASTER_DIR/output" "$deb_artifact_dir/$deb_name" || die "Failed generating artifact."
}





case "$1" in
    build)
        spec_path="$2"
        SUBCMD_build "$spec_path"
        ;;
    *)
        echo "For more info:  https://github.com/sashimios/spm-bash"
        ;;
esac



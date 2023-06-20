function SUBCMD_fix_spec_file() {
    spec_path="$1"
    log_info "Fixing spec file '$spec_path'..."
    (
        function find_hash_entry_line() {
            source "$spec_path"
            local arr=("$CHKSUMS")
            echo "${arr[$index_counter]}"
        }
        TMPDIR=/tmp/spm-maint-workdir/fix--$(dirname "$spec_path")
        mkdir -p "$TMPDIR"
        source "$spec_path"
        index_counter=0
        for src_url in $SRCS; do
            ### Download source file
            log_info "Fetching source file [#$index_counter] '$src_url'..."
            tmpfilepath="$TMPDIR/$(basename "$src_url")"
            wget "$src_url" -O "$tmpfilepath"
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
}




case "$1" in
    fix)
        spec_path="$2"
        SUBCMD_fix_spec_file "$spec_path"
        ;;
esac

#!/bin/bash

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

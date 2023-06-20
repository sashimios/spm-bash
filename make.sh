#!/bin/bash



BIN_TARGETS="spm spm-maint diel"

case $1 in
    build)
        ### Make directories
        mkdir -p build/bin dist
        ### Sync shared library
        for binname in $BIN_TARGETS; do
            rsync -av --delete "lib/" "src/$binname/001-lib/"
        done
        ### Combining files
        for binname in $BIN_TARGETS; do
            echo "[INFO] Building target '$binname'"
            binfn="build/bin/$binname"
            printf -- '' > "$binfn"
            find "src/$binname" -type f | sort | while read -r fn; do
                cat "$fn" >> "$binfn"
            done
        done
        ;;
    install_local)
        find build/bin -type f | while read -r binfn; do
            sudo install --verbose -m755 "$binfn" "/usr/local/bin/$(basename "$binfn")"
        done
        ;;
    easy)
        bash "$0" build
        bash "$0" install_local
        ;;
esac

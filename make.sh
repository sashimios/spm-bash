#!/bin/bash



BIN_TARGETS="spm spm-maint diel"

case $1 in
    build)
        ### Make directories
        mkdir -p build/bin dist
        ### Make portable shared library
        find lib -type f | sort | while read -r fn; do
            cat "$fn"
        done > build/spm-bash.lib.sh
        ### Sync shared library
        for binname in $BIN_TARGETS; do
            rsync -av --delete "lib/" "src/$binname/001-lib/"
        done
        ### Combining files
        for binname in $BIN_TARGETS; do
            echo "[INFO] Building target '$binname'"
            binfn="build/bin/$binname"
            find "src/$binname" -type f | sort | while read -r fn; do
                cat "$fn"
            done > "$binfn"
        done
        ;;
    install_local)
        find build/bin -type f | while read -r binfn; do
            sudo install --verbose -m755 "$binfn" "/usr/local/bin/$(basename "$binfn")"
        done
        sudo install --verbose build/spm-bash.lib.sh /usr/local/bin/spm-bash.lib.sh
        ;;
    easy)
        bash "$0" build
        bash "$0" install_local
        ;;
esac

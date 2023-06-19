#!/bin/bash



BIN_TARGETS="spm spm-maint"

case $1 in
    build)
        mkdir -p build/bin dist
        for binname in $BIN_TARGETS; do
            echo "[INFO] Building target '$binname'"
            binfn="build/bin/$binname"
            printf -- '' > "$binfn"
            find "src/$binname" -type f | while read -r fn; do
                cat "$fn" >> "$binfn"
            done
        done
        ;;
    install_local)
        find build/bin -type f | while read -r binfn; do
            install --verbose -m755 "$binfn" "$HOME/.local/bin/$(basename "$binfn")"
        done
        ;;
    easy)
        bash "$0" build
        bash "$0" install_local
        ;;
esac

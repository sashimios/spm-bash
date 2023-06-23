function SUBCMD_build() {
    export spec_path="$1"
    export pkg_cat="$(basename "$(dirname "$(dirname "$spec_path")")")"
    export pkg_name="$(basename "$(dirname "$spec_path")")"
    export pkg_id="$pkg_cat/$pkg_name"
    log_info "spec_path=$spec_path"
    log_info "pkg_cat=$pkg_cat"
    log_info "pkg_name=$pkg_name"

    ### Create working directory
    export FETCH_DIR="/var/cache/diel-fetch/$pkg_id"
    mkdir -p "$FETCH_DIR"
    export MASTER_DIR="/var/tmp/dielws/$pkg_id"
    mkdir -p "$MASTER_DIR"/{meta,work,output}
    rm -rf "$MASTER_DIR"/{meta,work,output}
    rsync -a --delete --mkpath "$(dirname "$spec_path")/" "$MASTER_DIR"/meta/
    mkdir -p "$MASTER_DIR"/{meta,work,output}
    chmod 755 "$MASTER_DIR"/{meta,work,output}
    chown $safe_user:root "$MASTER_DIR"/{meta,work,output}
    chown $safe_user:root "$FETCH_DIR"

    ### Download upstream dist files
    sudo -E -u $safe_user spec_path="$spec_path" diel-fetch  || die "Dist download phase failed."

    ### Preparation works
    preminibuild_src_unpack

    ### Start actual building
    buildlogfile="/var/log/diel-minibuild/$pkg_id.log"
    mkdir -p "$(dirname "$buildlogfile")"
    log_info "Saving build log to file: $buildlogfile"
    log_info "Assigning building job to Minibuild..."
    echo "==========================================================================="
    set -e
    trap 'die "Build phase failed."; exit 1' ERR
    sudo -E -u $safe_user bash "$MINIBUILD_DIR/static/build.sh" | tee "$buildlogfile"
    echo "==========================================================================="
    log_info "Saved build log to file: $buildlogfile"


    ### Generate deb artifact
    sudo -E -u $safe_user bash "$MINIBUILD_DIR/static/gen-deb.sh"
    VER="$(grep Version "$MASTER_DIR/output/DEBIAN/control" | cut -d' ' -f2)"
    deb_name="$pkg_name--$VER.deb"
    deb_artifact_dir="/var/cache/spm-deb/$pkg_id"
    mkdir -p "$deb_artifact_dir"
    dpkg-deb --build "$MASTER_DIR/output" "$deb_artifact_dir/$deb_name" || die "Failed generating artifact."

    ### Clean MASTER_DIR
    if [[ "$NOCLEAN" != y ]]; then
        rm -rf "/var/tmp/dielws/$pkg_id"
    fi
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



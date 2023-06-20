# depcom: Turns "$@" into a comma seperated list of deps.
pm_depcom(){
	: "${PM_ALT=1} ${PM_DELIM= | } ${PM_COMMA=, }"
	local IFS='|' dep pkg i cnt=0	# cnt_depcom: dep comma pos
	for i; do
		read -ra dep <<< "$i"
		ABCOMMA="$PM_COMMA" abmkcomma
		pm_deparse
	done
}
abmkcomma(){ ((cnt++)) && echo -n "${ABCOMMA-, }"; }
# deparse: turns dep[] into a member of the list.
pm_deparse(){
	local cnt=0			# cnt_deparse: dep delim pos
	if (( !PM_ALT && ${#dep[@]}>1 )); then
		pm_genver "${dep[0]}"; return;
	fi
	for pkg in "${dep[@]}"; do
		ABCOMMA="$PM_DELIM" abmkcomma
		pm_genver "$pkg"
	done
}
# genver <pkgspec> -> pkgname[<ver_s><op>verstr<ver_e>]
pm_genver(){
	local store IFS ver name       # IFS is also used for holding OP.
	: "${OP_EQ== } ${OP_LE=<= } ${OP_GE=>= } ${VER_S= (} ${VER_E=)}"
	if ((VER_NONE_ALL)); then			# name-only
		name="${1/%_}"
		echo "${name/[<>=]=*}"; return
	elif [[ "$1" =~ [\<\>=]= ]]; then		# nameOP[ver] -> name OP_ ver
		IFS="$BASH_REMATCH"	# split string using each char in OP
		read -ra store <<< "$1" 
		name=${store[0]} ver=${store[2]}	# constexpr store[${#IFS}]
		IFS=${IFS/==/$OP_EQ}	# translate to package manager notation
		IFS=${IFS/<=/$OP_LE}
		IFS=${IFS/>=/$OP_GE}
	elif ((VER_NONE)) || [[ "$1" =~ _$ ]]; then	# name{,_} -> name (e.g. conflicts, ..)
		echo -n "${1%_}"; return;
	else
		name=$1 IFS="$OP_GE"			# name -> name OP_GE getver
	fi
	# echo -n "$name$VER_S$IFS${ver=$(pm_getver "$1")}$VER_E"
	echo -n "$name$VER_S$IFS${ver=$(echo "$1")}$VER_E"
}



function dpkgfield() {
    echo -ne "$1: "; shift; pm_depcom "$@"; echo;
    # echo -ne "$1: "; shift; echo "$@"; echo;
}

function dpkgctrl() {
	# local arch="${ABHOST%%\/*}" # Some borrowed magic which I do not understand
	local arch="$(uname -m | tr '_' '-')"
	[[ "$arch" == noarch ]] && arch=all
	echo "Package: $pkg_name"
	echo "Version: $(dpkgpkgver)"
	echo "Architecture: $arch"
	[ "$pkg_cat" ] && echo "Section: $pkg_cat"
	echo "Maintainer: $USER"  # Use current user
	echo "Installed-Size: $(du -s "$MASTER_DIR/output" | cut -f 1)"
	echo "Description: $PKGDES"
	if ((PKGESS)); then
		echo "Essential: yes"
	else
		echo "Essential: no"
	fi
	[ "$PKGDEP" ] && dpkgfield Depends $PKGDEP
	VER_NONE=1 # We don't autofill versions in optional fields
	[ "$PKGRECOM" ] && dpkgfield Recommends $PKGRECOM
	[ "$PKGREP" ] && dpkgfield Replaces $PKGREP
	[ "$PKGCONFL" ] && dpkgfield Conflicts $PKGCONFL
	[ "$PKGPROV" ] && VER_NONE=1 dpkgfield Provides $PKGPROV
	[ "$PKGSUG" ] && dpkgfield Suggests $PKGSUG
	[ "$PKGBREAK" ] && dpkgfield Breaks $PKGBREAK
	if [ -e "$SRCDIR"/autobuild/extra-dpkg-control ]; then
		cat "$SRCDIR"/autobuild/extra-dpkg-control
	fi
	echo "$DPKGXTRACTRL"
}

function dpkgpkgver() {
	((EPOCH)) && echo -n "$EPOCH":
	echo -n "$VER"
	if [ "$REL" == 0 ] || [ -z "$REL" ]; then
		:
	else
		echo "-$REL"
	fi
}

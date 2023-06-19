# SPM (Bash)

The SPM implementation written in shell script.


## Introduction

SPM (Sashimi Package Manager) is a package management tool developed for Sashimi OS.

Here are the important ideas:

- Binary distributions rely too much on mirrors and/or CDN.
- Dpkg is a nice backend to cooperate with.
- This tool makes deb artifacts from source code and leaves them for Dpkg to actually install.
- This tool supports reusing deb artifacts shared on a mirror site, to opportunistically reduce the computation burden.



## Copyright

Copyright (c) 2023 Neruthes.

This program is free software; you can redistribute it and/or
modify it under the terms of the GNU General Public License
as published by the Free Software Foundation; only version 2
of the License is used.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program; if not, write to the Free Software
Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.

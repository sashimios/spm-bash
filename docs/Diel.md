# Sashimi Package Manager - Diel


## Introduction

Diel is responsible for generating deb artifacts.

If we are lucky, Autobuild3 from AOSC will be a nice backend.
Otherwise we will have to maintain separate build scripts.



## Input and Output

Diel takes the `spec` file path as input,
and its output is the `deb` file.

Example build command:

```
diel build /var/db/spm-repo/sashimi/tree/sys-kernel/linux-src/spec
```

Output file path:

```
/var/cache/spm-deb/sys-kernel/linux-src--6.3.0.deb
```



## Directories

The general prefix is `/var/tmp/dielws/sys-kernel/linux-src`.

| Subdirectory | Usage                                      |
| ------------ | ------------------------------------------ |
| `meta`       | Package definition files including patches |
| `work`       | Compilation working directory              |
| `output`     | Files to be put into the deb artifact      |




## Configuration

### Prefix Path

All config files are relative to this path:

```
/etc/diel
```






### File: make.conf

Heavily inspired by `/etc/portage/make.conf`.
For more info, see [Gentoo wiki](https://wiki.gentoo.org/wiki//etc/portage/make.conf).


#### MAKEOPTS

Example:

```
-j8
```


#### DIST_MIRRORS

Where to find dist files.

The server may be a simple Nginx config:

```
server {
    listen 28182;
    root /var/cache/diel-fetch;
    autoindex on;
}
```

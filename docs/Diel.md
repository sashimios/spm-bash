# Sashimi Package Manager - Diel


## Introduction

Diel is responsible for generating deb artifacts.

If we are lucky, Autobuild3 from AOSC will be a nice backend.
Otherwise we will have to maintain separate build scripts.



## Input and Output

Diel takes the `spec` file path as input,
and its output is the `deb` file.

Example command:

```
diel make /var/db/spm-repo/sashimi/tree/sys-kernel/linux-src/spec
```

Output file path:

```
/var/cache/spm-deb/sys-kernel/linux-src--6.3.0.deb
```

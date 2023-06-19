# Sashimi Package Manager - Developer Manual



## Introduction

Sashimi Package Manager (SPM) is a package management tool.
It is designed to work as a frontend for Dpkg.
Unlike APT and similar tools, SPM is primarily designed to serve source distributions instead of binary distributions.




## Features

### Basic Usage

- `sync`: Pull source tree repositories.
- `install`: Install new packages.
- `remove`: Remove some packages from `world` set.
- `kill`: Force delete some specific packages.
- `update`: Update some spcecific packages.
- `fullupgrade`: Update all updatable packages.
- `depclean`: Delete packages that are neither required (by the user) nor depended (by other packages).

### Advanced Usage

- Maintain package metadata
- Mirrors for binary artifacts




## Data Management

### Configuration

The base config directory is `/etc/spm-conf`.

For details, see `docs/Config.md`.

### Local Data

All source tree repositories are located in `/var/db/spm-repo`.
For example, the official `sashimi` source tree is placed at `/var/db/spm-repo/sashimi`.

### Tree Structure

Please see the existing practice in [sashimios/tree-sashimi](https://github.com/sashimios/tree-sashimi).

The tree structure should be similar to [AOSC-Dev/aosc-os-abbs](https://github.dev/AOSC-Dev/aosc-os-abbs).

### Binary Artifacts

All binary artifacts are placed under `/var/cache/spm-deb`.
If someone wants to host a small mirror site for sharing deb artifacts,
this path should be used as the root directory for the web server.




## Package Installation

On the end user machine, installing a package involves several steps:

- Detect conflicts from the current tree.
- Update the `world` set.
- Calculate dependency tree expansion.
- For each new dependency:
  - If the config file permits, detect available dpkg artifacts from configured mirrors. If found, skip the next step.
  - Make the dpkg artifact.
    - Retrieve source files.
    - Verify hash.
    - Decompress.
    - Run build script.
    - Produce dpkg artifact.
    - Clean working directory.
  - Install the dpkg artifact.




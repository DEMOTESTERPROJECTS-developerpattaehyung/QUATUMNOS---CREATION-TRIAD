#!/bin/bash
# This script is intended to be copied into the chroot and run there.
set -euo pipefail
echo "Running inside chroot: installing packages and cleaning up"

export DEBIAN_FRONTEND=noninteractive
apt-get update
if [ -f /build/config.packages ]; then
  xargs -a /build/config.packages apt-get install -y --no-install-recommends || true
fi
# Create minimal fstab, hostname, hosts
echo "quantum-live" > /etc/hostname
cat > /etc/hosts <<'HOSTS'
127.0.0.1 localhost
127.0.1.1 quantum-live
::1   localhost ip6-localhost ip6-loopback
HOSTS
# Set root password to 'quantum' (change before distribution)
echo root:quantum | chpasswd
# Clean apt cache
apt-get clean
rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
# Remove machine-id to be generated on first boot
rm -f /etc/machine-id

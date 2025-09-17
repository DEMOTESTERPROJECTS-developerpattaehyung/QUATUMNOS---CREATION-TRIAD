#!/bin/bash
# build.sh - starter ISO build driver (Debian/Ubuntu hosts)
set -euo pipefail

usage(){ cat <<USAGE
Usage: sudo bash build.sh [--workdir DIR] [--suite SUITE] [--arch ARCH]
Example: sudo bash build.sh --workdir /tmp/quantumiso --suite bookworm --arch amd64
USAGE
}

WORKDIR=${WORKDIR:-/tmp/quantumiso}
SUITE=${SUITE:-bookworm}
ARCH=${ARCH:-amd64}

while [ "$#" -gt 0 ]; do
  case "$1" in
    --workdir) WORKDIR=$2; shift 2;;
    --suite) SUITE=$2; shift 2;;
    --arch) ARCH=$2; shift 2;;
    -h|--help) usage; exit 0;;
    *) echo "Unknown arg: $1"; usage; exit 1;;
  esac
done

if [ "$EUID" -ne 0 ]; then echo "Run as root"; exit 1; fi

mkdir -p "$WORKDIR"
BUILD_DIR="$WORKDIR/build"
CHROOT_DIR="$BUILD_DIR/chroot"
ISO_DIR="$BUILD_DIR/iso"
mkdir -p "$CHROOT_DIR" "$ISO_DIR" "$BUILD_DIR/boot"

echo "[+] Creating debootstrap chroot for ${SUITE}/${ARCH} in $CHROOT_DIR"
apt-get update
apt-get install -y debootstrap squashfs-tools xorriso syslinux-utils grub-pc-bin grub-efi-amd64-bin

# Bootstrap base system
debootstrap --arch=$ARCH --variant=minbase $SUITE $CHROOT_DIR http://deb.debian.org/debian

echo "[+] Copying config and chroot bootstrap script"
mkdir -p "$CHROOT_DIR/build"
cp config.packages "$CHROOT_DIR/build/"
cp chroot-bootstrap.sh "$CHROOT_DIR/build/"
chmod +x "$CHROOT_DIR/build/chroot-bootstrap.sh"

# Mount pseudo-filesystems
mount --bind /dev "$CHROOT_DIR/dev"
mount --bind /dev/pts "$CHROOT_DIR/dev/pts"
mount -t proc /proc "$CHROOT_DIR/proc"
mount -t sysfs /sys "$CHROOT_DIR/sys"

# Run the chroot bootstrap script
chroot "$CHROOT_DIR" /bin/bash -c "/build/chroot-bootstrap.sh"

# Unmount pseudo-filesystems
umount -l "$CHROOT_DIR/dev/pts" || true
umount -l "$CHROOT_DIR/dev" || true
umount -l "$CHROOT_DIR/proc" || true
umount -l "$CHROOT_DIR/sys" || true

echo "[+] Create squashfs of chroot"
mkdir -p "$ISO_DIR/live"
mksquashfs "$CHROOT_DIR" "$ISO_DIR/live/filesystem.squashfs" -e boot

echo "[+] Copy kernel and initrd from chroot (adjust kernel path if needed)"
# Try a common kernel initrd location; users may need to adjust if different kernels are installed
KIMG=$(ls -1 $CHROOT_DIR/boot/vmlinuz-* | head -n1 || true)
INITRD=$(ls -1 $CHROOT_DIR/boot/initrd.img-* | head -n1 || true)
if [ -n "$KIMG" ] && [ -n "$INITRD" ]; then
  cp "$KIMG" "$ISO_DIR/live/vmlinuz"
  cp "$INITRD" "$ISO_DIR/live/initrd.img"
else
  echo "Warning: kernel/initrd not found in chroot. You must provide vmlinuz and initrd.img in $ISO_DIR/live"
fi

echo "[+] Populate ISO boot structure"
# Add simple isolinux/grub placeholders (users should customize for real distro)
mkdir -p "$ISO_DIR/boot/grub"
cat > "$ISO_DIR/boot/grub/grub.cfg" <<GRUBCFG
set timeout=5
set default=0
menuentry "Quantum Live" {
  linux /live/vmlinuz boot=live quiet
  initrd /live/initrd.img
}
GRUBCFG

ISO_NAME="quantum-${SUITE}-${ARCH}.iso"

echo "[+] Creating hybrid ISO: $ISO_NAME"
xorriso -as mkisofs -iso-level 3 -volleys -r -J -l \
  -b boot/grub/i386-pc/eltorito.img \
  -no-emul-boot -boot-load-size 4 -boot-info-table \
  -isohybrid-gpt-basdat \
  -eltorito-alt-boot -e EFI/boot/efiboot.img -no-emul-boot \
  -o "$WORKDIR/$ISO_NAME" "$ISO_DIR"

echo "[+] Done. ISO created at $WORKDIR/$ISO_NAME"

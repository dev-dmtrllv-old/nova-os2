DISK_NAME=out/disk.img

SECTOR_SIZE=512
PART_1_SECTOR=2048
PART_2_SECTOR=264192

PART_1_OFFSET=$((SECTOR_SIZE * PART_1_SECTOR))
PART_2_OFFSET=$((SECTOR_SIZE * PART_2_SECTOR))

MBR_SIZE=446
BOOT_OFFSET=90

echo "installing MBR boot code..."

LOOP_DEV=$(sudo losetup --show -f -P $DISK_NAME)
dd bs=$MBR_SIZE count=1 if=out/boot/mbr.o of=$DISK_NAME conv=notrunc >/dev/null 2>&1
sudo losetup -d $LOOP_DEV

echo "installing BPB boot code..."

LOOP_DEV=$(sudo losetup -o $PART_1_OFFSET --show -f -P $DISK_NAME)
sudo dd bs=1 if=out/boot/bpb.o count=3 of=$LOOP_DEV conv=notrunc
sudo dd bs=1 skip=$BOOT_OFFSET if=out/boot/bpb.o iflag=skip_bytes of=$LOOP_DEV seek=$BOOT_OFFSET conv=notrunc
sudo dd bs=512 if=out/boot/boot.o of=$LOOP_DEV seek=7 conv=notrunc
sudo losetup -d $LOOP_DEV

echo "installing boot done!"
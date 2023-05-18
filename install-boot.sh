DISK_NAME=out/disk.img

SECTOR_SIZE=512
PART_1_SECTOR=2048
PART_2_SECTOR=264192

PART_1_OFFSET=$((SECTOR_SIZE * PART_1_SECTOR))
PART_2_OFFSET=$((SECTOR_SIZE * PART_2_SECTOR))

MBR_SIZE=446

echo "installing MBR boot..."

LOOP_DEV=$(sudo losetup --show -f -P $DISK_NAME)
dd bs=$MBR_SIZE count=1 if=out/boot/mbr.o of=$DISK_NAME conv=notrunc >/dev/null 2>&1
sudo losetup -d $LOOP_DEV

# sudo losetup -o $PART_1_OFFSET $(LOOP_DEV) $DISK_NAME
# dd bs=1 if=out/boot/mbr.o of=$DISK_NAME conv=notrunc status=progress
# sudo dd bs=1 if=out/boot/bpb.o count=3 of=$(LOOP_DEV) conv=notrunc status=progress
# sudo dd bs=1 skip=$(BOOT_OFFSET) if=out/boot/bpb.o iflag=skip_bytes of=$(LOOP_DEV) seek=$(BOOT_OFFSET) conv=notrunc status=progress
# sudo dd bs=1 seek=1024 if=out/boot/boot.o iflag=skip_bytes of=$(LOOP_DEV) conv=notrunc status=progress
# sudo losetup -d $(LOOP_DEV)

echo "installing boot done!"
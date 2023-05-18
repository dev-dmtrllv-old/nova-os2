DISK_NAME=out/disk.img
SECTOR_SIZE=512
PART_1_SECTOR=2048
PART_2_SECTOR=264192

PART_1_OFFSET=$((SECTOR_SIZE * PART_1_SECTOR))
PART_2_OFFSET=$((SECTOR_SIZE * PART_2_SECTOR))

echo "creating disk"
mkdir -p out

dd if=/dev/zero of=$DISK_NAME bs=512M count=1 >/dev/null 2>&1

echo "creating partitions"

echo -e "o\nn\n\n\n\n+128M\nn\n\n\n\n\na\n1\nw\n" | fdisk $DISK_NAME >/dev/null 2>&1

echo "creating 1st FAT32 partition at offset $PART_1_OFFSET"

LOOP_DEV=$(sudo losetup --show -f -P -o $PART_1_OFFSET $DISK_NAME)
sudo mkfs.fat -F 32 $LOOP_DEV >/dev/null 2>&1
sudo losetup -d $LOOP_DEV

echo "creating 2nd FAT32 partition at offset $PART_2_OFFSET"

LOOP_DEV=$(sudo losetup --show -f -P -o $PART_2_OFFSET $DISK_NAME)
sudo mkfs.fat -F 32 $LOOP_DEV >/dev/null 2>&1
sudo losetup -d $LOOP_DEV

echo "creating disk done!"
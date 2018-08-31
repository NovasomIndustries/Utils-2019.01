#!/bin/bash

MTDPARTS="PARTITIONS|\
333a128e-d3e3-b94d-92f4-d3ebd9b3224f@64:16383(loader1)../../Bootloader/u-boot-novasomM7-2017.09/idbloader.img,\
f20aa902-1c5d-294a-9177-97a513e3cae4@16384:24575(loader2)../../Bootloader/u-boot-novasomM7-2017.09/uboot.img,\
f20aa902-1c5d-294a-9177-97a513e3cae4@24576:32767(trust)../../Bootloader/u-boot-novasomM7-2017.09/trust.img,\
f20aa902-1c5d-294a-9177-97a513e3cae4@32768:262143(boot),\
B921B045-1DF0-41C3-AF44-4C6F280D3FAE@262144:-(rootfs)"

DISK="/dev/sdb"
echo -n "Creating basic structure on ${DISK} ... "
sudo sgdisk -Z ${DISK} > /dev/null 2>&1
sudo sgdisk -U D768ED04-0D56-43E1-9E8C-59EAA895DA94 ${DISK} > /dev/null 2>&1
sudo partprobe ${DISK} > /dev/null 2>&1
sudo sgdisk -a 64 ${DISK} > /dev/null 2>&1
sudo partprobe ${DISK} > /dev/null 2>&1
echo "Done"


IFS="|"
definition=( $MTDPARTS )
unset IFS
IFS=','
read -ra partitions <<< "${definition[1]}"
unset IFS
PARTNUM=1
for partition in "${partitions[@]}"; do
	# echo $partition
	IFS='@:()!' read -r UUID START END NAME FILENAME<<< "$partition"
	# echo "uuid : $UUID , start : $START , size : $END , name : $NAME , filename = $FILENAME"
	if [ "${END}" == "-" ]; then
		#echo "sgdisk -n ${PARTNUM}:${START}: -c ${PARTNUM}:${NAME} -u ${PARTNUM}:${UUID} ${DISK}"
		sudo sgdisk -n ${PARTNUM}:${START}: -c ${PARTNUM}:${NAME} -u ${PARTNUM}:${UUID} ${DISK} > /dev/null 2>&1
	else
		#echo "sgdisk -n ${PARTNUM}:${START}:${END} -c ${PARTNUM}:${NAME} -u ${PARTNUM}:${UUID} ${DISK}"
		sudo sgdisk -n ${PARTNUM}:${START}:${END} -c ${PARTNUM}:${NAME} -u ${PARTNUM}:${UUID} ${DISK} > /dev/null 2>&1
	fi
	if ! [ "${FILENAME}" == "" ]; then
		if [ -f ${FILENAME} ]; then
#			echo "dd if=${FILENAME} of=${DISK} seek=${START} conv=notrunc"
			echo -n "Storing ${FILENAME} on partition ${PARTNUM}... "
			sudo dd if=${FILENAME} of=${DISK} seek=${START} conv=notrunc > /dev/null 2>&1
			echo "Done"
		else
			echo "*********************************** $FILENAME ***************************"
		fi
	else
		echo "[NOTE] : No file defined for partition ${PARTNUM}(${NAME})"
	fi
	let PARTNUM=${PARTNUM}+1
	sudo partprobe ${DISK} > /dev/null 2>&1
done
echo -n "Making partition 4 bootable on ${DISK} ... "
sudo sgdisk -A 4:set:2 -t 4:0700 ${DISK} > /dev/null 2>&1
sudo partprobe ${DISK} > /dev/null 2>&1
echo "Done"
sync
echo "Pouplating partitions on ${DISK} ... "
yes | sudo mkfs.ext4 ${DISK}5
sync
sudo rm -rf tmp
sudo mkdir tmp
echo -n "Creating boot partition ..."
sudo mkfs.vfat ${DISK}4 > /dev/null 2>&1
sync
sudo mount ${DISK}4 tmp
echo -n "Done. Populating boot partition ..."
sudo cp ../../Kernel/linux-4.4.143_M7/arch/arm64/boot/Image tmp/.
sudo cp ../../Kernel/linux-4.4.143_M7/arch/arm64/boot/dts/rockchip/rk3328-evb.dtb tmp/dtb.dtb
sudo cp ../../Deploy/uInitrd tmp/.
sudo umount tmp
echo "Done."
echo -n "Finishing up ..."
sync
echo "Done."

exit


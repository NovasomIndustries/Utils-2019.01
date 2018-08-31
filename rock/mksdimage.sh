#!/bin/bash

MTDPARTS="PARTITIONS|\
333a128e-d3e3-b94d-92f4-d3ebd9b3224f@64:16383(loader1)../../Bootloader/u-boot-novasomM7-2017.09/idbloader.img,\
f20aa902-1c5d-294a-9177-97a513e3cae4@16384:24575(loader2)../../Bootloader/u-boot-novasomM7-2017.09/uboot.img,\
f20aa902-1c5d-294a-9177-97a513e3cae4@24576:32767(trust)../../Bootloader/u-boot-novasomM7-2017.09/trust.img,\
f20aa902-1c5d-294a-9177-97a513e3cae4@32768:262143(boot),\
B921B045-1DF0-41C3-AF44-4C6F280D3FAE@262144:-(rootfs)"

DISKFILE="disk.img"
echo -n "Creating ${DISKFILE} ... "
dd if=/dev/zero of=${DISKFILE} bs=1M count=256  > /dev/null 2>&1
echo "Done"
echo -n "Creating basic structure on ${DISKFILE} ... "
sgdisk -Z ${DISKFILE} > /dev/null 2>&1
sgdisk -U D768ED04-0D56-43E1-9E8C-59EAA895DA94 ${DISKFILE} > /dev/null 2>&1
partprobe ${DISKFILE} > /dev/null 2>&1
sgdisk -a 64 ${DISKFILE} > /dev/null 2>&1
partprobe ${DISKFILE} > /dev/null 2>&1
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
		#echo "sgdisk -n ${PARTNUM}:${START}: -c ${PARTNUM}:${NAME} -u ${PARTNUM}:${UUID} ${DISKFILE}"
		sgdisk -n ${PARTNUM}:${START}: -c ${PARTNUM}:${NAME} -u ${PARTNUM}:${UUID} ${DISKFILE} > /dev/null 2>&1
	else
		#echo "sgdisk -n ${PARTNUM}:${START}:${END} -c ${PARTNUM}:${NAME} -u ${PARTNUM}:${UUID} ${DISKFILE}"
		sgdisk -n ${PARTNUM}:${START}:${END} -c ${PARTNUM}:${NAME} -u ${PARTNUM}:${UUID} ${DISKFILE} > /dev/null 2>&1
	fi
	if ! [ "${FILENAME}" == "" ]; then
		if [ -f ${FILENAME} ]; then
#			echo "dd if=${FILENAME} of=${DISKFILE} seek=${START} conv=notrunc"
			echo -n "Storing ${FILENAME} on partition ${PARTNUM}... "
			dd if=${FILENAME} of=${DISKFILE} seek=${START} conv=notrunc > /dev/null 2>&1
			echo "Done"
		else
			echo "*********************************** $FILENAME ***************************"
		fi
	else
		echo "[NOTE] : No file defined for partition ${PARTNUM}(${NAME})"
	fi
	let PARTNUM=${PARTNUM}+1
	partprobe ${DISKFILE} > /dev/null 2>&1
done
echo -n "Making partition 4 bootable on ${DISKFILE} ... "
sgdisk -A 4:set:2 -t 4:0700 ${DISKFILE} > /dev/null 2>&1
partprobe ${DISKFILE} > /dev/null 2>&1
echo "Done"
exit


#!/bin/bash

echo "###### Customizing file system ######"
echo "cp -r board/novasis/NOVAsomS/Init/* ${TARGET_DIR}"
cp -r board/novasis/NOVAsomS/Init/* ${TARGET_DIR}
chmod 777 ${TARGET_DIR}/bin/*
chmod 777 ${TARGET_DIR}/etc/init.d/*
sync
exit $?

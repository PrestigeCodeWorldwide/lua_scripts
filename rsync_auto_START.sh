#!/bin/bash

# Start the first instance of rsync_auto.sh in the background
#./rsync_auto_process.sh /home/kc/workspace/macroquest/RGLauncher/Config/ /mnt/g/Games/EQHax/RGLauncher/Config > /dev/null 2>&1 &

# Start the second instance of rsync_auto.sh in the background
./rsync_auto_process.sh /home/kc/workspace/macroquest/RGLauncher/lua/ /mnt/g/Games/EQHax/RGLauncher/lua > /dev/null 2>&1 &

# Optional: Print a message indicating the scripts are running
echo "Both rsync_auto_process.sh instances are running in the background."

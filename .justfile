# Justfile

format:
    stylua --glob '**/*.lua' .
sync:
    ./rsync_auto_START.sh
stopsync:
    sudo pkill -f rsync_auto_process.sh


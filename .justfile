# Justfile

format:
    stylua --glob '**/*.lua' .
sync:
    rsync -av --delete /home/kc/workspace/macroquest/RGLauncher/lua/ /mnt/g/Games/EQHax/RGLauncher/lua
	

#!/bin/bash

# Speed of the animation (higher value mean slower)
RUN_SPEED=0.02
# Number of frames used in the script, adapt it according to your resolution
START_INDEX=1
END_INDEX=121

# Script's root directory
SCRIPT_DIR=$(dirname "$(realpath "$0")")
# Directory where all of your motoRun*.txt frames will go
FRAMES_DIR="$SCRIPT_DIR/motoRun"
# Original frame used to generate others
ORIGIN_FRAME="$FRAMES_DIR/motoRun1.txt"
# Backup file of the motoRun1.txt
BAK_FRAME="$FRAMES_DIR/motoRun1.txt.bak"
# Prefix name for motoRun*.txt frames
PREFIX_NAME="motoRun"


# Original frame regen from the .bak if failed to find the .txt one
function original_frame_regen {
        cp "$BAK_FRAME" "$ORIGIN_FRAME"
        if [ -e "$ORIGIN_FRAME" ]; then
                echo "File has been created, auto-reboot in 3 seconds."
                sleep 3
        else
                echo "Creation of file $ORIGIN_FRAME has failed, exiting now..."
                exit
        fi
}

# Frame generation from the original frame
function frame_gen {
	for ((i=start_index; i<end_index; i++)); do
		current_file="${file_prefix}${i}.txt"
		next_file="${file_prefix}$((i+1)).txt"

		# Find the current frame
		if [[ -f "$current_file" ]]; then
			# Add a space at the beginning of each ligne and write it in th next file
		        sed 's/^/ /' "$current_file" > "$next_file"
		fi
	done
}

# Final run of the script
function moto_run {
        find "$FRAMES_DIR" -name "*Run*.txt" | sort -Vr | while read fichier; do
                clear
                cat "$fichier"
                sleep $RUN_SPEED
        done
        clear
        cat motoEnd.txt
	exit
}



# Try to find the original frame before generating others, if not found, try to copy it from the backup file
if [ ! -f "$FRAMES_DIR/$ORIGIN_FRAME" ]; then
	original_frame_regen
fi

frame_gen

# Finally running the animation script
moto_run

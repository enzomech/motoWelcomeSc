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
# The last frame that should be played
LAST_FRAME="motoEnd.txt"


# Original frame regen from the .bak file
function original_frame_regen {
        cp "$BAK_FRAME" "$ORIGIN_FRAME"
        if [ -e "$ORIGIN_FRAME" ]; then
                echo "$ORIGIN_FRAME has been found."
                #sleep 3
        else
                echo "Creation of file $ORIGIN_FRAME has failed, you should download again the repo, exiting now..."
                exit
        fi
}

# Frame generation from the original frame
function frame_gen {
	# Removing all of the ancient frames
	rm $FRAMES_DIR/$PREFIX_NAME*.txt
	echo "Remove ancient frames"
	# Try to copy the first frame from the backup file
	original_frame_regen
	for ((i=START_INDEX; i<END_INDEX; i++)); do
		current_file="${PREFIX_NAME}${i}.txt"
		next_file="${PREFIX_NAME}$((i+1)).txt"
		# Find the current frame
		if [[ -f "${FRAMES_DIR}/${current_file}" ]]; then
			# Add a space at the beginning of each ligne and write it in th next file
		        sed 's/^/ /' "${FRAMES_DIR}/${current_file}" > "${FRAMES_DIR}/${next_file}"
		fi
	done
}

# Final run of the script
function moto_run {
	# Search and sort motoRun.txt files from a descending order to show it the right timing from the right to the left
        find "$FRAMES_DIR" -name "*Run*.txt" | sort -Vr | while read fichier; do
                clear
                cat "$fichier"
                sleep $RUN_SPEED
        done
        clear
        cat $LAST_FRAME
	exit
}

# Try to find the last frame that thould have already been generated if the frame_gen has already been launched since the last index customisation or if there is a surplus of frames
end_index_test=$((END_INDEX + 1))
if [[ ! -f "${FRAMES_DIR}/${PREFIX_NAME}${END_INDEX}.txt" || -f "${FRAMES_DIR}/${PREFIX_NAME}${end_index_test}.txt" ]]; then 
	frame_gen
fi

# Finally running the animation script
moto_run

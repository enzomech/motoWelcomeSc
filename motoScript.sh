#!/bin/bash

# Main vars config, should be adapted with the config script, according to your resolution and patience
# Speed of the animation (higher value mean slower)
RUN_SPEED=0
# Number of frames used in the animation
START_INDEX=0
END_INDEX=0

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
LAST_FRAME="$SCRIPT_DIR/motoEnd.txt"

# Initialising the vars from the scriptVars.sh file
function init_vars {
	if [[ -f $SCRIPT_DIR/scriptVars.sh ]]; then
		echo "Values sourced by scriptVars.sh"
		source $SCRIPT_DIR/scriptVars.sh
		RUN_SPEED="$SPEED_NB"
		START_INDEX=1
		END_INDEX="$FRAME_NB"
	else
		echo "Failed to find the configuration file, you need to launch the config script first"
		exit
	fi
}

# Original frame regen from the .bak file
function original_frame_regen {
        cp "$BAK_FRAME" "$ORIGIN_FRAME"
        if [ -e "$ORIGIN_FRAME" ]; then
                echo "$ORIGIN_FRAME has been found."
                #sleep 3
        else
                echo "Creation of file $ORIGIN_FRAME has failed, you should download again the repo :"
		echo "https://github.com/enzomech/motoWelcomeSc"
		echo "Exitting the config now..."
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


	# START OF THE SCRIPT
# Init the vars first
init_vars

# Try to find the last frame that should have already been generated if the frame_gen has already been launched since the last index customisation or if there is a surplus of frames
end_index_test=$((END_INDEX + 1))
if [[ ! -f "${FRAMES_DIR}/${PREFIX_NAME}${END_INDEX}.txt" || -f "${FRAMES_DIR}/${PREFIX_NAME}${end_index_test}.txt" ]]; then
	frame_gen
fi

# Finally running the animation script
moto_run

exit

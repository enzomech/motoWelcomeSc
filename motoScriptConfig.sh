#!/bin/bash

# Vars of the default nb of frame, used by autoconfig for example
DEFAULT_FRAME_NB=120
temp_frame_nb=0
# Vars of the speed of the animation
DEFAULT_SPEED_NB=0.02
temp_speed_nb=0
# Temporary vars used for listening user interaction
answer_bool=""
return_answer=""

	# Directories used by the script
# Script's root directory
SCRIPT_DIR=$(dirname "$(realpath "$0")")
# Main script of the animation
RUN_SCRIPT="$SCRIPT_DIR/motoScript.sh"
# Shared vars file
VARS_FILE="$SCRIPT_DIR/scriptVars.sh"


# Function used to see if the speed_nb var (floating var) is equal to zero, without needing installing any packages used for this kind of operation
function is_zero() {
    local val="$1"
    # Remove leading zeros and the decimal point
    val="${val#0}"       # Strip leading zero
    val="${val/./}"      # Remove the decimal point
    [[ "$val" -eq 0 ]]   # Check if the result is zero
}

# Var init from the scriptVars.sh or from the default value if not found
function vars_init {
	if [[ -f $VARS_FILE ]]; then
		echo "Values sourced by scriptVars.sh"
		source $VARS_FILE
		temp_frame_nb=$FRAME_NB
		temp_speed_nb=$SPEED_NB

		# Second test to be sure vars are correct, using complex if statement, checking if frame nb is equal to zero
		# Then using a function to test if speed nb (which is a float) is equal to zero but to make it understandable to bash, we need to split this in another double pipe comparator (more like a bool condition)
		if [[ "$temp_frame_nb" -eq 0 || $(is_zero "$temp_speed_nb" && echo true || echo false) == "true" ]]; then
			echo "$VARS_FILE found, but values were null, temporary initialising the values by default settings for the config"
			temp_frame_nb=$DEFAULT_FRAME_NB
			temp_speed_nb=$DEFAULT_SPEED_NB
		fi
	else
		echo "$VARS_FILE not found, temporary initialising the values by default settings for the config"
		temp_frame_nb=$DEFAULT_FRAME_NB
		temp_speed_nb=$DEFAULT_SPEED_NB
	fi
}

# Function exporting vars to the shared vars script, ready to be used by the main script
function vars_export {
	cat <<EOL > scriptVars.sh
FRAME_NB="$temp_frame_nb"
SPEED_NB="$temp_speed_nb"
EOL
}

# Function to validate the integer answer (take a min and max answer argument as well)
function validate_answer() {
	local min=$1
	local max=$2
	local answer=""

	while true; do
	answer=""
	# Prompt the user for an answer
	read -p "Please enter an integer between $min and $max: " answer
	# Check if the answer is an integer and within the range
	if [[ "$answer" =~ ^[0-9]+$ ]] && ((answer >= min && answer <= max)); then
		return_answer="$answer"
		break
	fi
	answer=""
	done
}

# Function to show a test of the position for the user
function test_position {
	cp  $SCRIPT_DIR/motoRun/motoRun1.txt.bak $SCRIPT_DIR/motoRun/motoRunTest.txt
	local file=$SCRIPT_DIR/motoRun/motoRunTest.txt
	# Create a string with the specified number of spaces
	local spaces=$(printf '%*s' "$temp_frame_nb" '')

    	# Add spaces to each line and overwrite the file
    	sed -e "s/^/${spaces}/" "$file" > "${file}.tmp" && mv "${file}.tmp" "$file"
	cat $file
	echo -e "\n\n\n\n\n"
	echo "Now here is a test so you can see if the model is correctly placed, the model should be as far right as possible, but beware that the model should not cross the end of the right of your screen"
	rm $file
}

# Function to show a test of the speed animation for the user
function test_speed {
	case "$return_answer" in
		1)
			echo "So you have all of your time huh ?"
			temp_speed_nb=0.1
			;;
		2)
			echo "You selected a slow speed option."
			temp_speed_nb=0.5
			;;
		3)
			echo "Alright busy guy, let's test that."
			temp_speed_nb=0.02
			;;
		*)
			echo "Invalid input. Aborting the config script..."
			;;
	esac
	answer_bool=""
	return_answer=""
	echo "Test launch in 3s"
	sleep 3
	# Now exporting the vars to have the corrects values for testing the script
	vars_export
	clear
	bash $RUN_SCRIPT
}

function add_to_bashrc {
	# Check if the script path is already in .bashrc
	if grep -Fxq "$RUN_SCRIPT" ~/.bashrc; then
		echo "The script is already in .bashrc. No changes made."
	else
        	# Add the script path to .bashrc
		echo ""  >> ~/.bashrc
		echo "#Moto Script" >> ~/.bashrc
        	echo "$RUN_SCRIPT" >> ~/.bashrc
		echo "alias motoRun='$RUN_SCRIPT'" >> ~/.bashrc
		echo "alias motoConf='$(realpath "$0")'" >> ~/.bashrc
		echo "Added $RUN_SCRIPT to .bashrc."
		echo "Added alias to .bashrc, now you can use 'motoRun' cmd to start the script or 'motoConf' to start again the config script"
		echo "If you want to test it now you can do so by refreshing your bashrc : source ~/.bashrc"
	fi
}


	# START OF THE SCRIPT
# Initialisation of the vars
vars_init

echo "Hi and thank you for downloading my litle script !"
echo "You can choose between a fast and auto config, or a guided custom one adapting to your screen resolution and animation speed preference"
echo "Do you want to custom the script ? (y or n)"

read answer_bool
while [ "$answer_bool" != "y" ] && [ "$answer_bool" != "n" ]
do
        echo "Do you want to custom the script ? (y or n)"
        read answer_bool
done

# Fast config using default frame and fast speed preset, and writting it in bashrc
if [ "$answer_bool" = "n" ]; then
	vars_export
	add_to_bashrc
	echo "The configuration is done, thank you and ride safe"
	exit
else
	answer_bool=""
fi

# First part of the customisation is to modify the resolution of the animation
echo "Starting custom configuration"
echo "You need to select how much frames you want in your animation, more frames is equal to a wider screen"
echo "Take care of the inconvenient of having too much frames, it will cause the animation to not run properly, but you can test it to your desire with this script"
echo "Current frame number is $temp_frame_nb"
echo "How much frames do you want ?"

answer_bool=""
# Start a loop that should finish when the user is satisfied with the position of the model
while [ "$answer_bool" != "y" ]
do
	answer_bool=""

	# Try to get a valid integer for the configuration
	return_answer=""
	validate_answer 1 300
	temp_frame_nb=$return_answer
	# Show a test of the model
	test_position
	while [ "$answer_bool" != "y" ] && [ "$answer_bool" != "n" ]
	do
		echo "Are you satisfied with the current position of the model ? (y or n)"
	        read answer_bool
	done
done

# Second part of the customisation is to modify the speed of the animation
clear
echo "Next step is to modify the speed of the animation"
echo "You will have to choose from 1 to 3, where 1 is a very slow animation, and 3 a rapid one, you can test it again after"
echo "How fast do you want it ?"

answer_bool=""
# Start a loop that should finish when the user is satisfied with the speed of the animation
while [ "$answer_bool" != "y" ]
do
        # Try to get a valid integer for the configuration
	return_answer=""
        validate_answer 1 3
        temp_speed_nb=$return_answer
        # Test the final animation
        test_speed
        while [ "$answer_bool" != "y" ] && [ "$answer_bool" != "n" ]
        do
                echo "Are you satisfied with the current speed of the animation ? (y or n)"
                read answer_bool
        done
done

# Finaly test and add the main script in the bashrc if necessary
add_to_bashrc

echo "The configuration is done, thank you and ride safe"

exit

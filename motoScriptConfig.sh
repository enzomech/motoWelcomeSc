#!/bin/bash

DEFAULT_FRAME_NB=121
temp_frame_nb=0

DEFAULT_SPEED_NB=0.02
temp_speed_nb=0

answer_bool=""
return_answer=""


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

function test_position {
	cp  $(dirname "$(realpath "$0")")/motoRun/motoRun1.txt.bak motoRunTest.txt
	local file=motoRunTest.txt
	# Create a string with the specified number of spaces
	local spaces=$(printf '%*s' "$temp_frame_nb" '')

    	# Add spaces to each line and overwrite the file
    	sed -e "s/^/${spaces}/" "$file" > "${file}.tmp" && mv "${file}.tmp" "$file"
	cat $file
	echo -e "\n\n\n\n\n"
	echo "Now here is a test so you can see if the model is correctly placed, the model should be as far right as possible, but beware that the model should not cross the end of the right of your screen"
}

# Var init from the scriptVars.sh or from the default value if not found
if [[ -f scriptVars.sh ]]; then
	echo "Values sourced by scriptVars.sh"
	source scriptVars.sh
else
	echo "scriptVars.sh not found, initialising the values by default settings"
	temp_frame_nb=$DEFAULT_FRAME_NB
	temp_speed_nb=$DEFAULT_SPEED_NB
fi


echo "Hi and thank you for downloading my litle script !"
echo "You can choose between a fast and auto config, or a guided custom one adapting to your screen resolution and animation speed preference"
echo "Do you want to custom the script ? (y or n)"

read answer_bool
while [ "$answer_bool" != "y" ] && [ "$answer_bool" != "n" ]
do
        echo "Do you want to custom the script ? (y or n)"
        read answer_bool
done

if [ "$answer_bool" = "n" ]; then
	#fast config
	echo "Config is done"
	exit
else
	answer_bool=""
fi

echo "Starting custom configuration"
echo "You need to select how much frames you want in your animation, more frames is equal to a wider screen"
echo "Take care of the inconvenient of having too much frames, it will cause the animation to not run properly, but you can test it to your desire"
echo "Current frame number is $temp_frame_nb"
echo "How much frames do you want ?"

# Start a loop that should finish when the user is satisfied with the position of the model
while [ "$answer_bool" != "y" ]
do
	answer_bool=""

	# Try to get a valid integer for the configuration
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

# Now removing the useless file and exporting vars to the shared vars script, ready to be used by the main script
rm motoRunTest.txt
cat <<EOL > scriptVars.sh
FRAME_NB="$temp_frame_nb"
SPEED_NB="$temp_speed_nb"
EOL


echo $return_answer

exit

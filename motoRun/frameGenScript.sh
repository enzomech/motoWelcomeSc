#!/bin/bash

# Chemin pour relancer le script proprement
#(bash "$(realpath "$0")")


# Nom initial du fichier
fileOrigin="motoRun1.txt"
file_prefix="motoRun"
start_index=1
end_index=121


# Fonction pour regénérer les frames si il y a eu un problème
function original_frame_regen {

        echo "Le fichier originel motoRun1 n'a pas été trouvé."
	echo "Souhaitez vous essayer de regénérer les frames ? (o/n ?)"

	read answer
	while [ "$answer" != "o" ] && [ "$answer" != "n" ]
	do
        	echo "Souhaitez vous essayer de regénérer les frames ? (o/n ?)"
        	read answer
	done

	if [ "$answer" = "n" ]; then
        	exit
	fi

	cp motoRun1.bak motoRun1.txt

	if [ -e "$fileOrigin" ]; then
		echo "Le fichier $fileOrigin a été correctement créé, le script va redémarrer dans 3s."
		sleep 3
#		(bash "$(realpath "$0")")
		exit
	else
		echo "Le fichier $fileOrigin n'existe toujours pas, echec de la regénération des frames."
		exit
	fi
}

echo "ce message doit s'afficher en tout premier"

# Boucle pour créer les fichiers incrémentés
for ((i=start_index; i<end_index; i++)); do
    current_file="${file_prefix}${i}.txt"
    next_file="${file_prefix}$((i+1)).txt"

    # Vérifie si le fichier actuel existe
    if [[ -f "$current_file" ]]; then
        # Ajoute un espace au début de chaque ligne et écrit dans le fichier suivant
        sed 's/^/ /' "$current_file" > "$next_file"
    else
	original_frame_regen
    fi
done
exit



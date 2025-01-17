#!/bin/bash

# Fonction pour afficher l'utilisation du script
usage() {
    echo "Usage: $0 [react|angular] project_name"
    exit 1
}

# Vérifier les arguments
if [ $# -ne 2 ]; then
    usage
fi

FRAMEWORK=$1
PROJECT_NAME=$2

# Vérifier le framework choisi
if [ "$FRAMEWORK" != "react" ] && [ "$FRAMEWORK" != "angular" ]; then
    usage
fi

# Fonction pour créer la structure de projet React
create_react_structure() {
    npx create-react-app $PROJECT_NAME

    cd $PROJECT_NAME || exit
    mkdir -p src/components src/pages src/assets src/services
    touch src/components/.gitkeep src/pages/.gitkeep src/assets/.gitkeep src/services/.gitkeep

    echo "Structure de projet React créée avec succès."
}

# Fonction pour créer la structure de projet Angular
create_angular_structure() {
    npx @angular/cli new $PROJECT_NAME --style=scss --routing

    cd $PROJECT_NAME || exit
    mkdir -p src/app/components src/app/pages src/app/assets src/app/services
    touch src/app/components/.gitkeep src/app/pages/.gitkeep src/app/assets/.gitkeep src/app/services/.gitkeep

    echo "Structure de projet Angular créée avec succès."
}

# Exécuter la fonction appropriée selon le framework
if [ "$FRAMEWORK" == "react" ]; then
    create_react_structure
else
    create_angular_structure
fi

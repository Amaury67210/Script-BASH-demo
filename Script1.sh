#!/bin/bash

# URL de base de l'API JSON Placeholder (Fausse API gratuite pour les tests et le prototypage)
base_api_url="https://jsonplaceholder.typicode.com/users"

# Fonction pour afficher une erreur et quitter le script
function handle_error {
    echo "Erreur: $1"
    exit 1
}

# Boucle pour obtenir les informations de chaque utilisateur contenu dans l'API
for user_id in {1..10}; do

    api_url="$base_api_url/$user_id"

    response=$(curl -s "$api_url")

    if [ $? -ne 0 ]; then
        handle_error "La requête a échoué pour l'utilisateur $user_id."
    fi

    if ! jq -e '.username, .email, .phone, .website, .address.street, .address.suite, .address.city' <<< "$response" > /dev/null; then
        handle_error "La structure de la réponse JSON pour l'utilisateur $user_id est incorrecte."
    fi

    username=$(echo "$response" | jq -r '.username')
    email=$(echo "$response" | jq -r '.email')
    phone=$(echo "$response" | jq -r '.phone')
    website=$(echo "$response" | jq -r '.website')
    
    street=$(echo "$response" | jq -r '.address.street')
    suite=$(echo "$response" | jq -r '.address.suite')
    city=$(echo "$response" | jq -r '.address.city')

    postal_code=$(echo "$response" | jq -r '.address.zipcode' | grep -oE '[0-9]{5}')
    
    phone_no_spaces=$(echo "$phone" | sed 's/[[:space:]-]//g; s/[\.\(\)]/ /g')

    formatted_phone=$(echo "$phone_no_spaces" | awk '{print substr($0, 1, 2) " " substr($0, 3, 2) " " substr($0, 5, 2) " " substr($0, 7, 2) " " substr($0, 9, 2) " " substr($0, 11)}')

    echo "ID Utilisateur: $user_id"
    echo "Nom d'utilisateur: $username"
    echo "Email: $email"
    echo "Numéro de téléphone: $formatted_phone"
    echo "Site internet: $website"
    echo "Adresse: $street, $suite, $city, $postal_code"
    echo "---------------------------"
done

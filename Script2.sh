#!/bin/bash

# Nom du fichier de base de données
database_file="chinook.db"

# Vérifier si la commande sqlite3 est disponible
if ! command -v sqlite3 &> /dev/null; then
    echo "Erreur : La commande sqlite3 n'est pas disponible. Veuillez l'installer."
    exit 1
fi

# Vérifier si le fichier de base de données existe
if [ ! -f "$database_file" ]; then
    echo "Erreur : Le fichier de base de données '$database_file' n'existe pas dans le répertoire actuel."
    exit 1
fi

insert_query="INSERT INTO customers (FirstName, LastName, Company, Address, City, State, Country, PostalCode, Phone, Email, SupportRepID, CustomerId) VALUES ('Amaury', 'Sensenbrenner', 'Alsace compagny', '17 Rue de Rosheim', 'Strasbourg', 'CA', 'FR', '67000', '+636814218', 'amaury67210@outlook.fr', 3, 1000);"

sqlite3 "$database_file" "$insert_query"

echo "------------------------"
echo "Ligne insérée."

sql_query="SELECT * FROM customers WHERE FirstName = 'Amaury' AND LastName = 'Sensenbrenner';"

result=$(sqlite3 "$database_file" "$sql_query")

echo "Résultats de la requête :"
echo "$result"

delete_query="DELETE FROM customers WHERE FirstName = 'Amaury' AND LastName = 'SensenbrennerF';"

sqlite3 "$database_file" "$delete_query"

echo "Ligne supprimée."
echo "------------------------"

# -----------------------------------------

echo "------------------------"

sql_query="SELECT * FROM customers WHERE CustomerId = 1;"

result=$(sqlite3 "$database_file" "$sql_query")

echo "Résultats de la requête :"
echo "$result"

update_query="UPDATE customers SET FirstName = 'Matthéo' WHERE CustomerId = 1;"

sqlite3 "$database_file" "$update_query"

echo "Ligne modifiée."

sql_query="SELECT * FROM customers WHERE CustomerId = 1;"

result=$(sqlite3 "$database_file" "$sql_query")

echo "Résultats de la requête :"
echo "$result"

update_query="UPDATE customers SET FirstName = 'Luís' WHERE CustomerId = 1;"

sqlite3 "$database_file" "$update_query"

echo "Ligne remodifiée"

sql_query="SELECT * FROM customers WHERE CustomerId = 1;"

result=$(sqlite3 "$database_file" "$sql_query")

echo "Résultats de la requête :"
echo "$result"

echo "------------------------"

# -----------------------------------------

sql_query="SELECT * FROM customers LIMIT 5;"

# Vérifier si la requête SQL est définie
if [ -z "$sql_query" ]; then
    echo "Erreur : Aucune requête SQL définie."
    exit 1
fi

sqlite3 -separator ' | ' -header "$database_file" "$sql_query" | while IFS=' | ' read -r col1 col2 col3 col4 col5 col6 col7 col8 col9 col10 col11 col12 col13 col14 col15; do
    echo "ID: $col1"
    echo "Nom: $col2"
    echo "Prénom: $col3"
    echo "Compagnie: $col4"
    echo "Adresse: $col5"
    echo "Ville: $col6"
    echo "État: $col7"
    echo "Pays: $col8"
    echo "Code postal: $col9"
    echo "Téléphone: $col10"
    echo "Fax: $col11"
    echo "Courriel: $col12"
    echo "ID du support: $col13"
    echo "Assistance: $col14"
    echo "Client: $col15"
    echo "------------------------"
done

output_file="result.txt"
output_file_2="result2.txt"

# Requête : Calcul de la moyenne des prix des pistes par genre
sqlite3 "$database_file" <<EOF > $output_file
.mode column
.headers on

SELECT 
    genres.name AS Genre,
    AVG(tracks.unitprice) AS AveragePrice
FROM 
    genres
JOIN 
    tracks ON genres.genreid = tracks.genreid
GROUP BY 
    genres.genreid
ORDER BY 
    AveragePrice DESC;
EOF

cat $output_file

echo "  " >> $output_file
echo "# Requête : Calcul de la moyenne des prix des pistes par genre" >> $output_file

# Requête : Artistes avec le plus grand nombre de pistes
sqlite3 "$database_file" <<EOF > $output_file_2
.mode column
.headers on

SELECT 
    artists.Name AS Artist,
    COUNT(tracks.TrackId) AS TrackCount
FROM 
    artists
JOIN 
    albums ON artists.ArtistId = albums.ArtistId
JOIN 
    tracks ON albums.AlbumId = tracks.AlbumId
GROUP BY 
    artists.ArtistId
ORDER BY 
    TrackCount DESC
LIMIT 5;
EOF

cat $output_file_2

echo "  " >> $output_file_2
echo "# Requête : Artistes avec le plus grand nombre de pistes" >> $output_file_2

# Remove des fichiers texte
# rm $output_file
# rm $output_file_2

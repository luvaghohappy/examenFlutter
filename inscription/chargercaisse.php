<?php
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: GET");
header("Access-Control-Allow-Headers: *");
// Inclusion du fichier connect.php qui contient la connexion à la base de données
include('conn.php');

// Point de terminaison pour récupérer les données de la table paiement
if ($_SERVER['REQUEST_METHOD'] === 'GET') {
    // Requête SQL pour sélectionner uniquement les champs 'matricule', 'montant' et 'DatePaiement' de la table 'paiement'
    $rqt = "SELECT matricule, montant, DatePaiement FROM paiement";

    // Exécution de la requête SQL
    $rqt2 = mysqli_query($connect, $rqt) OR die("Erreur d'exécution de la requête : " . mysqli_error($connect));

    // Initialisation d'un tableau pour stocker les résultats de la requête
    $result = array();

    // Parcours des résultats de la requête et stockage dans le tableau $result
    while ($fetchData = $rqt2->fetch_assoc()) {
        $result[] = $fetchData;
    }

    // Conversion du tableau en format JSON et affichage
    echo json_encode($result);
}
?>
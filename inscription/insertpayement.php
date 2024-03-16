<?php
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: GET, POST, OPTIONS");
header("Access-Control-Allow-Headers: *");
include('conn.php');

// Récupération des données du formulaire, en les protégeant contre les attaques XSS
$matricule = htmlspecialchars($_POST["matricule"]);
$nom = htmlspecialchars($_POST["nom"]);
$postnom = htmlspecialchars($_POST["postnom"]);
$prenom = htmlspecialchars($_POST["prenom"]);
$classe = htmlspecialchars($_POST["classe"]);
$motif = htmlspecialchars($_POST["MotifPaiement"]);
$montant = htmlspecialchars($_POST["montant"]);
$date = htmlspecialchars($_POST["DatePaiement"]);



// Requête SQL pour insérer les données dans la table 'etudiants'
$sql = "INSERT INTO paiement (matricule,nom,postnom,prenom,classe,MotifPaiement,montant,DatePaiement) 
VALUES ('$matricule','$nom','$postnom','$prenom','$classe','$motif','$montant','$date')";

if(mysqli_query($connect, $sql)){
    echo json_encode("success");
}else{
    echo json_encode("failed");
}
// Exécution de la requête SQL

?>
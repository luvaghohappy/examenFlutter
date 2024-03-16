-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Hôte : 127.0.0.1
-- Généré le : sam. 16 mars 2024 à 08:45
-- Version du serveur : 10.4.28-MariaDB
-- Version de PHP : 8.0.28

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Base de données : `dbinscription`
--

DELIMITER $$
--
-- Procédures
--
CREATE DEFINER=`root`@`localhost` PROCEDURE `updateSoldeProcedure` (IN `new_matricule` VARCHAR(255), IN `new_montant` DECIMAL(10,2), IN `new_datePaiement` DATE)   BEGIN
    DECLARE existingRecord INT;

    -- Vérifiez si un enregistrement pour le même élève existe déjà dans la table de solde
    SELECT COUNT(*) INTO existingRecord FROM solde WHERE matricule = new_matricule;

    IF existingRecord > 0 THEN
        -- Mettez à jour le montant total et la date du dernier paiement
        UPDATE solde
        SET somme = somme + new_montant,
            Datepayement = new_datePaiement
        WHERE matricule = new_matricule;
    ELSE
        -- Insérez les nouvelles données dans la table de solde
        INSERT INTO solde (matricule, somme, Datepayement) VALUES (new_matricule, new_montant, new_datePaiement);
    END IF;
END$$

DELIMITER ;

-- --------------------------------------------------------

--
-- Structure de la table `caisse`
--

CREATE TABLE `caisse` (
  `id` int(11) NOT NULL,
  `matricule` varchar(100) NOT NULL,
  `montant` float NOT NULL,
  `DateCaisse` date NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Déchargement des données de la table `caisse`
--

INSERT INTO `caisse` (`id`, `matricule`, `montant`, `DateCaisse`) VALUES
(1, 'B1', 40, '2024-03-08'),
(2, 'C1', 20, '2024-03-08'),
(3, 'B1', 80, '2024-03-10'),
(4, 'C1', 100, '2024-03-10'),
(5, 'D1', 30, '2024-03-10'),
(6, 'D1', 70, '2024-03-09');

--
-- Déclencheurs `caisse`
--
DELIMITER $$
CREATE TRIGGER `caissier_delete` AFTER DELETE ON `caisse` FOR EACH ROW BEGIN
    INSERT INTO operation (service, date_heure)
    VALUES ('Caissier: Suppression dans la table caisse', NOW());
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `caissier_insertion` AFTER INSERT ON `caisse` FOR EACH ROW BEGIN
    INSERT INTO operation (service, date_heure)
    VALUES ('Caissier: Insertion dans la table caisse', NOW());
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `caissier_update` AFTER UPDATE ON `caisse` FOR EACH ROW BEGIN
    INSERT INTO operation (service, date_heure)
    VALUES ('Caissier: Modification dans la table caisse', NOW());
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `calculer_montant_total_journalier` AFTER INSERT ON `caisse` FOR EACH ROW BEGIN
    DECLARE date_transaction DATE;
    DECLARE total_montant DECIMAL(10,2);

    -- Récupérer la date de la transaction
    SET date_transaction = NEW.DateCaisse;

    -- Calculer le total des montants pour cette date
    SELECT SUM(montant) INTO total_montant
    FROM caisse
    WHERE DateCaisse = date_transaction;

    -- Mettre à jour le champ montanttotal dans la table rapportcaisse
    -- Si aucune entrée pour cette date n'existe, insérer une nouvelle ligne
    IF EXISTS (SELECT 1 FROM rapportcaisse WHERE Dates = date_transaction) THEN
        UPDATE rapportcaisse
        SET MontantTotal = total_montant
        WHERE Dates = date_transaction;
    ELSE
        INSERT INTO rapportcaisse (Dates, MontantTotal)
        VALUES (date_transaction, total_montant);
    END IF;
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Structure de la table `classe`
--

CREATE TABLE `classe` (
  `id` int(11) NOT NULL,
  `designation` varchar(100) NOT NULL,
  `section` varchar(100) NOT NULL,
  `options` varchar(100) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Déchargement des données de la table `classe`
--

INSERT INTO `classe` (`id`, `designation`, `section`, `options`) VALUES
(7, '7ieme', 'elementaire', 'elementaire'),
(8, '8ieme', 'elementaire', 'elementaire'),
(10, '1iere', 'technique', 'commercial'),
(11, '2ieme', 'technique  ', 'commercial');

-- --------------------------------------------------------

--
-- Structure de la table `eleve`
--

CREATE TABLE `eleve` (
  `id` int(11) NOT NULL,
  `matricule` varchar(100) NOT NULL,
  `nom` varchar(100) NOT NULL,
  `postnom` varchar(50) NOT NULL,
  `prenom` varchar(50) NOT NULL,
  `classe` varchar(100) NOT NULL,
  `section` varchar(100) NOT NULL,
  `options` varchar(100) NOT NULL,
  `AnneScolaire` varchar(100) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Déchargement des données de la table `eleve`
--

INSERT INTO `eleve` (`id`, `matricule`, `nom`, `postnom`, `prenom`, `classe`, `section`, `options`, `AnneScolaire`) VALUES
(12, '11A ', 'kasoki', 'luvagho', 'furaha', '7ieme', 'elementaire', 'elemenatire', '2020-2021'),
(15, '11B', 'moise', 'musa', 'moise', '8ieme', 'elementaire', 'elementaire', '2020-2021'),
(16, '11A', 'kasoki', 'luvagho', 'furaha', '7ieme', 'elementaire', 'elementaire', '2020-2021');

--
-- Déclencheurs `eleve`
--
DELIMITER $$
CREATE TRIGGER `secretaire_delete` AFTER DELETE ON `eleve` FOR EACH ROW BEGIN
    INSERT INTO operation (service, date_heure)
    VALUES ('Secretaire: Suppression dans la table eleve', NOW());
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `secretaire_insertion` AFTER INSERT ON `eleve` FOR EACH ROW BEGIN
    INSERT INTO operation (service, date_heure)
    VALUES ('Secretaire : Insertion dans la table eleve', NOW());
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `secretaire_update` AFTER UPDATE ON `eleve` FOR EACH ROW BEGIN
    INSERT INTO operation (service, date_heure)
    VALUES ('Secretaire:Modification dans la table eleve', NOW());
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Structure de la table `identification`
--

CREATE TABLE `identification` (
  `id` int(11) NOT NULL,
  `nom` varchar(100) NOT NULL,
  `postnom` varchar(100) NOT NULL,
  `prenom` varchar(50) NOT NULL,
  `sexe` char(10) NOT NULL,
  `DateNaissance` date NOT NULL,
  `LieuNaissance` varchar(100) NOT NULL,
  `EtatCivil` varchar(50) NOT NULL,
  `Adresse` varchar(150) NOT NULL,
  `Telephone` varchar(50) NOT NULL,
  `NomPere` varchar(50) NOT NULL,
  `NomMere` varchar(50) NOT NULL,
  `ProvOrigine` varchar(100) NOT NULL,
  `Territoire` varchar(50) NOT NULL,
  `EcoleProv` varchar(100) NOT NULL,
  `Dossier` varchar(100) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Déchargement des données de la table `identification`
--

INSERT INTO `identification` (`id`, `nom`, `postnom`, `prenom`, `sexe`, `DateNaissance`, `LieuNaissance`, `EtatCivil`, `Adresse`, `Telephone`, `NomPere`, `NomMere`, `ProvOrigine`, `Territoire`, `EcoleProv`, `Dossier`) VALUES
(2, 'happy', 'luvagho', 'kasoki', 'F', '2024-02-07', 'kirumba', 'celibataire', 'majengo', '+243999582152', 'kabuyaya', 'desange', 'nord-kivu', 'lubero', 'Wapole', 'Certificat'),
(3, 'moise', 'musa', 'moses', 'M', '2024-02-08', 'bunia', 'celibataire', 'majengo', '+2439879000', 'kakule', 'kahindo', 'ituri', 'Bunia', 'charite', 'certificat'),
(5, 'ungwa', 'justine', 'blessing', 'F', '2024-03-03', 'goma', 'mariee', 'himbi', '+243988990', 'muigi', 'mwanza', 'NK', 'nyiragongo', 'amani', 'diplome,bulletin'),
(6, 'moise', 'muhindo', 'musa', 'F', '2024-03-09', 'beni', 'marie', 'katoyi', '+909877655', 'monpere', 'mamere', 'ituri', 'bunia', 'racine', 'certificat'),
(7, 'kwanza', 'mwisho', 'bertin', 'M', '2024-03-10', 'goma', 'marie', 'majengo', '+0987876', 'monpere', 'mamere', 'ituri', 'beni', 'mwanga', 'certficat');

-- --------------------------------------------------------

--
-- Structure de la table `operation`
--

CREATE TABLE `operation` (
  `id` int(11) NOT NULL,
  `service` varchar(100) NOT NULL,
  `date_heure` datetime NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Déchargement des données de la table `operation`
--

INSERT INTO `operation` (`id`, `service`, `date_heure`) VALUES
(1, 'Caissier: Insertion dans la table caisse', '2024-03-11 11:55:49'),
(2, 'Caissier: Insertion dans la table caisse', '2024-03-11 11:55:50'),
(3, 'Caissier: Insertion dans la table caisse', '2024-03-11 11:55:50'),
(4, 'Caissier: Insertion dans la table caisse', '2024-03-11 11:55:50'),
(5, 'Caissier: Insertion dans la table caisse', '2024-03-11 11:55:50'),
(6, 'Caissier: Insertion dans la table caisse', '2024-03-11 11:55:50'),
(7, 'Comptable : Modification dans la table paiement', '2024-03-13 11:25:56'),
(8, 'Caissier: Insertion dans la table caisse', '2024-03-14 14:11:06'),
(9, 'Caissier: Insertion dans la table caisse', '2024-03-14 14:11:06'),
(10, 'Caissier: Insertion dans la table caisse', '2024-03-14 14:11:06'),
(11, 'Caissier: Insertion dans la table caisse', '2024-03-14 14:11:06'),
(12, 'Caissier: Insertion dans la table caisse', '2024-03-14 14:11:07'),
(13, 'Caissier: Insertion dans la table caisse', '2024-03-14 14:11:07'),
(14, 'Caissier: Insertion dans la table caisse', '2024-03-14 14:12:02'),
(15, 'Caissier: Insertion dans la table caisse', '2024-03-14 14:12:02'),
(16, 'Caissier: Insertion dans la table caisse', '2024-03-14 14:12:02'),
(17, 'Caissier: Insertion dans la table caisse', '2024-03-14 14:12:02'),
(18, 'Caissier: Insertion dans la table caisse', '2024-03-14 14:12:03'),
(19, 'Caissier: Insertion dans la table caisse', '2024-03-14 14:12:03');

-- --------------------------------------------------------

--
-- Structure de la table `paiement`
--

CREATE TABLE `paiement` (
  `id` int(11) NOT NULL,
  `matricule` varchar(100) NOT NULL,
  `nom` varchar(50) NOT NULL,
  `postnom` varchar(50) NOT NULL,
  `prenom` varchar(50) NOT NULL,
  `classe` varchar(40) NOT NULL,
  `MotifPaiement` varchar(50) NOT NULL,
  `montant` float NOT NULL,
  `DatePaiement` date NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Déchargement des données de la table `paiement`
--

INSERT INTO `paiement` (`id`, `matricule`, `nom`, `postnom`, `prenom`, `classe`, `MotifPaiement`, `montant`, `DatePaiement`) VALUES
(2, 'B1', 'muhindo', 'moise', 'moses', '8ieme', 'frais inscription', 40, '2024-03-08'),
(3, 'C1', 'nyota', 'ungwa', 'justine', '1iere', 'frais incsription', 20, '2024-03-08'),
(5, 'B1', 'muhindo', 'moise', 'moses', '8ieme', 'frais scolaire', 80, '2024-03-10'),
(6, 'C1', 'ungwa', 'nyota', 'justine', '1iere', 'frais scolaire', 100, '2024-03-10'),
(7, 'D1', 'blessing', 'kahindo', 'happy', '2ieme', 'frais scolaire', 30, '2024-03-10'),
(8, 'D1', 'blessing', 'kahindo', 'happy', '2ieme', 'frais scolaire', 70, '2024-03-09');

--
-- Déclencheurs `paiement`
--
DELIMITER $$
CREATE TRIGGER `comptable_delete` AFTER DELETE ON `paiement` FOR EACH ROW BEGIN
    INSERT INTO operation (service, date_heure)
    VALUES ('Comptable :Suppression dans la table paiement', NOW());
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `comptable_update` AFTER UPDATE ON `paiement` FOR EACH ROW BEGIN
    INSERT INTO operation (service, date_heure)
    VALUES ('Comptable : Modification dans la table paiement', NOW());
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `insertion` AFTER INSERT ON `paiement` FOR EACH ROW BEGIN
    INSERT INTO operation (service, date_heure)
    VALUES ('Comptable : Insertion dans la table paiement', NOW());
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `updateSoldeAfterInsert` AFTER INSERT ON `paiement` FOR EACH ROW BEGIN
    -- Appeler la procédure stockée pour mettre à jour le solde
    CALL updateSoldeProcedure(NEW.matricule, NEW.montant, NEW.DatePaiement);
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Structure de la table `rapportcaisse`
--

CREATE TABLE `rapportcaisse` (
  `id` int(11) NOT NULL,
  `MontantTotal` float NOT NULL,
  `solde` float NOT NULL,
  `Dates` datetime NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Déchargement des données de la table `rapportcaisse`
--

INSERT INTO `rapportcaisse` (`id`, `MontantTotal`, `solde`, `Dates`) VALUES
(2, 60, 0, '2024-03-08 00:00:00'),
(3, 210, 0, '2024-03-10 00:00:00'),
(4, 70, 0, '2024-03-09 00:00:00');

--
-- Déclencheurs `rapportcaisse`
--
DELIMITER $$
CREATE TRIGGER `calculer_difference` AFTER INSERT ON `rapportcaisse` FOR EACH ROW BEGIN
    DECLARE montant_hier DECIMAL(10, 2);
    DECLARE difference DECIMAL(10, 2);
    
    -- Récupérer le MontantTotal d'hier
    SELECT MontantTotal INTO montant_hier
    FROM rapportcaisse
    WHERE Dates = DATE_SUB(NEW.Dates, INTERVAL 1 DAY);

    -- Calculer la différence
    IF montant_hier IS NOT NULL THEN
        SET difference = NEW.MontantTotal - montant_hier;
    ELSE
        SET difference = NEW.MontantTotal;
    END IF;

    -- Mettre à jour le champ Solde
    UPDATE rapportcaisse
    SET Solde = difference
    WHERE id = NEW.id;
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Structure de la table `recouvrement`
--

CREATE TABLE `recouvrement` (
  `id` int(11) NOT NULL,
  `nom` varchar(100) NOT NULL,
  `postnom` varchar(100) NOT NULL,
  `prenom` varchar(50) NOT NULL,
  `classe` varchar(50) NOT NULL,
  `montant` float NOT NULL,
  `Total` float NOT NULL,
  `DateRecouvrement` date NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Déchargement des données de la table `recouvrement`
--

INSERT INTO `recouvrement` (`id`, `nom`, `postnom`, `prenom`, `classe`, `montant`, `Total`, `DateRecouvrement`) VALUES
(1, 'muhindo', 'moise', 'moses', '8ieme', 40, 120, '2024-03-13'),
(2, 'muhindo', 'moise', 'moses', '8ieme', 80, 120, '2024-03-13'),
(3, 'muhindo', 'moise', 'moses', '8ieme', 40, 120, '2024-03-13'),
(4, 'muhindo', 'moise', 'moses', '8ieme', 80, 120, '2024-03-13');

-- --------------------------------------------------------

--
-- Structure de la table `solde`
--

CREATE TABLE `solde` (
  `id` int(11) NOT NULL,
  `matricule` varchar(100) NOT NULL,
  `somme` float NOT NULL,
  `Datepayement` date NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Déchargement des données de la table `solde`
--

INSERT INTO `solde` (`id`, `matricule`, `somme`, `Datepayement`) VALUES
(1, 'A1', 130, '2024-03-10'),
(2, 'B1', 120, '2024-03-10'),
(3, 'C1', 120, '2024-03-10'),
(4, 'D1', 100, '2024-03-09');

-- --------------------------------------------------------

--
-- Structure de la table `user`
--

CREATE TABLE `user` (
  `id` int(11) NOT NULL,
  `email` varchar(100) NOT NULL,
  `passwords` varchar(100) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Déchargement des données de la table `user`
--

INSERT INTO `user` (`id`, `email`, `passwords`) VALUES
(2, 'sec@gmail.com', 'secretaire'),
(3, 'admin@gmail.com', 'Admin'),
(4, 'caisse@gmail.com', 'caissier'),
(7, 'compte@gmail.com', 'comptable');

--
-- Index pour les tables déchargées
--

--
-- Index pour la table `caisse`
--
ALTER TABLE `caisse`
  ADD PRIMARY KEY (`id`);

--
-- Index pour la table `classe`
--
ALTER TABLE `classe`
  ADD PRIMARY KEY (`id`);

--
-- Index pour la table `eleve`
--
ALTER TABLE `eleve`
  ADD PRIMARY KEY (`id`);

--
-- Index pour la table `identification`
--
ALTER TABLE `identification`
  ADD PRIMARY KEY (`id`);

--
-- Index pour la table `operation`
--
ALTER TABLE `operation`
  ADD PRIMARY KEY (`id`);

--
-- Index pour la table `paiement`
--
ALTER TABLE `paiement`
  ADD PRIMARY KEY (`id`);

--
-- Index pour la table `rapportcaisse`
--
ALTER TABLE `rapportcaisse`
  ADD PRIMARY KEY (`id`);

--
-- Index pour la table `recouvrement`
--
ALTER TABLE `recouvrement`
  ADD PRIMARY KEY (`id`);

--
-- Index pour la table `solde`
--
ALTER TABLE `solde`
  ADD PRIMARY KEY (`id`);

--
-- Index pour la table `user`
--
ALTER TABLE `user`
  ADD PRIMARY KEY (`id`);

--
-- AUTO_INCREMENT pour les tables déchargées
--

--
-- AUTO_INCREMENT pour la table `caisse`
--
ALTER TABLE `caisse`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=7;

--
-- AUTO_INCREMENT pour la table `classe`
--
ALTER TABLE `classe`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=12;

--
-- AUTO_INCREMENT pour la table `eleve`
--
ALTER TABLE `eleve`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=17;

--
-- AUTO_INCREMENT pour la table `identification`
--
ALTER TABLE `identification`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=8;

--
-- AUTO_INCREMENT pour la table `operation`
--
ALTER TABLE `operation`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=20;

--
-- AUTO_INCREMENT pour la table `paiement`
--
ALTER TABLE `paiement`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=9;

--
-- AUTO_INCREMENT pour la table `rapportcaisse`
--
ALTER TABLE `rapportcaisse`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

--
-- AUTO_INCREMENT pour la table `recouvrement`
--
ALTER TABLE `recouvrement`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

--
-- AUTO_INCREMENT pour la table `solde`
--
ALTER TABLE `solde`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

--
-- AUTO_INCREMENT pour la table `user`
--
ALTER TABLE `user`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=8;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;

/**
Requêtes SQL - SAE S2.04

---------------------------------------------------
/* SCHEMA RELATIONNEL

Compteur(numero (1), libelle, leQuartier = @Quartier.id)
Quartier(id (1), nomQuartier, longueurPiste)
Date(date (1), jour (NN), tempMoy, vacances)
Comptage([numCompteur = @Compteur.numero, laDate = @Date.date](1), nbVelo, probaAnomalie)
*/
---------------------------------------------------
*/

-- Question 1 : Quels sont les compteurs (numéro et libellé) situés dans le quartier "Centre-ville" ?
SELECT DISTINCT numero, libelle
FROM Compteur
    JOIN Quartier ON leQuartier = id
WHERE nomQuartier = 'Centre Ville';


-- Question 2 : Quels sont les quartiers qui ont la même longueur de piste cyclable ?
SELECT Q1.nomQuartier
FROM Quartier Q1, Quartier Q2
WHERE Q1.id != Q2.id
AND Q1.longueurPiste = Q2.longueurPiste;


-- Question 3 : Afficher tous les quartiers avec leurs compteurs, même ceux qui n'ont pas de compteurs.
SELECT numero, libelle, nomQuartier
FROM Compteur
    LEFT JOIN Quartier ON leQuartier = id;


-- Question 4 : Lister toutes les dates avec les comptages, y compris les dates où aucun comptage n'a été effectué.
SELECT date, laDate
FROM Date
    LEFT JOIN Comptage ON laDate = date;
    


-- Question 5 : Quels compteurs n'ont jamais enregistré de comptage avec une anomalie (probaAnomalie > 0) ?
SELECT DISTINCT numCompteur
FROM Comptage
WHERE numCompteur NOT IN (SELECT DISTINCT numCompteur
                           FROM Comptage
                           WHERE UPPER(probaAnomalie) = 'FORTE'
                          );


-- Question 6 : Quels quartiers ont des compteurs qui ont enregistré plus de 100 vélos un jour de vacances ?
SELECT DISTINCT numCompteur
FROM Comptage, Date
AND nbVelo > 100
AND numCompteur IN (SELECT numCompteur
                     FROM Comptage, Date
                     WHERE laDate = date
                     AND UPPER(vacances) != 'HORS VACANCES'
                    )
;


-- Question 7 : Quelles dates ont au moins un comptage avec une probabilité d'anomalie ?
SELECT DISTINCT date
FROM Date
WHERE EXISTS (
    SELECT numCompteur
    FROM Commpteur
    WHERE laDate = date
    AND UPPER(probaAnomalie) = 'FORTE'
);


-- Question 8 : Quels quartiers n'ont aucun compteur ayant enregistré de données ?
SELECT leQuartier
FROM Compteur
WHERE NOT EXISTS (
    SELECT *
    FROM Comptage
    WHERE numCompteur = numero
);

-- Question 9 : Quel est le nombre total de vélos comptés sur l'ensemble des comptages ?
SELECT COUNT(*) AS total_lignes
FROM ComptageVelo;

-- Question 10 : Quelle est la température moyenne la plus élevée enregistrée parmi toutes les dates ?
SELECT AVG(nombre_velos) AS moyenne_globale
FROM ComptageVelo;

-- Question 11 : Quel est le nombre moyen de vélos comptés par quartier ?
SELECT jour_semaine, AVG(nombre_velos) AS moyenne
FROM ComptageVelo
GROUP BY jour_semaine;

-- Question 12 : Combien de comptages ont été effectués pour chaque jour de la semaine ?
SELECT num_compteur, COUNT(*) AS nb_enregistrements
FROM ComptageVelo
GROUP BY num_compteur;

-- Question 13 : Quels quartiers ont une longueur totale de piste cyclable supérieure à 10 km et plus de 3 compteurs ?
SELECT num_compteur
FROM ComptageVelo
GROUP BY num_compteur
HAVING AVG(nombre_velos) > 1000;

-- Question 14 : Quels compteurs (numéro) ont enregistré en moyenne plus de 50 vélos par jour pendant les vacances ?
SELECT date
FROM ComptageVelo
GROUP BY date
HAVING SUM(nombre_velos) > 5000;


-- Question 15 : Quels compteurs ont enregistré des données pour toutes les dates de vacances ? (division normale)

SELECT num_compteur
FROM ComptageVelo
WHERE NOT EXISTS (
    SELECT date
    FROM Temperature
    WHERE temperature_moyenne < 5
    EXCEPT
    SELECT date
    FROM ComptageVelo CV
    WHERE CV.num_compteur = ComptageVelo.num_compteur
);



-- Question 16 : Quels compteurs ont enregistré des données uniquement les jours où la température moyenne était supérieure à 15°C ? (division exacte)

SELECT num_compteur
FROM ComptageVelo
WHERE num_compteur IS NOT NULL
GROUP BY num_compteur
HAVING NOT EXISTS (
    SELECT date
    FROM Temperature
    WHERE temperature_moyenne < 5
    EXCEPT
    SELECT date
    FROM ComptageVelo
    WHERE num_compteur = ComptageVelo.num_compteur
)
AND NOT EXISTS (
    SELECT date
    FROM ComptageVelo
    WHERE num_compteur = ComptageVelo.num_compteur
    EXCEPT
    SELECT date
    FROM Temperature
    WHERE temperature_moyenne < 5
);



-- Question 17 : Afficher les identifiants des compteurs qui n'ont jamais enregistré de données (Vue pour gérer une contrainte)
-- (Un compteur devrait normalement être utilisé au moins une fois)

CREATE OR REPLACE VIEW vue_CompteurSansComptage
AS
SELECT Numero
FROM Compteur
EXCEPT
SELECT DISTINCT num_compteur
FROM ComptageVelo;

-- Consultation
SELECT * FROM vue_CompteurSansComptage;



-- Question 18 : Afficher les identifiants des quartiers sans longueur d’aménagement cyclable renseignée (Vue pour gérer une contrainte)
-- (Chaque quartier devrait avoir une longueur de piste vélo enregistrée)

CREATE OR REPLACE VIEW vue_QuartierSansPiste
AS
SELECT Identifiant
FROM Quartier
EXCEPT
SELECT CodeQuartier
FROM LongueurPistesVelo;

-- Consultation
SELECT * FROM vue_QuartierSansPiste;



-- Question 19 : Afficher, pour chaque quartier, la longueur d’aménagement cyclable totale (Vue pour gérer une information dérivable)
CREATE OR REPLACE VIEW vue_LongueurCyclableParQuartier
AS
SELECT Identifiant, Nom, amenagement_cyclable
FROM Quartier
    JOIN LongueurPistesVelo ON Identifiant = CodeQuartier;

-- Consultation
SELECT * FROM vue_LongueurCyclableParQuartier;



-- Question 20 : Afficher, pour chaque compteur, le nombre total d’enregistrements réalisés (Vue pour gérer une information dérivable)
CREATE OR REPLACE VIEW vue_NbEnregistrementsParCompteur
AS
SELECT num_compteur, COUNT(*) AS nb_enregistrements
FROM ComptageVelo
GROUP BY num_compteur;

-- Consultation
SELECT * FROM vue_NbEnregistrementsParCompteur;



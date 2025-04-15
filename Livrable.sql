/**
Requêtes SQL - SAE S2.04
Prénom : Nolann / Matthieu / Arthur / Marin
Nom : LESCOP / GOUELO / JAN / WEIS
Groupe : 1D1

---------------------------------------------------
/* SCHEMA RELATIONNEL

Compteur(numero (1), libelle, leQuartier = @Quartier.id)
Quartier(id (1), nomQuartier, longueurPiste)
Date(date (1), jour (NN), tempMoy, vacances)
Comptage([numCompteur = @Compteur.numero, laDate = @Date.date](1), nbVelo, probaAnomalie)

*/
---------------------------------------------------
*/


-- Requête 1 : Quels sont les compteurs (numéro et libellé) situés dans le quartier "Centre-ville" ? (jointure interne)
SELECT DISTINCT numero, libelle
FROM Compteur
    JOIN Quartier ON leQuartier = id
WHERE nomQuartier = 'Centre Ville';
/* Résultat de la requête : 22 tuples
# numero, libelle
'664', 'Bonduelle vers sud'
'665', 'Bonduelle vers Nord'
'666', 'Pont Audibert vers Sud'
'674', 'Pont Haudaudine vers Sud'
'675', 'Pont Haudaudine vers Nord'
...
*/


-- Requête 2 : Quels sont les quartiers qui ont la même longueur de piste cyclable ? (auto-jointure)
SELECT Q1.nomQuartier
FROM Quartier Q1, Quartier Q2
WHERE Q1.id != Q2.id
AND Q1.longueurPiste = Q2.longueurPiste;
/* Résultat de la requête : 0 tuple

*/


-- Requête 3 : Afficher tous les quartiers avec leurs compteurs, même ceux qui n'ont pas de compteurs. (jointure externe)
SELECT numero, libelle, nomQuartier
FROM Compteur
    LEFT JOIN Quartier ON leQuartier = id;
/* Résultat de la requête : 76 tuples
 # numero, libelle, nomQuartier
'89', 'Coteaux vers Ouest', NULL
'664', 'Bonduelle vers sud', 'Centre Ville'
'665', 'Bonduelle vers Nord', 'Centre Ville'
'666', 'Pont Audibert vers Sud', 'Centre Ville'
'667', 'EntrÃ©e pont Audibert vers Nord', 'Ile de Nantes'
...
*/


-- Requête 4 : Lister toutes les dates avec les comptages, y compris les dates où aucun comptage n'a été effectué. (jointure externe)
SELECT date, laDate
FROM Date
    LEFT JOIN Comptage ON laDate = date;
/* Résultat de la requête : 1000 tuples
 # date, laDate
'2020-01-01', '2020-01-01'
'2020-01-01', '2020-01-01'
'2020-01-01', '2020-01-01'
'2020-01-01', '2020-01-01'
'2020-01-01', '2020-01-01'
...
*/


-- Requête 5 : Quels compteurs n'ont jamais enregistré de comptage avec une anomalie FORTE ? (sous-requête avec NOT IN)
SELECT DISTINCT numCompteur
FROM Comptage
WHERE numCompteur NOT IN (SELECT DISTINCT numCompteur
                           FROM Comptage
                           WHERE UPPER(probaAnomalie) = 'FORTE'
                          );
/* Résultat de la requête : 2 tuples
# numCompteur
'725'
'981'
*/


-- Requête 6 : Quels quartiers ont des compteurs qui ont enregistré plus de 100 vélos un jour de vacances ? (sous-requête avec IN)
SELECT DISTINCT nomQuartier
FROM Quartier
    JOIN Compteur ON leQuartier = id
WHERE numero IN ( SELECT DISTINCT numCompteur
                  FROM Comptage
                    JOIN Date ON laDate = date
                  WHERE nbVelo > 100
                  AND UPPER(vacances) != 'HORS VACANCES'
                )
;
/* Résultat de la requête : 9 tuples
# nomQuartier
'Centre Ville'
'Dervallières - Zola'
'Hauts Pavés - Saint Félix'
'Malakoff - Saint-Donatien'
'Ile de Nantes'
'Nantes Nord'
'Nantes Sud'
'Pont Rousseau'
'Ragon'
*/


-- Requête 7 : Quelles dates ont au moins un comptage avec une probabilité d'anomalie FORTE ? (sous-requête avec EXISTS)
SELECT DISTINCT date
FROM Date
WHERE EXISTS (
    SELECT numCompteur
    FROM Comptage
    WHERE laDate = date
        AND UPPER(probaAnomalie) = 'FORTE'
);
/* Résultat de la requête : 728 tuples
# date
'2020-01-01'
'2020-01-02'
'2020-01-03'
'2020-01-04'
'2020-01-05'
'2020-01-06'
...
*/


-- Requête 8 : Quels quartiers n'ont aucun compteur ayant enregistré de données ? (sous-requête avec NOT EXISTS)
SELECT nomQuartier
FROM Quartier
    JOIN Compteur ON leQuartier = id
WHERE NOT EXISTS (
    SELECT *
    FROM Comptage
    WHERE numCompteur = numero
);
/* Résultat de la requête : 2 tuples
# nomQuartier
'Doulon - Bottière'
'Doulon - Bottière'
*/


-- Requête 9 : Quel est le nombre total de vélos comptés sur l'ensemble des comptages ? (Fonction de groupe sans regroupement)
SELECT SUM(nbVelo) AS totalVelos
FROM Comptage;
/* Résultat de la requête : 1 tuple
# totalVelos
'39448940'
*/


-- Requête 10 : Quelle est la température moyenne la plus élevée enregistrée parmi toutes les dates ? (Fonction de groupe sans regroupement)
SELECT MAX(tempMoy) AS tempMax
FROM Date;
/* Résultat de la requête : 1 tuple
# tempMax
'30.95'
*/

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



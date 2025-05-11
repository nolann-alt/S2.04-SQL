/*
Requêtes SQL - SAE S2.04
Prénom : Nolann / Matthieu / Arthur / Marin
Nom : LESCOP / GOUELO / JAN / WEIS
Groupe : 1D1
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


-- Requête 11 : Quel est le nombre moyen de vélos comptés par quartier ? (Regroupement avec fonction de groupe)
SELECT nomQuartier, AVG(nbVelo) AS nbMoyenVelo
FROM Quartier
    JOIN Compteur ON leQuartier = id
        JOIN Comptage ON numCompteur = numero
GROUP BY nomQuartier;
/* Résultat de la requête : 9 tuples
# nomQuartier, nbMoyenVelo
'Centre Ville', '817.5560'
'Dervallières - Zola', '761.9452'
'Hauts Pavés - Saint Félix', '484.1551'
'Malakoff - Saint-Donatien', '260.4598'
'Ile de Nantes', '911.0991'
'Nantes Nord', '171.0307'
'Nantes Sud', '1129.9696'
'Pont Rousseau', '258.1362'
'Ragon', '49.3030'
*/


-- Requête 12 : Combien de comptages ont été effectués pour chaque jour de la semaine (triés dans l'ordre) ? (Regroupement avec fonction de groupe)
SELECT jour, COUNT(numCompteur) AS nbComptage
FROM Date
    JOIN Comptage ON laDate = date
GROUP BY jour
ORDER BY jour;
/* Résultat de la requête : 7 tuples
# jour, nbComptage
'1', '9722'
'2', '9720'
'3', '9652'
'4', '9670'
'5', '9664'
'6', '9722'
'7', '9654'
*/


-- Question 13 : Quels quartiers ont une longueur totale de piste cyclable supérieure à 10 km et plus de 3 compteurs ?
SELECT nomQuartier, SUM(longueurPiste) AS longueurPisteTotal
FROM Quartier
    JOIN Compteur ON leQuartier = id
GROUP BY nomQuartier
HAVING COUNT(leQuartier) > 3 AND SUM(longueurPiste) >= 10000;
/* Résultat de la requête : 4 tuples
# nomQuartier, longueurPisteTotal
'Centre Ville', '474071.3828125'
'Hauts Pavés - Saint Félix', '122091.6015625'
'Malakoff - Saint-Donatien', '252707.396484375'
'Ile de Nantes', '194389.1953125'
*/


-- Requête 14 : Quels compteurs (numéro) ont enregistré en moyenne plus de 50 vélos par jour pendant les vacances ? (Regroupement et restriction avec HAVING)
SELECT numero, AVG(nbVelo) AS moyenneVelo
FROM Compteur
    JOIN Comptage ON numCompteur = numero
        JOIN Date ON laDate = date
WHERE UPPER(vacances) != 'HORS VACANCES'
GROUP BY numero
HAVING AVG(nbVelo) > 50;
/* Résultat de la requête : 62 tuples
# numero, moyenneVelo
'664', '716.3554'
'665', '624.0680'
'666', '165.7681'
'667', '1753.4244'
'668', '540.9248'
...
*/


-- Requête 15 : Quels compteurs ont enregistré des données pour toutes les dates de vacances ? (Division normale)
SELECT numero
FROM Compteur
WHERE NOT EXISTS (
    SELECT date
    FROM Date
    WHERE UPPER(vacances) != 'HORS VACANCES'
    EXCEPT
    SELECT laDate
    FROM Comptage
    WHERE numCompteur = numero
);
/* Résultat de la requête : 50 tuples
 # numero
'981'
'667'
'668'
'669'
'672'
...
*/


-- Requête 16 : Quels compteurs ont enregistré des données uniquement les jours où la température moyenne était supérieure à 15°C ? (Division exacte)
SELECT numero
FROM Compteur
WHERE NOT EXISTS (
    SELECT laDate
    FROM Comptage
    WHERE numCompteur = numero
    EXCEPT
    SELECT date
    FROM Date
    WHERE tempMoy > 15
)
  AND EXISTS (
    SELECT laDate
    FROM Comptage
    WHERE numCompteur = numero
);
/* Résultat de la requête : 0 tuple
*/


-- Requête 17 : Créer une vue "ComptagesAnormaux" listant les comptages avec probaAnomalie = 'FORTE'
CREATE OR REPLACE VIEW vue_ComptageAnormaux AS
SELECT *
FROM Comptage
WHERE probaAnomalie = 'FORTE';

-- Consultation
SELECT * FROM ComptagesAnormaux;
/* Résultat de la requête : 1000 tuples
# numCompteur, laDate, nbVelo, probaAnomalie
'664', '2020-03-08', '0', 'Forte'
'664', '2020-05-20', '0', 'Forte'
'664', '2020-05-21', '0', 'Forte'
'664', '2020-05-22', '0', 'Forte'
'664', '2020-05-23', '0', 'Forte'
'664', '2020-05-24', '0', 'Forte'
...
 */


-- Requête 18 : Créer une vue "QuartiersSansDonnees" montrant les quartiers sans aucun comptage enregistré.
CREATE OR REPLACE VIEW vue_QuartiersSansDonnes AS
SELECT DISTINCT id, UPPER(nomQuartiers)
FROM Quartier
WHERE NOT EXISTS (
    SELECT *
    FROM Compteur
        JOIN Comptage ON numero = numCompteur
    WHERE leQuartier = id
);

-- Consultation
SELECT * FROM vue_QuartiersSansDonnees;
/* Résultat de la requête : 9 tuples
# id, UPPER(nomQuartier)
'2', 'BELLEVUE - CHANTENAY - SAINTE ANNE'
'7', 'BREIL - BARBERIE'
'9', 'NANTES ERDRE'
'10', 'DOULON - BOTTIÈRE'
'14301', 'TRENTEMOULT'
'14302', 'HÔTEL DE VILLE'
'14303', 'CHÂTEAU DE REZÉ'
'14305', 'LA HOUSSAIS'
'14306', 'BLORDIÈRE'
*/


-- Requête 19 : Créer une vue "StatistiquesQuartiers" qui montre pour chaque quartier le nombre total de vélos comptés et la moyenne par compteur
CREATE OR REPLACE VIEW vue_StatistiquesQuartiers AS
SELECT UPPER(nomQuartier), SUM(nbVelo) AS nbTotalVelo, AVG(nbVelo) AS moyenneCompteur
FROM Quartier
    JOIN Compteur ON leQuartier = id
        JOIN Comptage ON numCompteur = numero
GROUP BY leQuartier, nomQuartier;

-- Consultation
SELECT * FROM vue_StatistiquesQuartiers;
/* Résultat de la requête : 9 tuples
# UPPER(nomQuartier), nbTotalVelo, moyenneCompteur
'CENTRE VILLE', '20084080', '817.5560'
'DERVALLIÈRES - ZOLA', '848045', '761.9452'
'HAUTS PAVÉS - SAINT FÉLIX', '2163205', '484.1551'
'MALAKOFF - SAINT-DONATIEN', '2618402', '260.4598'
'ILE DE NANTES', '6106186', '911.0991'
'NANTES NORD', '161453', '171.0307'
'NANTES SUD', '2524352', '1129.9696'
'PONT ROUSSEAU', '576160', '258.1362'
'RAGON', '110143', '49.3030'
*/


-- Requête 20 : Créer une vue "FrequentationJournaliere" qui calcule le nombre total de vélos comptés par date, avec indication si c'était un jour de vacances.
CREATE OR REPLACE VIEW vue_FrequentationJournaliere AS
SELECT date, vacances, SUM(nbVelo) AS nbVeloTotal
FROM Date
    LEFT JOIN Comptage ON laDate = date
GROUP BY date, vacances;

-- Consultation
SELECT * FROM vue_FrequentationJournaliere;
/* Résultat de la requête : 1000 tuples
# date, vacances, nbVeloTotal
'2020-01-01', 'Vacances de Noël\r', '7777'
'2020-01-02', 'Vacances de Noël\r', '20921'
'2020-01-03', 'Vacances de Noël\r', '22655'
'2020-01-04', 'Vacances de Noël\r', '18760'
'2020-01-05', 'Vacances de Noël\r', '15444'
...
*/


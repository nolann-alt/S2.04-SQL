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

--Requête 1 : Quels sont les compteurs (numéro et libellé) situés dans le quartier "Centre-ville" ?
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


-- Question 4 : Afficher tous les quartiers et les compteurs associés, éventuellement rien.
SELECT Identifiant, nom, Libelle
FROM Quartier
    


-- Question 5 : Afficher les compteurs actifs uniquement pendant les vacances. (Sous-requête avec NOT IN)
SELECT DISTINCT num_compteur
FROM ComptageVelo
WHERE num_compteur NOT IN (SELECT DISTINCT num_compteur
                           FROM ComptageVelo
                           WHERE vacances != 'oui'
                          )
;


-- Question 6 : Afficher les compteurs utilisés à la fois en vacances et hors vacances. (Sous-requête avec IN)
SELECT DISTINCT num_compteur
FROM ComptageVelo
WHERE vacances = 'oui'
AND num_compteur IN (SELECT num_compteur
                     FROM ComptageVelo
                     WHERE vacances != 'oui'
                    )
;


-- Questi 7 : Afficher les identifiants des quartiers pour lesquels il existe au moins un Compteur associé dans QuartierCompteur. (Sous-requête avec EXISTS)
SELECT Identifiant
FROM Quartier
WHERE EXISTS (
    SELECT idCompteur
    FROM QuartierCompteur
    WHERE idQuartier = Identifiant
);


-- Question 8 : Afficher les noms des compteurs pour lesquels aucun enregistrement dans ComptageVelo ne dépasse 0.5 de probabilité d’anomalie (Sous-requête avec NOT EXISTS)
SELECT Libelle
FROM Compteur
WHERE NOT EXISTS (
    SELECT num_compteur
    FROM ComptageVelo
    WHERE num_compteur = Numero
    AND probabilite_anomalie > 0.5
);

-- Question 9 : Afficher le nombre total d’enregistrements dans ComptageVelo (Fonction de groupe sans regroupement)
SELECT COUNT(*) AS total_lignes
FROM ComptageVelo;

-- Question 10 : Afficher la moyenne globale du nombre de vélos enregistrés (Fonction de groupe sans regroupement)
SELECT AVG(nombre_velos) AS moyenne_globale
FROM ComptageVelo;

-- Question 11 : Afficher la moyenne de vélos enregistrés par jour de la semaine (Regroupement avec fonction de groupe)
SELECT jour_semaine, AVG(nombre_velos) AS moyenne
FROM ComptageVelo
GROUP BY jour_semaine;

-- Question 12 : Afficher le nombre d'enregistrements pour chaque compteur (Regroupement avec fonction de groupe)
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



/**
Requêtes SQL - SAE S2.04

---------------------------------------------------
Compteur(Numero(1), Libelle)
Quartier(Identifiant(1), Nom)
QuartierCompteur(idCompteur = @Compteur.Numero, idQuartier = @Quartier.Identifiant)
ComptageVelo(num_compteur = @Compteur.Numero, date, nombre_velos, probabilite_anomalie, jour_semaine, vacances)
LongueurPistesVelo(codeQuartier = @Quartier.Identifiant(1), amenagement_cyclable)
Temperature(date(1), temperature_moyenne)
---------------------------------------------------
*/

-- Requête 1 : Afficher les noms des compteurs et leurs quartiers associés. (jointure interne)
SELECT Libelle, nom
FROM Compteur
    JOIN QuartierCompteur ON Numero = idCompteur
        JOIN Quartier ON idQuartier = Quartier.Identifiant;


-- Requête 2 : Afficher les paires de compteurs ayant le même nom (auto-jointure)
SELECT C1.Numero, C2.Numero, C1.Libelle
FROM Compteur C1
    JOIN Compteur C2 ON C1.Libelle = C2.Libelle AND C1.Numero < C2.Numero;


-- Requête 3 : Afficher tous les compteurs et leurs quartiers, éventuellement rien. (jointure externe)
SELECT Numero, Libelle, nom
FROM Compteur
    LEFT JOIN QuartierCompteur ON Numero = idCompteur
        LEFT JOIN Quartier ON idQuartier = Quartier.Identifiant;


-- Requête 4 : Afficher tous les quartiers et les compteurs associés, éventuellement rien.
SELECT Identifiant, nom, Libelle
FROM Quartier
    LEFT JOIN QuartierCompteur ON Identifiant = QuartierCompteur.idQuartier
        LEFT JOIN Compteur ON idCompteur = Numero;


-- Requête 5 : Afficher les compteurs actifs uniquement pendant les vacances. (Sous-requête avec NOT IN)
SELECT DISTINCT num_compteur
FROM ComptageVelo
WHERE num_compteur NOT IN (SELECT DISTINCT num_compteur
                           FROM ComptageVelo
                           WHERE vacances != 'oui'
                          )
;


-- Requête 6 : Afficher les compteurs utilisés à la fois en vacances et hors vacances. (Sous-requête avec IN)
SELECT DISTINCT num_compteur
FROM ComptageVelo
WHERE vacances = 'oui'
AND num_compteur IN (SELECT num_compteur
                     FROM ComptageVelo
                     WHERE vacances != 'oui'
                    )
;


-- Requête 7 : Afficher les identifiants des quartiers pour lesquels il existe au moins un Compteur associé dans QuartierCompteur. (Sous-requête avec EXISTS)
SELECT Identifiant
FROM Quartier
WHERE EXISTS (
    SELECT idCompteur
    FROM QuartierCompteur
    WHERE idQuartier = Identifiant
);


-- Requête 8 : Afficher les noms des compteurs pour lesquels aucun enregistrement dans ComptageVelo ne dépasse 0.5 de probabilité d’anomalie (Sous-requête avec NOT EXISTS)
SELECT Libelle
FROM Compteur
WHERE NOT EXISTS (
    SELECT num_compteur
    FROM ComptageVelo
    WHERE num_compteur = Numero
    AND probabilite_anomalie > 0.5
);

-- Requête 9 : Afficher le nombre total d’enregistrements dans ComptageVelo (Fonction de groupe sans regroupement)
SELECT COUNT(*) AS total_lignes
FROM ComptageVelo;

-- Requête 10 : Afficher la moyenne globale du nombre de vélos enregistrés (Fonction de groupe sans regroupement)
SELECT AVG(nombre_velos) AS moyenne_globale
FROM ComptageVelo;

-- Requête 11 : Afficher la moyenne de vélos enregistrés par jour de la semaine (Regroupement avec fonction de groupe)
SELECT jour_semaine, AVG(nombre_velos) AS moyenne
FROM ComptageVelo
GROUP BY jour_semaine;

-- Requête 12 : Afficher le nombre d'enregistrements pour chaque compteur (Regroupement avec fonction de groupe)
SELECT num_compteur, COUNT(*) AS nb_enregistrements
FROM ComptageVelo
GROUP BY num_compteur;

-- Requête 13 : Afficher les compteurs ayant enregistré en moyenne plus de 1000 vélos par jour (Regroupement avec restriction HAVING)
SELECT num_compteur
FROM ComptageVelo
GROUP BY num_compteur
HAVING AVG(nombre_velos) > 1000;

-- Requête 14 : Afficher les jours ayant enregistré plus de 5000 vélos au total (Regroupement avec restriction HAVING)
SELECT date
FROM ComptageVelo
GROUP BY date
HAVING SUM(nombre_velos) > 5000;


-- Requête 15 : Afficher les numéros des compteurs ayant enregistré des données pour tous les jours où la température était < 5°C (Division normale)

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



-- Requête 16 : Afficher les numéros des compteurs ayant enregistré des données exactement pour tous les jours où la température était < 5°C (Division exacte)

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



-- Requête 17 : Afficher les identifiants des compteurs qui n'ont jamais enregistré de données (Vue pour gérer une contrainte)
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



-- Requête 18 : Afficher les identifiants des quartiers sans longueur d’aménagement cyclable renseignée (Vue pour gérer une contrainte)
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



-- Requête 19 : Afficher, pour chaque quartier, la longueur d’aménagement cyclable totale (Vue pour gérer une information dérivable)
CREATE OR REPLACE VIEW vue_LongueurCyclableParQuartier
AS
SELECT Identifiant, Nom, amenagement_cyclable
FROM Quartier
    JOIN LongueurPistesVelo ON Identifiant = CodeQuartier;

-- Consultation
SELECT * FROM vue_LongueurCyclableParQuartier;



-- Requête 20 : Afficher, pour chaque compteur, le nombre total d’enregistrements réalisés (Vue pour gérer une information dérivable)
CREATE OR REPLACE VIEW vue_NbEnregistrementsParCompteur
AS
SELECT num_compteur, COUNT(*) AS nb_enregistrements
FROM ComptageVelo
GROUP BY num_compteur;

-- Consultation
SELECT * FROM vue_NbEnregistrementsParCompteur;



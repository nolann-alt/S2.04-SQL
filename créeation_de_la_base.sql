
/* SCHEMA RELATIONNEL

Compteur(numero (1), libelle, leQuartier = @Quartier.id)
Quartier(id (1), nomQuartier, longueurPiste)
Date(date (1), jour (NN), tempMoy, vacances)
Comptage([numCompteur = @Compteur.numero, laDate = @Date.date](1), nbVelo, probaAnomalie)
*/

SET SQL_SAFE_UPDATES = 0;

DROP TABLE IF EXISTS Comptage;
DROP TABLE IF EXISTS Compteur;
DROP TABLE IF EXISTS Date;
DROP TABLE IF EXISTS Quartier;

CREATE TABLE Quartier (
    id INT,
    nomQuartier VARCHAR(50),
    longueurPiste FLOAT,
    CONSTRAINT pk_Quartier PRIMARY KEY (id),
    CONSTRAINT ck_longueurPiste CHECK (longueurPiste >= 0)
);

CREATE TABLE Compteur (
    numero INT,
    libelle VARCHAR(50),
    leQuartier INT,
    CONSTRAINT pk_Compteur PRIMARY KEY (numero),
    CONSTRAINT fk_Compteur_Quartier FOREIGN KEY (leQuartier) REFERENCES Quartier(id)
);


CREATE TABLE Date (
    date DATE,
    jour INT NOT NULL,
    tempMoy FLOAT,
    vacances VARCHAR(50),
    CONSTRAINT pk_date PRIMARY KEY (date),
    CONSTRAINT ck_jour CHECK (jour BETWEEN 1 AND 7)
);

CREATE TABLE Comptage (
    numCompteur INT,
    laDate DATE,
    nbVelo INT,
    probaAnomalie VARCHAR(10),
    CONSTRAINT pk_Comptage PRIMARY KEY (numCompteur, laDate),
    CONSTRAINT fk_Comptage_Compteur FOREIGN KEY (numCompteur) REFERENCES Compteur(numero),
    CONSTRAINT fk_Comptage_Date FOREIGN KEY (laDate) REFERENCES Date(date),
    CONSTRAINT ck_nbVelo CHECK (nbVelo >= 0)
);

/* CT
Les attributs numero, id, numCompteur, nbVelo, jour sont de type INTEGER.
Les attributs date et laDate sont de type DATE.
Les attributs longueurPiste et tempMoy sont de type FLOAT.
Les autres attributs sont de type VARCHAR.
Quartier : 
L'attribut longueurPiste doit être positif.

Comptage : 
Le nombre de velo doit être positif.

Date : 
Le jour de la semaine doit être compris entre 1 et 7.
*/
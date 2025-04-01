/*
Compteur(Numero(1), Libelle)
Quartier(Identifiant(1), Nom)
QuartierCompteur(idCompteur = @Compteur.Numero, idQuartier = @Quartier.Identifiant)
ComptageVelo(num_compteur = @Compteur.Numero, date, nombre_velos, probabilite_anomalie, jour_semaine, vacances)
LongueurPistesVelo(codeQuartier = @Quartier.Identifiant(1), amenagement_cyclable)
Temperature(date(1), temperature_moyenne)
*/

CREATE TABLE Compteur (
    Numero VARCHAR2(50),
    Libelle VARCHAR2(255),
    CONSTRAINT pk_Compteur PRIMARY KEY (Numero)
);

CREATE TABLE Quartier (
    Identifiant VARCHAR2(50),
    Nom VARCHAR2(255),
    CONSTRAINT pk_Quartier PRIMARY KEY (Identifiant)
);

CREATE TABLE QuartierCompteur (
    idCompteur VARCHAR2(50),
    idQuartier VARCHAR2(50),
    CONSTRAINT pk_QuartierCompteur PRIMARY KEY (idCompteur, idQuartier),
    CONSTRAINT fk_QC_Compteur FOREIGN KEY (idCompteur) REFERENCES Compteur(Numero),
    CONSTRAINT fk_QC_Quartier FOREIGN KEY (idQuartier) REFERENCES Quartier(Identifiant)
);

CREATE TABLE ComptageVelo (
    num_compteur VARCHAR2(50),
    date DATE,
    nombre_velos INT,
    probabilite_anomalie FLOAT,
    jour_semaine VARCHAR2(50),
    vacances VARCHAR2(50),
    CONSTRAINT pk_ComptageVelo PRIMARY KEY (num_compteur, date),
    CONSTRAINT fk_CV_Compteur FOREIGN KEY (num_compteur) REFERENCES Compteur(Numero)
);

CREATE TABLE LongueurPistesVelo (
    codeQuartier VARCHAR2(50),
    amenagement_cyclable FLOAT,
    CONSTRAINT pk_LPV PRIMARY KEY (codeQuartier),
    CONSTRAINT fk_LPV_Quartier FOREIGN KEY (codeQuartier) REFERENCES Quartier(Identifiant)
);

CREATE TABLE Temperature (
    date DATE,
    temperature_moyenne FLOAT,
    CONSTRAINT pk_Temperature PRIMARY KEY (date)
);
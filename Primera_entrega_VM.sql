CREATE schema sql_meta;
USE sql_meta;

CREATE table Estudio (
id_estudio INT auto_increment PRIMARY KEY,
titulo VARCHAR(200) NOT NULL, 
DOI VARCHAR(100),
tipo_de_estudio VARCHAR(100) NOT NULL,
año YEAR NOT NULL,
);

CREATE TABLE Planta (
    id_planta INT auto_increment PRIMARY KEY,
    nombre_cientifico VARCHAR(150) NOT NULL,
    familia VARCHAR(100) NOT NULL, 
    forma_de_vida VARCHAR(100) NOT NULL,
    id_estudio INT NOT NULL,
    FOREIGN KEY (id_estudio) REFERENCES Estudio(id_estudio)
);

CREATE TABLE Polinizador(
id_polinizador INT auto_increment PRIMARY KEY,
nombre_cientifico VARCHAR(100) NOT NULL,
grupo_funcional VARCHAR(100), 
id_estudio INT NOT NULL,
FOREIGN KEY (id_estudio) REFERENCES Estudio(id_estudio)
);

CREATE TABLE Interacciones(
id_interaccion INT auto_increment PRIMARY KEY, 
id_planta INT,
id_polinizador INT,
id_sitio INT,
id_estudio INT, 
FOREIGN KEY (id_planta) REFERENCES Planta (id_planta),
FOREIGN KEY (id_polinizador) REFERENCES Polinizador (id_polinizador),
FOREIGN KEY (id_estudio) REFERENCES Estudio (id_estudio)
);

CREATE TABLE Sitio (
    id_sitio INT AUTO_INCREMENT PRIMARY KEY,
    nombre_sitio VARCHAR(100) NOT NULL,
    pais VARCHAR(100),
    latitud DECIMAL(9,6),
    longitud DECIMAL(9,6),
    tipo_ecosistema VARCHAR(100),
    id_estudio INT NOT NULL,
    FOREIGN KEY (id_estudio) REFERENCES Estudio(id_estudio)
);

CREATE TABLE Fenologia_planta(
id_feno INT auto_increment PRIMARY KEY,
fecha_inicio DATE,
fecha_pico DATE,
fecha_fin DATE, 
id_planta INT NOT NULL,
 FOREIGN KEY (id_planta) REFERENCES Planta(id_planta)
);

CREATE TABLE Fenologia_polinizador(
id_feno_pol INT auto_increment PRIMARY KEY,
fecha_inicio_pol DATE,
fecha_pico_pol DATE,
fecha_fin_pol DATE, 
id_polinizador INT,
 FOREIGN KEY (id_polinizador) REFERENCES Polinizador(id_polinizador)
);

CREATE TABLE Clima(
id_data_climatico INT auto_increment PRIMARY KEY,
temperatura_media FLOAT,
precipitacion FLOAT,
id_sitio INT NOT NULL,
 FOREIGN KEY (id_sitio) REFERENCES Sitio(id_sitio)
);

ALTER TABLE Interacciones
ADD FOREIGN KEY (id_sitio) REFERENCES Sitio(id_sitio);

ALTER TABLE Fenologia_planta
CHANGE id_feno id_feno_planta INT;

ALTER TABLE Fenologia_planta
CHANGE fecha_inicio inicio_floracion DATE,
CHANGE fecha_pico pico_floracion DATE,
CHANGE fecha_fin fin_floracion DATE;

ALTER TABLE Fenologia_planta
ADD COLUMN id_sitio INT;

ALTER TABLE Fenologia_planta
ADD FOREIGN KEY (id_sitio) REFERENCES Sitio(id_sitio);

ALTER TABLE Fenologia_polinizador
CHANGE fecha_inicio_pol inicio_actividad DATE,
CHANGE fecha_pico_pol pico_actividad DATE,
CHANGE fecha_fin_pol fin_actividad DATE;

ALTER TABLE Fenologia_polinizador
ADD COLUMN id_sitio INT;

ALTER TABLE Fenologia_polinizador
ADD FOREIGN KEY (id_sitio) REFERENCES Sitio(id_sitio);




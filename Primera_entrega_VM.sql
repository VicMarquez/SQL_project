#### Primer Entrega 
DROP SCHEMA IF EXISTS sql_meta;
CREATE schema sql_meta;
USE sql_meta;

CREATE table estudio (
id_estudio INT auto_increment PRIMARY KEY,
titulo VARCHAR(200) NOT NULL, 
DOI VARCHAR(100),
tipo_de_estudio VARCHAR(100) NOT NULL,
year_estudio YEAR NOT NULL
);

CREATE TABLE planta (
    id_planta INT auto_increment PRIMARY KEY,
    nombre_cientifico VARCHAR(150) NOT NULL,
    familia VARCHAR(100) NOT NULL, 
    forma_de_vida VARCHAR(100) NOT NULL,
    id_estudio INT NOT NULL,
    FOREIGN KEY (id_estudio) REFERENCES estudio(id_estudio)
);

CREATE TABLE polinizador(
id_polinizador INT auto_increment PRIMARY KEY,
nombre_cientifico VARCHAR(100) NOT NULL,
grupo_funcional VARCHAR(100), 
id_estudio INT NOT NULL,
FOREIGN KEY (id_estudio) REFERENCES estudio(id_estudio)
);

CREATE TABLE interacciones(
id_interaccion INT auto_increment PRIMARY KEY, 
id_planta INT,
id_polinizador INT,
id_estudio INT, 
FOREIGN KEY (id_planta) REFERENCES planta (id_planta),
FOREIGN KEY (id_polinizador) REFERENCES polinizador (id_polinizador),
FOREIGN KEY (id_estudio) REFERENCES estudio (id_estudio)
);

CREATE TABLE sitio (
    id_sitio INT AUTO_INCREMENT PRIMARY KEY,
    nombre_sitio VARCHAR(100) NOT NULL,
    pais VARCHAR(100),
    latitud DECIMAL(9,6),
    longitud DECIMAL(9,6),
    tipo_ecosistema VARCHAR(100),
    id_estudio INT NOT NULL,
    FOREIGN KEY (id_estudio) REFERENCES estudio(id_estudio)
);

CREATE TABLE fenologia_planta (      # aclaro que son solo fechas de floración no se tienen en cuenta otras etapas fenológicas. 
id_fenologia_planta INT auto_increment PRIMARY KEY,
inicio_floracion DATE,
pico_floracion DATE,
fin_floracion DATE, 
id_planta INT NOT NULL,
id_sitio INT NOT NULL,
 FOREIGN KEY (id_planta) REFERENCES planta(id_planta),
 FOREIGN KEY (id_sitio) REFERENCES sitio (id_sitio)
);

CREATE TABLE fenologia_polinizador(
id_fenologia_polinizador INT auto_increment PRIMARY KEY,
inicio_actividad DATE,
pico_actividad DATE,
fin_actividad DATE, 
id_polinizador INT NOT NULL,
id_sitio INT NOT NULL,
 FOREIGN KEY (id_polinizador) REFERENCES polinizador(id_polinizador),
 FOREIGN KEY (id_sitio) REFERENCES sitio(id_sitio)
);

CREATE TABLE clima(
id_data_climatico INT auto_increment PRIMARY KEY,
temperatura_media FLOAT,
precipitacion FLOAT,
id_sitio INT NOT NULL,
 FOREIGN KEY (id_sitio) REFERENCES sitio(id_sitio)
);
#### Cargo datos cvs usando el entorno de MySQL Workbench########
#Carga de datos a partir de archivos CSV
#1. Cargo los datos en la tabla estudio archivo 1_estudios_random_planta_polinizador
#2. Cargo los datos en la tabla planta archivo 2_plantas_random
# Cargo los datos en la tabla polinizador archivo 3_polinizadores_random
# Cargo los datos en sitio archivo 4_sitios_random
# Cargo los datos en la tabla interacciones archivo 5_interacciones_generadas
# Cargo los datos en fenologia_planta archivo 6_fenologia_planta_generada
# Cargo los datos en fenologia_polinizador archivo 7_fenologia_polinizador_generada


SELECT * FROM sql_meta.estudio; # los datos se cargaron correctamente

SELECT * FROM sql_meta.planta;

SELECT * FROM sql_meta.polinizador;

SELECT * FROM sql_meta.sitio;

SELECT * FROM sql_meta.interacciones; 

SELECT * FROM sql_meta.fenologia_planta; 

SELECT * FROM sql_meta.fenologia_polinizador; 
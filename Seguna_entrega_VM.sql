### Segunda Entrega
USE sql_meta;
######################## Vistas ##########################
# 1) vista_fenologia_mismatch: 
#tiene como objetivo mostrar las fenologias de las plantas y polinizadores que esten en lo mismos sitios. Es útil para detectar posibles desajustes planta-polinizador (mismatch)
CREATE VIEW vista_fenologia_mismatch AS
SELECT 
    s.nombre_sitio,
    p.nombre_cientifico AS planta,
    fp.inicio_floracion,
    fp.pico_floracion,
    fp.fin_floracion,
    pol.nombre_cientifico AS polinizador,
    fpol.inicio_actividad,
    fpol.pico_actividad,
    fpol.fin_actividad
FROM fenologia_planta fp  # empiezo desde esta tabla que contiene las columanas fp que llame antes
INNER JOIN planta p ON fp.id_planta = p.id_planta # nombre cientifico de la planta
INNER JOIN sitio s ON fp.id_sitio = s.id_sitio # floracion + planta (nombre cientifico) + sitio
INNER JOIN fenologia_polinizador fpol ON fpol.id_sitio = s.id_sitio # traigo los polinizadores que este en los mismos sitios
INNER JOIN polinizador pol ON fpol.id_polinizador = pol.id_polinizador; # los nombres cientificos de los polinizadores

SELECT * FROM vista_fenologia_mismatch;

#2) vista_interacciones_taxonomia: me permite ver todas las interacciones planta-polinizador por ecosistema, sumandole la información 
# taxonómica (nombre científico de polinizador y planta). 
CREATE VIEW vista_interacciones_taxonomia AS
SELECT 
    pl.nombre_cientifico AS planta,
    pl.familia,
    pl.forma_de_vida,
    pol.nombre_cientifico AS polinizador,
    pol.grupo_funcional
FROM interacciones i # arranco desde esta tabla 
JOIN planta pl ON i.id_planta = pl.id_planta # sumo la info del nombre científico, forma de vida y familia que traigo de la tabla planta
JOIN polinizador pol ON i.id_polinizador = pol.id_polinizador; # lo mismo con el nombre de los polinizadores y grupo funcional

# 3) vista_estudios_detalle: muestra la info de cada estudio (tabla estudio), las especies estudiadas de plantas en una misma celda, las de 
# polinizadores y los sitios. Sirve para hacer analisis bibliométricos que pueden ser importantes en meta-análisis
CREATE VIEW vista_estudios_detalle AS
SELECT 
    e.id_estudio,
    e.titulo,
    e.DOI,
    e.tipo_de_estudio,
    e.year_estudio,
    GROUP_CONCAT(DISTINCT pl.nombre_cientifico SEPARATOR '; ') AS plantas_estudiadas, # agrupo las plantas estudiadas en una sola celda sin repetir valores
    GROUP_CONCAT(DISTINCT pol.nombre_cientifico SEPARATOR '; ') AS polinizadores_estudiados, # los mismo con polinizadores
    GROUP_CONCAT(DISTINCT s.nombre_sitio SEPARATOR '; ') AS sitios # lo mismo con sitios
FROM estudio e
LEFT JOIN planta pl ON pl.id_estudio = e.id_estudio # left join me asegura que todos los estudios aparezacan listados. 
LEFT JOIN polinizador pol ON pol.id_estudio = e.id_estudio
LEFT JOIN sitio s ON s.id_estudio = e.id_estudio
GROUP BY e.id_estudio; # criterio de agrupación para GROUP_CONCAT

SELECT * FROM vista_estudios_detalle;
##################### Funciones ##########################
#1) duracion_floracion_planta: calcula la duración en días de la floración de una planta en un sitio específico, usando las fechas de inicio y fin de la floración
#tabla involucrada: fenologia_planta (columnas: inicio_floracion, fin_floracion)
DELIMITER $$

CREATE FUNCTION duracion_floracion_planta(
    p_id_feno_planta INT
) RETURNS INT
DETERMINISTIC
BEGIN
    DECLARE duracion INT;
    SELECT DATEDIFF(fin_floracion, inicio_floracion)
    INTO duracion
    FROM fenologia_planta
    WHERE id_fenologia_planta = p_id_feno_planta;

    RETURN duracion;
END$$

DELIMITER ;

# 2) numero_interaccion_por_estudio: obtiene el número de interacciones planta-polinizador por estudio. 
# tabla involucrada: interacciones (columnas: id_estudio)

DELIMITER $$

CREATE FUNCTION numero_interacciones_por_estudio(
    p_id_estudio INT # me refuero al parámetro
) RETURNS INT
DETERMINISTIC
BEGIN
    DECLARE total_interacciones INT; # declaro la variable dentro de la función

    SELECT COUNT(*) INTO total_interacciones FROM interacciones WHERE id_estudio = p_id_estudio; # cuenta cuantas filas hay en la tabla interacción donde el sitio sea igual a p_id_count (valore que selecciono para aplicar la funcion)
    RETURN total_interacciones;
END$$

DELIMITER ;

################## Stored Procedure ########################
#1) sp_insertar_interaccion
DELIMITER $$

CREATE PROCEDURE sp_insertar_interaccion(
    IN p_id_planta INT,
    IN p_id_polinizador INT,
    IN p_id_estudio INT
)
BEGIN
    INSERT INTO interacciones (id_planta, id_polinizador, id_estudio)
    VALUES (p_id_planta, p_id_polinizador, p_id_estudio);
END$$

DELIMITER ;
#2) ver_fenologia

DELIMITER $$

CREATE PROCEDURE ver_fenologia (
    IN p_nombre_cientifico VARCHAR(150)
)
BEGIN
    SELECT 
        p.nombre_cientifico,
        fp.inicio_floracion,
        fp.pico_floracion,
        fp.fin_floracion
    FROM planta p
    JOIN fenologia_planta fp ON p.id_planta = fp.id_planta
    WHERE p.nombre_cientifico = p_nombre_cientifico;
END$$

DELIMITER ;
############### Triggers #######################
#1) trg_validar_fechas_fenologia: me tira un error si la fecha de inicio de floracion es posterior a la de fin esto permite
#mantener la integridad de los datos
DELIMITER $$

CREATE TRIGGER trg_validar_fechas_fenologia BEFORE INSERT ON fenologia_planta
FOR EACH ROW
BEGIN
    IF NEW.inicio_floracion > NEW.fin_floracion THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Error: inicio_floracion debe ser anterior a fin_floracion'; # sirve para chequear integridad
    END IF;
END$$

DELIMITER ;
#2) trg_log_cambio_nombre_planta y trg_log_cambio_nombre_polinizador, son dos uno que guarda la info de actualización de los nombres cientificos
# de plantas en la tabla log_cambios_nombre_cientifico y otro los cambios en los nombre de polinizadores

CREATE TABLE log_cambios_nombre_cientifico (
    id_log INT AUTO_INCREMENT PRIMARY KEY,
    tabla VARCHAR(50) NOT NULL,  # de que tabla viene si de polinizador o planta
    id_registro INT NOT NULL,   # id_planta o id_polinizador que cambió
    nombre_anterior VARCHAR(150) NOT NULL, # nombre cientifico viejo
    nombre_nuevo VARCHAR(150) NOT NULL, # nombre cientifico nuevo
    usuario VARCHAR(100) DEFAULT NULL  # guarda el usuario que hizo la actualizacion
);

DELIMITER $$

CREATE TRIGGER trg_log_cambio_nombre_planta BEFORE UPDATE ON planta
FOR EACH ROW
BEGIN
    IF OLD.nombre_cientifico <> NEW.nombre_cientifico THEN
        INSERT INTO log_cambios_nombre_cientifico (tabla, id_registro, nombre_anterior, nombre_nuevo)
        VALUES ('planta', OLD.id_planta, OLD.nombre_cientifico, NEW.nombre_cientifico);
    END IF;
END$$

DELIMITER ;

DELIMITER $$

CREATE TRIGGER trg_log_cambio_nombre_polinizador BEFORE UPDATE ON polinizador
FOR EACH ROW
BEGIN
    IF OLD.nombre_cientifico <> NEW.nombre_cientifico THEN
        INSERT INTO log_cambios_nombre_cientifico (tabla, id_registro, nombre_anterior, nombre_nuevo)
        VALUES ('polinizador', OLD.id_polinizador, OLD.nombre_cientifico, NEW.nombre_cientifico);
    END IF;
END$$

DELIMITER ;

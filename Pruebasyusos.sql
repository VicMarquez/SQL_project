############ Probamos las vistas, funciones, stored procedures y triggers ##########
USE sql_meta;
#vistas
SELECT * FROM vista_fenologia_mismatch LIMIT 10;
SELECT * FROM vista_interacciones_taxonomia LIMIT 10;
SELECT * FROM vista_estudios_detalle LIMIT 10;


#vista_fenologia_mismatch muestra las fenologia de las plantas y polinizadores que estan en lo mismos sitio. Agregando la segunda parte de WHERE
# puedo ver los polinizadores y plantas que posiblemente esten interactuando 
# La vista arroja 48 registros de especies en lo mismos sitios, eso no significa necesariamente que las especies esten interacutnado. 
# Es mas si consideramos que el desfasaje fenologico se produce cuando la floracion es anterior a la actividad de los polinizadores o cuando el fin de la floracion
# la floracion termina antes de que comience la actividad. Vemos que 43 de los registros anterior cumple con esa condiciones y solo 5 resgistros
# indicarian una posible interaccion
SELECT * FROM vista_fenologia_mismatch
WHERE inicio_floracion > fin_actividad
   OR fin_floracion < inicio_actividad;
   
SELECT * FROM vista_fenologia_mismatch
WHERE inicio_floracion <= fin_actividad
AND fin_floracion >= inicio_actividad;

##############
# Grupos funcionales de polinizadores viculados con algua forma de vida 
SELECT forma_de_vida, grupo_funcional, COUNT(*) AS n_interacciones
FROM vista_interacciones_taxonomia
GROUP BY forma_de_vida, grupo_funcional
ORDER BY n_interacciones DESC;

SELECT grupo_funcional, COUNT(*) AS n
FROM vista_interacciones_taxonomia
GROUP BY grupo_funcional
ORDER BY n DESC;

SELECT 
    p.nombre_cientifico AS planta,
    fp.inicio_floracion,
    fp.fin_floracion,
    duracion_floracion_planta(fp.id_fenologia_planta) AS duracion_dias
FROM fenologia_planta fp
JOIN planta p ON fp.id_planta = p.id_planta
ORDER BY duracion_dias DESC
LIMIT 3;

SELECT 
    p.nombre_cientifico AS planta,
    COUNT(i.id_interaccion) AS cantidad_interacciones
FROM interacciones i
JOIN planta p ON i.id_planta = p.id_planta
GROUP BY p.id_planta, p.nombre_cientifico
ORDER BY cantidad_interacciones DESC
LIMIT 3;

#funciones
SELECT duracion_floracion_planta(1); # duraciion de la floracion en dias

SELECT numero_interacciones_por_estudio(30);

# stored procedures
CALL sp_insertar_interaccion(1, 12, 1); 

SELECT DISTINCT nombre_cientifico FROM planta;
SELECT * FROM fenologia_planta;

CALL ver_fenologia ('Acacia grandiflora');
# trigger

INSERT INTO fenologia_planta (inicio_floracion, pico_floracion, fin_floracion, id_planta, id_sitio)
VALUES ('2023-10-01', '2023-10-15', '2023-09-30', 1, 1); # excelente

UPDATE planta SET nombre_cientifico = 'Prueba sp' WHERE id_planta = 1;
UPDATE polinizador SET nombre_cientifico = 'Abeja sp' WHERE id_polinizador = 21;
SELECT * FROM log_cambios_nombre_cientifico  # vemos que se agregaron los dos registro de cambios 
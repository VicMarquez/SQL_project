############ Probamos las vistas, funciones, stored procedures y triggers ##########
#vistas
SELECT * FROM vista_fenologia_mismatch LIMIT 10;
SELECT * FROM vista_interacciones_taxonomia LIMIT 10;
SELECT * FROM vista_estudios_detalle LIMIT 10;

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
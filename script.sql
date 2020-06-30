-- Database: olimpiadas

-- DROP DATABASE olimpiadas;

CREATE DATABASE olimpiadas
    WITH 
    OWNER = postgres
    ENCODING = 'UTF8'
    LC_COLLATE = 'es_GT.UTF-8'
    LC_CTYPE = 'es_GT.UTF-8'
    TABLESPACE = pg_default
    CONNECTION LIMIT = -1;

COMMENT ON DATABASE olimpiadas
    IS 'Practica MIAVJ20';
	
-- use olimpiadas;
-- SHOW TABLES;

-- 1. Script para la creacion de tablas de la BD

CREATE TABLE PROFESION(
	cod_prof INTEGER PRIMARY KEY NOT NULL,
	nombre VARCHAR(50) UNIQUE NOT NULL
	);
	
CREATE TABLE PAIS(
	cod_pais INTEGER PRIMARY KEY NOT NULL,
	nombre VARCHAR(50) UNIQUE NOT NULL
	);
	
CREATE TABLE PUESTO(
	cod_puesto INTEGER PRIMARY KEY NOT NULL,
	nombre VARCHAR(50) UNIQUE NOT NULL
	);
	
CREATE TABLE DEPARTAMENTO(
	cod_depto INTEGER PRIMARY KEY NOT NULL,
	nombre VARCHAR(50) UNIQUE NOT NULL
	);
	
CREATE TABLE MIEMBRO(
	cod_miembro INTEGER PRIMARY KEY NOT NULL,
	nombre VARCHAR(100) NOT NULL,
	apellido VARCHAR(100) NOT NULL,
	edad INTEGER NOT NULL,
	telefono INTEGER,
	residencia VARCHAR(100),
	PAIS_cod_pais INTEGER NOT NULL,
	PROFESION_cod_prof INTEGER NOT NULL,
	CONSTRAINT PAIS_cod_pais_fk FOREIGN KEY (PAIS_cod_pais) REFERENCES PAIS(cod_pais) ON UPDATE CASCADE ON DELETE CASCADE,
	CONSTRAINT PROFESION_cod_prof_fk FOREIGN KEY (PROFESION_cod_prof) REFERENCES PROFESION(cod_profesion) ON UPDATE CASCADE ON DELETE CASCADE
	);

CREATE TABLE PUESTO_MIEMBRO(
    MIEMBRO_cod_miembro INTEGER NOT NULL,
    PUESTO_cod_puesto INTEGER NOT NULL,
    DEPARTAMENTO_cod_depto INTEGER NOT NULL,
    fecha_inicio DATE NOT NULL,
    fecha_fin DATE,
	PRIMARY KEY(MIEMBRO_cod_miembro, PUESTO_cod_puesto, DEPARTAMENTO_cod_depto),
    CONSTRAINT MIEMBRO_cod_miembro_fk FOREIGN KEY (MIEMBRO_cod_miembro) REFERENCES MIEMBRO(cod_miembro) ON UPDATE CASCADE ON DELETE CASCADE,
    CONSTRAINT PUESTO_cod_puesto_fk FOREIGN KEY (PUESTO_cod_puesto) REFERENCES PUESTO(cod_puesto) ON UPDATE CASCADE ON DELETE CASCADE,
    CONSTRAINT DEPARTAMENTO_cod_depto_fk FOREIGN KEY (DEPARTAMENTO_cod_depto) REFERENCES DEPARTAMENTO(cod_depto) ON UPDATE CASCADE ON DELETE CASCADE
    );

CREATE TABLE TIPO_MEDALLA(
	cod_tipo INTEGER PRIMARY KEY NOT NULL,
	medalla VARCHAR(20) UNIQUE NOT NULL
	);

CREATE TABLE MEDALLERO(
    PAIS_cod_pais INTEGER NOT NULL,
    cantidad_medallas INTEGER NOT NULL,
    TIPO_MEDALLA_cod_tipo INTEGER NOT NULL,
	PRIMARY KEY(PAIS_cod_pais, TIPO_MEDALLA_cod_tipo),
    CONSTRAINT PAIS_cod_pais_medallero_fk FOREIGN KEY (PAIS_cod_pais) REFERENCES PAIS(cod_pais) ON UPDATE CASCADE ON DELETE CASCADE,
    CONSTRAINT TIPO_MEDALLA_cod_tipo_fk FOREIGN KEY (TIPO_MEDALLA_cod_tipo) REFERENCES TIPO_MEDALLA(cod_tipo) ON UPDATE CASCADE ON DELETE CASCADE
    );

CREATE TABLE DISCIPLINA(
	cod_disciplina INTEGER PRIMARY KEY NOT NULL,
	nombre VARCHAR(50) NOT NULL,
    descripcion VARCHAR(150)
	);

CREATE TABLE ATLETA(
	cod_atleta INTEGER PRIMARY KEY NOT NULL,
	nombre VARCHAR(50) NOT NULL,
	apellido VARCHAR(50) NOT NULL,
	edad INTEGER NOT NULL,
	Participaciones VARCHAR(100) NOT NULL,
    DISCIPLINA_cod_disciplina INTEGER NOT NULL,
	PAIS_cod_pais INTEGER NOT NULL,
    CONSTRAINT DISCIPLINA_cod_disciplina_fk FOREIGN KEY (DISCIPLINA_cod_disciplina) REFERENCES DISCIPLINA(cod_disciplina) ON UPDATE CASCADE ON DELETE CASCADE,
	CONSTRAINT PAIS_cod_pais_atleta_fk FOREIGN KEY (PAIS_cod_pais) REFERENCES PAIS(cod_pais) ON UPDATE CASCADE ON DELETE CASCADE
	);

CREATE TABLE CATEGORIA(
	cod_categoria INTEGER PRIMARY KEY NOT NULL,
	categoria VARCHAR(50) NOT NULL
	);

CREATE TABLE TIPO_PARTICIPACION(
	cod_participacion INTEGER PRIMARY KEY NOT NULL,
	tipo_participacion VARCHAR(100) NOT NULL
	);

CREATE TABLE EVENTO(
    cod_evento INTEGER PRIMARY KEY NOT NULL,
    fecha DATE NOT NULL,
    ubicacion VARCHAR(50) NOT NULL,
    hora DATE NOT NULL,
    DISCIPLINA_cod_disciplina INTEGER NOT NULL,
    TIPO_PARTICIPACION_cod_participacion INTEGER NOT NULL,
    CATEGORIA_cod_categoria INTEGER NOT NULL,
    CONSTRAINT DISCIPLINA_cod_disciplina_evento_fk FOREIGN KEY (DISCIPLINA_cod_disciplina) REFERENCES DISCIPLINA(cod_disciplina) ON UPDATE CASCADE ON DELETE CASCADE,
    CONSTRAINT TIPO_PARTICIPACION_cod_participacion_fk FOREIGN KEY (TIPO_PARTICIPACION_cod_participacion) REFERENCES TIPO_PARTICIPACION(cod_participacion) ON UPDATE CASCADE ON DELETE CASCADE,
    CONSTRAINT CATEGORIA_cod_categoria_fk FOREIGN KEY (CATEGORIA_cod_categoria) REFERENCES CATEGORIA(cod_categoria) ON UPDATE CASCADE ON DELETE CASCADE
    );

CREATE TABLE EVENTO_ATLETA(
	ATLETA_cod_atleta INTEGER NOT NULL,
	EVENTO_cod_evento INTEGER NOT NULL,
	PRIMARY KEY(ATLETA_cod_atleta, EVENTO_cod_evento),
    CONSTRAINT ATLETA_cod_atleta_fk FOREIGN KEY (ATLETA_cod_atleta) REFERENCES ATLETA(cod_atleta) ON UPDATE CASCADE ON DELETE CASCADE,
    CONSTRAINT EVENTO_cod_evento_fk FOREIGN KEY (EVENTO_cod_evento) REFERENCES EVENTO(cod_evento) ON UPDATE CASCADE ON DELETE CASCADE
	);

CREATE TABLE TELEVISORA(
	cod_televisora INTEGER PRIMARY KEY NOT NULL,
	nombre VARCHAR(50) NOT NULL
	);

CREATE TABLE EVENTO_ATLETA(
	EVENTO_cod_evento INTEGER NOT NULL,
    TELEVISORA_cod_televisora INTEGER NOT NULL,
	PRIMARY KEY(EVENTO_cod_evento, TELEVISORA_cod_televisora),
    CONSTRAINT EVENTO_cod_evento_atleta_fk FOREIGN KEY (EVENTO_cod_evento) REFERENCES EVENTO(cod_evento) ON UPDATE CASCADE ON DELETE CASCADE,
    CONSTRAINT TELEVISORA_cod_televisora FOREIGN KEY (TELEVISORA_cod_televisora) REFERENCES TELEVISORA(cod_televisora) ON UPDATE CASCADE ON DELETE CASCADE
	);
---2-----------------------------------------------------------------------------------
--En la tabla “Evento” se decidió que la fecha y hora se trabajaría en una sola columna.
--Eliminar las columnas fecha y hora.
ALTER TABLE EVENTO DROP fecha;
ALTER TABLE EVENTO DROP hora;
--Crear una columna llamada “fecha_hora” con el tipo de dato que
--corresponda según el DBMS.
ALTER TABLE EVENTO ADD fecha_hora timestamp not null;

--3----------------------------------------------------------------------------------
--Todos los eventos de las olimpiadas deben ser programados del 24 de julio
--de 2020 a partir de las 9:00:00 hasta el 09 de agosto de 2020 hasta las
--20:00:00.

--Generar el Script que únicamente permita registrar los eventos entre estas
--fechas y horarios.
ALTER TABLE EVENTO
    ADD CONSTRAINT fecha_ini CHECK (fecha_hora > to_timestamp('24 07 2020 09:00:00','DD MM YYYY HH24:MI:SS'));

ALTER TABLE EVENTO 
    ADD CONSTRAINT fecha_fin CHECK (fecha_hora <=to_timestamp('09 08 2020 20:00:00','DD MM YYYY HH24:MI:SS'));
--4----------------------------------------------------------------------------------
--Se decidió que las ubicación de los eventos se registrarán previamente en
--una tabla y que en la tabla “Evento” sólo se almacenara la llave foránea
--según el código del registro de la ubicación, para esto debe realizar lo
--siguiente:

--a. Crear la tabla llamada “Sede” que tendrá los campos:
--i. Código: será tipo entero y será la llave primaria.
--ii. Sede: será tipo varchar(50) y será obligatoria.
    CREATE TABLE SEDE (
    cod_sede INTEGER NOT NULL,
    sede VARCHAR(50) NOT NULL,
    PRIMARY KEY(cod_sede)
    );
--b. Cambiar el tipo de dato de la columna Ubicación de la tabla Evento
--por un tipo entero.
    ALTER TABLE Evento ALTER ubicacion TYPE INTEGER USING (ubicacion::integer);
--c. Crear una llave foránea en la columna Ubicación de la tabla Evento y
--referenciarla a la columna código de la tabla Sede, la que fue creada
--en el paso anterior.
    ALTER TABLE EVENTO  add CONSTRAINT FK_sede_evento_N
    FOREIGN KEY (ubicacion) REFERENCES SEDE (cod_sede) ON DELETE CASCADE;
--5----------------------------------------------------------------------------------
--Se revisó la información de los miembros que se tienen actualmente y antes
--de que se ingresen a la base de datos el Comité desea que a los miembros
--que no tengan número telefónico se le ingrese el número por Default 0 al
--momento de ser cargados a la base de datos.
    ALTER TABLE MIEMBRO ALTER COLUMN telefono SET DEFAULT 0;
--6-----------------------------------------------------------------------------
--Generar el script necesario para hacer la inserción de datos a las tablas
--requeridas.

--Revisar el documento “Insercion.pdf” compartido junto a este enunciado,
--ahí se encuentran las tablas y los datos que hay que insertar.

--Inserccion de Datos en las Tablas---------------------------------------------
--Tabla PAis
    INSERT INTO PAIS (cod_pais,nombre) VALUES (1,'Guatemala');
    INSERT INTO PAIS (cod_pais,nombre) VALUES (2,'Francia');
    INSERT INTO PAIS (cod_pais,nombre) VALUES (3,'Argentina');
    INSERT INTO PAIS (cod_pais,nombre) VALUES (4,'Alemania');
    INSERT INTO PAIS (cod_pais,nombre) VALUES (5,'Italia');
    INSERT INTO PAIS (cod_pais,nombre) VALUES (6,'Brasil');
    INSERT INTO PAIS (cod_pais,nombre) VALUES (7,'Estados Unidos');
--Tabla PROFESION
    INSERT INTO PROFESION (cod_prof,nombre) VALUES (1,'Medico');
    INSERT INTO PROFESION (cod_prof,nombre) VALUES (2,'Arquitecto');
    INSERT INTO PROFESION (cod_prof,nombre) VALUES (3,'Ingeniero');
    INSERT INTO PROFESION (cod_prof,nombre) VALUES (4,'Secretaria');
    INSERT INTO PROFESION(cod_prof,nombre) VALUES (5,'Auditor');
--tabla MIEMBRO
    INSERT INTO MIEMBRO (cod_miembro,nombre,apellido,edad,residencia,pais_cod_pais,profesion_cod_prof) 
                        VALUES (1,'Scott','Mitchell',32,'1092 Highland Drive Manitowoc, WI 54220',7,3);
    INSERT INTO MIEMBRO (cod_miembro,nombre,apellido,edad,telefono,residencia,pais_cod_pais,profesion_cod_prof) 
                        VALUES (2,'Fanette','Poulin',25,25075853,'49, boulevard Aristide Briand 76120 LE GRAND-QUEVILLY',2,4);
    INSERT INTO MIEMBRO (cod_miembro,nombre,apellido,edad,residencia,pais_cod_pais,profesion_cod_prof) 
                        VALUES (3,'Laura','Cunha Silva',55,'Rua Onze, 86 Uberaba-MG',6,5);
    INSERT INTO MIEMBRO (cod_miembro,nombre,apellido,edad,telefono,residencia,pais_cod_pais,profesion_cod_prof) 
                        VALUES (4,'Juan Jose','Lopez',38,36985247,'26 calle 4-10 zona 11',1,2);
    INSERT INTO MIEMBRO (cod_miembro,nombre,apellido,edad,telefono,residencia,pais_cod_pais,profesion_cod_prof) 
                        VALUES (5,'Arcangela','Panicucci',39,391664921,'Via Santa Teresa, 11490010-Geraci Siculo PA',5,1);
    INSERT INTO MIEMBRO (cod_miembro,nombre,apellido,edad,residencia,pais_cod_pais,profesion_cod_prof) 
                        VALUES (6,'Jeuel','Villalpando',31,'Acuña de Figeroa 610680101 Playa Pascual',3,5);
---tabla disciplina------------------------------------------------------------
INSERT INTO DISCIPLINA (cod_disciplina,nombre,descripcion) 
VALUES (1,'Atletismo','Saltos de longitud y triples, de altura y con pértiga o garrocha; las pruebas de lanzamiento de martillo, jabalina y disco.');

INSERT INTO DISCIPLINA (cod_disciplina,nombre) 
VALUES (2,'Badminton');

INSERT INTO DISCIPLINA (cod_disciplina,nombre) 
VALUES (3,'Ciclismo');

INSERT INTO DISCIPLINA (cod_disciplina,nombre,descripcion) 
VALUES (4,'Judo','Es un arte marcial que se originó en Japón alrededor de 1880');

INSERT INTO DISCIPLINA (cod_disciplina,nombre) 
VALUES (5,'Lucha');

INSERT INTO DISCIPLINA (cod_disciplina,nombre) 
VALUES (6,'Tenis de mesa');

INSERT INTO DISCIPLINA (cod_disciplina,nombre) 
VALUES (7,'Boxeo');

INSERT INTO DISCIPLINA (cod_disciplina,nombre,descripcion) 
VALUES (8,'Natacion','Está presente como deporte en los Juegos desde la primera edición de la era moderna, en Atenas, Grecia, en 1896, donde se disputo en aguas abiertas.');

INSERT INTO DISCIPLINA (cod_disciplina,nombre) 
VALUES (9,'Esgrima');   

INSERT INTO DISCIPLINA (cod_disciplina,nombre) 
VALUES (10,'Vela');
---------tabla TIPO_MEDALLA
INSERT INTO tipo_medalla (cod_tipo,medalla) VALUES (1,'Oro');
INSERT INTO tipo_medalla (cod_tipo,medalla) VALUES (2,'Plata');
INSERT INTO tipo_medalla (cod_tipo,medalla) VALUES (3,'Bronce');
INSERT INTO tipo_medalla (cod_tipo,medalla) VALUES (4,'Platino');
--CATEGORIA
INSERT INTO CATEGORIA (cod_categoria,categoria) VALUES (1,'Clasificatorio');
INSERT INTO CATEGORIA (cod_categoria,categoria) VALUES (2,'Eliminatorio');
INSERT INTO CATEGORIA (cod_categoria,categoria) VALUES (3,'Final');
--TIPO_PARTICIPACION--------------
INSERT INTO TIPO_PARTICIPACION (cod_participacion,tipo_participacion) VALUES (1,'Individual');
INSERT INTO TIPO_PARTICIPACION (cod_participacion,tipo_participacion) VALUES (2,'Parejas');
INSERT INTO TIPO_PARTICIPACION (cod_participacion,tipo_participacion) VALUES (3,'Equipos');
--MEDALLERO-----------------
INSERT INTO MEDALLERO (pais_cod_pais,tipo_medalla_cod_tipo,cantidad_medallas) VALUES (5,1,3);
INSERT INTO MEDALLERO (pais_cod_pais,tipo_medalla_cod_tipo,cantidad_medallas) VALUES (2,1,5);
INSERT INTO MEDALLERO (pais_cod_pais,tipo_medalla_cod_tipo,cantidad_medallas) VALUES (6,3,4);
INSERT INTO MEDALLERO (pais_cod_pais,tipo_medalla_cod_tipo,cantidad_medallas) VALUES (4,4,3);
INSERT INTO MEDALLERO (pais_cod_pais,tipo_medalla_cod_tipo,cantidad_medallas) VALUES (7,3,10);
INSERT INTO MEDALLERO (pais_cod_pais,tipo_medalla_cod_tipo,cantidad_medallas) VALUES (3,2,8);
INSERT INTO MEDALLERO (pais_cod_pais,tipo_medalla_cod_tipo,cantidad_medallas) VALUES (1,1,2);
INSERT INTO MEDALLERO (pais_cod_pais,tipo_medalla_cod_tipo,cantidad_medallas) VALUES (1,4,5);
INSERT INTO MEDALLERO (pais_cod_pais,tipo_medalla_cod_tipo,cantidad_medallas) VALUES (5,2,7);
--------SEDE_-------------------
INSERT INTO SEDE (cod_sede,sede) VALUES (1,'Gimnasio Metropolitano de Tokio');
INSERT INTO SEDE(cod_sede,sede) VALUES (2,'Jardin del palacio Imperial de Tokio');
INSERT INTO SEDE (cod_sede,sede) VALUES (3,'Gimnacio Nacional Yoyogi');
INSERT INTO SEDE (cod_sede,sede) VALUES (4,'Nippon Budokan');
INSERT INTO SEDE (cod_sede,sede) VALUES (5,'Estadio Olimpico');
--------EVENTO------------------------------------------------
INSERT INTO EVENTO (cod_evento,fecha_hora,ubicacion,DISCIPLINA_cod_disciplina,TIPO_PARTICIPACION_cod_participacion,categoria_cod_categoria) 
VALUES (1,to_timestamp('24 july 2020 11:00:00','dd month yyyy hh24:mi:ss'),3,2,2,1);

INSERT INTO EVENTO (cod_evento,fecha_hora,ubicacion,DISCIPLINA_cod_disciplina,TIPO_PARTICIPACION_cod_participacion,categoria_cod_categoria) 
VALUES (2,to_timestamp('26 july 2020 10:30:00','dd month yyyy hh24:mi:ss'),1,6,1,3);

INSERT INTO EVENTO (cod_evento,fecha_hora,ubicacion,DISCIPLINA_cod_disciplina,TIPO_PARTICIPACION_cod_participacion,categoria_cod_categoria) 
VALUES (3,to_timestamp('30 july 2020 18:45:00','dd month yyyy hh24:mi:ss'),5,7,1,2);

INSERT INTO EVENTO (cod_evento,fecha_hora,ubicacion,DISCIPLINA_cod_disciplina,TIPO_PARTICIPACION_cod_participacion,categoria_cod_categoria) 
VALUES (4,to_timestamp('01 august 2020 12:15:00','dd month yyyy hh24:mi:ss'),2,1,1,1);

INSERT INTO EVENTO (cod_evento,fecha_hora,ubicacion,DISCIPLINA_cod_disciplina,TIPO_PARTICIPACION_cod_participacion,categoria_cod_categoria) 
VALUES (5,to_timestamp('08 august 2020 19:35:00','dd month yyyy hh24:mi:ss'),4,10,3,1);

---7.-------------------------------------------------------------------------------
--Después de que se implementó el script el cuál creó todas las tablas de las
--bases de datos, el Comité Olímpico Internacional tomó la decisión de
--eliminar la restricción “UNIQUE” de las siguientes tablas:

--PAIS
 ALTER TABLE PAIS DROP CONSTRAINT nombre;
--TIPO_MEDALLA
 ALTER TABLE TIPO_MEDALLA DROP CONSTRAINT Medalla;
--DEPARTAMENTO
 ALTER TABLE DEPARTAMENTO DROP CONSTRAINT nombre;

 --8--------------------------------------------------------------------------
 --Después de un análisis más profundo se decidió que los Atletas pueden
--participar en varias disciplinas y no sólo en una como está reflejado
--actualmente en las tablas, por lo que se pide que realice lo siguiente.

--a. Script que elimine la llave foránea de “cod_disciplina” que se
--encuentra en la tabla “Atleta”.
     ALTER TABLE ATLETA DROP column  disciplina_cod_disciplina;
--b. Script que cree una tabla con el nombre “Disciplina_Atleta” que
--contendrá los siguiente campos:
--i. Cod_atleta (llave foránea de la tabla Atleta)
--ii. Cod_disciplina (llave foránea de la tabla Disciplina)
     CREATE TABLE DISCIPLINA_ATLETA
    (  cod_atleta integer NOT NULL, 
       cod_disciplina integer not null,
        primary key(cod_atleta,cod_disciplina)    
    );
    
    alter table DISCIPLINA_ATLETA  add constraint FK_ATLETA_DIS
    foreign key (cod_atleta)references ATLETA (cod_atleta) ON DELETE CASCADE;
    
    alter table DISCIPLINA_ATLETA  add constraint FK_DISCIPLINA_ATL
    foreign key (cod_disciplina)references DISCIPLINA (cod_disciplina) ON DELETE CASCADE;
--9.----------------------------------------------------------
--En la tabla “Costo_Evento” se determinó que la columna “tarifa” no debe
--ser entero sino un decimal con 2 cifras de precisión.

   alter table costo_evento alter column tarifa  type numeric(36,2);
   
--10-------------------------------------------------------------------
 --Generar el Script que borre de la tabla “Tipo_Medalla”, el registro siguiente
  Delete from Tipo_medalla where lower(medalla)='platino';

    --11-----------------------------------------------------------------
--  La fecha de las olimpiadas está cerca y los preparativos siguen, pero de
--último momento se dieron problemas con las televisoras encargadas de
--transmitir los eventos, ya que no hay tiempo de solucionar los problemas
--que se dieron, se decidió no transmitir el evento a través de las televisoras
--por lo que el Comité Olímpico pide generar el script que elimine la tabla
--“TELEVISORAS” y “COSTO_EVENTO”.
    DROP TABLE COSTO_EVENTO;
    DROP TABLE TELEVISORA;
    --12---------------------------------------------------------
--    El comité olímpico quiere replantear las disciplinas que van a llevarse a cabo,
--por lo cual pide generar el script que elimine todos los registros contenidos
--en la tabla “DISCIPLINA”.
Delete from disciplina;
---13---------------------------------------------------------------------------
--Los miembros que no tenían registrado su número de teléfono en sus
--perfiles fueron notificados, por lo que se acercaron a las instalaciones de
--Comité para actualizar sus datos.
UPDATE Miembro SET telefono = 55464601 
WHERE nombre='Laura' and Apellido='Cunha Silva';

UPDATE Miembro SET telefono = 55464601 
WHERE nombre='Jeuel' and Apellido='Villalpando';

UPDATE Miembro SET telefono = 55464601 
WHERE nombre='Scott' and Apellido='Mitchell';
--14-----------------------------------------------------------------------------------
--El Comité decidió que necesita la fotografía en la información de los atletas
--para su perfil, por lo que se debe agregar la columna “Fotografía” a la tabla
--Atleta, debido a que es un cambio de última hora este campo deberá ser
--opcional.
--Utilice el tipo de dato que crea conveniente según el DBMS y explique el por
--qué utilizó este tipo de dato.
ALTER TABLE ATLETA ADD fotografia bytea;
--Bytea permite guardar la imagen directamente en la bd para no guardar una ruta en caso de que sea una bd compartida
--y no correr riesgo de que la imagen cambie de ruta o no sea accesible de distintos equipos

--15-------------------------------------------------------------------------------------------------------------------
--Todos los atletas que se registren deben cumplir con ser menores a 25 años.
--De lo contrario no se debe poder registrar a un atleta en la base de datos.
ALTER TABLE ATLETA ADD CONSTRAINT constr_edad CHECK (edad<25);
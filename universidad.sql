-- SCRIPT EN REVISIÓN----

-- Crear Base de Datos "universidad" ----
CREATE DATABASE universidad;
-- Usar la Base de Datos "universidad" ----
USE universidad;
-- Crear las tablas----

-- cursos ----
CREATE TABLE cursos (
  idCurso INT PRIMARY KEY NOT NULL AUTO_INCREMENT,
  nombreDescriptivo VARCHAR(55) NOT NULL,
  nAsignatura INT NOT NULL
  );

-- profesores ----
CREATE TABLE profesores (
  idProfesor VARCHAR(55) NOT NULL PRIMARY KEY,
  nif VARCHAR(40) NOT NULL UNIQUE,
  nombre VARCHAR(55) NOT NULL,
  apellido1 VARCHAR(55) NOT NULL,
  apellido2 VARCHAR(55) NOT NULL,
  email VARCHAR(55) NOT NULL UNIQUE,
  direccion VARCHAR(255) NOT NULL,
  codigoPostal INT UNSIGNED NOT NULL,
  municipio VARCHAR(55) NOT NULL,
  provincia VARCHAR(55) NOT NULL,
  categoria VARCHAR(50) NOT NULL
  );

-- alumnos----
CREATE TABLE alumnos (
  idAlumno VARCHAR(55) PRIMARY KEY NOT NULL,
  nif VARCHAR(40) NOT NULL UNIQUE,
  nombre VARCHAR(55) NOT NULL,
  apellido1 VARCHAR(55) NOT NULL,
  apellido2 VARCHAR(55) NOT NULL,
  email VARCHAR(55) NOT NULL UNIQUE,
  direccion VARCHAR(255) NOT NULL,
  codigoPostal INT UNSIGNED NOT NULL,
  municipio VARCHAR(55) NOT NULL,
  provincia VARCHAR(55) NOT NULL,
  categoria VARCHAR(50) NOT NULL
);

-- asignaturas ---
CREATE TABLE asignaturas (
	 idCurso INT NOT NULL,
    idAsignatura VARCHAR(55) PRIMARY KEY NOT NULL,
    nombre VARCHAR(100) NOT NULL,
    cuatrimestre INT UNSIGNED NOT NULL,
    creditos INT UNSIGNED NOT NULL,
    caracter VARCHAR(55) NOT NULL,
    coordinador VARCHAR(55) NOT NULL,
    FOREIGN KEY (idCurso) REFERENCES cursos(idCurso),
    FOREIGN KEY (coordinador) REFERENCES profesores(idProfesor)
);

-- matricula ---
CREATE TABLE matricula (
	idAlumno VARCHAR(55) NOT NULL,
    idAsignatura VARCHAR(55) NOT NULL,
    nota INT UNSIGNED NOT NULL,
    FOREIGN KEY (idAlumno) REFERENCES alumnos(idAlumno),
    FOREIGN KEY (idAsignatura) REFERENCES asignaturas(idAsignatura)
);

-- impartir ---	
CREATE TABLE impartir (
	idProfesor VARCHAR(55) NOT NULL,
    idAsignatura VARCHAR(55) NOT NULL,
    FOREIGN KEY (idProfesor) REFERENCES profesores(idProfesor),
    FOREIGN KEY (idAsignatura) REFERENCES asignaturas(idAsignatura)
);

-- telefono Contacto del profesor ---
CREATE TABLE tlfContactoProf (
	idProfesor VARCHAR(55) NOT NULL,
    telefono INT UNIQUE NOT NULL,
    FOREIGN KEY (idProfesor) REFERENCES profesores(idProfesor)
);

-- Importar todos los datos de cada tabla ----

-- Alumnos ----
LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/carpeta_de_la_profe/alumnos.csv'
INTO TABLE alumnos
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

-- Cursos ----
LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/carpeta_de_la_profe/curso.csv'
INTO TABLE cursos
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

-- Profesores ----
LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/carpeta_de_la_profe/profesor.csv'
INTO TABLE profesores
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

-- Asignaturas ----

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/carpeta_de_la_profe/asignatura.csv'
INTO TABLE asignaturas
CHARACTER SET utf8mb4
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\r\n' -- Problema resuelto: Csv tenia saltos de linea de Windows (\r\n), es probable que fuera uno de los princpales problemas al insertar los FK y el error 1452, y además, al hacer las consultas, el coordinador PR005 era el único que salía, casualmente, no tenía ese salto de linea raro.--
IGNORE 1 ROWS;

-- Matricula ----
LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/carpeta_de_la_profe/matricula.csv'
INTO TABLE matricula
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

-- Impartir (Cuidado, no tiene PK, se puede importar tantas veces como se quiera)----
ALTER TABLE impartir ADD COLUMN id INT AUTO_INCREMENT PRIMARY KEY; -- Solucion: Agregar un id unico a cada fila, para no repetir.---
LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/carpeta_de_la_profe/impartir.csv'
INTO TABLE impartir
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS;

-- Telefono Contacto del Profesor ----
LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/carpeta_de_la_profe/tlfContactoProf.csv'
INTO TABLE tlfContactoProf
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

-- Consultas ----


-- 1. Información de cada asignatura con estadísticas de notas (Correcto)
SELECT a.idCurso AS curso, a.nombre, a.caracter, COUNT(m.idAlumno) AS alumnos, MIN(m.nota) AS nota_min, MAX(m.nota) AS nota_max, AVG(m.nota) AS nota_media
FROM asignaturas a
LEFT JOIN matricula m
ON a.idAsignatura = m.idAsignatura
GROUP BY a.idAsignatura
ORDER BY a.idCurso, a.nombre;

-- 2. Asignaturas con nota media menor que 5 (Correcto)
SELECT *
FROM (
SELECT a.idCurso AS curso, a.nombre, AVG(m.nota) AS media
FROM asignaturas a
JOIN matricula m
ON a.idAsignatura = m.idAsignatura
GROUP BY a.idAsignatura
) AS tabla
WHERE media < 5
ORDER BY curso, nombre;

-- 3. Número de profesores por categoría (Correcto)
SELECT categoria, COUNT(*) AS total
FROM profesores
GROUP BY categoria
ORDER BY total DESC;

-- 4. Asignatura con su profesor coordinador (Correcto)
SELECT c.nombreDescriptivo AS curso, a.nombre AS asignatura, a.caracter, p.nombre, p.apellido1, p.apellido2, p.email
FROM asignaturas a
JOIN cursos c
ON a.idCurso = c.idCurso
JOIN profesores p
ON a.coordinador = p.idProfesor
ORDER BY c.nombreDescriptivo, a.nombre;

-- 5. Número de asignaturas que imparte cada profesor (Correcto)
SELECT p.idProfesor, p.nombre, COUNT(i.idAsignatura) AS asignaturas
FROM profesores p
JOIN impartir i
ON p.idProfesor = i.idProfesor
GROUP BY p.idProfesor
ORDER BY asignaturas DESC;

-- 6. Alumnos con media mayor que 7
SELECT *
FROM (
SELECT a.nombre, a.apellido1, a.apellido2, AVG(m.nota) AS media
FROM alumno a
JOIN matricula m
ON a.idAlumno = m.idAlumno
GROUP BY a.idAlumno
) as tabla
WHERE media > 7
ORDER BY media DESC;

-- 7. Créditos totales por curso y carácter
SELECT curso, caracter, SUM(creditos) AS total_creditos
FROM asignatura
GROUP BY curso, caracter;

-- 8. Asignaturas optativas sin alumnos
SELECT a.idAsignatura, a.nombre, a.curso
FROM asignatura a
LEFT JOIN matricula m
ON a.idAsignatura = m.idAsignatura
WHERE a.caracter = 'Optativa'
AND m.idAlumno IS NULL;

-- 9. Alumnos que van a recuperación en asignaturas de primero
SELECT a.nombre, COUNT(m.idAlumno) AS alumnos_recuperacion
FROM asignatura a
JOIN matricula m
ON a.idAsignatura = m.idAsignatura
WHERE a.curso = 1
AND m.nota < 5
GROUP by a.idAsignatura;

-- 10. Alumnos que suspendieron Álgebra lineal
SELECT al.nombre, al.apellido1, al.apellido2, m.nota
FROM alumno al
JOIN matricula m
ON al.idAlumno = m.idAlumno
JOIN asignatura a
ON m.idAsignatura = a.idAsignatura
WHERE a.nombre = 'Álgebra lineal'
AND m.nota < 5;

-- 11. Alumnos de segundo curso con nota 10
SELECT a.nombre, a.apellido1, a.apellido2, asig.nombre, m.nota
FROM alumno a
JOIN matricula m
ON a.idAlumno = m.idAlumno
JOIN asignatura asig
ON m.idAsignatura = asig.idAsignatura
WHERE asig.curso = 2
AND m.nota = 10
ORDER BY asig.nombre;

-- 12. Número total de alumnos y alumnos con beca
SELECT COUNT(*) AS total_alumnos, SUM(beca = 'Sí') AS alumnos_beca
FROM alumno;

-- 13. Nota media de alumnos becados
SELECT a.nombre, a.apellido1, a.apellido2, asig.curso, AVG(m.nota) AS media
FROM alumno a
JOIN matricula m
ON a.idAlumno = m.idAlumno
JOIN asignatura asig
ON m.idAsignatura = asig.idAsignatura
WHERE a.beca = 'Sí'
GROUP BY a.idAlumno, asig.curso
ORDER BY asig.curso;

-- 14. Profesores con mejor media
SELECT p.nombre, p.apellido1, p.apellido2, AVG(m.nota) AS media
FROM profesor p
JOIN impartir i
ON p.idProfesor = i.idProfesor
JOIN matricula m
ON i.idAsignatura = m.idAsignatura
GROUP BY p.idProfesor
ORDER BY media DESC
LIMIT 10;

-- 15. Asignaturas con
SELECT *
FROM asignatura
WHERE nombre LIKE '%datos%'
OR nombre LIKE '%progra%'
ORDER BY curso, nombre;

-- 16. Lista de personas
SELECT nombre, apellido1, apellido2, email
FROM alumno;

SELECT nombre, apellido1, apellido2, email
FROM profesor;
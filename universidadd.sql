USE universidad;

-- 1. Información de cada asignatura con estadísticas de notas
SELECT a.curso, a.nombre, a.caracter, COUNT(m.idAlumno) AS alumnos, MIN(m.nota) AS nota_min, MAX(m.nota) AS nota_max, AVG(m.nota) AS nota_media
FROM asignatura a
LEFT JOIN matricula m
ON a.idAsignatura = m.idAsignatura
GROUP BY a.idAsignatura
ORDER BY a.curso, a.nombre;

-- 2. Asignaturas con nota media menor que 5
SELECT *
FROM (
SELECT a.curso, a.nombre, AVG(m.nota) AS media
FROM asignatura a
JOIN matricula m
ON a.idAsignatura = m.idAsignatura
GROUP BY a.idAsignatura
) AS tabla
WHERE media < 5
ORDER BY curso, nombre;

-- 3. Número de profesores por categoría
SELECT categoria, COUNT(*) AS total
FROM profesor
GROUP BY categoria
ORDER BY total DESC;

-- 4. Asignatura con su profesor coordinador
SELECT c.nombreDescriptivo, a.nombre, a.caracter, p.nombre, p.apellido1, p.apellido2, p.email
FROM asignatura a
JOIN curso c
ON a.curso = c.idCurso
JOIN profesor p
ON a.coordinador = p.idProfesor
ORDER BY c.nombreDescriptivo, a.nombre;

-- 5. Número de asignaturas que imparte cada profesor
SELECT p.idProfesor, p.nombre, COUNT(i.idAsignatura) AS asignaturas
FROM profesor p
JOIN impartir i
ON p.idProfesor = i.idProfesor
GROUP BY p.idProfesor
ORDER BY asignaturas desc;

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
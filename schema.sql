SET NAMES utf8mb4;
CREATE DATABASE IF NOT EXISTS faculty_software CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE faculty_software;

-- 1. Студенти-розробники
CREATE TABLE students (
                          id INT AUTO_INCREMENT PRIMARY KEY,
                          full_name VARCHAR(100) NOT NULL,
                          student_group VARCHAR(20) NOT NULL,
                          email VARCHAR(100) NOT NULL
);

-- 2. Викладачі-керівники / розробники
CREATE TABLE teachers (
                          id INT AUTO_INCREMENT PRIMARY KEY,
                          full_name VARCHAR(100) NOT NULL,
                          degree VARCHAR(50) NOT NULL,
                          department VARCHAR(100) NOT NULL
);

-- 3. Пакети прикладних програм (ППП)
CREATE TABLE software_packages (
                                   id INT AUTO_INCREMENT PRIMARY KEY,
                                   name VARCHAR(100) NOT NULL,
                                   version VARCHAR(20) NOT NULL,
                                   description TEXT NOT NULL
);

-- 4. Участь студентів та викладачів у розробці ППП (зв'язок)
CREATE TABLE package_developers (
                                    id INT AUTO_INCREMENT PRIMARY KEY,
                                    package_id INT NOT NULL,
                                    student_id INT NULL,
                                    teacher_id INT NULL,
                                    role VARCHAR(50) NOT NULL,
                                    FOREIGN KEY (package_id) REFERENCES software_packages(id) ON DELETE CASCADE,
                                    FOREIGN KEY (student_id) REFERENCES students(id) ON DELETE SET NULL,
                                    FOREIGN KEY (teacher_id) REFERENCES teachers(id) ON DELETE SET NULL
);

-- 5. Графік роботи семінарів для ознайомлення з ППП
CREATE TABLE seminars (
                          id INT AUTO_INCREMENT PRIMARY KEY,
                          package_id INT NOT NULL,
                          topic VARCHAR(150) NOT NULL,
                          seminar_date VARCHAR(30) NOT NULL, -- Формат: YYYY-MM-DD HH:MM
                          room VARCHAR(20) NOT NULL,
                          FOREIGN KEY (package_id) REFERENCES software_packages(id) ON DELETE CASCADE
);

-- 6. План проведення демонстрацій та тестових випробувань
CREATE TABLE demo_tests (
                            id INT AUTO_INCREMENT PRIMARY KEY,
                            package_id INT NOT NULL,
                            event_type VARCHAR(50) NOT NULL,   -- 'Демонстрація' або 'Тестування'
                            scheduled_date VARCHAR(30) NOT NULL,
                            status VARCHAR(30) NOT NULL,       -- 'Заплановано', 'Проведено'
                            FOREIGN KEY (package_id) REFERENCES software_packages(id) ON DELETE CASCADE
);

-- ==========================================

-- 1. Студенти-розробники
INSERT INTO students (full_name, student_group, email) VALUES
                                                           ('Коваленко Олександр Петрович', 'ІПС-31', 'o.kovalenko@univ.edu.ua'),
                                                           ('Мельник Анастасія Ігорівна', 'ІПС-31', 'a.melnyk@univ.edu.ua'),
                                                           ('Бондаренко Дмитро Сергійович', 'ІПС-41', 'd.bondarenko@univ.edu.ua');

-- 2. Викладачі
INSERT INTO teachers (full_name, degree, department) VALUES
                                                         ('Шевченко Андрій Вікторович', 'к.т.н., доцент', 'Кафедра інженерії ПЗ'),
                                                         ('Ткаченко Олена Миколаївна', 'д.ф.-м.н., професор', 'Кафедра прикладної математики');

-- 3. Пакети прикладних програм (ППП)
INSERT INTO software_packages (name, version, description) VALUES
                                                               ('MatrixSolver', '1.2.0', 'Пакет для розв''язання систем лінійних рівнянь та знаходження власних значень'),
                                                               ('NetSimFaculty', '2.0.1', 'Симулятор локальних мереж для лабораторних робіт'),
                                                               ('GraphLab', '0.9.5', 'Інструмент для візуалізації та аналізу алгоритмів на графах');

-- 4. Участь студентів та викладачів у розробці ППП
INSERT INTO package_developers (package_id, student_id, teacher_id, role) VALUES
                                                                              (1, 1, NULL, 'Головний розробник'),
                                                                              (1, NULL, 2, 'Науковий керівник'),
                                                                              (2, 2, NULL, 'Backend-розробник'),
                                                                              (2, 3, NULL, 'Тестувальник'),
                                                                              (2, NULL, 1, 'Керівник проєкту'),
                                                                              (3, 1, NULL, 'Розробник візуалізації');

-- 5. Графік роботи семінарів
INSERT INTO seminars (package_id, topic, seminar_date, room) VALUES
                                                                 (1, 'Огляд чисельних методів у MatrixSolver', '2026-12-02 14:00', 'Ауд. 304'),
                                                                 (2, 'Налаштування топологій у NetSimFaculty', '2026-12-05 12:30', 'Ауд. 215'),
                                                                 (3, 'Пошук найкоротших шляхів за допомогою GraphLab', '2026-12-10 15:30', 'Ауд. 308');

-- 6. План проведення демонстрацій та тестових випробувань
INSERT INTO demo_tests (package_id, event_type, scheduled_date, status) VALUES
                                                                            (1, 'Демонстрація', '2026-12-12 10:00', 'Заплановано'),
                                                                            (1, 'Тестування', '2026-12-01 16:00', 'Проведено'),
                                                                            (2, 'Тестування', '2026-12-14 11:00', 'Заплановано'),
                                                                            (3, 'Демонстрація', '2026-12-18 14:30', 'Заплановано');
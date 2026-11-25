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
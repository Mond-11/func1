{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE ScopedTypeVariables #-}

module Main where

import Control.Monad (void)
import Database.MySQL.Simple
import Database.MySQL.Simple.QueryResults (QueryResults(..), convertError)
import Database.MySQL.Simple.Result (Result, convert)
import System.IO (hFlush, stdout)


-- ==========================================
--       МОДЕЛІ ДАНИХ
-- ==========================================

data Student = Student
  { stId    :: Int
  , stName  :: String
  , stGroup :: String
  , stEmail :: String
  } deriving (Show)

data Teacher = Teacher
  { tId         :: Int
  , tName       :: String
  , tDegree     :: String
  , tDepartment :: String
  } deriving (Show)

data SoftwarePackage = SoftwarePackage
  { pkgId   :: Int
  , pkgName :: String
  , pkgVer  :: String
  , pkgDesc :: String
  } deriving (Show)

data Seminar = Seminar
  { semId    :: Int
  , semPkgId :: Int
  , semTopic :: String
  , semDate  :: String
  , semRoom  :: String
  } deriving (Show)

data DemoTest = DemoTest
  { dtId     :: Int
  , dtPkgId  :: Int
  , dtType   :: String
  , dtDate   :: String
  , dtStatus :: String
  } deriving (Show)

-- ==========================================
--    КЛАС ТИПІВ ДЛЯ РОБОТИ З БД (CLASS)
-- ==========================================

class DBEntity a where
  insertEntity :: Connection -> a -> IO ()
  updateEntity :: Connection -> Int -> a -> IO ()
  getAll       :: Connection -> IO [a]
  formatEntity :: a -> String

-- ==========================================
--      РЕАЛІЗАЦІЇ (INSTANCES)
-- ==========================================

-- --- Student ---
instance QueryResults Student where
  convertResults [fa, fb, fc, fd] [va, vb, vc, vd] =
    Student (convert fa va) (convert fb vb) (convert fc vc) (convert fd vd)
  convertResults fs vs = convertError fs vs 4

instance DBEntity Student where
  insertEntity conn s = void $ execute conn
    "INSERT INTO students (full_name, student_group, email) VALUES (?, ?, ?)"
    (stName s, stGroup s, stEmail s)

  updateEntity conn eid s = void $ execute conn
    "UPDATE students SET full_name = ?, student_group = ?, email = ? WHERE id = ?"
    (stName s, stGroup s, stEmail s, eid)

  getAll conn = query_ conn "SELECT id, full_name, student_group, email FROM students"

  formatEntity s =
    "[" ++ show (stId s) ++ "] " ++ stName s ++ " | Група: " ++ stGroup s ++ " | " ++ stEmail s

-- --- Teacher ---
instance QueryResults Teacher where
  convertResults [fa, fb, fc, fd] [va, vb, vc, vd] =
    Teacher (convert fa va) (convert fb vb) (convert fc vc) (convert fd vd)
  convertResults fs vs = convertError fs vs 4

instance DBEntity Teacher where
  insertEntity conn t = void $ execute conn
    "INSERT INTO teachers (full_name, degree, department) VALUES (?, ?, ?)"
    (tName t, tDegree t, tDepartment t)

  updateEntity conn eid t = void $ execute conn
    "UPDATE teachers SET full_name = ?, degree = ?, department = ? WHERE id = ?"
    (tName t, tDegree t, tDepartment t, eid)

  getAll conn = query_ conn "SELECT id, full_name, degree, department FROM teachers"

  formatEntity t =
    "[" ++ show (tId t) ++ "] " ++ tName t ++ " (" ++ tDegree t ++ ") | Кафедра: " ++ tDepartment t

-- --- SoftwarePackage ---
instance QueryResults SoftwarePackage where
  convertResults [fa, fb, fc, fd] [va, vb, vc, vd] =
    SoftwarePackage (convert fa va) (convert fb vb) (convert fc vc) (convert fd vd)
  convertResults fs vs = convertError fs vs 4

instance DBEntity SoftwarePackage where
  insertEntity conn p = void $ execute conn
    "INSERT INTO software_packages (name, version, description) VALUES (?, ?, ?)"
    (pkgName p, pkgVer p, pkgDesc p)

  updateEntity conn eid p = void $ execute conn
    "UPDATE software_packages SET name = ?, version = ?, description = ? WHERE id = ?"
    (pkgName p, pkgVer p, pkgDesc p, eid)

  getAll conn = query_ conn "SELECT id, name, version, description FROM software_packages"

  formatEntity p =
    "[" ++ show (pkgId p) ++ "] " ++ pkgName p ++ " v" ++ pkgVer p ++ " — " ++ pkgDesc p

-- --- Seminar ---
instance QueryResults Seminar where
  convertResults [fa, fb, fc, fd, fe] [va, vb, vc, vd, ve] =
    Seminar (convert fa va) (convert fb vb) (convert fc vc) (convert fd vd) (convert fe ve)
  convertResults fs vs = convertError fs vs 5

instance DBEntity Seminar where
  insertEntity conn s = void $ execute conn
    "INSERT INTO seminars (package_id, topic, seminar_date, room) VALUES (?, ?, ?, ?)"
    (semPkgId s, semTopic s, semDate s, semRoom s)

  updateEntity conn eid s = void $ execute conn
    "UPDATE seminars SET package_id = ?, topic = ?, seminar_date = ?, room = ? WHERE id = ?"
    (semPkgId s, semTopic s, semDate s, semRoom s, eid)

  getAll conn = query_ conn "SELECT id, package_id, topic, seminar_date, room FROM seminars"

  formatEntity s =
    "[" ++ show (semId s) ++ "] ППП #" ++ show (semPkgId s) ++ " | " ++ semTopic s
    ++ " | Дата: " ++ semDate s ++ " | Ауд.: " ++ semRoom s

-- --- DemoTest ---
instance QueryResults DemoTest where
  convertResults [fa, fb, fc, fd, fe] [va, vb, vc, vd, ve] =
    DemoTest (convert fa va) (convert fb vb) (convert fc vc) (convert fd vd) (convert fe ve)
  convertResults fs vs = convertError fs vs 5

instance DBEntity DemoTest where
  insertEntity conn d = void $ execute conn
    "INSERT INTO demo_tests (package_id, event_type, scheduled_date, status) VALUES (?, ?, ?, ?)"
    (dtPkgId d, dtType d, dtDate d, dtStatus d)

  updateEntity conn eid d = void $ execute conn
    "UPDATE demo_tests SET package_id = ?, event_type = ?, scheduled_date = ?, status = ? WHERE id = ?"
    (dtPkgId d, dtType d, dtDate d, dtStatus d, eid)

  getAll conn = query_ conn "SELECT id, package_id, event_type, scheduled_date, status FROM demo_tests"

  formatEntity d =
    "[" ++ show (dtId d) ++ "] ППП #" ++ show (dtPkgId d) ++ " | " ++ dtType d
    ++ " | Дата: " ++ dtDate d ++ " | Статус: " ++ dtStatus d

-- ==========================================
--     ДОПОМІЖНІ ФУНКЦІЇ ТА ІНТЕРФЕЙС
-- ==========================================

prompt :: String -> IO String
prompt text = putStr text >> hFlush stdout >> getLine

printList :: DBEntity a => [a] -> IO ()
printList [] = putStrLn "  (Записів немає)"
printList xs = mapM_ (putStrLn . ("  " ++) . formatEntity) xs

mainMenu :: Connection -> IO ()
mainMenu conn = do
  putStrLn "\n=== ІС: Пакети прикладних програм факультету ==="
  putStrLn "1. Показати всі ППП"
  putStrLn "2. Додати новий ППП"
  putStrLn "3. Коригувати ППП"
  putStrLn "4. Показати студентів"
  putStrLn "5. Додати студента"
  putStrLn "6. Показати графік семінарів"
  putStrLn "7. Додати семінар"
  putStrLn "8. Показати план демонстрацій та тестувань"
  putStrLn "9. Додати демонстрацію/тестування"
  putStrLn "0. Вихід"
  choice <- prompt "Оберіть дію: "
  case choice of
    "1" -> do
      (pkgs :: [SoftwarePackage]) <- getAll conn
      printList pkgs
      mainMenu conn
    "2" -> do
      n <- prompt "Назва ППП: "
      v <- prompt "Версія: "
      d <- prompt "Опис: "
      insertEntity conn (SoftwarePackage 0 n v d)
      putStrLn "ППП додано."
      mainMenu conn
    "3" -> do
      eid <- read <$> prompt "ID ППП для редагування: "
      n   <- prompt "Нова назва: "
      v   <- prompt "Нова версія: "
      d   <- prompt "Новий опис: "
      updateEntity conn eid (SoftwarePackage eid n v d)
      putStrLn "ППП оновлено."
      mainMenu conn
    "4" -> do
      (sts :: [Student]) <- getAll conn
      printList sts
      mainMenu conn
    "5" -> do
      n <- prompt "ПІБ студента: "
      g <- prompt "Група: "
      e <- prompt "Email: "
      insertEntity conn (Student 0 n g e)
      putStrLn "Студента додано."
      mainMenu conn
    "6" -> do
      (sems :: [Seminar]) <- getAll conn
      printList sems
      mainMenu conn
    "7" -> do
      pid <- read <$> prompt "ID ППП: "
      t   <- prompt "Тема семінару: "
      dt  <- prompt "Дата та час (YYYY-MM-DD HH:MM): "
      r   <- prompt "Аудиторія: "
      insertEntity conn (Seminar 0 pid t dt r)
      putStrLn "Семінар додано."
      mainMenu conn
    "8" -> do
      (dts :: [DemoTest]) <- getAll conn
      printList dts
      mainMenu conn
    "9" -> do
      pid <- read <$> prompt "ID ППП: "
      tp  <- prompt "Тип (Демонстрація / Тестування): "
      dt  <- prompt "Дата (YYYY-MM-DD HH:MM): "
      st  <- prompt "Статус (Заплановано / Проведено): "
      insertEntity conn (DemoTest 0 pid tp dt st)
      putStrLn "Запис додано."
      mainMenu conn
    "0" -> putStrLn "Роботу завершено."
    _   -> putStrLn "Невірний вибір." >> mainMenu conn

main :: IO ()
main = do
  conn <- connect defaultConnectInfo
    { connectHost     = "db"
    , connectUser     = "root"
    , connectPassword = "rootpass"
    , connectDatabase = "faculty_software"
    }
  mainMenu conn
  close conn
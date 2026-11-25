{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE ScopedTypeVariables #-}

module Main where

import Control.Monad (void)
import Database.MySQL.Simple
import Database.MySQL.Simple.QueryResults (QueryResults(..), convertError)
import Database.MySQL.Simple.Result (convert)
import System.IO (hFlush, stdout)
import Text.Read (readMaybe)

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

data PackageDeveloper = PackageDeveloper
  { pdId        :: Int
  , pdPkgId     :: Int
  , pdStudentId :: Maybe Int
  , pdTeacherId :: Maybe Int
  , pdRole      :: String
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

class DBEntity a where
  insertEntity :: Connection -> a -> IO ()
  updateEntity :: Connection -> Int -> a -> IO ()
  getAll       :: Connection -> IO [a]
  formatEntity :: a -> String

-- ==========================================

-- --- 1. Student ---
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

-- --- 2. Teacher ---
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

-- --- 3. SoftwarePackage ---
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

-- --- 4. PackageDeveloper ---
instance QueryResults PackageDeveloper where
  convertResults [fa, fb, fc, fd, fe] [va, vb, vc, vd, ve] =
    PackageDeveloper (convert fa va) (convert fb vb) (convert fc vc) (convert fd vd) (convert fe ve)
  convertResults fs vs = convertError fs vs 5

instance DBEntity PackageDeveloper where
  insertEntity conn pd = void $ execute conn
    "INSERT INTO package_developers (package_id, student_id, teacher_id, role) VALUES (?, ?, ?, ?)"
    (pdPkgId pd, pdStudentId pd, pdTeacherId pd, pdRole pd)

  updateEntity conn eid pd = void $ execute conn
    "UPDATE package_developers SET package_id = ?, student_id = ?, teacher_id = ?, role = ? WHERE id = ?"
    (pdPkgId pd, pdStudentId pd, pdTeacherId pd, pdRole pd, eid)

  getAll conn = query_ conn
    "SELECT id, package_id, student_id, teacher_id, role FROM package_developers"

  formatEntity pd =
    "[" ++ show (pdId pd) ++ "] ППП #" ++ show (pdPkgId pd)
    ++ " | Студент: " ++ maybe "-" (("#" ++) . show) (pdStudentId pd)
    ++ " | Викладач: " ++ maybe "-" (("#" ++) . show) (pdTeacherId pd)
    ++ " | Роль: " ++ pdRole pd

-- --- 5. Seminar ---
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

-- --- 6. DemoTest ---
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

prompt :: String -> IO String
prompt text = putStr text >> hFlush stdout >> getLine

promptInt :: String -> IO Int
promptInt text = do
  s <- prompt text
  case readMaybe s of
    Just n  -> return n
    Nothing -> putStrLn "  Помилка: введіть ціле число." >> promptInt text

promptMaybeInt :: String -> IO (Maybe Int)
promptMaybeInt text = do
  s <- prompt text
  if null s
    then return Nothing
    else case readMaybe s of
      Just n  -> return (Just n)
      Nothing -> putStrLn "  Помилка: введіть число або залиште порожнім." >> promptMaybeInt text

printList :: DBEntity a => [a] -> IO ()
printList [] = putStrLn "  (Записів немає)"
printList xs = mapM_ (putStrLn . ("  " ++) . formatEntity) xs

-- ==========================================

entityMenu :: forall a. DBEntity a => String -> Connection -> IO a -> IO ()
entityMenu title conn readItem = loop
  where
    loop = do
      putStrLn $ "\n--- " ++ title ++ " ---"
      putStrLn "1. Переглянути всі записи"
      putStrLn "2. Додати запис"
      putStrLn "3. Коригувати запис за ID"
      putStrLn "0. Назад"
      ch <- prompt "Оберіть дію: "
      case ch of
        "1" -> (getAll conn :: IO [a]) >>= printList >> loop
        "2" -> do
          item <- readItem
          insertEntity conn item
          putStrLn "Запис додано."
          loop
        "3" -> do
          eid  <- promptInt "Введіть ID запису для коригування: "
          item <- readItem
          updateEntity conn eid item
          putStrLn "Запис оновлено."
          loop
        "0" -> return ()
        _   -> putStrLn "Невірний вибір." >> loop

readPackage :: IO SoftwarePackage
readPackage = SoftwarePackage 0
  <$> prompt "Назва ППП: "
  <*> prompt "Версія: "
  <*> prompt "Опис: "

readStudent :: IO Student
readStudent = Student 0
  <$> prompt "ПІБ студента: "
  <*> prompt "Група: "
  <*> prompt "Email: "

readTeacher :: IO Teacher
readTeacher = Teacher 0
  <$> prompt "ПІБ викладача: "
  <*> prompt "Науковий ступінь / звання: "
  <*> prompt "Кафедра: "

readDeveloper :: IO PackageDeveloper
readDeveloper = PackageDeveloper 0
  <$> promptInt "ID ППП: "
  <*> promptMaybeInt "ID студента (Enter, якщо не студент): "
  <*> promptMaybeInt "ID викладача (Enter, якщо не викладач): "
  <*> prompt "Роль у проєкті: "

readSeminar :: IO Seminar
readSeminar = Seminar 0
  <$> promptInt "ID ППП: "
  <*> prompt "Тема семінару: "
  <*> prompt "Дата та час (YYYY-MM-DD HH:MM): "
  <*> prompt "Аудиторія: "

readDemoTest :: IO DemoTest
readDemoTest = DemoTest 0
  <$> promptInt "ID ППП: "
  <*> prompt "Тип (Демонстрація / Тестування): "
  <*> prompt "Дата (YYYY-MM-DD HH:MM): "
  <*> prompt "Статус (Заплановано / Проведено): "

-- ==========================================

mainMenu :: Connection -> IO ()
mainMenu conn = do
  putStrLn "\n=== ІС: Пакети прикладних програм факультету ==="
  putStrLn "1. Пакети прикладних програм (ППП)"
  putStrLn "2. Студенти-розробники"
  putStrLn "3. Викладачі"
  putStrLn "4. Участь у розробці ППП (зв'язки)"
  putStrLn "5. Графік семінарів"
  putStrLn "6. План демонстрацій та тестувань"
  putStrLn "0. Вихід"
  choice <- prompt "Оберіть розділ: "
  case choice of
    "1" -> entityMenu "Пакети прикладних програм" conn readPackage >> mainMenu conn
    "2" -> entityMenu "Студенти-розробники" conn readStudent >> mainMenu conn
    "3" -> entityMenu "Викладачі" conn readTeacher >> mainMenu conn
    "4" -> entityMenu "Участь у розробці ППП" conn readDeveloper >> mainMenu conn
    "5" -> entityMenu "Графік семінарів" conn readSeminar >> mainMenu conn
    "6" -> entityMenu "План демонстрацій та тестувань" conn readDemoTest >> mainMenu conn
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
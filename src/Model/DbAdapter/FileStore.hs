module Model.DbAdapter.FileStore (
    -- ^ retrieve all
    getAllCourses

    -- ^ retrieve one by primary key
  , getCourse
  , getStudent
  , getTask
  , getTaskInstance
  , getTutor

    -- ^ retrieve many by primary jey 
  , getGroups

    -- ^ retrieve many by foreign key
  , getAssignmentsByCourse
  , getAssignmentsByTask
  , getCoursesByTutor
  , getEnrollmentsByStudent
  , getGroupsByCourse
  , getSolutionsByTaskInstance
  , getTasksByTutor
  , getTaskInstancesByAssignment

    -- ^ create
  , createAssignment
  , createCourse
  , createEnrollment
  , createGroup
  , createSolution
  , createTask
  , createTaskInstance

    -- ^ other
  , getLastSolutionsByTaskInstance

    -- ^ helper
  , createFiles

  ) where

------------------------------------------------------------------------------
import           Data.Map             (Map)
import qualified Data.Map             as Map
import           System.IO            hiding (hGetContents)
import           System.IO.Strict     (hGetContents)
------------------------------------------------------------------------------
import           Snap                 (liftIO, (<$>))
------------------------------------------------------------------------------
import           Application          (AppHandler)
import           Model.Indexable
import           Model.Types


------------------------------------------------------------------------------
-- | Returns the filepath to a specific data file.
datafile :: String -> String
datafile name = "data/" ++ name


loadMap :: (Read a) => String -> IO (Map Integer a)
loadMap name = do
    handle   <- liftIO $ openFile (datafile name) ReadMode
    contents <- liftIO $ hGetContents handle
    liftIO $ hClose handle
    return $ Map.fromList (map read $ lines contents)

------------------------------------------------------------------------------ 
-- | Generic getter and setter.
get :: (Read a) => String -> Integer -> AppHandler (Maybe a)
get name oid = do
    objectMap <- liftIO $ loadMap name
    return $ Map.lookup oid objectMap

------------------------------------------------------------------------------
-- | Return all stored records from a file.
list :: (Read a) => String -> AppHandler [a]
list name = do
    objectMap <- liftIO $ loadMap name
    return . Map.elems $ objectMap

------------------------------------------------------------------------------
-- | Determine the next free index and store the record in a file.
create :: (Read a, Show a, Indexable a) => String -> a -> AppHandler Integer
create name object = do
    objectMap <- liftIO $ loadMap name
    let newObject  = constructOrCopy object objectMap
        newObjects = Map.insert (iid newObject) newObject objectMap
    handle <- liftIO $ openFile (datafile name) WriteMode
    liftIO $ hPutStr handle . unlines $ map show (Map.toList newObjects)
    liftIO $ hClose handle
    return $ iid newObject
  where
    constructOrCopy obj objs
      | iid object == 0 = setId object (getNextId objs)
      | otherwise       = obj


------------------------------------------------------------------------------ 
-- | Specific getters.

getAssignmentsByCourse :: CourseId -> AppHandler [Assignment]
getAssignmentsByCourse cid =
    filter (\a -> assignmentCourse a == cid) <$> list "assignments"

getAssignmentsByTask :: TaskId -> AppHandler [Assignment]
getAssignmentsByTask tid =
    filter (\a -> assignmentTask a == tid) <$> list "assignments"

------------------------------------------------------------------------------ 

getCourse :: Integer -> AppHandler (Maybe Course)
getCourse = get "courses"

getCoursesByTutor :: TutorId -> AppHandler [Course]
getCoursesByTutor tid =
    filter (\c -> courseTutor c == tid) <$> list "courses"

getAllCourses :: AppHandler [Course]
getAllCourses = list "courses"

------------------------------------------------------------------------------ 

getEnrollmentsByStudent :: StudentId -> AppHandler [Enrollment]
getEnrollmentsByStudent sid =
    filter (\e -> enrollmentStudent e == sid) <$> list "enrollments"

------------------------------------------------------------------------------ 

getGroups :: [GroupId] -> AppHandler [Group]
getGroups gids =
    filter (\g -> groupId g `elem` gids) <$> list "groups"

getGroupsByCourse :: CourseId -> AppHandler [Group]
getGroupsByCourse cid =
    filter (\g -> groupCourse g == cid) <$> list "groups"

------------------------------------------------------------------------------ 

getSolutionsByTaskInstance :: TaskInstanceId -> AppHandler [Solution]
getSolutionsByTaskInstance tid =
    filter (\s -> solutionTaskInstance s == tid) <$> list "solutions"

getLastSolutionsByTaskInstance :: TaskInstanceId -> AppHandler (Maybe Solution)
getLastSolutionsByTaskInstance tid =
    listToMaybe <$>
    filter (\s -> solutionTaskInstance s == tid) <$> list "solutions"

------------------------------------------------------------------------------ 

getStudent :: Integer -> AppHandler (Maybe Student)
getStudent = get "students"

------------------------------------------------------------------------------ 

getTask :: Integer -> AppHandler (Maybe Task)
getTask = get "tasks"

getTasksByTutor :: TutorId -> AppHandler [Task]
getTasksByTutor tid = do
    filter (\t -> taskTutor t == tid) <$> list "tasks"

------------------------------------------------------------------------------ 

getTutor :: Integer -> AppHandler (Maybe Tutor)
getTutor = get "tutors"

------------------------------------------------------------------------------ 

getTaskInstance :: Integer -> AppHandler (Maybe TaskInstance)
getTaskInstance = get "task_instances"

getTaskInstancesByAssignment :: AssignmentId -> AppHandler [TaskInstance]
getTaskInstancesByAssignment aid =
    filter (\t -> taskInstanceAssignment t == aid) <$> list "task_instances"


------------------------------------------------------------------------------ 
-- | Specific setters.

createAssignment :: AssignmentValues -> AppHandler AssignmentId
createAssignment (course, task, status, start, end) =
    create "assignments" $ Assignment 0 course task status start end

createCourse :: CourseValues -> AppHandler CourseId
createCourse (tutor, name, semester, enrol_from, enrol_to, pass_criteria) =
    create "courses" $ Course 0 tutor name semester enrol_from enrol_to
                              pass_criteria

createEnrollment :: EnrollmentValues -> AppHandler EnrollmentId
createEnrollment (group, student, time) =
    create "enrollments" $ Enrollment 0 group student time

createGroup :: GroupValues -> AppHandler GroupId
createGroup (course, description, capacity)=
    create "groups" $ Group 0 course description capacity

createSolution :: SolutionValues -> AppHandler SolutionId
createSolution (task_instance, content, evaluation, result, submission) =
    create "solutions" $ Solution 0 task_instance content evaluation result
                                  submission

createTask :: TaskValues -> AppHandler TaskId
createTask (tutor, name, type_, signature, scoring_order, created) =
    create "tasks" $ Task 0 tutor name type_ signature scoring_order created

createTaskInstance :: TaskInstanceValues -> AppHandler TaskInstanceId
createTaskInstance (assignment, student, desc, doc, solution, signature) =
    create "task_instances" $ TaskInstance 0 assignment student desc doc
                                           solution signature


------------------------------------------------------------------------------ 
-- | Utils.
listToMaybe :: [a] -> Maybe a
listToMaybe [] = Nothing
listToMaybe xs = Just $ last xs

------------------------------------------------------------------------------
-- | Return the highest found index (id) + 1 from a list of indexable DTs.
getNextId :: (Indexable a) => Map Integer a -> Integer
getNextId m | Map.null m = 1
            | otherwise  = maximum (Map.keys m) + 1

------------------------------------------------------------------------------ 
-- | Set up.
createFiles :: IO ()
createFiles = do
  appendFile "data/assignments"   ""
  appendFile "data/courses"       ""
  appendFile "data/enrollments"   ""
  appendFile "data/groups"        ""
  appendFile "data/solutions"     ""
  appendFile "data/task_instances" ""
  appendFile "data/tasks"         ""

  appendFile "data/tutors"        ""
  appendFile "data/students"      ""

  tutors <- loadMap "tutors"
  case Map.lookup 1 tutors of
    (Just (Tutor _ _)) -> return ()
    Nothing            -> do
      appendFile "data/tutors" $
        show (1::Int, Tutor 1 "tutor1@htwk-leipzig.de") ++ "\n"
      appendFile "data/tutors" $
        show (2::Int, Tutor 2 "tutor2@htwk-leipzig.de")

  students <- loadMap "students"
  case Map.lookup 1 students of
    (Just (Student _ _)) -> return ()
    Nothing              -> do
      appendFile "data/students" $
        show (1::Int, Student 1 "student1@htwk-leipzig.de") ++ "\n"
      appendFile "data/students" $
        show (2::Int, Student 2 "student2@htwk-leipzig.de") ++ "\n"
      appendFile "data/students" $
        show (3::Int, Student 3 "student3@htwk-leipzig.de") ++ "\n"
      appendFile "data/students" $
        show (4::Int, Student 4 "student4@htwk-leipzig.de")

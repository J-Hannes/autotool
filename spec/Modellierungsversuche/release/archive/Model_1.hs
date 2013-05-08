-------------------------------------------------------------------------------
-- MODEL
-------------------------------------------------------------------------------
module Model where

import Data.Set (Set)
import Data.Time (UTCTime)
import Autotool.Client.Types.ScoringOrder (ScoringOrder)


-------------------------------------------------------------------------------
-- COMMON
-------------------------------------------------------------------------------

data FullName = FullName
  { prename :: String
  , surname :: String
  } deriving (Eq, Read, Show)

data TimeSpan = TimeSpan
  { from :: UTCTime
  , to   :: UTCTime
  } deriving (Eq, Read, Show)

type ServerHash = String


-------------------------------------------------------------------------------
-- INDEX
-------------------------------------------------------------------------------

newtype TutorId = TutorId
  { unTutorId :: Integer
  } deriving (Eq, Ord, Read, Show)

newtype CourseId = CourseId
  { unCourseId :: Integer
  } deriving (Eq, Ord, Read, Show)

newtype GroupId = GroupId
  { unGroupId   :: Integer
  } deriving (Eq, Ord, Read, Show)

newtype StudentId = StudentId
  { unStudentId :: Integer
  } deriving (Eq, Ord, Read, Show)

newtype TaskId = TaskId
  { unTaskId :: Integer
  } deriving (Eq, Ord, Read, Show)

newtype AssignmentId = AssignmentId
  { unAssignmentId :: Integer
  } deriving (Eq, Ord, Read, Show)

newtype TaskInstanceId = TaskInstanceId
  { unTaskInstanceId :: Integer
  } deriving (Eq, Ord, Read, Show)

newtype SolutionId = SolutionId
  { unSolutionId :: Integer
  } deriving (Eq, Ord, Read, Show)


-------------------------------------------------------------------------------
-- TUTOR
-------------------------------------------------------------------------------

data Tutor = Tutor {
    -- ^ Identifier
    tutorId       :: TutorId

    -- ^ Attributes
  , tutorName     :: FullName
  , tutorEmail    :: String
  , tutorPassword :: String

    -- ^ Relationships
  , tutorCourses  :: Set CourseId
  , tutorTasks    :: Set TaskId

  } deriving (Eq, Read, Show)



-------------------------------------------------------------------------------
-- COURSE
-------------------------------------------------------------------------------

data Course = Course {
    -- ^ Identifier
    courseId          :: CourseId

    -- ^ Attributes
  , courseName        :: String
  , courseSemester    :: Semester
  , courseEnrollment  :: TimeSpan

    -- ^ Relationships
  , courseTutor       :: TutorId
  , courseGroups      :: Set GroupId
  , courseAssignments :: Set AssignmentId

  } deriving (Eq, Read, Show)

data Semester = SS13 deriving (Eq, Read, Show)


-------------------------------------------------------------------------------
-- GROUP
-------------------------------------------------------------------------------

data Group = Group {
    -- ^ Identifier
    groupId       :: GroupId

    -- ^ Attributes
  , groupName     :: String
  , groupCapacity :: Int

    -- ^ Relationships
  , groupCourse   :: CourseId
  , groupStudents :: Set StudentId

  } deriving (Eq, Read, Show)


-------------------------------------------------------------------------------
-- STUDENT
-------------------------------------------------------------------------------

data Student = Student {
    -- ^ Identifier
    studentId            :: StudentId

    -- ^ Attributes
  , studentName          :: FullName
  , studentEmail         :: String
  , studentPassword      :: String

    -- ^ Relationships
  , studentGroups        :: Set GroupId
  , studentTaskInstances :: Set TaskInstanceId

  } deriving (Eq, Read, Show)


-------------------------------------------------------------------------------
-- TASK
-------------------------------------------------------------------------------

data Task = Task {
    -- ^ Identifier
    taskId           :: TaskId

    -- ^ Attributes
  , taskName         :: String
  , taskSignature    :: ServerHash
  , taskScoringOrder :: ScoringOrder

    -- ^ Relationships
  , taskTutor        :: TutorId
  , taskAssignments  :: Set AssignmentId

  } deriving (Eq, Read, Show)


-------------------------------------------------------------------------------
-- ASSIGNMENT
-------------------------------------------------------------------------------

data Assignment = Assignment {
    -- ^ Identifier
    assignmentId            :: AssignmentId

    -- ^ Attributes
  , assignmentStatus        :: Status
  , assignmentSubmission    :: TimeSpan

    -- ^ Relationships
  , assignmentCourse        :: CourseId
  , assignmentTask          :: TaskId
  , assignmentTaskInstances :: Set TaskInstanceId

  } deriving (Eq, Read, Show)

data Status = Mandatory | Optional deriving (Eq, Read, Show)


-------------------------------------------------------------------------------
-- TASK INSTANCE
-------------------------------------------------------------------------------

data TaskInstance = TaskInstance {
    -- ^ Identifier
    taskInstanceId         :: TaskInstanceId

    -- ^ Attributes
  , taskInstanceSignature  :: ServerHash

    -- ^ Relationships
  , taskInstanceStudent    :: StudentId
  , taskInstanceAssignment :: Set AssignmentId
  , taskInstanceSolutions  :: Set SolutionId

  } deriving (Eq, Read, Show)


-------------------------------------------------------------------------------
-- SOLUTION
-------------------------------------------------------------------------------

data Solution = Solution {
    -- ^ Identifier
    solutionId           :: SolutionId

    -- ^ Attributes
  , solutionContent      :: String
  , solutionEvaluation   :: String
  , solutionResult       :: Maybe Result
  , solutionSubission    :: UTCTime

    -- ^ Relationships
  , solutionTaskInstance :: TaskInstanceId

  } deriving (Eq, Read, Show)

data Result = Result {
    score :: Int
  , size :: Int
  } deriving (Eq, Read, Show)


-- this belong to the peristence layer

{-
connectTutorToCourse :: Tutor -> Course -> (Tutor, Course)
connectTutorToCourse tutor course =
    (tutor', course')
  where
    tutor' = tutor {tutorCourses = S.insert (courseId course)
                                            (tutorCourses tutor)}
    course' = course {courseTutor = tutorId tutor}

connectTutorToTask :: Tutor -> Task -> (Tutor, Task)
connectTutorToTask tutor task =
    (tutor', task')
  where
    tutor' = tutor {tutorTasks = S.insert (taskId task)
                                          (tutorTasks tutor)}
    task' = task {taskTutor = tutorId tutor}
-}

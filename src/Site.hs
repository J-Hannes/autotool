{-# LANGUAGE OverloadedStrings #-}

------------------------------------------------------------------------------
-- | This module is where all the routes and handlers are defined for your
-- site. The 'app' function is the initializer that combines everything
-- together and is exported by this module.
module Site
  ( app
  ) where

------------------------------------------------------------------------------
import           Data.ByteString       (ByteString)
import           Data.Monoid
------------------------------------------------------------------------------
import           Heist
import           Snap
import           Snap.Snaplet.Heist
import           Snap.Util.FileServe
------------------------------------------------------------------------------
import           Application
import           Modules.Student.Controller.Enrollment (handleEnrollment)
import           Modules.Student.Controller.Enrollment (showEnrollments)
import           Modules.Student.Controller.Main       (handleStudent)
import           Modules.Student.Controller.Main       (handleStudentSelection)
import           Modules.Student.Controller.Solution   (showSolveTaskForm)
import           Modules.Tutor.Controller.Assignment   (handleAssignTask)
import           Modules.Tutor.Controller.Course       (handleCourseForm)
import           Modules.Tutor.Controller.Tasks        (showTaskList)
import           Modules.Tutor.Controller.Main         (handleTutor)
import           Modules.Tutor.Controller.TaskConfig   (handleTaskConfig)
import           Modules.Tutor.Controller.TaskTree     (handleTaskTree)

------------------------------------------------------------------------------
-- To enable the Model.DbAdapter.FileStore:
------------------------------------------------------------------------------

import          Model.DbAdapter.FileStore

------------------------------------------------------------------------------
-- To enable the Model.DbAdapter.Sqlite:
------------------------------------------------------------------------------
{-import           Control.Concurrent (withMVar)-}
{-import           Snap.Snaplet.SqliteSimple-}
{-import           Model.DbAdapter.Sqlite (createTables)-}


------------------------------------------------------------------------------
-- | The application's routes.
routes :: [(ByteString, Handler App App ())]
routes = [
    ("/",                                         ifTop $ render "index")
  , ("/tutor",                                    handleTutor)
  , ("/tutor/tasks",                              showTaskList)
  , ("/student/select",                           handleStudentSelection)
  , ("/student/:studentId",                       handleStudent)
  , ("/student/:studentId/enroll/:groupId",       handleEnrollment)
  , ("/student/:studentId/enrollments",           showEnrollments)
  , ("/student/:studentId/solve/:taskInstanceId", showSolveTaskForm)
  , ("/course/create",                            handleCourseForm)
  , ("/assign_task",                              handleAssignTask)
  , ("/task/select",                              handleTaskTree)
  , ("/task/configure/:taskname",                 handleTaskConfig)
  , ("/404",                                      render "404")
  , ("",                                          serveDirectory "static")
  ]


------------------------------------------------------------------------------
-- | The application initializer.
app :: SnapletInit App App
app = makeSnaplet "app" "An snaplet example application." Nothing $ do
    h <- nestSnaplet "" heist $ heistInit' "templates" config
    
------------------------------------------------------------------------------
-- To set up the Model.DbAdapter.FileStore:
------------------------------------------------------------------------------

    liftIO createFiles  

------------------------------------------------------------------------------
-- To set up the Model.DbAdapter.Sqlite:
------------------------------------------------------------------------------
    {-d <- nestSnaplet "db" db sqliteInit-}
    {-let c = sqliteConn $ d ^# snapletValue-}
    {-liftIO $ withMVar c $ \conn -> createTables conn-}

    addRoutes routes
    return $ App h

------------------------------------------------------------------------------
-- To enable the Model.DbAdapter.Sqlite:
------------------------------------------------------------------------------
      {-d-}
    
  where
    config = mempty { hcInterpretedSplices = defaultInterpretedSplices }

{-# LANGUAGE OverloadedStrings #-}

------------------------------------------------------------------------------
-- | This controller enables the enrollments between courses and tasks.
module Modules.Student.Controller.Enrollment
    ( handleEnrollment
    , showEnrollments
    ) where

------------------------------------------------------------------------------
import qualified Data.ByteString.Char8 as BS
import           Data.Maybe            (fromMaybe)
import qualified Data.Text             as T
import           Data.Time             (getCurrentTime)
import           Heist.Interpreted     (Splice)
import qualified Heist.Interpreted     as I
import           Snap                  (liftIO, (<$>), redirect, getParam)
import           Snap.Snaplet.Heist    (heistLocal, render)
------------------------------------------------------------------------------
import           Application           (AppHandler)
import qualified Model.Base            as Model
import           Model.Types.Course
import           Model.Types.Group
import           Utils.Auth            (getStudentId)


------------------------------------------------------------------------------
-- | Handler to enroll a task to a course.
showEnrollments :: AppHandler ()
showEnrollments = do
  -- todo: get all groups, but actually sorted nicely by courses to show them
  -- below each other. allow to enroll only in one of the groups for each
  -- courses. show only courses where the student is not yet enrolled, hehe.
  studentId <- getStudentId
  courses   <- Model.getCoursesWithEnrollableGroups studentId
  let splices = [
          ("studentId",    I.textSplice . T.pack $ show studentId)
        , ("courseGroups", I.mapSplices renderCourseGroup courses)
        ]  
  heistLocal (I.bindSplices splices) $ render "student/pages/enrollment"

renderCourseGroup :: (Course, [Group]) -> Splice AppHandler
renderCourseGroup (course, groups) =
    I.runChildrenWith splices
  where
    splices = [
        ("courseName", I.textSplice . T.pack $ courseName course)
      , ("groups", I.mapSplices renderGroup groups)
      ]

renderGroup :: Group -> Splice AppHandler
renderGroup group =
    I.runChildrenWith splices
  where
    splices = [
        ("groupId",          I.textSplice . T.pack . show $ groupId   group)
      , ("groupDescription", I.textSplice . T.pack $ groupDescription group)
      ]

handleEnrollment :: AppHandler ()
handleEnrollment = do
    sid <- getStudentId
    gid <- BS.unpack <$> fromMaybe "0" <$> getParam "groupId"
    now <- liftIO getCurrentTime
    _   <- Model.createEnrollment (read gid) sid now
    redirect (BS.pack ("/student/" ++ show sid))

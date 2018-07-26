require 'xcodeproj'
xcproj = Xcodeproj::Project.open("Telegraph.xcodeproj")
xcproj.recreate_user_schemes
xcproj.save

#!/usr/bin/env ruby

require 'xcodeproj'

xcodeproject_name = ARGV[0]
if xcodeproject_name.size > 0 then
    xcproj = Xcodeproj::Project.open(xcodeproject_name)
    xcproj.recreate_user_schemes
    xcproj.save
end

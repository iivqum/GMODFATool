
fatool = {}

AddCSLuaFile("fatool/spline.lua")

AddCSLuaFile("fatool/ui.lua")
AddCSLuaFile("fatool/ui/spline.lua")

if SERVER then
	return
end

include("fatool/spline.lua")
include("fatool/ui.lua")

fatool = {}

AddCSLuaFile("fatool/spline.lua")
AddCSLuaFile("fatool/saveload.lua")
AddCSLuaFile("fatool/animation.lua")
AddCSLuaFile("fatool/sequence.lua")

AddCSLuaFile("fatool/ui.lua")
AddCSLuaFile("fatool/ui/spline.lua")
AddCSLuaFile("fatool/ui/timeline.lua")
AddCSLuaFile("fatool/ui/timeline_bar.lua")
AddCSLuaFile("fatool/ui/preview.lua")
AddCSLuaFile("fatool/ui/editor.lua")
AddCSLuaFile("fatool/ui/menubar.lua")
AddCSLuaFile("fatool/ui/grabbable.lua")
AddCSLuaFile("fatool/ui/event_creator.lua")
AddCSLuaFile("fatool/ui/messages.lua")

if SERVER then
	return
end

include("fatool/spline.lua")
include("fatool/sequence.lua")
include("fatool/saveload.lua")
include("fatool/ui.lua")


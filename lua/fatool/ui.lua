include("fatool/ui/spline.lua")

fatool.ui = {}

local test = fatool.spline.new()
test:add_point(Vector(0.5,0.5))
test:add_point(Vector(0.3,0.5))
test:update()
test.alpha = 10
test.control0 = Vector(1,1,1)
PrintTable(test)
local a = 1322

function fatool.ui.open()
	local flex_ui = {}

	flex_ui.window=vgui.Create("DFrame")
	flex_ui.window:SetSize(ScrW()*0.7,ScrH()*0.7)
	flex_ui.window:SetSizable(false)
	flex_ui.window:SetTitle("test") 
	flex_ui.window:SetVisible(true) 
	flex_ui.window:SetDraggable(true) 
	flex_ui.window:ShowCloseButton(true) 
	flex_ui.window:MakePopup()
	flex_ui.window:Center()
	
	local spline = vgui.Create("fatool_spline",flex_ui.window)
	spline:Dock(FILL)
end

concommand.Add("flextest",fatool.ui.open)
include("fatool/ui/spline.lua")

fatool.ui = {}

function fatool.ui.open()
	local body = vgui.Create("DFrame")
	body:SetSize(ScrW() * 0.7, ScrH() * 0.7)
	body:SetSizable(false)
	body:SetTitle("test") 
	body:SetVisible(true) 
	body:SetDraggable(true) 
	body:ShowCloseButton(true) 
	body:MakePopup()
	body:Center()
	
	local spline = vgui.Create("fatool_spline",body)
	spline:Dock(FILL)
end

concommand.Add("fatool",fatool.ui.open)


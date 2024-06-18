include("fatool/ui/spline.lua")

fatool.ui = {}

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

concommand.Add("flexui",fatool.ui.open)
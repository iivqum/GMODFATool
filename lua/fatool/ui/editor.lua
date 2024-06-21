
local PANEL = {}

function PANEL:Init()
	self:Dock(FILL)
end

function PANEL:Paint()
	surface.SetDrawColor(80, 80, 80)
	self:DrawFilledRect()
	surface.SetDrawColor(255, 255, 255)
end

vgui.Register("fatool_editor", PANEL, "DPanel")
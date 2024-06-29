
local PANEL = {}

function PANEL:Init()
	self:Dock(FILL)
	
	-- String identifier for the animation
	self.identifier = ""
end

function PANEL:set_animation(identifier)
	self.identifier = identifier
end



function PANEL:Paint(width, height)
	surface.SetDrawColor(80, 80, 80)
	self:DrawFilledRect()
	surface.SetDrawColor(255, 255, 255)
	
	if not fatool.ui.sequence:get_animation(self.identifier) then
		draw.DrawText("No animation selected", "HudDefault", width * 0.5, height * 0.5, nil, TEXT_ALIGN_CENTER)
	end
end

vgui.Register("fatool_editor", PANEL, "DPanel")
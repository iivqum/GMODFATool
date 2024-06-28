
local PANEL = {}

function PANEL:Init()
	self:Dock(FILL)
	
	self.animation = nil
end

function PANEL:set_animation(animation)

end

function PANEL:Paint(width, height)
	surface.SetDrawColor(80, 80, 80)
	self:DrawFilledRect()
	surface.SetDrawColor(255, 255, 255)
	
	if self.animation == nil then
		draw.DrawText("No animation selected", "HudDefault", width * 0.5, height * 0.5, nil, TEXT_ALIGN_CENTER)
	end
end

vgui.Register("fatool_editor", PANEL, "DPanel")
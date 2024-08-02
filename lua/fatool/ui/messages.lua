
local PANEL = {}

function PANEL:Init()
	
end

function PANEL:Paint()
	surface.SetDrawColor(80, 80, 80)
	self:DrawFilledRect()
end

function PANEL:write(text)
	self:AppendText(text .. "\n")
end

vgui.Register("fatool_messages", PANEL, "RichText")
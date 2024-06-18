local PANEL = {}

function PANEL:Init()
	self.spline = fatool.spline.new()
end

function PANEL:get_spline()
	return self.spline
end

function PANEL:Paint(width, height)
	
end

vgui.Register("fatool_spline", PANEL, "DPanel")
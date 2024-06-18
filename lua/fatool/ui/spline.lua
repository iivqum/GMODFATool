local default_background_color = Color(255,255,255)
local default_foreground_color = Color(0,0,255)


local PANEL = {}

function PANEL:Init()
	self.spline = fatool.spline.new()
end

function PANEL:get_spline()
	return self.spline
end

function PANEL:Paint(width, height)
	surface.SetDrawColor(self:GetBackgroundColor() or default_background_color)
	self:DrawFilledRect()
	
	surface.SetDrawColor(default_foreground_color)
	
	-- Draw each spline segment
	local window_dimensions = Vector(width, height)
	for i, segment in ipairs(self.spline:get_segments()) do
		self.spline:sample_along(i, 10, function(old_point, new_point)
			-- Flip Y axis because screen Y is flipped
			new_point.y = -new_point.y
			old_point.y = -old_point.y
			new_point = new_point * window_dimensions
			old_point = old_point * window_dimensions
			surface.DrawLine(old_point.x, old_point.y, new_point.x, new_point.y)
		end)
	end
	
	-- Draw each spline point
	for i, point in ipairs(self.spline:get_points()) do
		point = point * window_dimensions
		surface.DrawRect(point.x, point.y, 4, 4)
	end
end

function PANEL:OnMousePressed(mouse_key)
	if mouse_key == MOUSE_LEFT then
	
	
	end
end

vgui.Register("fatool_spline", PANEL, "DPanel")
local default_background_color = Color(255,255,255)
local default_foreground_color = Color(0,0,255)

local PANEL = {}

function PANEL:Init()
	self.spline = fatool.spline()
end

function PANEL:get_spline()
	return self.spline
end

function PANEL:normalized_mouse_pos()
	local mouse_x, mouse_y = self:ScreenToLocal(gui.MouseX(), gui.MouseY())
	local width, height = self:GetSize()
	return mouse_x / width, mouse_y / height
end

function PANEL:Paint(width, height)
	surface.SetDrawColor(self:GetBackgroundColor() or default_background_color)
	self:DrawFilledRect()
	
	surface.SetDrawColor(default_foreground_color)
	
	-- Draw each spline segment
	for i, segment in ipairs(self.spline:get_segments()) do
		self.spline:sample_along(i, 10, function(old_point, new_point)
			-- Flip Y axis because screen Y is flipped
			local start_x = old_point.x * width
			local start_y = (1 - old_point.y) * height
			local end_x = new_point.x * width
			local end_y = (1 - new_point.y) * height
			surface.DrawLine(start_x, start_y, end_x, end_y)
		end)
	end
	
	-- Draw each spline point
	for i, point in ipairs(self.spline:get_points()) do
		local x = point.x * width
		local y = (1 - point.y) * height
		surface.DrawRect(x, y, 4, 4)
	end
	
	local normal_mouse_x, normal_mouse_y = self:normalized_mouse_pos()
	local y = self.spline:sample_continous(normal_mouse_x, 16)
	
	surface.DrawRect(normal_mouse_x * width, (1 - y) * height, 4, 4)
end

function PANEL:OnMousePressed(mouse_key)
	if mouse_key == MOUSE_LEFT then
		local normal_mouse_x, normal_mouse_y = self:normalized_mouse_pos()
	
		self.spline:add_point(Vector(normal_mouse_x, 1 - normal_mouse_y))
		self.spline:update()
	end
end

vgui.Register("fatool_spline", PANEL, "DPanel")
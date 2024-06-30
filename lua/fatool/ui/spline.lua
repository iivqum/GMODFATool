local default_background_color = Color(70,70,70)
local default_foreground_color = Color(200, 200, 200)
local point_size = 8

local PANEL = {}

function PANEL:Init()
	self.spline = fatool.spline()
	-- A point in the spline that the user selected
	self.selected_point = 0
end

function PANEL:get_spline()
	return self.spline
end

function PANEL:set_spline(spline)
	self.spline = spline
end

function PANEL:get_clamped_mouse_position()
	local width, height = self:GetSize()
	local mouse_x, mouse_y = self:ScreenToLocal(gui.MouseX(), gui.MouseY())
	mouse_x = math.Clamp(mouse_x, 0, width)
	mouse_y = math.Clamp(mouse_y, 0, height)
	return mouse_x, mouse_y
end

function PANEL:normalized_mouse_pos()
	local mouse_x, mouse_y = self:get_clamped_mouse_position()
	local width, height = self:GetSize()
	return mouse_x / width, mouse_y / height
end

function PANEL:Paint(width, height)
	surface.SetDrawColor(self:GetBackgroundColor() or default_background_color)
	self:DrawFilledRect()
	
	surface.SetDrawColor(default_foreground_color)
	
	-- Draw each spline segment
	for segment_index, segment in ipairs(self.spline:get_segments()) do
		self.spline:sample_along(segment_index, 10, function(old_point, new_point)
			-- Flip Y axis because screen Y is flipped
			local start_x = old_point.x * width
			local start_y = (1 - old_point.y) * height
			local end_x = new_point.x * width
			local end_y = (1 - new_point.y) * height
			surface.DrawLine(start_x, start_y, end_x, end_y)
		end)
	end

	if not self:IsHovered() then
		return
	end
	
	local normal_mouse_x, normal_mouse_y = self:normalized_mouse_pos()
	local y = 1 - self.spline:sample_continous(normal_mouse_x, 16)
	
	fatool.ui.draw_vertical_dashed_line(3, normal_mouse_x * width, 0, height)
	fatool.ui.draw_horizontal_dashed_line(3, normal_mouse_y * height, 0, width)
	fatool.ui.draw_horizontal_dashed_line(3, y * height, 0, width)
end

function PANEL:get_point_position(point_index)
	--[[
		Purpose:
			Get the position of a spline point from a screen point
	--]]
	local point = self.spline:get_point(point_index)
	local width, height = self:GetSize()
	local point_x = point.x * width
	local point_y = (1 - point.y) * height
	return point_x, point_y
end

function PANEL:get_spline_position(x, y)
	--[[
		Purpose:
			Get the position of a screen point from a spline point
	--]]
	local width, height = self:GetSize()
	return x / width, 1 - (y / height)
end

function PANEL:update_points()
	local width, height = self:GetSize()
	local half_size = point_size * 0.5
	
	self:Clear()

	for point_index, point in pairs(self.spline:get_points()) do
		local point_panel = self:Add("fatool_grabby")
		local point_x, point_y = self:get_point_position(point_index)
		point_panel:SetSize(point_size, point_size)
		point_panel:SetX(point_x - half_size)
		point_panel:SetY(point_y - half_size)
		function point_panel.on_grabbing(panel)
			local mouse_x, mouse_y = self:get_clamped_mouse_position()
			local spline_x, spline_y = self:get_spline_position(mouse_x, mouse_y)
			panel:SetY(mouse_y - half_size)
			point.y = spline_y
			self.spline:update()
		end
		function point_panel.on_grab(panel)
			self.selected_point = point_index
		end
		function point_panel.Paint(panel, width, height)
			if self.selected_point == point_index then
				surface.SetDrawColor(255, 100, 100)
			else
				surface.SetDrawColor(default_foreground_color)
			end
			self:DrawFilledRect()		
		end
	end
end

function PANEL:OnMousePressed(mouse_key)
	if mouse_key == MOUSE_LEFT then
		local normal_mouse_x, normal_mouse_y = self:normalized_mouse_pos()
		if input.IsKeyDown(KEY_LSHIFT) then
			self.spline:add_point(Vector(normal_mouse_x, 1 - normal_mouse_y))
		end
	end
	self:update_points()
end

vgui.Register("fatool_spline", PANEL, "DPanel")
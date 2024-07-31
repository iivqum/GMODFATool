local default_background_color = Color(70,70,70)
local default_foreground_color = Color(200, 200, 200)
local point_size = 12

local PANEL = {}

function PANEL:Init()
	self:Dock(FILL)

	self.spline = fatool.spline()
	self.motion_id = ""
end

function PANEL:get_spline()
	return self.spline
end

function PANEL:set_spline(spline, identifier)
	self.spline = spline
	self.motion_id = identifier
	self:update_points()
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
	surface.SetDrawColor(default_background_color)
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

function PANEL:update_existing_points()
	--[[
		Purpose:
			Update all existing points on the screen
			The spline's points are already sorted so the screen points simply 
			reorder themselves and the last point is always removed
	--]]
	local half_size = point_size * 0.5
	for panel_id, panel in pairs(self:GetChildren()) do
		if not self.spline:get_point(panel.point_index) then
			panel:Remove()
		else
			local point_x, point_y = self:get_point_position(panel.point_index)
			panel:SetSize(point_size, point_size)
			panel:SetX(point_x - half_size)
			panel:SetY(point_y - half_size)
		end
	end
end

function PANEL:add_point(point_index)
	--[[
		Purpose:
			Add a point to the screen with the given point index
	--]]
	if not self.spline:get_point(point_index) then
		return
	end
	
	local width, height = self:GetSize()
	local half_size = point_size * 0.5

	local point_panel = self:Add("fatool_grabby")
	
	point_panel.point_index = point_index
	
	function point_panel.on_grabbing(panel)
		local point = self.spline:get_point(panel.point_index)
		local mouse_x, mouse_y = self:get_clamped_mouse_position()
		local spline_x, spline_y = self:get_spline_position(mouse_x, mouse_y)
		local new_point_x, new_point_y = self:get_point_position(point_index)
		point.y = spline_y
		self.spline:update()
		panel:SetY(new_point_y - half_size)
	end
	function point_panel.on_grab(panel)
		fatool.ui.state:get_editor():select_point(panel.point_index, self.motion_id)
	end
	function point_panel.Paint(panel, width, height)
		if fatool.ui.state:get_editor():is_point_selected(panel.point_index, self.motion_id) then
			surface.SetDrawColor(255, 100, 100)
		else
			surface.SetDrawColor(default_foreground_color)
		end
		self:DrawFilledRect()
	end
end

function PANEL:update_points()
	for point_index, point in pairs(self.spline:get_points()) do
		self:add_point(point_index)
	end
end

function PANEL:PerformLayout()
print("IT DID IT!")
	self:update_existing_points()
end

function PANEL:Think()
	if input.IsKeyDown(KEY_DELETE) and self.selected_point then
		self.spline:remove_point(self.selected_point)
		self.selected_point = nil
		self:update_existing_points()
	end
end

function PANEL:OnMousePressed(mouse_key)
	if mouse_key == MOUSE_LEFT then
		local normal_mouse_x, normal_mouse_y = self:normalized_mouse_pos()
		if input.IsKeyDown(KEY_LSHIFT) then
			local point_index = self.spline:add_point(Vector(normal_mouse_x, 1 - normal_mouse_y))
			self:add_point(point_index)
		end
	end
	fatool.ui.state:get_editor():clear_selected_point()
	self:update_existing_points()
end

vgui.Register("fatool_spline", PANEL, "EditablePanel")
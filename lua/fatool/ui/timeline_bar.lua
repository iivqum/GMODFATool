
local PANEL = {}

function PANEL:Init()
	-- Animation that this bar corresponds to
	self.animation = nil
	-- Timeline position when a grab takes place
	self.start_timeline_position = 0
	-- Gap around top and bottom edges
	self.gap = 12
	self.base_width = 24
	
	self.identifier = "None"
	
	
	self:SetMouseInputEnabled(true)
	self:SetTall(self.gap + self.base_width)
end

function PANEL:place_on_timeline()
	--[[
		Purpose:
			Move the bar to where it should be displayed horizontally on the timeline
	--]]
	local timeline = fatool.ui.state:get_timeline()
	local left_boundary, right_boundary = timeline:get_boundaries()
	local width = self:GetParent():GetWide()
	local span = timeline:get_span()
	local start_x = 1
	local stop_x = width
	
	local start_time = self.animation:get_start()
	local stop_time = self.animation:get_stop()
	
	if start_time > left_boundary then
		start_x = math.floor((start_time - left_boundary) / span * width) + 1
	end
	
	if stop_time < right_boundary then
		stop_x = math.floor((stop_time - left_boundary) / span * width)
		stop_x = math.max(stop_x, 0 )
	end

	self:SetWide(stop_x - start_x)
	self:SetX(start_x)
end

function PANEL:local_mouse_pos()
	local mouse_x, mouse_y = gui.MousePos()
	return self:ScreenToLocal(mouse_x, mouse_y)
end

function PANEL:set_animation(animation, identifier)
	assert(isstring(identifier))
	self.animation = animation
	self.identifier = identifier
end

function PANEL:get_animation()
	return self.animation
end

function PANEL:update_cursor()
	local has_left, has_right = self:get_edge_states()
	if has_left or has_right then
		self:SetCursor("sizewe")
		return
	end
	self:SetCursor("sizeall")
end

function PANEL:update_actions()
	if not self:is_grabbed() then
		return
	end
	local timeline = fatool.ui.state:get_timeline()
	if self:has_left_grab() then
		self.animation:set_start(timeline:get_timeline_position())		
		return
	end
	if self:has_right_grab() then
		self.animation:set_stop(timeline:get_timeline_position())
		return
	end
	local delta = timeline:get_timeline_position() - self.start_timeline_position
	self.animation:set_start(self.animation:get_start() + delta)
	self.animation:set_stop(self.animation:get_stop() + delta)
	self.start_timeline_position = timeline:get_timeline_position()	
end

function PANEL:on_grab()
	local timeline = fatool.ui.state:get_timeline()
	self.start_timeline_position = timeline:get_timeline_position()
end

function PANEL:Think()
	self:place_on_timeline()
	self:update_cursor()
	self:update_actions()
	self:update_grab()
end

function PANEL:Paint(width, height)
	surface.SetDrawColor(180, 40, 40)
	surface.DrawRect(0, self.gap, width, height - self.gap * 2)
	
	surface.SetDrawColor(0, 0, 0)
	surface.DrawOutlinedRect(0, self.gap, width, height - self.gap * 2)
	
	draw.DrawText(self.identifier, "DefaultSmall", 0, height - self.gap, nil, TEXT_ALIGN_LEFT)
	
	if self.animation:get_type() == "flex" then
		draw.DrawText("Flex", "DefaultSmall", width, height - self.gap, nil, TEXT_ALIGN_RIGHT)
	end
	
	if self:is_grabbed() then
		surface.SetDrawColor(180, 180, 180)
		fatool.ui.draw_dashed_rectangle(3, 0, 0, width, height)
	end
end

vgui.Register("fatool_timeline_bar", PANEL, "fatool_grabby")
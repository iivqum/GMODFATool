
local PANEL = {}

function PANEL:Init()
	-- Animation that this bar corresponds to
	self.animation = nil
	-- How far from the edges you can change the width of the bar
	self.edge_grab_threshold = 8
	
	self.grab_state = {
		-- If user grabbed the left edge
		has_left_edge = false,
		-- If user grabbed the right edge
		has_right_edge = false,
		-- If the user is grabbing
		grabbing = false,
		-- Where in the timeline the grab started
		timeline_position = 0
	}
	
	self:SetMouseInputEnabled(true)
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

function PANEL:update_grab(is_mouse_pressed)
	-- If we're grabbing then don't update the grab
	-- But if we're grabbing and the mouse is not down then release the grab
	if self.grab_state.grabbing then
		if not is_mouse_pressed then
			self.grab_state.grabbing = false
		end
		return
	elseif not is_mouse_pressed then
		-- If not grabbing and the mouse is not down don't grab 
		return
	end
	-- Update grab if we're not grabbing and the mouse is down
	local timeline = fatool.ui.state:get_timeline()
	local mouse_x, mouse_y = self:local_mouse_pos()
	local left_edge = self.edge_grab_threshold
	local right_edge = self:GetWide() - self.edge_grab_threshold
	
	self.grab_state.has_left_edge = mouse_x <= left_edge
	self.grab_state.has_right_edge = mouse_x >= right_edge
	self.grab_state.grabbing = true
	self.grab_state.timeline_position = timeline:get_timeline_position()
end

function PANEL:Think()
	self:place_on_timeline()
	
	if not self.grab_state.grabbing then
		-- Make sure the initial grab is inside the bar
		self:update_grab(self:IsHovered() and input.IsMouseDown(MOUSE_LEFT))
	else
		self:update_grab(input.IsMouseDown(MOUSE_LEFT))
	end
	
	PrintTable(self.grab_state)
end

function PANEL:Paint()
	surface.SetDrawColor(100, 0, 0)
	self:DrawFilledRect()	
end

vgui.Register("fatool_timeline_bar", PANEL, "DPanel")
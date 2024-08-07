
local PANEL = {}

function PANEL:Init()
	self.grab_state = {
		has_left_edge = false,
		has_right_edge = false,
		grabbing = false,
		mouse_x = 0,
		mouse_y = 0
	}
	self.edge_grab_threshold = 8
	
	self:SetCursor("hand")
end

function PANEL:local_mouse_pos()
	local mouse_x, mouse_y = gui.MousePos()
	return self:ScreenToLocal(mouse_x, mouse_y)
end

function PANEL:update_grab_state(is_mouse_pressed)
	--[[
		Purpose:
			Toggle the grab state and store grab data when a grab happens
	--]]
	-- If we're grabbing then don't update the grab
	-- But if we're grabbing and the mouse is not down then release the grab
	if self.grab_state.grabbing then
		if not is_mouse_pressed then
			self.grab_state.grabbing = false
		else
			self:on_grabbing()
		end
		return
	elseif not is_mouse_pressed then
		-- If not grabbing and the mouse is not down don't grab 
		return
	end
	-- Update grab if we're not grabbing and the mouse is down
	local mouse_x, mouse_y = self:local_mouse_pos()
	local left_edge = self.edge_grab_threshold
	local right_edge = self:GetWide() - self.edge_grab_threshold
	local has_left, has_right = self:get_edge_states()
	self.grab_state.has_left_edge = has_left
	self.grab_state.has_right_edge = has_right
	self.grab_state.grabbing = true
	self.grab_state.mouse_x = mouse_x
	self.grab_state.mouse_y = mouse_y
	self:on_grab()
end

function PANEL:get_mouse_delta()
	local mouse_x, mouse_y = self:local_mouse_pos()
	local delta_x = mouse_x - self.grab_state.mouse_x
	local delta_y = mouse_y - self.grab_state.mouse_y
	self.grab_state.mouse_x = mouse_x
	self.grab_state.mouse_y = mouse_y
	return delta_x, delta_y
end

function PANEL:get_edge_states()
	--[[
		Purpose:
			Get whether the mouse is hovered over the left or right edge of the panel
	--]]
	local mouse_x, mouse_y = self:local_mouse_pos()
	local left_edge = self.edge_grab_threshold
	local right_edge = self:GetWide() - self.edge_grab_threshold
	local has_left_edge = mouse_x <= left_edge
	local has_right_edge = mouse_x >= right_edge
	return has_left_edge, has_right_edge
end

function PANEL:is_grabbed()
	return self.grab_state.grabbing
end

function PANEL:has_left_grab()
	return self.grab_state.has_left_edge
end

function PANEL:has_right_grab()
	return self.grab_state.has_right_edge
end

function PANEL:on_grab()
end

function PANEL:on_grabbing()
end

function PANEL:OnMousePressed(mouse_code)
	self:update_grab_state(self:IsHovered() and mouse_code == MOUSE_LEFT)
end

function PANEL:update_grab()
	if self.grab_state.grabbing then
		self:update_grab_state(input.IsMouseDown(MOUSE_LEFT))
	end
end

function PANEL:Think()
	self:update_grab()
end

vgui.Register("fatool_grabby", PANEL, "EditablePanel")
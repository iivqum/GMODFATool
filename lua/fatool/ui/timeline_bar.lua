
local PANEL = {}

function PANEL:Init()
	-- Animation that this bar corresponds to
	self.animation = nil
	self.SetDragParent(self:GetParent())
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

function PANEL:DragHoverClick(mouse_key)
	print(mouse_key)
end

function PANEL:Think()
	self:place_on_timeline()
	
	
end

function PANEL:Paint()
	surface.SetDrawColor(100, 0, 0)
	self:DrawFilledRect()	
end

vgui.Register("fatool_timeline_bar", PANEL, "DPanel")

local function closest_multiples(n, factor)
	--[[
		Purpose:
			Find closest multiples of a number that contains n
	--]]
	local lowest_multiple = math.floor(n / factor)
	local highest_multiple = lowest_multiple + 1
	return lowest_multiple * factor, highest_multiple * factor
end

local PANEL = {}

function PANEL:Init()
	-- How much the timeline is shifted to the right
	self.timeline_left_margin = 32
	-- Normal amount of time that can be displayed
	self.timeline_display_seconds = 10
	-- Maximum time step between timeline divisons
	self.timeline_step_seconds = 0.5
	self.timeline_top_bar_height = 16	
	-- How zoomed the timeline is
	self.scale = 1
	-- Current sequence to edit
	self.sequence = nil

	self:Dock(FILL)
	
	self.top_bar = self:Add("DPanel")
	self.top_bar:SetTall(self.timeline_top_bar_height)
	self.top_bar:Dock(TOP)
	
	function self.top_bar:Paint(width, height)	
		surface.SetDrawColor(150, 150, 150)
		surface.DrawLine(-1, height - 1, width - 1, height - 1)
		--self:DrawFilledRect()
	end
	
	self.top_scroll = self:Add("DScrollPanel")
	self.top_scroll:DockMargin(self.timeline_left_margin, 0, 0, 0)
	self.top_scroll:Dock(FILL)
	self.top_scroll:GetCanvas():DockPadding(0, 16, 0, 0)
	
	function self.top_scroll:Paint(width, height)
		surface.SetDrawColor(150, 150, 150)
		surface.DrawLine(0, 0, 0, height)		
	end
	
	self.bottom_scroll = self:Add("DHScrollBar")
	self.bottom_scroll:Dock(BOTTOM)
	self.bottom_scroll:SetUp(1, 10)
end

function PANEL:get_startstop()
	--[[
		Purpose:
			
	--]]
end

function PANEL:draw_markers()
	-- How many markers are on the screen
	local marker_amount = math.floor(self.timeline_display_seconds / self.timeline_step_seconds)
	-- Distance between markers on the timeline
	local marker_step = self.top_scroll:GetCanvas():GetWide() / marker_amount
	-- The time that corresponds to the leftmost border of the timeline
	local marker_start_time = self.bottom_scroll:GetOffset() * -1
	-- Closest marker boundaries
	local marker_lower, marker_upper = closest_multiples(marker_start_time, self.timeline_step_seconds)
	-- Where the markers will start from the leftmost border
	local marker_start_position = (marker_start_time - marker_lower) / self.timeline_step_seconds * marker_step * -1
	for i = 0, marker_amount do
		local marker_number = math.Truncate(marker_lower + self.timeline_step_seconds * i, 2)
		marker_number = tostring(marker_number)
		local marker_x = math.floor(marker_start_position + self.timeline_left_margin + marker_step * i) 
		if marker_x >= self.timeline_left_margin then
			local marker_y = self.top_scroll:GetY() - draw.GetFontHeight("DefaultSmall")
			
			draw.DrawText(marker_number, "DefaultSmall", marker_x, marker_y, nil, TEXT_ALIGN_CENTER)
			fatool.ui.draw_vertical_dashed_line(3, marker_x, self.top_scroll:GetY(), self.top_scroll:GetTall(), 150, 150, 150)
		end
	end	
end

function PANEL:Paint(width, height)
	surface.SetDrawColor(80, 80, 80)
	self:DrawFilledRect()
	self:draw_markers()
	
end

function PANEL:OnMousePressed(mouse_key)
	
end

vgui.Register("fatool_timeline", PANEL, "DPanel")
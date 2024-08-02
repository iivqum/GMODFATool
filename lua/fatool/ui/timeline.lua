include("fatool/ui/timeline_bar.lua")
include("fatool/ui/event_creator.lua")

local timeline_font = "DefaultSmall"

local function closest_multiples(n, factor)
	--[[
		Purpose:
			Find closest multiples of a number that contains n
	--]]
	local lowest_multiple = math.floor(n / factor)
	local highest_multiple = lowest_multiple + 1
	return lowest_multiple * factor, highest_multiple * factor
end

local function get_within_bounds(fraction, lower_bound, upper_bound)
	return lower_bound + (upper_bound - lower_bound) * fraction
end

local PANEL = {}

function PANEL:Init()
	-- How much the timeline is shifted to the right
	self.timeline_left_margin = 32
	-- Normal amount of time that can be displayed
	self.timeline_span = 10
	-- Maximum time step between timeline divisons
	self.timeline_step_seconds = 0.5
	self.timeline_top_bar_height = 32	
	-- How zoomed the timeline is
	self.scale = 1
	-- All bars in the timeline
	self.bars = {}
	-- Gap between bars
	self.bar_gap = 4

	self.playing = false
	
	self:Dock(FILL)
	
	self.top_bar = self:Add("DPanel")
	self.top_bar:SetTall(fatool.ui.get_font_height(timeline_font) * 2)
	self.top_bar:Dock(TOP)
	
	function self.top_bar:Paint(width, height)	
		surface.SetDrawColor(150, 150, 150)
		surface.DrawLine(-1, height - 1, width - 1, height - 1)
		--self:DrawFilledRect()
	end
	
	self.scrubber = self.top_bar:Add("fatool_grabby")
	
	self.scrubber:SetTall(fatool.ui.get_font_height(timeline_font))
	self.scrubber:SetWide(self.timeline_left_margin * 2)
	self.scrubber.playing = false
	
	function self.scrubber.on_grabbing(panel)
		fatool.ui.sequence:set_progress(self:get_timeline_position())
	end
	
	function self.scrubber.Think(panel)
		panel:update_grab()
		-- Center the scrubber bar on the marker
		local marker_x = self:time_to_coordinate(fatool.ui.sequence:get_progress())
		local half_width = panel:GetWide() * 0.5
		marker_x = math.min(marker_x, self:GetWide() - half_width)
		local scrubber_x = marker_x - half_width
		panel:SetX(scrubber_x)
	end
	
	function self.scrubber.Paint(panel)
		surface.SetDrawColor(40, 140, 40)
		panel:DrawFilledRect()
		surface.SetDrawColor(0, 0, 0)
		panel:DrawOutlinedRect()
		local scrubber_text = math.Truncate(fatool.ui.sequence:get_progress(), 2)
		local scrubber_x = math.floor(panel:GetWide() * 0.5)
		local scrubber_y = math.floor(panel:GetTall() * 0.5 - draw.GetFontHeight(timeline_font) * 0.5)
		draw.DrawText(scrubber_text, timeline_font, scrubber_x, scrubber_y, nil, TEXT_ALIGN_CENTER)
	end
	
	self.top_scroll = self:Add("DScrollPanel")
	self.top_scroll:DockMargin(self.timeline_left_margin, 0, 0, 0)
	self.top_scroll:Dock(FILL)

	function self.top_scroll.Paint(panel, width, height)
		surface.SetDrawColor(150, 150, 150)
		surface.DrawLine(0, 0, 0, height)
	end
	
	self.timeline_canvas = self.top_scroll:Add("DPanel")
	self.timeline_canvas:Dock(TOP)
	
	function self.timeline_canvas.Paint(panel)
	
	end

	function self.timeline_canvas.OnMousePressed(panel, mouse_key)
		if mouse_key ~= MOUSE_RIGHT then
			return
		end
		local menu = DermaMenu(false)
		menu:Open()
		menu:AddOption("Add event", function()
			if self.event_creator then
				self.event_creator:Remove()
			end		
			self.event_creator = self:Add("fatool_event_creator")
		end)
	end	
	
	self.bottom_scroll = self:Add("DHScrollBar")
	self.bottom_scroll:Dock(BOTTOM)
	self.bottom_scroll:Hide()
end

function PANEL:add_animation(name, start, stop)
	local sequence = fatool.ui.sequence
	local animation = sequence:add_animation(name, "flex")
	if not animation then
		-- Error!
		return
	end
	animation:set_start(start)
	animation:set_stop(stop)
	self:update_bars()
	return animation
end

function PANEL:get_timeline_position()
	--[[
		Purpose:
			Get the time at the user's mouse position
	--]]
	local left_boundary, right_boundary = self:get_boundaries()
	local mouse_x, mouse_y = self.top_scroll:GetCanvas():ScreenToLocal(gui.MouseX(), gui.MouseY())
	local timeline_width = self.top_scroll:GetCanvas():GetWide()
	mouse_x = math.Clamp(mouse_x, 0, timeline_width)
	local fraction = mouse_x / timeline_width
	return get_within_bounds(fraction, left_boundary, right_boundary)
end

function PANEL:layout_bars()
	--[[
		Purpose:
			Ensure the bars don't overlap
	--]]
	local bars = table.Copy(self.bars)
	table.sort(bars, function(bar1, bar2)
		local start1 = bar1:get_animation():get_start()
		local start2 = bar2:get_animation():get_start()
		return start1 < start2
	end)
	-- Minimum height for the panel containing the bars
	local minimum_height = 0
	local bar_rows = {}
	for bar_index, bar in ipairs(bars) do
		local start = bar:get_animation():get_start()
		local first_free_row = 0
		for row_index, row in ipairs(bar_rows) do
			local intersects_with_row = false
			for previous_bar_index, previous_bar in ipairs(row) do
				local stop = previous_bar:get_animation():get_stop()
				if start < stop then
					intersects_with_row = true
					break
				end
			end
			if not intersects_with_row then
				first_free_row = row_index
				break
			end
		end
		if first_free_row == 0 then
			first_free_row = table.insert(bar_rows, {})
		end
		table.insert(bar_rows[first_free_row], bar)
		local y = (first_free_row - 1) * (bar:GetTall() + self.bar_gap)
		minimum_height = math.max(minimum_height, y + bar:GetTall())
		bar:SetY(y)
	end
	minimum_height = math.max(self.top_scroll:GetTall(), minimum_height)
	self.timeline_canvas:SetTall(minimum_height)
end

function PANEL:toggle_play()
	self.playing = not self.playing
end

function PANEL:update_scroll()
	local left_boundary, right_boundary = self:get_boundaries()
	local sequence = fatool.ui.sequence
	local stop = sequence:get_stop()
	if stop > self.timeline_span then
		-- self.timeline_span * 0.5 so the timeline bars are always visible
		local lowest, highest = closest_multiples(stop, self.timeline_span * 0.25)
		self.bottom_scroll:Show()
		self.bottom_scroll:SetUp(10, highest)
		self:InvalidateLayout(true)
	elseif self.bottom_scroll:IsVisible() then
		self.bottom_scroll:Hide()
		self:InvalidateLayout(true)
	end
end

function PANEL:update_bars()
	--[[
		Purpose:
			Synchronise timeline bars with the sequence
			Add relevant bars and remove bars that don't exist anymore
	--]]
	-- Lazy way
	for bar_index, bar in pairs(self.bars) do
		bar:Remove()
	end
	self.bars = {}
	for animation_id, animation in pairs(fatool.ui.sequence:get_animations()) do
		local bar = self.timeline_canvas:Add("fatool_timeline_bar")
		bar:set_animation(animation_id)
		table.insert(self.bars, bar)
	end
end

function PANEL:select_animation(animation_id)
	--[[
		Purpose:
			Select animation that will be removed when the user presses delete
	--]]
	
end

function PANEL:OnKeyCodePressed(key_code)
	--[[
		Purpose:
			Check and respond to key presses
	--]]
	local editor = fatool.ui.state:get_editor()
	local animation_id = editor:get_animation_id()
	if key_code == KEY_DELETE and editor:get_animation() then
		fatool.ui.sequence:remove_animation(animation_id)
		editor:update()
		self:update_bars()
	end
	if key_code == KEY_SPACE then
		self:toggle_play()
	end
end

function PANEL:Think()
	self:layout_bars()
	self:update_scroll()
	fatool.ui.sequence:update(self.playing and FrameTime() or 0)
end

function PANEL:get_boundaries()
	--[[
		Purpose:
			Get the time corresponding to the left and right borders
	--]]
	local start_time = self.bottom_scroll:GetOffset() * -1
	local stop_time = start_time + self.timeline_span
	return start_time, stop_time
end

function PANEL:time_to_coordinate(t)
	--[[
		Purpose:
			Get the x value corresponding to time t relative to the timeline parent panel
	--]]
	local start, stop = self:get_boundaries()
	local delta = t - start
	local fraction = math.Clamp(delta / self.timeline_span, 0, 1)
	local x = get_within_bounds(fraction, self.timeline_left_margin, self.top_scroll:GetCanvas():GetWide() + self.timeline_left_margin)
	return math.floor(x)
end

function PANEL:get_span()
	return self.timeline_span	
end

function PANEL:draw_timeline_markers()
	-- How many markers are on the screen
	local marker_amount = math.floor(self.timeline_span / self.timeline_step_seconds)
	-- Distance between markers on the timeline
	local marker_step = self.top_scroll:GetCanvas():GetWide() / marker_amount
	-- The time that corresponds to the leftmost border of the timeline
	local marker_start_time = self:get_boundaries()
	-- Closest marker boundaries
	local marker_lower, marker_upper = closest_multiples(marker_start_time, self.timeline_step_seconds)
	-- Where the markers will start from the leftmost border
	local marker_start_position = (marker_start_time - marker_lower) / self.timeline_step_seconds * marker_step * -1
	surface.SetDrawColor(150, 150, 150)
	for i = 0, marker_amount do
		local marker_number = math.Truncate(marker_lower + self.timeline_step_seconds * i, 2)
		marker_number = tostring(marker_number)
		local marker_x = math.floor(marker_start_position + self.timeline_left_margin + marker_step * i) 
		if marker_x >= self.timeline_left_margin then
			local marker_y = self.top_scroll:GetY() - draw.GetFontHeight(timeline_font)
			
			draw.DrawText(marker_number, timeline_font, marker_x, marker_y, nil, TEXT_ALIGN_CENTER)
			fatool.ui.draw_vertical_dashed_line(3, marker_x, self.top_scroll:GetY(), self.top_scroll:GetTall())
		end
	end
end

function PANEL:draw_max_sequence_marker()
	-- Draw max sequence time
	local sequence = fatool.ui.sequence
	surface.SetDrawColor(200, 10, 10)
	local marker_x = self:time_to_coordinate(sequence:get_stop())
	fatool.ui.draw_vertical_dashed_line(3, marker_x, self.top_scroll:GetY(), self.top_scroll:GetTall())
end

function PANEL:draw_scrubber_marker()
	surface.SetDrawColor(10, 10, 10)
	local marker_x = self:time_to_coordinate(fatool.ui.sequence:get_progress())
	fatool.ui.draw_vertical_dashed_line(3, marker_x, self.top_scroll:GetY(), self.top_scroll:GetTall())	
end

function PANEL:Paint(width, height)
	surface.SetDrawColor(80, 80, 80)
	self:DrawFilledRect()
	self:draw_timeline_markers()
	self:draw_max_sequence_marker()
	--self:draw_test()
end

function PANEL:PaintOver()
	self:draw_scrubber_marker()
end

vgui.Register("fatool_timeline", PANEL, "DPanel")
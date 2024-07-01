local scrubber_font = "DefaultSmall"

local PANEL = {}

function PANEL:Init()
	self:Dock(FILL)
	
	-- String animation_id for the animation
	self.animation_id = ""
	
	self.top_bar = self:Add("DPanel")
	self.top_bar:SetTall(fatool.ui.get_font_height(scrubber_font) * 1.2)
	self.top_bar:Dock(TOP)
	
	function self.top_bar.Paint(panel)
	end
	
	self.list = self:Add("DCategoryList")
	self.list:Dock(FILL)
	
	function self.list.Paint(panel)
	end
	
	self.scrubber = self:Add("fatool_grabby")
	
	self.scrubber:SetTall(fatool.ui.get_font_height(scrubber_font))
	self.scrubber:SetWide(64)
	self.scrubber:Hide()
	
	function self.scrubber.on_grabbing(panel)
		fatool.ui.sequence:set_progress(self:get_timeline_position())
	end
	
	function self.scrubber.Think(panel)
		panel:update_grab()
		-- Center the scrubber bar on the marker
		local marker_x = self:time_to_coordinate(fatool.ui.sequence:get_progress())
		local half_width = panel:GetWide() * 0.5
		marker_x = math.min(marker_x, self:GetWide() - half_width)
		local scrubber_x = math.max(marker_x - half_width, 0)
		panel:SetX(scrubber_x)
	end
	
	function self.scrubber.Paint(panel)
		surface.SetDrawColor(40, 140, 40)
		panel:DrawFilledRect()
		surface.SetDrawColor(0, 0, 0)
		panel:DrawOutlinedRect()
		local scrubber_text = math.Truncate(fatool.ui.sequence:get_progress(), 2)
		local scrubber_x = math.floor(panel:GetWide() * 0.5)
		local scrubber_y = math.floor(panel:GetTall() * 0.5 - draw.GetFontHeight(scrubber_font) * 0.5)
		draw.DrawText(scrubber_text, scrubber_font, scrubber_x, scrubber_y, nil, TEXT_ALIGN_CENTER)
	end
end

function PANEL:time_to_coordinate(t)
	--[[
		Purpose:
			Get the x value corresponding to time t relative to the timeline parent panel
	--]]
	local start = self:get_animation():get_start()
	local stop = self:get_animation():get_stop()
	local delta = t - start
	local fraction = math.Clamp(delta / (stop - start), 0, 1)
	local x = fraction * self.list:GetCanvas():GetWide()
	return math.floor(x)
end

function PANEL:Think()
	if not self:get_animation() then
		return
	end
	if not self.scrubber:IsVisible() then
		self.scrubber:Show()
	end
end

function PANEL:get_timeline_position()
	--[[
		Purpose:
			Get the time at the user's mouse position
	--]]
	local left_boundary = self:get_animation():get_start()
	local right_boundary = self:get_animation():get_stop()
	local mouse_x, mouse_y = self:ScreenToLocal(gui.MouseX(), gui.MouseY())
	local width = self.list:GetCanvas():GetWide()
	mouse_x = math.Clamp(mouse_x, 0, width)
	local fraction = mouse_x / width
	local timeline_position = fraction * (right_boundary - left_boundary) + left_boundary
	return timeline_position
end

function PANEL:get_animation_id()
	return self.animation_id
end

function PANEL:get_animation()
	return fatool.ui.sequence:get_animation(self.animation_id)
end

function PANEL:build()
	local animation = self:get_animation()
	
	self.list:Clear()
	
	for motion_id, spline in pairs(animation:get_motions()) do
		local category = self.list:Add(motion_id)
		category:SetTall(self:GetTall() * 0.3)
		category:SetExpanded(spline:get_num_points() > 0)
		
		function category.Paint(panel)
			surface.SetDrawColor(90, 90, 90)
			self:DrawFilledRect()	
		end
		
		
	
		local spline_panel = vgui.Create("fatool_spline")
		spline_panel:set_spline(spline)
		
		-- This is a hack to stop the DCategoryCollapse from trying to resize the spline panel
		function spline_panel.SizeToChildren(panel)
		end
		
		category:SetContents(spline_panel)

	end	
	
	--self:InvalidateLayout(true)
	--self:InvalidateChildren(true)
end

function PANEL:set_animation(animation_id)
	if self.animation_id == animation_id or not fatool.ui.sequence:get_animation(animation_id) then
		-- Error!
		return
	end
	self.animation_id = animation_id
	self:build()
end

function PANEL:Paint(width, height)
	surface.SetDrawColor(80, 80, 80)
	self:DrawFilledRect()
	surface.SetDrawColor(255, 255, 255)
	
	if not fatool.ui.sequence:get_animation(self.animation_id) then
		draw.DrawText("No animation selected", "HudDefault", width * 0.5, height * 0.5, nil, TEXT_ALIGN_CENTER)
		return
	end
end

function PANEL:PaintOver(width, height)
	if not fatool.ui.sequence:get_animation(self.animation_id) then
		return
	end
	fatool.ui.draw_vertical_dashed_line(3, self:time_to_coordinate(fatool.ui.sequence:get_progress()), self.top_bar:GetTall(), height)
end

vgui.Register("fatool_editor", PANEL, "DPanel")
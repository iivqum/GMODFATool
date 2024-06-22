-- How much the timeline is shifted to the right
local timeline_left_margin = 32
-- Normal amount of time that can be displayed
local timeline_display_seconds = 10
-- Maximum time step between timeline divisons
local timeline_step_seconds = 0.5

local timeline_top_bar_height = 16

local PANEL = {}

function PANEL:Init()
	-- How zoomed the timeline is
	self.scale = 1
	-- Current sequence to edit
	self.sequence = nil

	self:Dock(FILL)
	
	self.top_bar = self:Add("DPanel")
	self.top_bar:SetTall(timeline_top_bar_height)
	self.top_bar:Dock(TOP)
	
	function self.top_bar:Paint(width, height)	
		surface.SetDrawColor(150, 150, 150)
		surface.DrawLine(-1, height - 1, width - 1, height - 1)
		--self:DrawFilledRect()
	end
	
	
	self.contents = self:Add("DScrollPanel")
	self.contents:DockMargin(timeline_left_margin, 0, 0, 0)
	self.contents:Dock(FILL)
	self.contents:SetPadding(100)
	
	function self.contents:Paint(width, height)
		surface.SetDrawColor(150, 150, 150)
		--surface.DrawLine(0, 0, 0, height)		
		--fatool.ui.draw_vertical_dashed_line(4, 10, height, 255, 255, 255)
		--fatool.ui.draw_horizontal_dashed_line(2, 10, width, 255, 255, 255)
	end
	
	self.bottom_scroll = self:Add("DHScrollBar")
	self.bottom_scroll:Dock(BOTTOM)
	self.bottom_scroll:SetUp(1, 10)
end

function PANEL:Paint(width, height)
	surface.SetDrawColor(80, 80, 80)
	self:DrawFilledRect()
	
	-- Draw timeline markers
	local markers = math.floor(timeline_display_seconds / timeline_step_seconds)
	local step = self.contents:GetWide() / markers
	for i = 0, markers do
		local marker_number = tostring(timeline_step_seconds * i)
		local marker_x = math.floor(timeline_left_margin + step * i)
		local marker_y = self.contents:GetY() - draw.GetFontHeight("DefaultSmall")
		
		draw.DrawText(marker_number, "DefaultSmall", marker_x, marker_y, nil, TEXT_ALIGN_CENTER)
		fatool.ui.draw_vertical_dashed_line(3, marker_x, self.contents:GetY(), self.contents:GetTall(), 255, 255, 255)
	end	
	
end

function PANEL:OnMousePressed(mouse_key)
	
end

vgui.Register("fatool_timeline", PANEL, "DPanel")
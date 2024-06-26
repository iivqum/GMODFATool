include("fatool/ui/spline.lua")
include("fatool/ui/grabbable.lua")
include("fatool/ui/timeline.lua")
include("fatool/ui/editor.lua")
include("fatool/ui/preview.lua")
include("fatool/ui/menubar.lua")

fatool.ui = fatool.ui or {}

function fatool.ui.draw_vertical_dashed_line(gap, x, start_y, length)
	local max_y = start_y + length
	for i = 0, math.floor(length / gap * 0.5) do
		local y_start = start_y + i * gap * 2
		if y_start >= max_y then
			return
		end
		local y_end = math.min(y_start + gap, max_y)
		surface.DrawLine(x, y_start, x, y_end)
	end
end

function fatool.ui.draw_horizontal_dashed_line(gap, y, start_x, length)
	local max_x = start_x + length
	for i = 0, math.floor(length / gap * 0.5) do
		local x_start = start_x + i * gap * 2
		if x_start >= max_x then
			return
		end
		local x_end = math.min(x_start + gap, max_x)
		surface.DrawLine(x_start, y, x_end, y)
	end
end

function fatool.ui.draw_dashed_rectangle(gap, x, y, width, height)
	local width = width - 1
	local height = height - 1

	fatool.ui.draw_horizontal_dashed_line(gap, y, x, width)
	fatool.ui.draw_horizontal_dashed_line(gap, y + height, x, width)
	fatool.ui.draw_vertical_dashed_line(gap, x, y, height)
	fatool.ui.draw_vertical_dashed_line(gap, x + width, y, height)
end

function fatool.ui.get_font_height(font)
	assert(isstring(font))
	surface.SetFont(font)
	return select(2, surface.GetTextSize(""))
end

local PANEL = {}

function PANEL:Init()
	self:SetSize(ScrW() * 0.7, ScrH() * 0.7)
	self:SetSizable(false)
	self:SetTitle("FATool") 
	self:SetVisible(true) 
	self:SetDraggable(true) 
	self:ShowCloseButton(true) 
	self:MakePopup()
	self:Center()
	
	self.menubar = self:Add("fatool_menubar")
	self.menubar:Dock(TOP)
	
	self.timeline = self:Add("DFrame")
	self.timeline:SetTall(self:GetTall() * 0.3)
	self.timeline:ShowCloseButton(false)
	self.timeline:SetDraggable(false)
	self.timeline:SetTitle("Timeline")
	self.timeline:Dock(BOTTOM)
	
	self.timeline.panel = self.timeline:Add("fatool_timeline")
	
	self.preview = self:Add("DFrame")
	self.preview:ShowCloseButton(false)
	self.preview:SetDraggable(false)
	self.preview:SetTitle("Animation preview")
	self.preview:SetWide(self:GetWide() * 0.3)
	self.preview:Dock(LEFT)
	
	self.preview.panel = self.preview:Add("fatool_preview")
	
	self.editor = self:Add("DFrame")
	self.editor:ShowCloseButton(false)
	self.editor:SetDraggable(false)
	self.editor:SetTitle("Editor")	
	self.editor:Dock(FILL)
	
	self.editor.panel = self.editor:Add("fatool_editor")
end

function PANEL:get_editor()
	return self.editor.panel
end

function PANEL:get_timeline()
	return self.timeline.panel
end

function PANEL:get_preview()
	return self.preview.panel
end

vgui.Register("fatool_ui", PANEL, "DFrame")

function fatool.ui.open()
	fatool.ui.sequence = fatool.sequence()
	fatool.ui.state = vgui.Create("fatool_ui")
end

concommand.Add("fatool",fatool.ui.open)


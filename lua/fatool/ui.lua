include("fatool/ui/messages.lua")
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

local function request_focus(panel)
	for k, v in pairs(panel:GetChildren()) do
		v:RequestFocus()
	end
	--panel:RequestFocus()
end

local function is_hovered(panel)
	local mouse_x, mouse_y = input.GetCursorPos()
	local width, height = panel:GetSize()
	local x, y = panel:GetParent():LocalToScreen(panel:GetPos())
	local dx = mouse_x - x
	local dy = mouse_y - y
	if dx >= 0 and dx < width and dy >= 0 and dy < height then
		return true
	end
end

local PANEL = {}

function PANEL:Init()
	self:SetSize(ScrW() * 0.7, ScrH() * 0.7)
	self:SetSizable(false)
	self:SetTitle("FATool") 
	self:SetVisible(true) 
	self:SetDraggable(true)
	self:SetKeyboardInputEnabled(true)
	self:ShowCloseButton(true)
	self:MakePopup()
	self:Center()
	self:SetFocusTopLevel(true)
	
	self.menubar = self:Add("fatool_menubar")
	self.menubar:Dock(TOP)
	
	self.messages = self:Add("fatool_messages")
	self.messages:SetTall(self:GetTall() * 0.05)
	self.messages:Dock(BOTTOM)	
	
	self.timeline = self:Add("DFrame")
	self.timeline:SetTall(self:GetTall() * 0.25)
	self.timeline:ShowCloseButton(false)
	self.timeline:SetTitle("Timeline")
	self.timeline:Dock(BOTTOM)
	
	self.timeline.panel = self.timeline:Add("fatool_timeline")
	
	self.editor = self:Add("DFrame")
	self.editor:ShowCloseButton(false)
	self.editor:SetTitle("Editor")
	self.editor:SetWide(self:GetWide() * 0.6)
	self.editor:Dock(LEFT)
	
	self.editor.panel = self.editor:Add("fatool_editor")
	
	self.preview = self:Add("DFrame")
	self.preview:ShowCloseButton(false)
	self.preview:SetTitle("Animation preview")
	self.preview:Dock(FILL)
	
	self.preview.panel = self.preview:Add("fatool_preview")
	
	self.timeline:KillFocus()
	self.preview:KillFocus()
	self.editor:KillFocus()
	
	fatool.ui.sequence:set_actor(self.preview.panel:GetEntity())
end

function PANEL:Think()
	local mouse_left_pressed = input.IsMouseDown(MOUSE_LEFT)
	if mouse_left_pressed then 
		if not self.mouse_left_pressed then
			self.mouse_left_pressed = true
			self:mouse_pressed()
		end
	elseif self.mouse_left_pressed then
		self.mouse_left_pressed = false
	end
end

function PANEL:mouse_pressed()
	if is_hovered(self.timeline) then
		request_focus(self.timeline)
	end
	if is_hovered(self.preview) then
		request_focus(self.preview)
	end	
	if is_hovered(self.editor) then
		request_focus(self.editor)
	end	
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

function PANEL:get_messages()
	return self.messages
end

vgui.Register("fatool_ui", PANEL, "DFrame")

function fatool.ui.open()
	fatool.ui.sequence = fatool.sequence()
	fatool.ui.state = vgui.Create("fatool_ui")
end

function fatool.ui.load_sequence(sequence_identifier)
	if not IsValid(fatool.ui.state) then
		return
	end
	local sequence = fatool.load(sequence_identifier)
	if not sequence then
		fatool.ui.message("Couldn't load sequence!")
		return
	end
	sequence:set_actor(fatool.ui.state:get_preview():GetEntity())
	fatool.ui.sequence = sequence
	fatool.ui.state:InvalidateChildren(true)
end

function fatool.ui.message(text)
	if not IsValid(fatool.ui.state) then
		return
	end
	local messages = fatool.ui.state:get_messages()
	messages:write(text)
end

concommand.Add("fatool",fatool.ui.open)


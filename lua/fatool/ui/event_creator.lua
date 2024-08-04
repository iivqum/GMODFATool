
local PANEL = {}

local valid_text_chars = "0123456789"

function PANEL:Init()

	self:SetSize(256, 192)
	self:MakePopup()
	self:Center()
	self:SetTitle("Create event")

	self.contents = self:Add("DPanel")
	self.contents:Dock(FILL)
	
	self.animation_id_label = self.contents:Add("DLabel")
	self.animation_id_label:SetText("Animation ID: ")
	self.animation_id_label:Dock(TOP)
	self.animation_id_label:DockMargin(32, 0, 0, 0)
	self.animation_id_label:SetColor(Color(0, 0, 0))
	
	self.animation_id_entry = self.contents:Add("DTextEntry")
	self.animation_id_entry:Dock(TOP)
	self.animation_id_entry:DockMargin(32, 0, 32, 0)
	self.animation_id_entry:SetValue("Default")	

	self.start_time_label = self.contents:Add("DLabel")
	self.start_time_label:SetText("Start time (seconds):")
	self.start_time_label:Dock(TOP)
	self.start_time_label:DockMargin(32, 0, 0, 0)
	self.start_time_label:SetColor(Color(0, 0, 0))
	
	self.start_time_entry = self.contents:Add("DTextEntry")
	self.start_time_entry:Dock(TOP)
	self.start_time_entry:DockMargin(32, 0, 32, 0)
	self.start_time_entry:SetValue(0)
	self.start_time_entry:SetNumeric(true)
	
	function self.start_time_entry.AllowInput(panel, character)
		return not (valid_text_chars:find(character) and true or false)
	end
	
	function self.start_time_entry.OnValueChange(panel, text)
		local start = panel:GetFloat()
		local stop = self.stop_time_entry:GetFloat()
		if text:len() == 0 then
			panel:SetText(0)
		elseif start >= stop then
			self.stop_time_entry:SetText(start + 1)
		end
	end	
	
	self.stop_time_label = self.contents:Add("DLabel")
	self.stop_time_label:SetText("Stop time (seconds):")
	self.stop_time_label:Dock(TOP)
	self.stop_time_label:DockMargin(32, 0, 0, 0)
	self.stop_time_label:SetColor(Color(0, 0, 0))
	
	self.stop_time_entry = self.contents:Add("DTextEntry")
	self.stop_time_entry:Dock(TOP)
	self.stop_time_entry:DockMargin(32, 0, 32, 0)
	self.stop_time_entry:SetValue(5)
	self.stop_time_entry:SetNumeric(true)
	
	function self.stop_time_entry.AllowInput(panel, character)
		return not (valid_text_chars:find(character) and true or false)
	end
	
	function self.stop_time_entry.OnValueChange(panel, text)
		local start = self.start_time_entry:GetFloat()
		local stop = panel:GetFloat()
		if text:len() == 0 or stop <= start then
			panel:SetText(start + 1)
		end
	end
	
	self.accept = self.contents:Add("DButton")
	self.accept:Dock(TOP)
	self.accept:DockMargin(32, 16, 32, 0)
	self.accept:SetText("OK")
	
	function self.accept.DoClick(panel)
		local animation = fatool.ui.sequence:add_animation(self.animation_id_entry:GetValue())
		if not animation then
			fatool.ui.message("Failed to create animation...")
		else
			animation:set_start(self.start_time_entry:GetFloat())
			animation:set_stop(self.stop_time_entry:GetFloat())
			animation:setup()
		end
		self:Close()
		fatool.ui.state:InvalidateChildren(true)
	end
end

vgui.Register("fatool_event_creator", PANEL, "DFrame")

local PANEL = {}

local valid_text_chars = "0123456789"

function PANEL:Init()

	self:SetSize(256, 192)
	self:MakePopup()
	self:Center()
	self:SetTitle("Create event")

	self.contents = self:Add("DPanel")
	self.contents:Dock(FILL)

	self.label1 = self.contents:Add("DLabel")
	self.label1:SetText("Start time (seconds):")
	self.label1:Dock(TOP)
	self.label1:DockMargin(32, 0, 0, 0)
	self.label1:SetColor(Color(0, 0, 0))
	
	self.entry1 = self.contents:Add("DTextEntry")
	self.entry1:Dock(TOP)
	self.entry1:DockMargin(32, 0, 32, 0)
	self.entry1:SetValue(0)
	self.entry1:SetNumeric(true)
	
	function self.entry1.AllowInput(panel, character)
		return not (valid_text_chars:find(character) and true or false)
	end
	
	function self.entry1.OnValueChange(panel, text)
		local start = panel:GetFloat()
		local stop = self.entry2:GetFloat()
		if text:len() == 0 then
			panel:SetText(0)
		elseif start >= stop then
			self.entry2:SetText(start + 1)
		end
	end	
	
	self.label2 = self.contents:Add("DLabel")
	self.label2:SetText("Stop time (seconds):")
	self.label2:Dock(TOP)
	self.label2:DockMargin(32, 0, 0, 0)
	self.label2:SetColor(Color(0, 0, 0))
	
	self.entry2 = self.contents:Add("DTextEntry")
	self.entry2:Dock(TOP)
	self.entry2:DockMargin(32, 0, 32, 0)
	self.entry2:SetValue(5)
	self.entry2:SetNumeric(true)
	
	function self.entry2.AllowInput(panel, character)
		return not (valid_text_chars:find(character) and true or false)
	end
	
	function self.entry2.OnValueChange(panel, text)
		local start = self.entry1:GetFloat()
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
		local timeline = fatool.ui.state:get_timeline()
		
	end
end

vgui.Register("fatool_event_creator", PANEL, "DFrame")
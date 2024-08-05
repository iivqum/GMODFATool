
local PANEL = {}

function PANEL:Init()
	self.file = self:AddMenu("File")
	
	self.file:AddOption("New")
	
	self.file:AddOption("Load", function()
		local body = fatool.ui.state:Add("DFrame")
		body:SetSize(ScrW() * 0.25, ScrH() * 0.25)
		body:SetSizable(false)
		body:SetTitle("Load animation") 
		body:SetVisible(true) 
		body:SetDraggable(true) 
		body:ShowCloseButton(true) 
		body:Center()
		
		local browser = vgui.Create("DFileBrowser", body)
		browser:SetOpen(true)
		browser:SetFileTypes("*.json")
		browser:Dock(FILL)
		browser:SetPath("DATA")
		browser:SetBaseFolder("fatool")
		browser:SetCurrentFolder("fatool")
		
		function browser:OnDoubleClick(path, selected)
			fatool.ui.load_sequence(path:GetFileFromFilename())
			body:Close()
		end		
	end)
	
	self.file:AddOption("Save", function()
		fatool.save(fatool.ui.sequence, "test", fatool.ui.state:get_preview():get_model())
	end)
	
	self.edit = self:AddMenu("Edit")
	
	self.edit:AddOption("Change model", function()
		local body = fatool.ui.state:Add("DFrame")
		body:SetSize(ScrW() * 0.45, ScrH() * 0.45)
		body:SetSizable(false)
		body:SetTitle("Change model") 
		body:SetVisible(true) 
		body:SetDraggable(true) 
		body:ShowCloseButton(true) 
		body:Center()
		
		local browser = vgui.Create("DFileBrowser", body)
		browser:SetModels(true)
		browser:SetOpen(true)
		browser:SetFileTypes("*.mdl")
		browser:Dock(FILL)
		browser:SetPath("GAME")
		browser:SetBaseFolder("models")
		
		function browser:OnDoubleClick(model_path, selected)
			fatool.ui.state:get_preview():set_model(model_path)
			body:Close()
		end
	end)
end

vgui.Register("fatool_menubar", PANEL, "DMenuBar")

local PANEL = {}

function PANEL:Init()
	self.file = self:AddMenu("File")
	
	self.file:AddOption("New")
	self.file:AddOption("Load")
	
	self.edit = self:AddMenu("Edit")
	
	self.edit:AddOption("Change model", function()
		local body = vgui.Create("DFrame")
		body:SetSize(ScrW() * 0.45, ScrH() * 0.45)
		body:SetSizable(false)
		body:SetTitle("Save animation") 
		body:SetVisible(true) 
		body:SetDraggable(true) 
		body:ShowCloseButton(true) 
		body:MakePopup()
		body:Center()
		
		local browser = vgui.Create("DFileBrowser", body)
		browser:SetModels(true)
		browser:SetOpen(true)
		browser:SetFileTypes("*.mdl")
		browser:Dock(FILL)
		browser:SetPath("GAME")
		browser:SetBaseFolder("models")
		
		function browser:OnDoubleClick(path, selected)
			fatool.ui.state:get_preview():GetEntity():SetModel(path)
			if not fatool.ui.sequence:is_supported() then
				fatool.ui.message("Model " .. path .. " has unsupported animations!")
			end
			body:Close()
		end
	end)
end

vgui.Register("fatool_menubar", PANEL, "DMenuBar")

local PANEL = {}

function PANEL:Init()
	self.file = self:AddMenu("File")
	
	self.file:AddOption("New")
	
	self.file:AddOption("Load", function()
		fatool.ui.load_sequence("test")
	end)
	
	self.file:AddOption("Save", function()
		fatool.save(fatool.ui.sequence, "test")
	end)
	
	self.edit = self:AddMenu("Edit")
	
	self.edit:AddOption("Change model", function()
		local body = fatool.ui.state:Add("DFrame")
		body:SetSize(ScrW() * 0.45, ScrH() * 0.45)
		body:SetSizable(false)
		body:SetTitle("Save animation") 
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
		
		function browser:OnDoubleClick(path, selected)
			fatool.ui.state:get_preview():GetEntity():SetModel(path)
			for animation_id, animation in pairs(fatool.ui.sequence:get_animations()) do
				if animation:has_unsupported_flexes() then
					fatool.ui.message("Warning! Animation \"" .. animation_id .. "\" has unsupported flexes!")
				end
			end
			body:Close()
		end
	end)
end

vgui.Register("fatool_menubar", PANEL, "DMenuBar")
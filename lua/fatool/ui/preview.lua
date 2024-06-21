
local PANEL = {}

function PANEL:Init()
	self:Dock(FILL)
	self:SetModel("models/Humans/Group02/male_02.mdl")
	self:SetAnimated(true)	
end

function PANEL:LayoutEntity()
	local head_position = self:GetEntity():GetBonePosition(self:GetEntity():LookupBone("ValveBiped.Bip01_Head1"))
	self:SetLookAt(head_position)
	self:SetCamPos(head_position - Vector(-15, 0, 0))
	self:GetEntity():SetEyeTarget(head_position - Vector(-15, 0, 0))
end

function PANEL:PreDrawModel(preview_entity)
	cam.Start2D()
	surface.SetDrawColor(0, 0, 0)
	self:DrawFilledRect()
	cam.End2D()	
end

vgui.Register("fatool_preview", PANEL, "DModelPanel")
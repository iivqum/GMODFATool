
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
	
	fatool.ui.sequence:set_actor(self:GetEntity())
	
	local timeline = fatool.ui.state:get_timeline()
	
	timeline:add_animation("test", 1, 2)
	timeline:add_animation("test2", 3, 4)
	timeline:add_animation("test3", 5, 6)
	timeline:add_animation("test4", 7, 8)
	timeline:add_animation("test5", 7, 8)
	timeline:add_animation("test6", 7, 8)	
end

function PANEL:PreDrawModel(preview_entity)
	cam.Start2D()
	surface.SetDrawColor(0, 0, 0)
	self:DrawFilledRect()
	cam.End2D()	
end

vgui.Register("fatool_preview", PANEL, "DModelPanel")
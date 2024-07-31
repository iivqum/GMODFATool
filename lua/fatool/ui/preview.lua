
local PANEL = {}

function PANEL:Init()
	self:Dock(FILL)
	self:SetModel("models/Humans/Group02/male_02.mdl")
	self:SetAnimated(true)
	
	self.drag_panel = self:Add("fatool_grabby")
	self.drag_panel:Dock(FILL)
	
	function self.drag_panel.Paint(panel)
	
	end
	
	function self.drag_panel.on_grabbing(panel)
		local delta_x, delta_y = panel:get_mouse_delta()

		local degrees_per_pixel = 0.1
		local angle = self:GetEntity():GetAngles()

		angle.pitch = angle.pitch + degrees_per_pixel * delta_y
		angle.yaw = angle.yaw + degrees_per_pixel * delta_x
		
		self:GetEntity():SetAngles(angle)
	end
	
	function self.drag_panel.OnMouseWheeled(panel, scroll_delta)
		local look_at = (self:GetLookAt() - self:GetCamPos())
		look_at:Normalize()
		local pos = self:GetEntity():GetPos()
		local delta = look_at * scroll_delta
		self:GetEntity():SetPos(pos + delta)
	end
	
	fatool.ui.sequence:set_actor(self:GetEntity())
end

function PANEL:LayoutEntity()
	local head_position = self:GetEntity():GetBonePosition(self:GetEntity():LookupBone("ValveBiped.Bip01_Head1")) + self:GetEntity():GetPos()
	self:SetLookAt(head_position)
	self:SetCamPos(head_position - Vector(-15, 0, 0))
	self:GetEntity():SetEyeTarget(self:GetCamPos())	
end

function PANEL:PreDrawModel(preview_entity)
	cam.Start2D()
	surface.SetDrawColor(0, 0, 0)
	self:DrawFilledRect()
	cam.End2D()	
end

vgui.Register("fatool_preview", PANEL, "DModelPanel")
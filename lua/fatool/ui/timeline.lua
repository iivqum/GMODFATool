local PANEL = {}

function PANEL:Init()
	-- How zoomed the timeline is
	self.scale = 1
	-- Current sequence to edit
	self.sequence = nil

	self:Dock(FILL)
	
	self.top = self:Add("DPanel")
	self.top:SetTall(24)
	self.top:Dock(TOP)
	
	function self.top:Paint(width, height)	
		surface.SetDrawColor(150, 150, 150)
		surface.DrawLine(-1, height - 1, width - 1, height - 1)
		--self:DrawFilledRect()
	end	
	
	self.contents = self:Add("DScrollPanel")
	self.contents:Dock(FILL)
	self.contents:SetPadding(100)
	
	function self.contents:Paint(width, height)
		surface.SetDrawColor(150, 150, 150)
		surface.DrawLine(128, -1, 128, height + 1)
	end
	
	for i = 0, 1 do
		self.test = self.contents:Add("DPanel")
		self.test:SetTall(48)
		self.test:Dock(TOP)
		function self.test:Paint(width, height)
			surface.SetDrawColor(100, 100, 100)
			surface.DrawLine(128, height - 1, width - 1, height - 1)
		end	
	end
end

function PANEL:draw_dashed_line(start_x, start_y, stop_x, stop_y)
	
end

function PANEL:Paint(width, height)
	surface.SetDrawColor(80, 80, 80)
	self:DrawFilledRect()
	surface.SetDrawColor(255, 255, 255)
	
	
end

function PANEL:OnMousePressed(mouse_key)
	
end

vgui.Register("fatool_timeline", PANEL, "DPanel")
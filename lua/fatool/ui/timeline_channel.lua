
local PANEL = {}

function PANEL:Init()
	self:Dock(FILL)
end

function PANEL:Paint()
	surface.SetDrawColor(80, 80, 80)
	self:DrawFilledRect()
	surface.SetDrawColor(255, 255, 255)
end


--[[
	for i = 0, 5 do
	local test = self.top_scroll:Add("DPanel")
	test:SetTall(16)
	test:Dock(TOP)
	test:DockMargin(0, 16, 0, 0)
	
	function test.Paint(panel, width, height)
		local left_boundary, right_boundary = self:get_time_boundaries()
		local span = self.timeline_span
		local start_time = 5
		local stop_time = 7
		local start_x = 1
		local stop_x = width
		
		if start_time > left_boundary then
			start_x = math.floor((start_time - left_boundary) / span * width) + 1
		end
		if stop_time < right_boundary then
			stop_x = math.floor((stop_time - left_boundary) / span * width)
		end
		
		surface.SetDrawColor(120, 20, 20)
		--surface.DrawLine(start_x, 0, stop_x, 0)
		surface.DrawRect(start_x, 0, stop_x - start_x, height)
	end
	end
--]]
vgui.Register("fatool_timeline_chan", PANEL, "DPanel")
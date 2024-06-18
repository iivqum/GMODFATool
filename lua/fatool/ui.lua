include("fatool/ui/spline.lua")

fatool.ui = {}

function fatool.ui.open()
	local flex_ui = {}

	flex_ui.window=vgui.Create("DFrame")
	flex_ui.window:SetSize(ScrW()*0.7,ScrH()*0.7)
	flex_ui.window:SetSizable(false)
	flex_ui.window:SetTitle("test") 
	flex_ui.window:SetVisible(true) 
	flex_ui.window:SetDraggable(true) 
	flex_ui.window:ShowCloseButton(true) 
	flex_ui.window:MakePopup()
	flex_ui.window:Center()
	
	local spline = vgui.Create("fatool_spline",flex_ui.window)
	spline:Dock(FILL)
end

concommand.Add("flextest",fatool.ui.open)

local PANEL = {}

PANEL.Init = function( panel )
	panel:SetText( "" )
	panel:SetSize( 24, 24 )
	panel.Dragging = false
end
PANEL.OnCursorMoved = function( panel, x, y )
	if ( panel.Dragging ) then
		local x, y = input.GetCursorPos()
		panel:SetPos( panel.StartPos.x + x - panel.CursorPos.x , panel.StartPos.y + y - panel.CursorPos.y )
	end
end
PANEL.OnMousePressed = function( panel, x, y )
	panel.Dragging = true
	local x, y = input.GetCursorPos()
	panel.CursorPos = { x = x, y = y }
	local x, y = panel:GetPos()
	panel.StartPos = { x = x, y = y }
end

PANEL.OnMouseReleased = function( panel, x, y ) panel.Dragging = false end
PANEL.OnCursorExited = PANEL.OnCursorMoved 

local MovableButton = vgui.RegisterTable( PANEL, "DButton" )


local f = vgui.Create( "DFrame" )
f:SetSize( 500, 500 )
f:Center()
f:MakePopup()

local oldPaint = f.Paint
f.Paint = function( pnl, w, h )
	oldPaint( pnl, w, h )

	local points = {}
	for k, pnl in ipairs( pnl:GetChildren() ) do
		local x, y = pnl:GetPos()
		if ( pnl.Dragging != nil ) then
			table.insert( points, Vector( x, y, 0 ) )
			pnl:SetText( #points )
		end
	end

	surface.SetDrawColor( 255, 0, 0, 255 )
	local lastPos = math.BSplinePoint( 0, points, 1 )
	for i=0, 32 do
		local pos = math.BSplinePoint( i / 32, points, 1 )
		surface.DrawLine( lastPos.x, lastPos.y, pos.x, pos.y )
		lastPos = pos
	end
end

vgui.CreateFromTable( MovableButton, f ):SetPos( 100, 100 )
vgui.CreateFromTable( MovableButton, f ):SetPos( 200, 200 )
vgui.CreateFromTable( MovableButton, f ):SetPos( 300, 100 )
vgui.CreateFromTable( MovableButton, f ):SetPos( 400, 200 )

local addBtn = vgui.Create( "DButton", f )
addBtn:Dock( TOP )
addBtn:SetText( "Add point" )
addBtn.DoClick = function() vgui.CreateFromTable( MovableButton, f ):SetPos( VectorRand( 20, 450 ):Unpack() ) end
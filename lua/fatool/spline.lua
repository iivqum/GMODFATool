fatool.spline = {}

local catmull_rom_spline = {
	-- Catmull-Rom spline parameters used to change its shape
	alpha = 0.5,
	tension = 0,
	-- Array of points in the spline. Points are Vector types.
	points = {},
	-- Array of pairs of points. A pair of points specifies a segment
	segments = {},
	-- Spline control points which specify the start and end of the spline
	control0 = Vector(0),
	control1 = Vector(0,1),
	-- Length of the spline
	length = 0,
	-- Spline Y offset
	offset = 0
}

catmull_rom_spline.__index = catmull_rom_spline

function fatool.spline.new(alpha, tension)
	[[
		Purpose:
			Create an instance of a spline object
	]]
	return setmetatable({alpha = alpha, tension = tension}, catmull_rom_spline)
end

local function catmull_rom(alpha, tension, p0, p1, p2, p3)
	[[
		Purpose:
			Compute Catmull-Rom spline coefficients
	]]
	local t0 = 0
	local t1 = t0+math.pow(distance2d(p0,p1),alpha)
	local t2 = t1+math.pow(distance2d(p1,p2),alpha)
	local t3 = t2+math.pow(distance2d(p2,p3),alpha)
	
	local m1 = (1-tension)*(t2-t1)*((p1-p0)/(t1-t0)-(p2-p0)/(t2-t0)+(p2-p1)/(t2-t1))
	local m2 = (1-tension)*(t2-t1) *((p2-p1)/(t2-t1)-(p3-p1)/(t3-t1)+(p3-p2)/(t3-t2))
	
	local a = 2*(p1-p2)+m1+m2
	local b = -3*(p1-p2)-m1-m1-m2
	local c = m1
	local d = p1
	
	return a, b, c, d
end


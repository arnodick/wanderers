local function components(x,y,x2,y2)
	return x2-x, y2-y
end

function normalize(vx,vy)
	local l = distance(0,0,vx,vy)
	return vx/l, vy/l
end

function distance(x,y,x2,y2)
	local w,h = x2 - x, y2 - y
	return math.sqrt(w^2+h^2)
end

return
{
	components = components,
	normalize = normalize,
	distance = distance,
}
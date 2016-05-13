local function vector(x,y,x2,y2)
	return x2-x, y2-y
end

function distance(x,y,x2,y2)
	local w,h = x2 - x, y2 - y
	return math.sqrt(w^2+h^2)
end

function collidepoint(x, y, t)
	if  x > t.x - 1 -- the -1 is just so hit pixel is visible always, maybe won't need it later
	and x < t.x + t.w
	and y > t.y - 1
	and y < t.y + t.h then
		return true
	end
	return false
end

return
{
	vector = vector,
	distance = distance,
	collidepoint = collidepoint,
}
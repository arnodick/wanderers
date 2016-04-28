local function vector(x,y,x2,y2)
	return x2-x, y2-y
end

function distance(x,y,x2,y2)
	local w,h = x2 - x, y2 - y
	return math.sqrt(w^2+h^2)
end

return
{
	vector = vector,
	distance = distance,
}
function point(x, y, t)
	--checks if an x,y position is in an actor's hitbox
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
	point = point,
}
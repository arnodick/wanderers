function make(t,s,x,y,d,v)
	local a={}
	a.t=t --type (player,enemy, etc)
	a.s=s --sprite
	a.x=x
	a.y=y
--	a.d=d --direction --NOTE: don't need this?
	a.v=v --velocity
	a.spd=0.5
	a.tar={x,y}--TODO: change this to tar.x
	a.vec={0,0}--TODO: change this to vec.x
--	a.moving=false
	a.id = #Actors + 1
	table.insert(Actors,a)
	return a
end

function control(a)
--	if a.moving then
	if a.v > 0 then
		local dist = movement.distance(a.x,a.y,a.tar[1],a.tar[2])
		if dist < 1 then
--			a.moving=false
			--TODO: put snap to grid stuff here
			a.v=0
		else
			local vec1, vec2 = movement.vector(a.x,a.y,a.tar[1],a.tar[2])
			a.vec[1] = (vec1/dist)
			a.vec[2] = (vec2/dist)
			if not actor.collide(a, Walls) then
				a.x = a.x + a.vec[1] * a.v
				a.y = a.y + a.vec[2] * a.v
			end
		end
	end
end

function collide(a, targets)
	for i,v in ipairs(targets) do
		if  a.x + a.vec[1]*a.v > v.x - 1 -- the -1 is just so hit pixel is visible always, maybe won't need it later
		and a.x + a.vec[1]*a.v < v.x + v.w
		and a.y + a.vec[2]*a.v > v.y - 1
		and a.y + a.vec[2]*a.v < v.y + v.h then
			return true
		end
	end
	return false
end

function draw(a)
	love.graphics.draw(Spritesheet,Quads[a.s],math.floor(a.x) - TileW/2,math.floor(a.y) - TileH/2)
	if DebugMode then
		love.graphics.setColor(0, 255, 0, 255)
		love.graphics.line( a.x, a.y, a.tar[1], a.tar[2] )
		love.graphics.setColor(255, 255, 255, 255)
	end
end

return
{
	make = make,
	control = control,
	collide = collide,
	draw = draw,
}
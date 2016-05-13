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
	if a.v > 0 then
		local dist = movement.distance(a.x,a.y,a.tar[1],a.tar[2])
		if dist < 1 then
			--TODO: put snap to grid stuff here
			a.v = 0
		else
			local vec1, vec2 = movement.vector(a.x,a.y,a.tar[1],a.tar[2])
			a.vec[1] = (vec1/dist)
			a.vec[2] = (vec2/dist)
			local xdest = a.x + a.vec[1] * a.v
			local ydest = a.y + a.vec[2] * a.v
			local colhor = false
			local colver = false
			for i,v in ipairs(Walls) do
				if movement.collidepoint(xdest, ydest, v) then
					if movement.collidepoint(xdest, a.y, v) then
						colhor = true
					end
					if movement.collidepoint(a.x, ydest, v) then
						colver = true
					end
				end
			end
			--TODO: fix case where if you hit a corner and don't move
			if not colhor then
				a.x = xdest
			end
			if not colver then
				a.y = ydest
			end
		end
	end
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
	draw = draw,
}
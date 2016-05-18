function make(t,s,x,y,spd,mt)
	local a={}
	a.t=t --type (player,enemy, etc)
	a.s=s --sprite
	a.x=x
	a.y=y
	a.spd=spd
	a.mt=mt
	a.v=0 --velocity
	a.tar={x,y}--TODO: change this to tar.x
	a.vec={0,0}--TODO: change this to vec.x
	a.id = #Actors + 1
	table.insert(Actors,a)
	return a
end

function control(a, id)
	if a.v > 0 then
		--TODO: update vector here
		if a.mt == Enums.walk then
			local dist = movement.distance(a.x,a.y,a.tar[1],a.tar[2])
			local vec1, vec2 = movement.vector(a.x,a.y,a.tar[1],a.tar[2])
			--TODO: make normalize function
			a.vec[1] = (vec1/dist)
			a.vec[2] = (vec2/dist)
			local xdest = a.x + a.vec[1] * a.v
			local ydest = a.y + a.vec[2] * a.v
			if dist < a.v then
				--TODO: put snap to grid stuff here
				a.v = 0
			else
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
		elseif a.mt == Enums.bullet then
			local xdest = a.x + a.vec[1] * a.v
			local ydest = a.y + a.vec[2] * a.v
			for i,v in ipairs(Walls) do
				if movement.collidepoint(xdest, ydest, v) then
					table.remove(Actors,id)
				end
			end
			a.x = xdest
			a.y = ydest
		end
	end
	if a.x < 0 - GameWidth
	or a.x > #Map[1]*TileW + GameWidth
	or a.y < 0 - GameHeight
	or a.y > #Map*TileH + GameHeight then
		table.remove(Actors,id)
	end
end

function draw(a)
	--love.graphics.draw(Spritesheet,Quads[a.s],math.floor(a.x+math.cos(Slowdown.timer/Slowdown.amount*a.v)),math.floor(a.y+math.sin(Slowdown.timer/Slowdown.amount*a.v)), math.atan2(a.vec[2],a.vec[1]), 1, 1, TileW/2, TileH/2)
	love.graphics.draw(Spritesheet,Quads[a.s],math.floor(a.x),math.floor(a.y), math.atan2(a.vec[2],a.vec[1]), 1, 1, TileW/2, TileH/2)
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
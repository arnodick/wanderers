function make(t,s,x,y,spd,mt)
	local a={}
	a.t=t --type (player,enemy, etc)
	a.s=s --sprite
	a.x=x
	a.y=y
	a.spd=spd
	a.mt=mt
	a.v=0 --velocity
	a.tar={} a.tar.x=0 a.tar.y=0
	a.vec={} a.vec.x=0 a.vec.y=0
	--a.id = #Actors + 1
	table.insert(Actors,a)
	return a
end

function control(a, id)
	if a.v > 0 then
		if a.mt == Enums.walk then
			a.vec.x, a.vec.y = movement.normalize(movement.vector(a.x,a.y,a.tar.x,a.tar.y))
			local xdest = a.x + a.vec.x * a.v
			local ydest = a.y + a.vec.y * a.v
			if movement.distance(a.x,a.y,a.tar.x,a.tar.y) < a.v then
				--TODO: put snap to grid stuff here maybe?
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
			local xdest = a.x + a.vec.x * a.v
			local ydest = a.y + a.vec.y * a.v
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
	--love.graphics.draw(Spritesheet,Quads[a.s],math.floor(a.x),math.floor(a.y), math.atan2(a.vec.y,a.vec.x), 1, 1, TileW/2, TileH/2)
	love.graphics.draw(Spritesheet,Quads[a.s],math.floor(a.x + Slowdown.timer/Slowdown.amount*(a.vec.x * a.v) ),math.floor(a.y + Slowdown.timer/Slowdown.amount*(a.vec.y * a.v) ), math.atan2(a.vec.y,a.vec.x), 1, 1, TileW/2, TileH/2) --FUCK YEAH. TODO: should these heavy calculations be done outside of draw function?
	if DebugMode then
		love.graphics.setColor(0, 255, 0, 255)
		love.graphics.line( a.x, a.y, a.tar.x, a.tar.y )
		love.graphics.setColor(255, 255, 255, 255)
	end
end

return
{
	make = make,
	control = control,
	draw = draw,
}
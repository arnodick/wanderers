function update()
	local debuglist={}
--	table.insert(debuglist,love.timer.getTime())
	table.insert(debuglist,love.timer.getFPS())
	table.insert(debuglist,"Turn timer: "..Turn.timer)
	table.insert(debuglist,"Slowdown timer: "..Slowdown.timer)
	table.insert(debuglist,"Slowdown rate: "..Slowdown.rate)
	table.insert(debuglist,"Actors: "..#Actors)
	table.insert(debuglist,"Walls: "..#Walls)
	table.insert(debuglist,"Player X: "..Player.x)
	table.insert(debuglist,"Player Y: "..Player.y)
	table.insert(debuglist,"Player Vec X: "..Player.vec[1])
	table.insert(debuglist,"Player Vec Y: "..Player.vec[2])
	table.insert(debuglist,"Player Dir: "..math.atan(Player.vec[2],Player.vec[1]))
	table.insert(debuglist,"Player Vel: "..Player.v)
--	table.insert(debuglist,"Player Dir: "..Player.d)
	return debuglist
end

function draw(debuglist)
	love.graphics.setColor(0, 0, 255, 255)
	love.graphics.print("DEBUG",130,0)
	for i,v in ipairs(debuglist) do
		love.graphics.print(v,10,10+10*i)
	end
end

return
{
	update = update,
	draw = draw,
}
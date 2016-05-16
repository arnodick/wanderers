function update()
	local debuglist={}
--	table.insert(debuglist,love.timer.getTime())
	table.insert(debuglist,"FPS: "..love.timer.getFPS())
	table.insert(debuglist,"Timer: "..Timer)
	table.insert(debuglist,"Slowdown timer: "..Slowdown.timer)
	table.insert(debuglist,"Slowdown amount: "..Slowdown.amount)
	table.insert(debuglist,"Actors: "..#Actors)
	table.insert(debuglist,"Walls: "..#Walls)
	table.insert(debuglist,"Player X: "..Player.x)
	table.insert(debuglist,"Player Y: "..Player.y)
	table.insert(debuglist,"Player Vec X: "..Player.vec[1])
	table.insert(debuglist,"Player Vec Y: "..Player.vec[2])
	table.insert(debuglist,"Player Dir: "..math.atan2(Player.vec[2],Player.vec[1]))
	table.insert(debuglist,"Player Vel: "..Player.v)
	table.insert(debuglist,"Save: "..love.filesystem.getSaveDirectory())
	return debuglist
end

function draw(debuglist)
	love.graphics.setColor(0, 0, 255, 255)
	love.graphics.print("DEBUG",130,0)
	for i,v in ipairs(debuglist) do
		love.graphics.print(v,10,10+FontDebug:getHeight()*i)
	end
end

return
{
	update = update,
	draw = draw,
}
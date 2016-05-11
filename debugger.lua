function update()
	local debuglist={}
	table.insert(debuglist,love.timer.getTime())
	table.insert(debuglist,love.timer.getFPS())
	table.insert(debuglist,"Actors: "..#Actors)
	table.insert(debuglist,"Walls: "..#Walls)
	table.insert(debuglist,"Player X: "..Player.x)
	table.insert(debuglist,"Player Y: "..Player.y)
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
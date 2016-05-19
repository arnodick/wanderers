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
	table.insert(debuglist,"Player Vec X: "..Player.vec.x)
	table.insert(debuglist,"Player Vec Y: "..Player.vec.y)
	table.insert(debuglist,"Player Dir: "..math.atan2(Player.vec.y,Player.vec.x))
	table.insert(debuglist,"Player Vel: "..Player.v)
	table.insert(debuglist,"Save: "..love.filesystem.getSaveDirectory())
	table.insert(debuglist,"Game Canv W: "..Canvas.game:getWidth())
	table.insert(debuglist,"Game Canv H: "..Canvas.game:getHeight())
	table.insert(debuglist,"Scrn Canv W: "..Canvas.debug:getWidth())
	table.insert(debuglist,"Scrn Canv H: "..Canvas.debug:getHeight())
	table.insert(debuglist,"Scrn X Offset: "..Screen.xoff)
	table.insert(debuglist,"Scrn Scale: "..Screen.scale)
	local mx,my=love.mouse.getPosition()
	table.insert(debuglist,"Mouse X: "..mx)
	table.insert(debuglist,"Mouse Y: "..my)
	table.insert(debuglist,"Cursor X: "..Cursor.x)
	table.insert(debuglist,"Cursor Y: "..Cursor.y)
	mx,my = mapcoords(Cursor.x,Cursor.y)
	table.insert(debuglist,"Map X: "..mx)
	table.insert(debuglist,"Map Y: "..my)
--Canvas:getWidth( )
	return debuglist
end

function draw(debuglist)
	love.graphics.setColor(0, 200, 0, 255)
	love.graphics.print("DEBUG",130,0)
	for i,v in ipairs(debuglist) do
		love.graphics.print(v,10,10+FontDebug:getHeight()*i)
	end
	love.graphics.setColor(255, 255, 255, 255) --sets draw colour back to normal
end

return
{
	update = update,
	draw = draw,
}
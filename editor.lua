function draw(debuglist)
	for i,v in ipairs(debuglist) do
		love.graphics.print(v,10,10+10*i)
	end
end

function update()
	local debuglist={}
	table.insert(debuglist,love.timer.getTime())
	table.insert(debuglist,love.timer.getFPS())
	return debuglist
end

return
{
	draw = draw,
	update = update,
}
function make(x,y)
	local cursor = {}
	cursor.x=x
	cursor.y=y
	cursor.selection = 1
	return cursor
end

function mapcoords(x,y)
	--return math.floor(x/Screen.scale), math.floor(y/Screen.scale)
	return math.floor(x/TileW), math.floor(y/TileH)
end

function update(cursor)
	local mx,my=love.mouse.getPosition()
	cursor.x, cursor.y = mx/(Screen.width/GameWidth), my/Screen.scale
	--cursor.x, cursor.y = mapcoords(mx/(Screen.width/GameWidth), my/Screen.scale)
end

function draw(cursor)
	--need to fix this now that fullscreen
	local mapx,mapy = mapcoords(cursor.x,cursor.y)
	love.graphics.setColor(255, 0, 0, 255)
	love.graphics.rectangle("line",mapx*TileW,mapy*TileH,TileW+1,TileH+1)
	love.graphics.draw(Spritesheet,Quads[cursor.selection-1],mapx*TileW,mapy*TileH)
	love.graphics.print(cursor.selection,mapx*TileW+TileW+1,mapy*TileH+TileH+1)
	love.graphics.setColor(255, 255, 255, 255)
end

return
{
	make = make,
	mapcoords = mapcoords,
	update = update,
	draw = draw,
}
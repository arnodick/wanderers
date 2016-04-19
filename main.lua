function love.load()
	math.randomseed(os.time())
	State=1

	spritesheet_i("gfx/sprites.png", 8, 8)
	Scale=4

	love.graphics.setDefaultFilter("nearest","nearest",0)
	love.graphics.setLineStyle("rough")
	love.mouse.setVisible(false)

	Font = love.graphics.newFont("fonts/Kongtext Regular.ttf",10)
	love.graphics.setFont(Font)
	Font:setFilter("nearest","nearest",0)

	canvas = love.graphics.newCanvas(320, 240)
	--Map = loadmap("maps/blankmap.txt")
	Map = loadmap("maps/saved.txt")

	Cursor = {}
	Cursor.selection = 2
end

function spritesheet_i(spr, tw, th)
	Spritesheet=love.graphics.newImage(spr)
	local spritesheetW, spritesheetH = Spritesheet:getWidth(), Spritesheet:getHeight()
	TileW, TileH = tw,th
	local spritesheetTilesW,spritesheetTilesH = spritesheetW/TileW, spritesheetH/TileH
	Quads = {}
	for b=0, spritesheetTilesW do
		for a=0, spritesheetTilesH do
			Quads[a+b*spritesheetTilesH] = love.graphics.newQuad(a*TileW,b*TileH,TileW,TileH,spritesheetW,spritesheetH)
		end
	end
end

function loadmap(m)
	local map = {}
	for line in love.filesystem.lines(m) do
		table.insert(map, parse(line))
	end
	return map
end

function savemap(m,n)
	local str=""
	for b=1,#m do
		for a=1,#m[b] do
			local val=m[b][a]
			local pad=""
			if val<16 then pad='0' end
			local hex=string.format("%x",val)
			str=str..pad..hex
		end
		str=str.."\n"
	end
	love.filesystem.write(n, str)
end

function parse(l)
	local ar={}
	for a=1, #l, 2 do
		table.insert( ar, tonumber(string.sub(l, a, a+1),16) )
	end
	return ar
end

function clamp(n, mi, ma)
	if n<mi then n=mi
	elseif n>ma then n=ma end
	return n
end

function getTileCoordinates(x,y)
	local mousex,mousey = math.floor(x/Scale), math.floor(y/Scale)
	local mapx,mapy = math.floor(mousex/TileW), math.floor(mousey/TileH)
	return mapx,mapy
end

function love.update(dt)
	if State==1 then
		if love.keyboard.isDown('z') then
			State=2
		end
	elseif State==2 then
		--controls etc. here
		function love.wheelmoved(x, y)
			Cursor.selection = clamp(y + Cursor.selection,1,60)
		end
		function love.mousepressed(x, y, button)
			if button==1 then
				local mapx,mapy = getTileCoordinates(x,y)
				Map[mapy+1][mapx+1] = Cursor.selection
			end
		end
		if love.keyboard.isDown('s') then
			--save
			savemap(Map,"saved.txt")
		end
	end
	if love.keyboard.isDown('escape') then
		love.event.quit()
	end
end

function love.draw(dt)
	love.graphics.setCanvas(canvas)
		love.graphics.clear()
		if State==1 then
			love.graphics.print("ROAD DRIVIN",40,100)		
		elseif State==2 then
			for b=1,#Map do
				for a=1,#Map[b] do
					love.graphics.draw(Spritesheet,Quads[Map[b][a]-1],(a-1)*TileW,(b-1)*TileH)
				end
			end
			local mapx,mapy = getTileCoordinates(love.mouse.getPosition())
			love.graphics.setColor(255, 0, 0, 255)
			love.graphics.rectangle("line",mapx*TileW,mapy*TileH,TileW+1,TileH+1)
			love.graphics.draw(Spritesheet,Quads[Cursor.selection-1],mapx*TileW,mapy*TileH)
			love.graphics.print(Cursor.selection,mapx*TileW+TileW+1,mapy*TileH+TileH+1)
			love.graphics.setColor(255, 255, 255, 255)
		end
	love.graphics.setCanvas()
	love.graphics.draw(canvas,0,0,0,Scale,Scale,0,0)
end
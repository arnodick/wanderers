movement = require "movement"
controls = require "controls"
textfile = require "textfile"

function love.load()
	math.randomseed(os.time())
	State=1

	spritesheet_load("gfx/sprites.png", 8, 8)

	Scale=4
	love.graphics.setDefaultFilter("nearest","nearest",0) --clean SPRITE scaling
	love.graphics.setLineStyle("rough") --clean SHAPE scaling

	love.mouse.setVisible(false)
	Font = love.graphics.newFont("fonts/Kongtext Regular.ttf",10)
	love.graphics.setFont(Font)
	Font:setFilter("nearest","nearest",0) --clean TEXT scaling

	canvas = love.graphics.newCanvas(320, 240)
	--Map = textfile.load("maps/blankmap.txt")
	Map = textfile.load("maps/saved3.txt")

	Cursor = {}
	Cursor.selection = 1

	Actors={}
	makeactor(1,50,20,20,0,0.5)
end

function spritesheet_load(spr, tw, th)
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

function clamp(n, mi, ma)
	if n<mi then n=mi
	elseif n>ma then n=ma end
	return n
end

function maptotilecoords(x,y)
	local mousex,mousey = controls.mousetomapcoords(x,y)
	local mapx,mapy = math.floor(mousex/TileW), math.floor(mousey/TileH)
	return mapx,mapy
end

function makeactor(t,s,x,y,d,v)
	local a={}
	a.t=t
	a.s=s
	a.x=x
	a.y=y
	a.d=d
	a.v=v
	a.tar={0,0}--TODO: change this to tar.x
	a.vec={0,0}--TODO: change this to vec.x
	a.moving=false
	table.insert(Actors,a)
	return a
end

function controlactor(a)
	love.keyboard.setKeyRepeat(true)
	function love.mousepressed(x, y, button)
		if button==1 then
			a.moving=true
			a.tar[1],a.tar[2] = maptotilecoords(x,y)
			a.tar[1]=a.tar[1]*TileW
			a.tar[2]=a.tar[2]*TileH
		end
	end
	
	if a.moving then
		local d = movement.distance(a.x,a.y,a.tar[1],a.tar[2])
		if d<1 then
			a.moving=false
		else
			local vec1, vec2 = movement.vector(a.x,a.y,a.tar[1],a.tar[2])
			a.vec[1] = (vec1/d)
			a.vec[2] = (vec2/d)
			a.x=a.x + a.vec[1]*a.v
			a.y=a.y + a.vec[2]*a.v
		end
	end
end

function drawactor(a)
	love.graphics.draw(Spritesheet,Quads[a.s],math.floor(a.x),math.floor(a.y))
end

function drawmap(m)
	for b=1,#m do
		for a=1,#m[b] do
			love.graphics.draw(Spritesheet,Quads[m[b][a]-1],(a-1)*TileW,(b-1)*TileH)
		end
	end
end

function drawcursor()
	local mapx,mapy = maptotilecoords(love.mouse.getPosition())
	love.graphics.setColor(255, 0, 0, 255)
	love.graphics.rectangle("line",mapx*TileW,mapy*TileH,TileW+1,TileH+1)
	love.graphics.draw(Spritesheet,Quads[Cursor.selection-1],mapx*TileW,mapy*TileH)
	love.graphics.print(Cursor.selection,mapx*TileW+TileW+1,mapy*TileH+TileH+1)
	love.graphics.setColor(255, 255, 255, 255)
end

function love.update(dt)
	if State==1 then
		if love.keyboard.isDown('z') then
			State=2
		end
	elseif State==2 then
		for i,v in ipairs(Actors) do controlactor(v) end
		love.keyboard.setKeyRepeat(false)
		function love.keypressed(key,scancode,isrepeat)
			if key=='tab' then
				State=3
			end
		end
		if love.keyboard.isDown('escape') then
			love.event.quit()
		end
	elseif State==3 then
		--controls etc. here
		function love.wheelmoved(x, y)
			Cursor.selection = clamp(y + Cursor.selection,1,60)
		end
		function love.mousepressed(x, y, button)
			if button==1 then
				local mapx,mapy = maptotilecoords(x,y)
				Map[mapy+1][mapx+1] = Cursor.selection
			end
		end
		love.keyboard.setKeyRepeat(false)
		if love.keyboard.isDown('s') then
			--save
			textfile.save(Map,"saved3.txt")
		end
		function love.keypressed(key,scancode,isrepeat )
			if key=='tab' then
				State=2
			end
		end
		if love.keyboard.isDown('escape') then
			love.event.quit()
		end
	end
end

function love.draw(dt)
	love.graphics.setCanvas(canvas)
		love.graphics.clear()
		if State==1 then
			love.graphics.print("THE WANDERERS",40,100)		
		elseif State==2 then
			drawmap(Map)
			for i,v in ipairs(Actors) do drawactor(v) end
			drawcursor()
		elseif State==3 then
			drawmap(Map)
			for i,v in ipairs(Actors) do drawactor(v) end
			drawcursor()
		end
	love.graphics.setCanvas()
	love.graphics.draw(canvas,0,0,0,Scale,Scale,0,0)
end
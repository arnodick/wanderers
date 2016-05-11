movement = require "movement"
controls = require "controls"
textfile = require "textfile"
editor = require "editor"
maps = require "maps"
spritesheets = require "spritesheets"

function love.load()
	math.randomseed(os.time())
	DebugList={}
	Spritesheet={}
	Quads={}
	Actors={}
	Walls={}
	
	State=1
	Scale=4
	TileW=8
	TileH=8

	love.graphics.setDefaultFilter("nearest","nearest",0) --clean SPRITE scaling
	love.graphics.setLineStyle("rough") --clean SHAPE scaling
	love.mouse.setVisible(false)

	Spritesheet, Quads = spritesheets.load("gfx/sprites.png", TileW, TileH)

	Font = love.graphics.newFont("fonts/Kongtext Regular.ttf",10)
	Font:setFilter("nearest","nearest",0) --clean TEXT scaling
	love.graphics.setFont(Font)

	Canvas = love.graphics.newCanvas(320, 240)

	Map = maps.load("maps/saved3.txt")

	Cursor = {}
	Cursor.selection = 1

	makeactor(1,50,20,20,0,0.5) -- spawns player
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

function makewall(x,y,w,h)
	local wall={}
	wall.x=x
	wall.y=y
	wall.w=w
	wall.h=h
	table.insert(Walls,wall)
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
	a.colx = 0
	a.coly = 0
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
			a.tar[1]=a.tar[1]*TileW + TileW/2
			a.tar[2]=a.tar[2]*TileH + TileH/2
		end
	end
	
	if a.moving then
		local d = movement.distance(a.x,a.y,a.tar[1],a.tar[2])
		local move = false
		if d<1 then
			a.moving=false
		else
			local vec1, vec2 = movement.vector(a.x,a.y,a.tar[1],a.tar[2])
			a.vec[1] = (vec1/d)
			a.vec[2] = (vec2/d)
			for i,v in ipairs(Walls) do
				if a.x + a.vec[1]*a.v > v.x
				and a.x + a.vec[1]*a.v < v.x + v.w
				and a.y + a.vec[2]*a.v > v.y
				and a.y + a.vec[2]*a.v < v.y + v.h then
					--hit wall
				else
					move = true
				end
			end
			--end
		end
		if move then
			a.x = a.x + a.vec[1]*a.v
			a.y = a.y + a.vec[2]*a.v
		end
	end
end

function drawactor(a)
	love.graphics.draw(Spritesheet,Quads[a.s],math.floor(a.x) - TileW/2,math.floor(a.y) - TileH/2)
	love.graphics.setColor(0, 255, 0, 255)
	love.graphics.points( a.x, a.y )
	love.graphics.setColor(255, 255, 255, 255)
--	love.graphics.rectangle( "line", a.colx * TileW + TileW/2, a.coly * TileH + TileH/2, TileW, TileH)
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
		--debug/map edit
		function love.wheelmoved(x, y)
			Cursor.selection = clamp(y + Cursor.selection,1,60)
		end
		function love.mousepressed(x, y, button)
			local mapx,mapy = maptotilecoords(x,y)
			if button==1 then
				Map[mapy+1][mapx+1] = Cursor.selection
			elseif button==2 then
				Map[mapy+1][mapx+1] = bit.bor( Map[mapy+1][mapx+1], 0x00010000 )
				makewall((mapx)*TileW, (mapy)*TileH, TileW, TileH)
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
		DebugList=editor.update()
	end
end

function love.draw(dt)
	love.graphics.setCanvas(Canvas)
		love.graphics.clear()
		if State==1 then
			love.graphics.print("THE WANDERERS",40,100)		
		elseif State==2 then
			maps.draw(Map)
			for i,v in ipairs(Actors) do drawactor(v) end
			drawcursor()
		elseif State==3 then
			maps.draw(Map)
			love.graphics.setColor(255, 0, 0, 255)
			for i,v in ipairs(Actors) do drawactor(v) love.graphics.rectangle("line", v.x-TileW/2, v.y-TileH/2, TileW, TileH) end
			for i,v in ipairs(Walls) do love.graphics.rectangle("line", v.x, v.y, v.w, v.h) end
			--love.graphics.setColor(255, 255, 255, 255)
			drawcursor()
			editor.draw(DebugList)
			
		end
	love.graphics.setCanvas()
	love.graphics.draw(Canvas,0,0,0,Scale,Scale,0,0)
end
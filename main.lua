movement = require "movement"
controls = require "controls"
textfile = require "textfile"
debugger = require "debugger"
maps = require "maps"
spritesheets = require "spritesheets"

function love.load()
	math.randomseed(os.time())
	DebugMode=false
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

	Player = makeactor(1,50,20,20,0,0.5) -- spawns player
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
	a.tar={x,y}--TODO: change this to tar.x
	a.vec={0,0}--TODO: change this to vec.x
	a.colx = 0
	a.coly = 0
	a.moving=false
	a.id = #Actors + 1
	table.insert(Actors,a)
	return a
end

function collideactor(a, targets)
	for i,v in ipairs(targets) do
		if  a.x + a.vec[1]*a.v > v.x - 1 -- the -1 is just so hit pixel is visible always, maybe won't need it later
		and a.x + a.vec[1]*a.v < v.x + v.w
		and a.y + a.vec[2]*a.v > v.y - 1
		and a.y + a.vec[2]*a.v < v.y + v.h then
			return true
		end
	end
	return false
end

function controlactor(a)
	if a.moving then
		local d = movement.distance(a.x,a.y,a.tar[1],a.tar[2])
		local move = false
		if d<1 then
			a.moving=false
		else
			local vec1, vec2 = movement.vector(a.x,a.y,a.tar[1],a.tar[2])
			a.vec[1] = (vec1/d)
			a.vec[2] = (vec2/d)
			if not collideactor(a, Walls) then
				a.x = a.x + a.vec[1] * a.v
				a.y = a.y + a.vec[2] * a.v
			end
		end
	end
end

function drawactor(a)
	love.graphics.draw(Spritesheet,Quads[a.s],math.floor(a.x) - TileW/2,math.floor(a.y) - TileH/2)
	if DebugMode then
		love.graphics.setColor(0, 255, 0, 255)
		love.graphics.line( a.x, a.y, a.tar[1], a.tar[2] )
		love.graphics.setColor(255, 255, 255, 255)
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

function love.keypressed(key,scancode,isrepeat)
	love.keyboard.setKeyRepeat(false)
	if State == 1 then
		if key == 'z' then
			State = 2
		end
	else
		if key == 'tab' then
			if State ~= -1 then 
				State = -1
			else
				State = 2
			end
		elseif key == '`' then
			DebugMode = not DebugMode
		elseif key == 's' then
			if State == -1 then
				textfile.save(Map,"saved3.txt")
			end
		end
	end
	if key == 'escape' then
		love.event.quit()
	end
end

function love.wheelmoved(x, y)
	if State == -1 then
		Cursor.selection = clamp(y + Cursor.selection,1,60)
	end
end

function love.mousepressed(x, y, button)
	if State == 1 then
		State = 2
	elseif State == 2 then
		if button==1 then
			Player.moving=true
			Player.tar[1],Player.tar[2] = maptotilecoords(x,y)
			Player.tar[1]=Player.tar[1] * TileW + TileW/2
			Player.tar[2]=Player.tar[2] * TileH + TileH/2
		end
	elseif State == -1 then
		local mapx,mapy = maptotilecoords(x,y)
		if button==1 then
			Map[mapy+1][mapx+1] = Cursor.selection
		elseif button==2 then
			Map[mapy+1][mapx+1] = bit.bor( Map[mapy+1][mapx+1], 0x00010000 )
			makewall((mapx)*TileW, (mapy)*TileH, TileW, TileH)
		end
	end
end

function love.update(dt)
	if State == 1 then --title screen
		--title screen logic HEEEEEERE
	elseif State == 2 then --gameplay
		for i,v in ipairs(Actors) do controlactor(v) end
	elseif State == -1 then --editor
		--editor logic HEEEERE(?) maybe menu stuff or whatever
	end
	DebugList = debugger.update()
end

function love.draw(dt)
	love.graphics.setCanvas(Canvas) --sets drawing to the 320x240 canvas
	love.graphics.clear() --cleans that messy ol canvas all up, makes it all fresh and new and good you know
	if State == 1 then
		love.graphics.print("THE WANDERERS",40,100)
	elseif State == 2 then
		maps.draw(Map)
		for i,v in ipairs(Actors) do drawactor(v) end
		drawcursor()
	elseif State == -1 then
		maps.draw(Map)
		love.graphics.setColor(255, 0, 0, 255)
		for i,v in ipairs(Actors) do drawactor(v) end
		for i,v in ipairs(Walls) do love.graphics.rectangle("line", v.x, v.y, v.w, v.h) end
		drawcursor()
		love.graphics.print("EDITOR",130,10)
	end
	if DebugMode then
		love.graphics.setColor(255, 0, 0, 255)
		for i,v in ipairs(Actors) do love.graphics.rectangle("line", v.x-TileW/2, v.y-TileH/2, TileW, TileH) end
		for i,v in ipairs(Walls) do love.graphics.rectangle("line", v.x, v.y, v.w, v.h) end
		debugger.draw(DebugList)
	end
	love.graphics.setColor(255, 255, 255, 255) --sets draw colour back to normal
	love.graphics.setCanvas() --sets drawing back to screen
	love.graphics.draw(Canvas,0,0,0,Scale,Scale,0,0) --just like draws everything to the screen or whatever
end
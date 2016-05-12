debugger 		= require "debugger"
spritesheets 	= require "spritesheets"
textfile 		= require "textfile"
maps 			= require "maps"
controls 		= require "controls"
movement 		= require "movement"
actor			= require "actor"

function love.load()
	--enumerators (DUHHHHHHHHHHHHH DURRRR FLUHHH BLUh)
	Enums = {}
	--actors
	Enums.player = 0
	Enums.wall = 1
	--gamestates
	Enums.title = 1
	Enums.gameplay = 2
	Enums.editor = -1

	--game initialization stuff (just boring stuff you need to have Video Game work)
	math.randomseed(os.time())
	DebugMode=false
	DebugList={}
	Actors={}
	Walls={}
	
	--global variables
	State=1
	Scale=4
	TileW=8
	TileH=8

	Slowdown={}
	Slowdown.rate=5
	Slowdown.timer=0

	Turn={}
	Turn.timer=0
	Turn.length=180

	--graphics settings and asset inits
	Spritesheet, Quads = spritesheets.load("gfx/sprites.png", TileW, TileH)
	love.graphics.setDefaultFilter("nearest","nearest",0) --clean SPRITE scaling
	love.graphics.setLineStyle("rough") --clean SHAPE scaling
	love.mouse.setVisible(true)

	Font = love.graphics.newFont("fonts/Kongtext Regular.ttf",10)
	Font:setFilter("nearest","nearest",0) --clean TEXT scaling
	love.graphics.setFont(Font)

	Canvas = love.graphics.newCanvas(320, 240)

	--game asset inits (map, entities, sounds, etc)
	Map = maps.load("maps/saved3.txt")
	Cursor = {}
	Cursor.selection = 1
	Sound = love.audio.newSource("sounds/amb.wav")
	Sound:setLooping(true)

	Player = actor.make(0,50,20,20,0,0.5) --spawns player
	rawset(_G, "Butt", 14)
	Files = love.filesystem.getDirectoryItems("")
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
		if key == 'space' then
			if Turn.timer == 0 then
				Turn.timer = Turn.length
			end
		elseif key == 'tab' then
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
	if State == 2 then
		Slowdown.rate = clamp(y/10 + Slowdown.rate,1,15)
	elseif State == -1 then
		Cursor.selection = clamp(y + Cursor.selection,1,60)
	end
end

function love.mousepressed(x, y, button)
	if State == 1 then
		State = 2
		Sound:play()
	elseif State == 2 then
		if button==1 then
			--if Turn.timer == 0 then
			Player.v = Player.spd
			Player.tar[1],Player.tar[2] = maptotilecoords(x,y)
			Player.tar[1]=Player.tar[1] * TileW + TileW/2
			Player.tar[2]=Player.tar[2] * TileH + TileH/2
			--end
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
		--if math.floor(love.timer.getTime()) % 2 == 0 then --LURCHINESS!
		if Slowdown.timer >= Slowdown.rate then --slows down time!
			for i,v in ipairs(Actors) do actor.control(v) end
			Slowdown.timer = 0
			Turn.timer = Turn.timer - 1
		end
		local slowdowndir = 0
		if Player.v > 0 then
			slowdowndir = -0.05
		else
			slowdowndir = 0.05
		end
		Slowdown.rate = clamp(Slowdown.rate + slowdowndir, 1, 5)
		Sound:setPitch(2/Slowdown.rate)
	elseif State == -1 then --editor
		--editor logic HEEEERE(?) maybe menu stuff or whatever
	end
	Slowdown.timer = Slowdown.timer + 1
	DebugList = debugger.update()
end

function love.draw(dt)
	love.graphics.setCanvas(Canvas) --sets drawing to the 320x240 canvas
	love.graphics.clear() --cleans that messy ol canvas all up, makes it all fresh and new and good you know
	if State == 1 then
		love.graphics.print("THE WANDERERS",40,100)
	elseif State == 2 then
		maps.draw(Map)
		for i,v in ipairs(Actors) do actor.draw(v) end
		drawcursor()
	elseif State == -1 then
		maps.draw(Map)
		love.graphics.setColor(255, 0, 0, 255)
		for i,v in ipairs(Actors) do actor.draw(v) end
		for i,v in ipairs(Walls) do love.graphics.rectangle("line", v.x, v.y, v.w, v.h) end
		drawcursor()
		love.graphics.print("EDITOR",130,10)
	end
	if DebugMode then
		love.graphics.setColor(255, 0, 0, 255)
		for i,v in ipairs(Actors) do love.graphics.rectangle("line", v.x-TileW/2, v.y-TileH/2, TileW, TileH) end
		for i,v in ipairs(Walls) do love.graphics.rectangle("line", v.x, v.y, v.w, v.h) end
		--debugger.draw(DebugList)
		for i,v in ipairs(Files) do
			love.graphics.print(v,160,10+10*i)
		end
	end
	love.graphics.setColor(255, 255, 255, 255) --sets draw colour back to normal
	love.graphics.setCanvas() --sets drawing back to screen
	love.graphics.draw(Canvas,0,0,0,Scale,Scale,0,0) --just like draws everything to the screen or whatever
end
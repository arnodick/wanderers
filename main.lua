--loads all the library.lua files you've made
--it is dynamic ie if you put a library.lua file in the working directory it will load it into the game automatically
local files = love.filesystem.getDirectoryItems("") --get all the files+directories in working dir
for i = #files,1,-1 do
	if love.filesystem.isFile(files[i]) then --if it isn't a directory
		local filedata = love.filesystem.newFileData("code", files[i])
		local filename = filedata:getFilename() --get the file's name
		if filedata:getExtension(filedata) == "lua" --if it's a lua file and isn't a reserved file
		and filename ~= "conf.lua"
		and filename ~= "main.lua" then --it's a library, so include it
			rawset( _G, string.gsub(filename, ".lua", ""), require(string.gsub(filename, ".lua", "")) ) --TODO do we need rawset here?
		end
	end
end

function love.load()
 	Shader = love.graphics.newShader
	[[
	extern number screenWidth;
	vec4 effect (vec4 color,Image texture,vec2 texture_coords,vec2 screen_coords)
	{
		//if(screen_coords.x > 640)
		//	{return vec4(1,0,0,1);}
		//else
		//	{return vec4(0,0,1,1);}
		vec4 pixel = Texel(texture, texture_coords); //current pixel colour
		number average = (pixel.r + pixel.b + pixel.g) / 3;
		number factor = screen_coords.x/screenWidth;
		//pixel.r = pixel.r + (average-pixel.r) * factor;
		//pixel.g = pixel.g + (average-pixel.g) * factor;
		//pixel.r = pixel.r -0.2;
		//pixel.g = 1;
		//pixel.b = 1;
		//pixel.t = 1;
		return pixel;
    }
 	]]
	--Shader:send("screenWidth", 1280)

	--enumerators (DUHHHHHHHHHHHHH DURRRR FLUHHH BLUh)
	Enums = {}
	--actors
	Enums.player = 0
	Enums.wall = 1
	--gamestates
	Enums.title = 1
	Enums.gameplay = 2
	Enums.editor = -1
	--movement types
	Enums.walk = 1
	Enums.bullet = 2

	--game initialization stuff (just boring stuff you need to maek Video Game)
	math.randomseed(os.time())
	DebugMode=false
	DebugList={}
	Actors={}
	Walls={}
	
	--global variables
	State=1
	TileW=8
	TileH=8
	GameWidth=320
	GameHeight=240
	Screen={}
	Screen.width,Screen.height=love.graphics.getDimensions()
	Screen.scale=Screen.height/GameHeight
	Screen.xoff=(Screen.width-GameWidth*Screen.scale)/2

	Slowdown={}
	Slowdown.timer=0
	Slowdown.max=6
	Slowdown.amount=Slowdown.max

	Timer=0

	--graphics settings and asset inits
	--love.window.setFullscreen(true, "desktop")
	love.graphics.setDefaultFilter("nearest","nearest",0) --clean SPRITE scaling
	love.graphics.setLineStyle("rough") --clean SHAPE scaling
	love.graphics.setBlendMode("replace")
	love.mouse.setVisible(false)
	Spritesheet, Quads = spritesheets.load("gfx/sprites.png", TileW, TileH)

	Font = love.graphics.newFont("fonts/Kongtext Regular.ttf",10)
	FontDebug = love.graphics.newFont("fonts/lucon.ttf",30)
	Font:setFilter("nearest","nearest",0) --clean TEXT scaling
	love.graphics.setFont(Font)

	
	Canvas = {}
	Canvas.game = love.graphics.newCanvas(GameWidth,GameHeight) --sets width and height of fictional retro video game (320x240)
	Canvas.debug = love.graphics.newCanvas(Screen.width,Screen.height) --sets width and height of debug overlay (size of window)

	--game asset inits (map, entities, sounds, etc)
	Map = maps.load("maps/saved3.txt")
	Cursor = cursor.make(love.mouse.getPosition())
	Sound = love.audio.newSource("sounds/amb.wav")
	Sound:setLooping(true)
	Gun = love.audio.newSource("sounds/gun.wav")

	Player = actor.make(0,50,20,20,0.5,1) --spawns player
end

function makewall(x,y,w,h)
	local wall={}
	wall.x=x
	wall.y=y
	wall.w=w
	wall.h=h
	table.insert(Walls,wall)
end

function love.keypressed(key,scancode,isrepeat)
	love.keyboard.setKeyRepeat(false)
	if State == Enums.title then
		if key == 'z' then
			State = Enums.gameplay
		end
	else
		if key == 'tab' then
			if State ~= Enums.editor then 
				State = Enums.editor
			else
				State = Enums.gameplay
			end
		elseif key == '`' then
			DebugMode = not DebugMode
			--local fontset = (FontDebug and DebugMode)
			if DebugMode then
				love.graphics.setFont(FontDebug)
			else
				love.graphics.setFont(Font)
			end
		elseif key == 's' then
			if State == Enums.editor then
				textfile.save(Map,"saved3.txt")
			end
		end
	end
	if key == 'escape' then
		love.event.quit()
	end
end

function love.wheelmoved(x, y)
	if State == Enums.editor then
		Cursor.selection = maths.clamp(y + Cursor.selection,1,60)
	end
end

function love.mousepressed(x, y, button)
	x,y = Cursor.x, Cursor.y
	if State == Enums.title then
		State = Enums.gameplay
		Sound:play()
	elseif State == Enums.gameplay then
		if button == 1 then
			Player.v = Player.spd
			Player.tar[1],Player.tar[2] = cursor.mapcoords(x,y)
			Player.tar[1] = Player.tar[1] * TileW + TileW/2
			Player.tar[2] = Player.tar[2] * TileH + TileH/2
		elseif button == 2 then
			love.audio.rewind(Gun)
			love.audio.play(Gun)
			local bullet = actor.make(2,65,Player.x,Player.y,5,2)
			bullet.tar[1], bullet.tar[2] = Cursor.x, Cursor.y
			local dist = movement.distance(bullet.x,bullet.y,bullet.tar[1],bullet.tar[2])
			local vec1, vec2 = movement.vector(bullet.x,bullet.y,bullet.tar[1],bullet.tar[2])
			bullet.vec[1] = (vec1/dist)
			bullet.vec[2] = (vec2/dist)
			bullet.v = bullet.spd
		end
	elseif State == Enums.editor then
		local mapx,mapy = cursor.mapcoords(x,y)
		if button == 1 then
			Map[mapy+1][mapx+1] = Cursor.selection
		elseif button == 2 then
			Map[mapy+1][mapx+1] = bit.bor( Map[mapy+1][mapx+1], 0x00010000 )
			makewall((mapx)*TileW, (mapy)*TileH, TileW, TileH)
		end
	end
end

function love.update(dt)
	cursor.update(Cursor)
	if State == Enums.title then
		--title screen logic HEEEEEERE
	elseif State == Enums.gameplay then
		--if math.floor(love.timer.getTime()) % 2 == 0 then --LURCHINESS!
		if Slowdown.timer >= Slowdown.amount then --slows down time!
			for i,v in ipairs(Actors) do actor.control(v,i) end
			Slowdown.timer = 0
			Timer = Timer + 1
		end
		local slowdowndir = 0
		
		if Player.v > 0 then
			if movement.distance(Player.x,Player.y,Player.tar[1],Player.tar[2]) < 10 then
				slowdowndir = 0.1
			else
				slowdowndir = -0.1
			end
		--else
		--	slowdowndir = 0.1
		end
		Slowdown.amount = maths.clamp(Slowdown.amount + slowdowndir, 1, Slowdown.max)
		Sound:setPitch(1/Slowdown.amount)
		Gun:setPitch(1/Slowdown.amount)
	elseif State == Enums.editor then
		--editor logic HEEEERE(?) maybe menu stuff or whatever
	end
	Slowdown.timer = Slowdown.timer + 1
	DebugList = debugger.update()
end

function love.draw(dt)
	love.graphics.setShader(Shader)
	love.graphics.clear() --cleans that messy ol canvas all up, makes it all fresh and new and good you know
	love.graphics.setBlendMode("replace")
	love.graphics.setCanvas(Canvas.game) --sets drawing to the 320x240 canvas
	love.graphics.setBackgroundColor(0,0,0,0)
	if State == 1 then
		love.graphics.print("THE WANDERERS",40,100)
	elseif State == 2 then
		maps.draw(Map)
		for i,v in ipairs(Actors) do actor.draw(v) end
		cursor.draw(Cursor)
	elseif State == -1 then
		maps.draw(Map)
		love.graphics.setColor(255, 0, 0, 255)
		for i,v in ipairs(Actors) do actor.draw(v) end
		for i,v in ipairs(Walls) do love.graphics.rectangle("line", v.x, v.y, v.w, v.h) end
		cursor.draw(Cursor)
		love.graphics.print("EDITOR",130,10)
	end
	if DebugMode then
		love.graphics.setColor(0, 0, 255, 255)
		for i,v in ipairs(Actors) do love.graphics.rectangle("line", v.x-TileW/2, v.y-TileH/2, TileW, TileH) end
		--love.graphics.setColor(255, 0, 0, 255)
		--for i,v in ipairs(Walls) do love.graphics.rectangle("line", v.x, v.y, v.w, v.h) end
	end
	love.graphics.setColor(255, 255, 255, 255) --sets draw colour back to normal
	love.graphics.setCanvas() --sets drawing back to screen
	love.graphics.draw(Canvas.game,0+Screen.xoff,0,0,Screen.scale,Screen.scale,0,0) --just like draws everything to the screen or whatever
	love.graphics.setShader()
	if DebugMode then
		love.graphics.setCanvas(Canvas.debug) --sets drawing to the 1280 x 960 debug canvas
		love.graphics.clear() --cleans that messy ol canvas all up, makes it all fresh and new and good you know
		--love.graphics.setBackgroundColor(0,0,0,0)
		debugger.draw(DebugList)
		love.graphics.setCanvas() --sets drawing back to screen
		love.graphics.setBlendMode("add")
		love.graphics.draw(Canvas.debug,0+Screen.xoff,0,0,1,1,0,0) --just like draws everything to the screen or whatever
	end
end
ATL_Loader = require("AdvTiledLoader.Loader")
ATL_Loader.path = "assets/"

SHIPRADIUS = 7
FORCE = 15000
UPFORCE = 3*FORCE
DOWNFORCE = FORCE
METERS = 10
GRAVITY = 35
BOUNCY = 0.0
FRICTION = 0.0
DONETIME = 3
SUCKYENGINE = 0.5
MAXBANGLIFE = 0.5

MINX = -SHIPRADIUS
MINY = -SHIPRADIUS
MAXX = 800+SHIPRADIUS
MAXY = 600+SHIPRADIUS

MAXHEALTH = 1
RADIATION = 0.35
	
function Density(id)
	if id == 0 then
		-- wood
		return 200
	elseif id == 1 then
		-- iron
		return 400
	else
		-- glass
		return 100
	end
end
	
function randomsign()
	if math.random() > 0.5 then
		return 1
	else
		return -1
	end
end
	
function SetupMaxHealth(data)
	local hull = data[3]
	local weakness = 1
	if data[5] == 1 then
		weakness = 0.5
	end
	if hull == 0 then
		-- wood
		return 2*weakness
	elseif hull == 1 then
		-- iron
		return 4*weakness
	else
		-- glass
		return 1*weakness
	end
end

-- Aliases
local Draw = love.graphics.draw
local PauseAllAudio = love.audio.pause
local Print = love.graphics.print

function Play(x)
	x:rewind()
	love.audio.play(x)
end
	
function Random(a)
	return a[math.random(#a)]
end

function remove_if(list, func)
	local toremove = {}
	for i,item in ipairs(list) do
		if func(item) then
				table.insert(toremove, i)
		end
	end
	local i = 0
		while #toremove ~= 0 do
		i = table.remove(toremove)
		table.remove(list,i)
	end
end

function Img(p)
	local r
	r = love.graphics.newImage(p)
	return r
end

function Music(p)
	local s
	s = love.audio.newSource(p, "stream")
	s:setLooping(true)
	s:setVolume(0.5)
	return s
end

function Sfx(p)
	local s
	s = love.audio.newSource(p, "static")
	return s
end

function BeginPrint()
	love.graphics.setColor(255, 255, 255)
end

function EndPrint()
	love.graphics.setColor(255, 255, 255)
end

function SetDefaultColor()
	love.graphics.setColor(255, 255, 255)
end

function RGB(c)
	local r,g,b = 255,255,255
	if c == 0 then
		r,g,b = 255,0,0
	end
	if c == 1 then
		r,g,b = 0,255,0
	end
	if c == 2 then
		r,g,b = 0,0,255
	end
	return r,g,b
end

function SetColor(v)
	if v == 0 then
		love.graphics.setColor(255, 0, 0)
	elseif v == 1 then
		love.graphics.setColor(0, 255, 0)
	elseif v == 2 then
		love.graphics.setColor(0, 0, 255)
	else
		love.graphics.setColor(255, 255, 255)
	end
end

function mod3(x)
	if x >= 3 then
		return 0
	elseif x < 0 then
		return 2
	end
	return x
end

function RStat()
	--return 0
	return math.random(3)-1
end

function love.load()
	bgmusic = Music("assets/ChipChippy (loop).mp3")
		Play(bgmusic)
	love.mouse.setVisible(false)
	love.graphics.setFont(love.graphics.newFont("PressStart2P.ttf", 20))
	math.randomseed( tonumber(tostring(os.time()):reverse():sub(1,6)) )
	SetState(STATETITLE)
	love.physics.setMeter(METERS)
	
	p1data = {RStat(),RStat(),RStat(),RStat(),RStat()}
	p2data = {RStat(),RStat(),RStat(),RStat(),RStat()}
	
	local e = love.graphics.newParticleSystem(gfxstar, 400)
	local r,g,b = 255,255,255
	e:setPosition(0,0)
	e:setParticleLife(10,30)
	e:setEmissionRate(40)
	e:setSizes(1, 1)
	e:setSpeed(0.1,5)
	e:setSpread(2*math.pi)
	e:setColors(r,g,b,0, r,g,b,100,r,g,b,0)
	e:start()
	starsem = e
	for i=0, 70 do
		e:setPosition(math.random(800), math.random(600))
		e:update(0.1)
	end
end

--------------------------------------------------

STATENULL = 0
STATESETUP = 1
STATETITLE = 2
STATECRAFT = 3
STATEGAME = 4
STATESTATE = 6


state = STATENULL

-------------------

local sfxgui = Sfx("sfx/gui.wav")
local sfxselect = Sfx("sfx/select.wav")
local sfxenter = Sfx("sfx/enter.wav")
	
local sfxshoot = Sfx("sfx/shoot.wav")
local sfxdie = Sfx("sfx/die.wav")

local sfxgrenade = Sfx("sfx/grenade.wav")
local sfxrocket = Sfx("sfx/rocket.wav")
local sfxnuke = Sfx("sfx/nuke.wav")

function SetPitch(p)
	sfxgui:setPitch(p)
	sfxselect:setPitch(p)
	sfxenter:setPitch(p)
	
	sfxshoot:setPitch(p)
	sfxdie:setPitch(p)

	sfxgrenade:setPitch(p)
	sfxrocket:setPitch(p)
	sfxnuke:setPitch(p)
		
	bgmusic:setPitch(p)
end

--------------------------------------------------

local gfxwhite = Img("assets/white.png")
local gfxcircle = Img("assets/circle.png")
local gfxbox = Img("assets/box.png")
local gfxpart = gfxbox
local gfxbullet = Img("assets/bullet.png")
local gfxtriangle = Img("assets/triangle.png")
local gfxarrow = Img("assets/arrow.png")

local gfxcraftbox = Img("assets/craft/box.png")
local gfxcrafttri = Img("assets/craft/tri.png")
local gfxcraftcircle = Img("assets/craft/circle.png")
	
local gfxcraftred = Img("assets/craft/red.png")
local gfxcraftgreen = Img("assets/craft/green.png")
local gfxcraftblue = Img("assets/craft/blue.png")
	
local gfxcraftwood = Img("assets/craft/wood.png")
local gfxcraftiron = Img("assets/craft/iron.png")
local gfxcraftglass = Img("assets/craft/glass.png")
	
local gfxcraftrockets = Img("assets/craft/rockets.png")
local gfxcraftnuke = Img("assets/craft/nuke.png")
local gfxcraftslingshot = Img("assets/craft/slingshot.png")
	
local gfxcraftfragile = Img("assets/craft/fragile.png")
local gfxcraftweak = Img("assets/craft/weak.png")
local gfxcraftheat = Img("assets/craft/heat.png")
		
		gfxstar = Img("assets/star.png")

		local gfxscreencraft = Img("assets/screens/craft.png")

function GfxCraft(class, id)
	if class == 0 then
		if id == 0 then
			return gfxcraftbox
		end
		if id == 1 then
			return gfxcrafttri
		end
		if id == 2 then
			return gfxcraftcircle
		end
	end
	if class == 1 then
		if id == 0 then
			return gfxcraftred
		end
		if id == 1 then
			return gfxcraftgreen
		end
		if id == 2 then
			return gfxcraftblue
		end
	end
	if class == 2 then
		if id == 0 then
			return gfxcraftwood
		end
		if id == 1 then
			return gfxcraftiron
		end
		if id == 2 then
			return gfxcraftglass
		end
	end
	if class == 3 then
		if id == 0 then
			return gfxcraftrockets
		end
		if id == 1 then
			return gfxcraftnuke
		end
		if id == 2 then
			return gfxcraftslingshot
		end
	end
	if class == 4 then
		if id == 0 then
			return gfxcraftfragile
		end
		if id == 1 then
			return gfxcraftweak
		end
		if id == 2 then
			return gfxcraftheat
		end
	end
	return gfxwhite
end

function Shipgfx(id)
	if id == 0 then
		return gfxbox
	elseif id == 1 then
		return gfxtriangle
	else
		return gfxcircle
	end
end

--------------------------------------------------

p1left = "a"
p1right = "d"
p1down = "s"
p1up = "w"
p1action = "q"
p1start = "e"

p2left = "left"
p2right = "right"
p2down = "down"
p2up = "up"
p2action = "return"
p2start = "rshift"
	
function setkeyboard()
	p1left = "a"
	p1right = "d"
	p1down = "s"
	p1up = "w"
	p1action = "q"
	p1start = "e"

	p2left = "left"
	p2right = "right"
	p2down = "down"
	p2up = "up"
	p2action = "return"
	p2start = "rshift"
end

function setgamepads()
	local p1 = "joy1."
	p1left = p1.."-ax4"
	p1right = p1.."+ax4"
	p1down = p1.."+ax5"
	p1up = p1.."-ax5"
	p1action = p1.."btn3"
	p1start = p1.."btn10"

	local p2 = "joy2."
	p2left = p2.."-ax4"
	p2right = p2.."+ax4"
	p2down = p2.."+ax5"
	p2up = p2.."-ax5"
	p2action = p2.."btn3"
	p2start = p2.."btn10"
end

function determinesuperkey(key)
	if key == "return" then
		return 1
	elseif key == "joy1.btn3" then
		return 2
	elseif key == "joy2.btn3" then
		return 2
	else
		return 0
	end
end

--------------------------------------------------

function title_setup()
	p1craftready = false
	p2craftready = false
end

function CenterPrint(t, y)
	local d = 10
	love.graphics.printf(t, d, y, 800-d*2, "center")
end

function title_draw()
	Draw(starsem)
	BeginPrint()
		CenterPrint("a nomoresweden 2013", 370)
		CenterPrint("game by @sirGustav", 400)
		CenterPrint("Super Ultimate Pirates", 150)
		CenterPrint("in Extremly Radiated Spaces", 200)
		CenterPrint("press retur or B on gamepad", 550)
	EndPrint()
end

function title_onkey(key, down)
	if down==false then
		local super = determinesuperkey(key)
		if super == 1 then
			setkeyboard()
			SetState(STATECRAFT)
		elseif super==2 then
			setgamepads()
			SetState(STATECRAFT)
		end
	end
end



function title_update(dt)
	starsem:setPosition(math.random(800), math.random(600))
	starsem:update(dt)
end

MODTITLES = {"Shape", "Color", "Hull", "Weapon", "Flaw"}
MODDESC = {{"The BOX is a easy shape to furnish.", "The TRIANGLE blends standard ship design and powerful attack vectors.", "The CIRCLE shape is powerful, the enemy doesn't know what way you're facing."}, {"RED is the color of a angry romulan warbird.", "GREEN is the color of peace.", "BLUE is a kinda nice color."}, {"WOOD may not be the best material to build a spaceship of but it's cheap and pretty durable", "IRON is the material most cruisers are made of, but they are slow because of it.", "GLASS is really fragile but also really light"}, {"The ROCKETS are powerful and reliable for a first craft owner.", "The NUKE is a truly devestating weapon but it also takes time to reload.", "The SLINGSHOT might not be the most dangerous weapon but it takes no time to reload and theese FORCE GRENADES could come in handy."}, {"FRAGILE: The architect was lazy and didn't really consider structural integrity.", "WEAK ENGINE: The mechanics has made a engine that is weak, it might even be too weak.", "HEAT PROBLEM: The engineers forgot to install proper cooling. The heat from the engine and guns will be a problem and there is no excuse for that."}}

--------------------------------------------------
p1place = 0
p1data = {0,0,0,0,0}
p1craftready = false
p2place = 0
p2data = {0,0,0,0,0}
p2craftready = false

function craft_setup()
	p1place = 0
	p2place = 0
end

local TEXTWIDTH = 300

function craft_draw_player(ready,data,place,x,d,tx,align)
	SetDefaultColor()
	for i=0, 4 do
		local y = 10+i*110
		Draw(GfxCraft(i, data[i+1]), x, y)
		if ready == false then
			if place == i then
				Draw(GfxCraft(i, mod3(data[place+1]-1)), x+d*110, y)
				Draw(GfxCraft(i, mod3(data[place+1]+1)), x+d*110*2, y)
			end
		end
	end
	
	BeginPrint()
	if ready then
		love.graphics.printf(" < R E A D Y > ", tx, 500, TEXTWIDTH, "center")
	else
		love.graphics.printf(MODTITLES[place+1] .. ":", tx, 100, TEXTWIDTH, align)
		love.graphics.printf(MODDESC[place+1][data[place+1]+1], tx, 120, TEXTWIDTH, align)
	end
	EndPrint()
end

function craft_draw()
	Draw(gfxscreencraft, 0, 0)
	craft_draw_player(p1craftready, p1data,p1place,10,1,120,"left")
	craft_draw_player(p2craftready, p2data,p2place,690,-1,680-TEXTWIDTH,"right")
end

function craft_onkey(key, down)
	if down then
		if p1craftready == false then
			if key == p1up then
				p1place = p1place - 1
				Play(sfxgui)
			end
			if key == p1down then
				p1place = p1place + 1
					Play(sfxgui)
			end
			if p1place == -1 then
				p1place = 4
			end
			if p1place == 5 then
				p1place = 0
			end
			if key == p1left then
				p1data[p1place+1] = mod3(p1data[p1place+1]-1)
				Play(sfxselect)
			end
			if key == p1right then
				p1data[p1place+1] = mod3(p1data[p1place+1]+1)
				Play(sfxselect)
			end
		end
		if key == p1action then
			p1craftready = not p1craftready
			Play(sfxenter)
		end
		
		if p2craftready == false then
			if key == p2up then
				p2place = p2place - 1
				Play(sfxgui)
			end
			if key == p2down then
				p2place = p2place + 1
				Play(sfxgui)
			end
			if p2place == -1 then
				p2place = 4
			end
			if p2place == 5 then
				p2place = 0
			end
			if key == p2left then
				p2data[p2place+1] = mod3(p2data[p2place+1]+1)
				Play(sfxselect)
			end
			if key == p2right then
				p2data[p2place+1] = mod3(p2data[p2place+1]-1)
				Play(sfxselect)
			end
		end
		if key == p2action then
			p2craftready = not p2craftready
				Play(sfxenter)
		end
	end
end

function craft_update(dt)
	if p1craftready and p2craftready then
		SetState(STATEGAME)
	end
end

---------------------------------------------------
p1hasaction = 0
p2hasaction = 0
			
map = nil
world = nil

function addRect(x,y,w,h)
	local xx = x + w/2
	local yy = y + h/2
	local body = love.physics.newBody(world,xx,yy,"static")
	local shape = love.physics.newRectangleShape(w,h)
	local fix = love.physics.newFixture(body, shape, 1)
	fix:setFriction(FRICTION)
end

function addShip(x,y, data)
	local body = love.physics.newBody(world,x,y,"dynamic")
	local shape = nil
	local hull = data[1]
	if hull == 3 then
		shape = love.physics.newCircleShape(SHIPRADIUS)
	else
		shape = love.physics.newRectangleShape(SHIPRADIUS,SHIPRADIUS)
	end
	local fix = love.physics.newFixture(body, shape, Density(data[3]))
	fix:setRestitution(BOUNCY)
	fix:setFriction(FRICTION)
	return body
end

function rsel(v, a, b, c)
	if v == 0 then
		return a
	end
	if v == 1 then
		return b
	end
	return c
end

function addBullet(x,y,dir,data)
	BULLETIMPULSE = 1000
	DISP = 10
	
	local shape = nil
	local hull = data[1]
	local dx,dy = 0,0
	if dir == 4 then
		dx = -1
	end
	if dir == 6 then
		dx = 1
	end
	if dir == 8 then
		dy = -1
	end
	if dir == 2 then
		dy = 1
	end
	
	local body = love.physics.newBody(world,x+dx*DISP,y+dy*DISP,"dynamic")
	shape = love.physics.newCircleShape(2)
	local fix = love.physics.newFixture(body, shape, 50)
	fix:setRestitution(0.5)
	fix:setFriction(0.5)
	body:setBullet(true)
			
	local weapon = data[4]
	
	body:applyLinearImpulse(dx*BULLETIMPULSE,dy*BULLETIMPULSE)
	local bullet = {}
	bullet.gfx = gfxbullet
	bullet.maxlife = rsel(weapon, 2, 3, 5)
	bullet.bangsize = rsel(weapon, 100, 500, 300)
	bullet.damage = rsel(weapon, 3, 2, 0.01)
	bullet.force = rsel(weapon, 100, 2000, 70000)
	bullet.sfx = rsel(weapon, sfxrocket,sfxnuke,sfxgrenade)
	bullet.body = body
	bullet.life = 0
	bullet.color = data[2]
	table.insert(objects,bullet)
	
	return rsel(weapon, 0.5, 5, 0.1)
end
	
function addBang(bullet)
	Play(bullet.sfx)
	local x,y = bullet.body:getPosition()
	local size = bullet.bangsize
	local dmg = bullet.damage
		
	local b = {}
	b.x = x
	b.y = y
	b.size = size
	b.life = 0
	b.dmg = dmg
	b.color = bullet.color
	b.force = bullet.force
	table.insert(bangs, b)
end
	
function createworld()
	map = ATL_Loader.load("world.tmx")
	map.useSpriteBatch = true
	map.drawObjects = false

	world = love.physics.newWorld(0,GRAVITY,false)
	p1body = addShip(300, 30, p1data)
	p2body = addShip(500, 30, p2data)
	for tilename, tilelayer in pairs(map.tileLayers) do
		--print("Working on ", tilename, map.height, map.width, tilelayer)
		if tilename == "col" then
			for y=1,map.height do
				for x=1,map.width do
					local tile = tilelayer.tileData(x,y)
					if tile and tile ~= nil then 
						--print(x,y, tilenumber)
						local epsilon = 0.0
						local ctile = addRect((x)* map.tileWidth, (y) * map.tileHeight, map.tileWidth-epsilon, map.tileHeight-epsilon)
						--print("detected collision tile!")
						--ctile.type = nil
						--collider:addToGroup("tiles", ctile)
						--collider:setPassive(ctile)
						--tiles[#self.tiles+1] = ctile
						--added = added + 1
					end
				end
			end
		end
	end
end
	
function Em(gfx, data, x, y)
	local e = love.graphics.newParticleSystem(gfx, 400)
	local r,g,b = RGB(data[2])
	e:setPosition(x,y)
	e:setParticleLife(2.5,3)
	e:setEmissionRate(40)
	e:setSizes(0.1, 1)
	e:setSpeed(1,10)
	e:setSpread(2*math.pi)
	e:setColors(r,g,b,100,r,g,b,0)
	return e
end

function game_setup()
	p1maxhealth = SetupMaxHealth(p1data)
	p2maxhealth = SetupMaxHealth(p2data)
	createworld()
	p1direction = 6
	p1health = p1maxhealth
	p1hasaction = 0
	p1em = Em(gfxpart, p1data, p1body:getPosition())
	p1em:start()
	
	p2direction = 4
	p2health = p2maxhealth
	p2hasaction = 0
	p2em = Em(gfxpart, p2data, p2body:getPosition())
	p2em:start()
	
	donetimer = 0
	objects = {}
	bangs = {}
	
	p1heat = 0
	p2heat = 0
end
	
function Within(mi, v, ma)
	if v <= mi then
		return mi
	end
	if v >= ma then
		return ma
	end
	return v
end
	
function Withinx(x)
	return Within(5, x, 800-25)
end
	
function Withiny(y)
	return Within(5, y, 600-25)
end

function isshipoutside(body)
	local x, y = body:getPosition()
	if x < MINX then
		return true
	elseif x > MAXX then
		return true
	elseif y < MINY then
		return true
	elseif y > MAXY then
		return true
	else
		return false
	end
end

function gamedrawship(body, data, health, maxhealth, heat)
	if health > 0 then
		local x, y = body:getPosition()
		local a = body:getAngle()
		SetColor(data[2])
		Draw(Shipgfx(data[1]), x,y,a,1,1,10,10)
		SetDefaultColor()
	
		local outside = false
		local rotation = 0
		if x < MINX then
			rotation = 180
			outside = true
		elseif x > MAXX then
			rotation = 0
			outside = true
		elseif y < MINY then
			rotation = -90
			outside = true
		elseif y > MAXY then
			rotation = 90
			outside = true
		end
		if outside then
			local d = 10
			SetColor(data[2])
			Draw(gfxarrow, Withinx(x-10)+d, Withiny(y-10)+d, rotation * (math.pi/180), 1,1,d,d)
			SetDefaultColor()
		end
	
		local barx,bary = x-12,y+12
		if outside then
			barx,bary = Withinx(x-12),Withiny(y-12)+22
		end
		SetDefaultColor()
		love.graphics.rectangle("fill", barx, bary, 24, 3)
		SetColor(data[2])
		love.graphics.rectangle("fill", barx, bary, 24*(health/maxhealth), 3)
		if heat > 0 then
			local hv = math.min(1, heat)
			love.graphics.setColor(255,255,255,255)
			love.graphics.rectangle("fill", barx, bary+5, 24, 3)
			love.graphics.setColor(255,0,0,255)
			love.graphics.rectangle("fill", barx, bary+5, 24*hv, 3)
		end
		SetDefaultColor()
	end
end
	
function game_draw()
	love.graphics.push()
		love.graphics.translate(shakex,shakey)
	map:draw()
	
	Draw(p1em)
	Draw(p2em)
	Draw(starsem)
	gamedrawship(p1body, p1data, p1health, p1maxhealth, p1heat)
	gamedrawship(p2body, p2data, p2health, p2maxhealth, p2heat)
	for i=1, #objects do
		Draw(objects[i].gfx, objects[i].body:getPosition())
	end
	for i=1, #bangs do
		local l = bangs[i].l
		local rad = bangs[i].rad
		local r,g,b = RGB(bangs[i].color)
		love.graphics.setColor(r,g,b,255*(1-l))
		love.graphics.circle("fill", bangs[i].x, bangs[i].y, rad)
		SetDefaultColor()
	end
	love.graphics.pop()
end

function b2i(b)
	if b then
		return 1
	else
		return -1
	end
end

function game_onkey_ship(body, key, isdown, left, right, up, down, action, data, direction, hasaction, heat)
		if key == left then
			if isdown then direction = 4 end
			hasaction = hasaction + b2i(isdown)
		end
		if key == right then
			if isdown then direction = 6 end
			hasaction = hasaction + b2i(isdown)
		end
		if key == up then
			if isdown then direction = 8 end
			hasaction = hasaction + b2i(isdown)
		end
		if key == down then
			if isdown then direction = 2 end
			hasaction = hasaction + b2i(isdown)
		end
		
		if key == action and isdown and heat <= 1 and body then
			local x,y = body:getPosition()
			heat = heat + addBullet(x,y,direction,data)
			Play(sfxshoot)
		end
	
		return direction, hasaction, heat
end

function game_onkey(key,down)
	p1direction,p1hasaction,p1heat = game_onkey_ship(p1body, key, down, p1left, p1right, p1up, p1down, p1action, p1data, p1direction, p1hasaction,p1heat)
	p2direction,p2hasaction,p2heat = game_onkey_ship(p2body, key, down, p2left, p2right, p2up, p2down, p2action, p2data, p2direction, p2hasaction,p2heat)
	if key == p1start and down then
		p1health = -1
	end
	if key == p2start and down then
		p2health = -1
	end
end
	
function game_update_ship(body, direction, hasaction, health,data,dt,heat)
	if hasaction > 0 and health >= 0 then
		local enginepower = 1
		if data[5] == 1 then
			enginepower = SUCKYENGINE
		end
		if direction == 4 then
			body:applyForce(-FORCE*enginepower,0)
		end
		if direction == 6 then
			body:applyForce(FORCE*enginepower,0)
		end
		if direction == 8 then
			body:applyForce(0,-UPFORCE*enginepower)
		end
		if direction == 2 then
			body:applyForce(0,DOWNFORCE*enginepower)
		end
	end
	if body then
		local x,y = body:getPosition()
		for i=1, #bangs do
			local dx = x - bangs[i].x
			local dy = y - bangs[i].y
			local l = math.sqrt(dx*dx+dy*dy)
			if l < bangs[i].rad then
				local s = (1 - l/bangs[i].rad)
				local tdmg = bangs[i].dmg*s*dt
				health = health - tdmg
				
				local fscale = s*bangs[i].force/l
				body:applyForce(dx*fscale,dy*fscale)
			end
		end
	end
	if heat > 0 then
		local release = 1
		if data[5] == 2 then
			release = 0.5
		end
		heat = heat - dt*release
	end
	return health, heat
end

function objects_remove_func(o)
	if o.life > o.maxlife then
		addBang(o)
		o.body:destroy()
		return true
	end
end
	
function bangs_remove_func(o)
	if o.life > MAXBANGLIFE then
		return true
	end
end

shaketimer = 0
shakex = 0
shakey = 0

function game_update(dt)
	local delta = 1 - donetimer/(DONETIME*3)
	SetPitch(delta)
	local sdt = delta * dt
	for i=1, #objects do
		objects[i].life = objects[i].life + dt
	end
	remove_if(objects, objects_remove_func)
	local totaldmg = 0
	for i=1, #bangs do
		bangs[i].life = bangs[i].life + dt
		local l = bangs[i].life/MAXBANGLIFE
		local rad = bangs[i].size*l
		local r,g,b = RGB(bangs[i].color)
		bangs[i].l = l
		bangs[i].rad = rad
		totaldmg = math.max(totaldmg,math.min(0.1,bangs[i].dmg))
	end
	remove_if(bangs, bangs_remove_func)
	shaketimer = shaketimer + dt
	if shaketimer > 0.01 then
			SHAKESCALE = 300
		shaketimer = shaketimer - 0.01
		shakex = totaldmg * math.random() * SHAKESCALE * randomsign()
		shakey = totaldmg * math.random() * SHAKESCALE * randomsign()
	end
	p1health,p1heat = game_update_ship(p1body, p1direction, p1hasaction, p1health, p1data,sdt,p1heat)
	p2health,p2heat = game_update_ship(p2body, p2direction, p2hasaction, p2health, p2data,sdt,p2heat)
	if p1body and isshipoutside(p1body) then
		p1health = p1health - sdt * RADIATION
	end
	if p2body and isshipoutside(p2body) then
		p2health = p2health - sdt * RADIATION
	end
	if p1body then p1em:setPosition(p1body:getPosition()) end
	if p2body then p2em:setPosition(p2body:getPosition()) end
	p1em:update(sdt)
	p2em:update(sdt)
	starsem:setPosition(math.random(800), math.random(600))
	starsem:update(sdt)
	world:update(sdt)
	if p1body and p1health < 0 then
		p1body:destroy()
		p1body = nil
		Play(sfxdie)
		p1em:stop()
	end
	if p2body and p2health < 0 then
		p2body:destroy()
		p2body = nil
		Play(sfxdie)
		p2em:stop()
	end
		
	if p1body == nil and p2body==nil then
		donetimer = donetimer + DONETIME
	end
	
	if p1body == nil or p2body==nil then
		donetimer = donetimer + dt
		if donetimer > DONETIME then
			if p1body == nil and p2body==nil then
				statstate = 0
			elseif p1body == nil then
				statstate = 2
			else
				statstate = 1
			end
			SetState(STATESTAT)
			world:destroy()
			world = nil
			map = nil
		end
	end
end
	
---------------------------------------------------

function stat_setup()
	if statstate == 0 then
		stattext = Random({"The pirates fought bravley and was ultimatly both killed", "404: No winner available, all pirates died", "Somehow both players died..."})
	elseif statstate == 1 then
		stattext = Random({"Captain left rules again!", "Right lost due to left being better", "Captain left got a hook for a hand and right was no match for him"})
	elseif statstate == 2 then
		stattext = Random({"Captain right beats lefty easily", "Lefty was no match for the captain", "Captain right rules the contaminated space!"})
	else
		stattext = "Unknown statstate " .. tostring(statstate)
	end
end
	
function stat_draw()
	Draw(starsem)
		love.graphics.printf(stattext, 10, 250, 780, "center")
end
	
function stat_onkey(key,down)
	if down==false and determinesuperkey(key)>0 then
		SetState(STATETITLE)
	end
end
	
function stat_update(dt)
	starsem:setPosition(math.random(800), math.random(600))
	starsem:update(dt)
end

---------------------------------------------------


function SetState(nextstate)
	state = nextstate
	-- PauseAllAudio()
	SetPitch(1)
	if state == STATETITLE then title_setup()
	elseif state == STATECRAFT then craft_setup()
	elseif state == STATEGAME then game_setup()
	elseif state == STATESTAT then stat_setup()
	else
		print("unknown gamestate " .. state)
	end
end

function love.draw()
	if state == STATETITLE then title_draw()
	elseif state == STATECRAFT then craft_draw()
	elseif state == STATEGAME then game_draw()
	elseif state == STATESTAT then stat_draw()
	else
		BeginPrint()
		love.graphics.print("unknown gamestate " .. state, 400, 300)
		EndPrint()
	end
end

function onkey(key, down)
	if down == false then
		if key == "escape" then
			love.event.push("quit")   -- actually causes the app to quit
		elseif key == "<" then
				love.graphics.toggleFullscreen()
		end
	end
	--print("Key " .. key .. " changed to ".. tostring(down))
	if state == STATETITLE then title_onkey(key, down)
	elseif state == STATECRAFT then craft_onkey(key, down)
	elseif state == STATEGAME then game_onkey(key, down)
	elseif state == STATESTAT then stat_onkey(key,down)
	else
		print("unknown gamestate " .. state)
	end
end

function love.keypressed(key)
	onkey(key,true)
end
	
function love.keyreleased(key)
	onkey(key, false)
end

function love.joystickpressed( joystick, button )
	onkey("joy"..tostring(joystick)..".btn"..tostring(button), true)
end

function love.joystickreleased( joystick, button )
	onkey("joy"..tostring(joystick)..".btn"..tostring(button), false)
end

function sendjoykeys()
	local joysticks = love.joystick.getNumJoysticks()

	if js == nil then
		js = {}
		for joystick=1, joysticks do
			local data = {}
			data.axes = love.joystick.getNumAxes(joystick)
			data.axesl = {}
			data.axesr = {}
			for axis=1, data.axes do
				data.axesl[axis] = false
				data.axesr[axis] = false
			end
			js[joystick] = data
		end
	end

	for joystick=1, joysticks do
		local data = js[joystick]
		for axis=1, data.axes do
			local direction = love.joystick.getAxis(joystick, axis)
			local left = false
			local right = false
			if direction > 0.5 then
				right = true
			end
			if direction < -0.5 then
				left = true
			end
			if data.axesl[axis] ~= left then
				data.axesl[axis] = left
				onkey("joy"..tostring(joystick)..".-ax"..tostring(axis), left)
			end
			if data.axesr[axis] ~= right then
				data.axesr[axis] = right
				onkey("joy"..tostring(joystick)..".+ax"..tostring(axis), right)
			end
		end
	end
end


function love.update(dt)
	sendjoykeys()
	if state == STATETITLE then title_update(dt)
	elseif state == STATECRAFT then craft_update(dt)
	elseif state == STATEGAME then game_update(dt)
	elseif state == STATESTAT then stat_update(dt)
	else
		print("unknown gamestate " .. state)
	end
end



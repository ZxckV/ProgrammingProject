function love.load()

	love.window.setMode(600, 400, {fullscreen=true, vsync=true})
	window_h = love.graphics.getHeight()
	window_w = love.graphics.getWidth()
	
	anim8 = require 'libraries/anim8'
	love.graphics.setDefaultFilter('nearest', 'nearest')

	sti = require 'libraries/sti'
	gameMap = sti('maps/FinalMap.lua')

	camera = require 'libraries/camera'
	cam = camera()
	
	wf = require 'libraries/windfield'
	world = wf.newWorld(0, 0)


	player = {}
	player.x = 2704 -- Spawn Coordinates for in forest
	player.y = 594
	player.speed = 30
	player.spriteSheet = love.graphics.newImage('sprites/player2.png')
	player.grid = anim8.newGrid( 16, 16, player.spriteSheet:getWidth(), player.spriteSheet:getHeight() )
	player.collider = world:newBSGRectangleCollider(2704, 594, 14, 14, 2)
	player.collider:setFixedRotation(true)

	player.animations = {}
	player.animations.down = anim8.newAnimation(player.grid('1-3', 1), 0.2)
	player.animations.right = anim8.newAnimation(player.grid('1-3', 2), 0.2)
	player.animations.left = anim8.newAnimation(player.grid('1-3', 3), 0.2)
	player.animations.up = anim8.newAnimation(player.grid('1-3', 4), 0.2)

	player.anim = player.animations.down -- Random animation, doesn't matter what it is 
	
	zoom_scale = 4
	cam:zoom(zoom_scale) -- Zooming the camera


	objects = {}
	if gameMap.layers['objects'] then
		for i, obj in pairs(gameMap.layers['objects'].objects) do
			local wall = world:newRectangleCollider(obj.x, obj.y, obj.width, obj.height)
			wall: setType('static')
			table.insert(objects, wall)
		end
	end	


	title_font = love.graphics.newFont('fonts/title_font.ttf', 96)
	menu_font = love.graphics.newFont('fonts/menu_font.ttf', 32)
	menu_font_l = love.graphics.newFont('fonts/menu_font.ttf', 128)
	

	sounds = {}
	sounds.theForest = love.audio.newSource('sounds/TheForest.wav', 'stream') -- In game music
	sounds.bonus = love.audio.newSource('sounds/bonusgame.wav', 'stream') -- End game music
	sounds.menu = love.audio.newSource('sounds/menu.mp3', 'stream') -- Menu music

	sounds.theForest:setLooping(true)
	sounds.menu:setLooping(true)
	sounds.menu:play()
	
	
	cross = love.graphics.newImage('images/cross.png')
	f_cross = love.graphics.newImage('images/f_cross.png')
	g_cross = love.graphics.newImage('images/g_cross.png')
	i_cross = love.graphics.newImage('images/i_cross.png')
	r_cross = love.graphics.newImage('images/r_cross.png')
	s_cross = love.graphics.newImage('images/s_cross.png')
	w_cross = love.graphics.newImage('images/w_cross.png')
	
	pixel_map = love.graphics.newImage('images/pixel_map.png')


	gap = 64
	fc_pos = ((window_w / 2) - 32) - (gap * 5)
	gc_pos = ((window_w / 2) - 32) - (gap * 3)
	ic_pos = ((window_w / 2) - 32) - (gap * 1)
	rc_pos = ((window_w / 2) + 32) + (gap * 0)
	sc_pos = ((window_w / 2) + 32) + (gap * 2)
	wc_pos = ((window_w / 2) + 32) + (gap * 4)


	fc_claimed = false
	gc_claimed = false
	ic_claimed = false
	rc_claimed = false
	sc_claimed = false
	wc_claimed = false
	complete = false

	show_WRLD = false


	state = 'menu'

end

function love.update(dt)
	
	local isMoving = false
	local show_world = false

	local vx = 0
	local vy = 0
	
	-- Keyboard input

	if love.keyboard.isDown('w') then
		if state == 'play' then
			vy = player.speed * -1
			player.anim = player.animations.up 
			isMoving = true
		end
	end

	if love.keyboard.isDown('a') then
		if state == 'play' then
			vx = player.speed * -1
			player.anim = player.animations.left
			isMoving = true
		end
	end

	if love.keyboard.isDown('s') then
		if state == 'play' then
			vy = player.speed
			player.anim = player.animations.down
			isMoving = true
		end
	end

	if love.keyboard.isDown('d') then
		if state == 'play' then
			vx = player.speed
			player.anim = player.animations.right
			isMoving = true
		end
	end

	if love.keyboard.isDown('lshift') then
		player.speed = 45
	else
		player.speed = 30
	end
	
	if love.keyboard.isDown('escape') then
		if state == 'menu' then
			love.event.quit()
		end
	end

	if love.keyboard.isDown('space') then
		if state == 'menu' then
			state = 'play'
			sounds.menu:pause()
			sounds.theForest:play()
		end
	end

	if love.keyboard.isDown('p') then
		if state == 'play' then
			state = 'pause'
		end
	end

	if love.keyboard.isDown('q') then
		if state == 'pause' then
			state = 'menu'
			sounds.theForest:pause()
			sounds.menu:play()
		end
	end

	if love.keyboard.isDown('r') then
		if state == 'pause' then
			state = 'play'
		end
	end

	if love.keyboard.isDown('1') then
		if state == 'play' then
			show_WRLD = true
		end
	end

	if love.keyboard.isDown('2') then
		if state == 'play' then
			show_WRLD = false
		end
	end

	player.collider:setLinearVelocity(vx, vy)

	if isMoving == false then -- If the player is not moving
		player.anim:gotoFrame(1) -- Go to the still frame
	end

	world:update(dt)
	player.x = player.collider:getX()
	player.y = player.collider:getY()
	
	player.anim:update(dt) -- Update the current animation
	
	cam:lookAt(player.x, player.y) -- Makes the camera look at the player
	
	-- Stopping the camera at the edge of the map
	
	local w = love.graphics.getWidth() / zoom_scale -- Width of the window (divided by zoom scale)
	local h = love.graphics.getHeight() / zoom_scale -- Height of the window (divided by zoom scale)

	local mapW = gameMap.width * gameMap.tilewidth -- Width of the map
	local mapH = gameMap.height * gameMap.tileheight -- Height of the map

	-- Left border
	if cam.x < w/2 then	
		cam.x = w/2
	end

	-- Top border
	if cam.y < h/2 then
		cam.y = h/2
	end

	-- Right border
	if cam.x > (mapW - w/2) then
		cam.x = (mapW - w/2)
	end

	-- Bottom border
	if cam.y > (mapH - h/2) then
		cam.y = (mapH - w/2)
	end

end

function love.draw()

	if state == 'menu' then
		love.graphics.setBackgroundColor( 0.251, 0.627, 1, 1 )
		love.graphics.setFont(title_font)
		love.graphics.printf('Hello World', 0, window_h / 2 - 146, window_w, 'center')
		love.graphics.setFont(menu_font)
		love.graphics.printf('Press [Space] To Start', 0, window_h / 2 + 10, window_w, 'center')
		love.graphics.printf('[ESC] Exit', 0, window_h - 64, window_w, 'center')

		love.graphics.draw(pixel_map, (window_w - 512), (window_h - 256))
	end

	if state == 'play' then
		cam:attach() -- All draw within this section will be affected by the camera settings
			gameMap:drawLayer(gameMap.layers['ground'])
			player.anim:draw(player.spriteSheet, player.x, player.y, nil, nil, nil, 8, 8)
			gameMap:drawLayer(gameMap.layers['buildings and objects'])	
			if show_WRLD == true then
				world:draw()
			end
		cam:detach()
	end

	if state == 'pause' then
		love.graphics.setBackgroundColor( 0.251, 0.627, 1, 1 )

		love.graphics.setColor(0, 0, 0, 1)
		love.graphics.setFont(menu_font_l)
		love.graphics.printf('Paused', 0, 128, window_w, 'center')
		love.graphics.setFont(menu_font)
		love.graphics.printf('[R] Resume', 0, 288, window_w, 'center')
		love.graphics.printf('[Q] Quit To Main Menu', 0, 352, window_w, 'center')

		love.graphics.setColor(1, 1, 1, 1)
		love.graphics.rectangle('fill', (fc_pos - 32), (window_h - 160), (64 * 12), 128)
		love.graphics.setColor(0, 0, 0, 1)
		love.graphics.rectangle('line', (fc_pos - 32), (window_h - 160), (64 * 12), 128)
	
		love.graphics.setColor(1, 1, 1, 1)
		love.graphics.draw( cross, fc_pos, (window_h - 128) )
		love.graphics.draw( cross, gc_pos, (window_h - 128) )
		love.graphics.draw( cross, ic_pos, (window_h - 128) )
		love.graphics.draw( cross, rc_pos, (window_h - 128) )
		love.graphics.draw( cross, sc_pos, (window_h - 128) )
		love.graphics.draw( cross, wc_pos, (window_h - 128) )
	

		if fc_claimed == true then
			love.graphics.draw( f_cross, fc_pos, (window_h - 128) )
		end
	
		if gc_claimed == true then
			love.graphics.draw( g_cross, gc_pos, (window_h - 128) )
		end

		if ic_claimed == true then
			love.graphics.draw( i_cross, ic_pos, (window_h - 128) )
		end

		if rc_claimed == true then
			love.graphics.draw( r_cross, rc_pos, (window_h - 128) )
		end
	
		if sc_claimed == true then
			love.graphics.draw( s_cross, sc_pos, (window_h - 128) )
		end
	
		if wc_claimed == true then
			love.graphics.draw( w_cross, wc_pos, (window_h - 128) )
		end
	end

end
-- FinalMap v0.5



-- LOADING THE GAME

-- This section of code loads in all of the things needed to constuct the game.
-- Any graphics, sounds and fonts need to be declared here.
-- Additional libaries that are being used are also instantiated here.
function love.load() 

	-- <<<<< SETTING UP THE GAME WINDOW >>>>>

	love.window.setMode(600, 400, {fullscreen=true, vsync=true}) -- Set the window to fullscreen
	window_h = love.graphics.getHeight() -- Store the height of the window in a variable
	window_w = love.graphics.getWidth() -- Stonre the width of the window in a variable



	-- <<<<< LIBRARIES >>>>>

	-- Amim8
	-- Used to animate the character
	anim8 = require 'libraries/anim8'
	love.graphics.setDefaultFilter('nearest', 'nearest') -- Setting a filter so the scaled sprite appears clearly


	-- Simple Tiled Implementation 
	-- Used to allow Tiled maps to work with Love2d
	sti = require 'libraries/sti'
	gameMap = sti('maps/FinalMap.lua') -- Loading the map of the game 


	-- Camera
	-- Used to create a camera that the player is viewed through
	camera = require 'libraries/camera'
	cam = camera() 

	
	-- Windfield
	-- Used for colision detection between the player and the world
	wf = require 'libraries/windfield'
	world = wf.newWorld(0, 0) -- Creating the world 

	

	-- <<<<< CREATING THE PLAYER >>>>>

	-- Player General
	player = {} -- Creating a table called player that stores all the player info
	player.x = 2704 -- Spawn x coordinate for in forest
	player.y = 594 -- Spawn y coordinate for in forest
	player.speed = 30 -- The speed of the player


	-- Player Links With Libraries
	player.spriteSheet = love.graphics.newImage('sprites/player2.png') -- Loading the sprite sheet for the player
	player.grid = anim8.newGrid( 16, 16, player.spriteSheet:getWidth(), player.spriteSheet:getHeight() ) -- Creating a grid to be used with Anim8
	player.collider = world:newBSGRectangleCollider(2704, 594, 14, 14, 2) -- Creating a collider for the player to work with Windfield 
	player.collider:setFixedRotation(true) -- Locking the players rotation


	-- Player Animations
	player.animations = {} -- Creating a new player animation
	player.animations.down = anim8.newAnimation(player.grid('1-3', 1), 0.2) -- Player animation for down
	player.animations.right = anim8.newAnimation(player.grid('1-3', 2), 0.2) -- Player animation for right
	player.animations.left = anim8.newAnimation(player.grid('1-3', 3), 0.2) -- Player animation for left
	player.animations.up = anim8.newAnimation(player.grid('1-3', 4), 0.2) -- Player animation for up

	player.anim = player.animations.down -- Setting the players animation to a random one for the start of the game
	
	

	-- <<<<< CAMERA >>>>>

	zoom_scale = 4 -- Setting the zoom scale for the camera 
	cam:zoom(zoom_scale) -- Zooming the camera



	-- <<<<< GENERATING COLLIDERS >>>>> 

	objects = {} -- Creating a table called objects for the colliders in the world
	if gameMap.layers['objects'] then -- Using my Tiled game map object layer
		for i, obj in pairs(gameMap.layers['objects'].objects) do
			local wall = world:newRectangleCollider(obj.x, obj.y, obj.width, obj.height) -- Create a wall with Windfield
			wall: setType('static') -- Set the wall to static
			table.insert(objects, wall) -- Add it to the table 
		end
	end	
	


	-- <<<<< FONTS >>>>>

	title_font = love.graphics.newFont('fonts/title_font.ttf', 96) -- Title font for the title seen on the main menu
	menu_font = love.graphics.newFont('fonts/menu_font.ttf', 32) -- The standard font seen in the main menu and pause menu
	menu_font_l = love.graphics.newFont('fonts/menu_font.ttf', 128) -- A larger version of the standard menu font
	


	--  <<<<< SOUNDS >>>>>

	-- Loading Sounds
	sounds = {} -- Creating a table called sounds to store the games sounds
	sounds.theForest = love.audio.newSource('sounds/TheForest.wav', 'stream') -- The music played when playing the game
	sounds.menu = love.audio.newSource('sounds/menu.mp3', 'stream') -- The music that plays in the main menu
	sounds.bonus = love.audio.newSource('sounds/bonusgame.wav', 'stream') -- Additional music with no purpose as of yet


	-- Playing Sounds
	sounds.theForest:setLooping(true) -- Set the track theForest to loop when it is played
	sounds.menu:setLooping(true) -- Set the tract menu to loop when it is played
	sounds.menu:play() -- Play the menu music
	


	--  <<<<< GRAPHICS >>>>>

	-- Main Meu 
	pixel_map = love.graphics.newImage('images/pixel_map.png') -- Blocky map overview image

	
	-- Pause Menu
	cross = love.graphics.newImage('images/cross.png') -- Empty cross image
	f_cross = love.graphics.newImage('images/f_cross.png') -- Forest cross image
	g_cross = love.graphics.newImage('images/g_cross.png') -- Grass cross image
	i_cross = love.graphics.newImage('images/i_cross.png') -- Ice cross image 
	r_cross = love.graphics.newImage('images/r_cross.png') -- Rock cross image 
	s_cross = love.graphics.newImage('images/s_cross.png') -- Sand cross image
	w_cross = love.graphics.newImage('images/w_cross.png') -- Witch cross image
	


	-- <<<<< VARIABLES >>>>> 	

	-- Playing Game
	show_WRLD = false -- Set show_WRLD to false


	-- Pause Menu
	gap = 64 -- Gap between each cross
	fc_pos = ((window_w / 2) - 32) - (gap * 5) -- Position of f_cross
	gc_pos = ((window_w / 2) - 32) - (gap * 3) -- Position of g_cross
	ic_pos = ((window_w / 2) - 32) - (gap * 1) -- Position of i_cross
	rc_pos = ((window_w / 2) + 32) + (gap * 0) -- Position of r_cross
	sc_pos = ((window_w / 2) + 32) + (gap * 2) -- Position of s_cross
	wc_pos = ((window_w / 2) + 32) + (gap * 4) -- Position of w_cross

	fc_claimed = false -- Sets the f_cross claim to false
	gc_claimed = false -- Sets the g_cross claim to false
	ic_claimed = false -- Sets the i_cross claim to false
	rc_claimed = false -- Sets the r_cross claim to false
	sc_claimed = false -- Sets the s_cross claim to false
	wc_claimed = false -- Sets the w_cross claim to false
	complete = false -- Set completed to false

	

	-- <<<<< STATE >>>>> 

	state = 'menu' -- Set the starting game state to menu



end



-- UPDATING THE GAME

-- This section of code is constantly ran from the start of the game.
-- Any conditions that need to be checked constantly, such as keyboard input, can be done so here.
-- Delta time is passed in, so the real time since the last loop can be used here.
function love.update(dt)

	-- <<<<< VARIABLES >>>>> 
		
	local isMoving = false -- Create a local variable called isMoving and set it to false
	local show_world = false -- Create a local variable called show_world and set it to false

	local vx = 0 -- Create a variable for the horizontal velocity of the player
	local vy = 0 -- Create a variable for the vertical velocity of the player
	



	-- <<<<< KEYBOARD INPUT >>>>

	-- Main Menu
	-- Starting the game
	if love.keyboard.isDown('space') then -- If the space bar is pressed
		if state == 'menu' then -- If the game is in the menu state
			state = 'play' -- Change the state to play
			sounds.menu:pause() -- Pause the menu music
			sounds.theForest:play() -- Play the game music 
		end
	end

	-- Closing the game
	if love.keyboard.isDown('escape') then -- If the escape key is pressed
		if state == 'menu' then -- If the game is in the menu state
			love.event.quit() -- Call the quit event, which closes the game
		end
	end


	-- Playing Game
	-- Walking Up	
	if love.keyboard.isDown('w') then -- If the W key is pressed
		if state == 'play' then -- If the game is in the play state
			vy = player.speed * -1 -- Change the vertical velocity of the player
			player.anim = player.animations.up -- Update the current animation to up
			isMoving = true -- Update isMoving to true 
		end
	end

	-- Walking Left
	if love.keyboard.isDown('a') then -- If the A key is pressed
		if state == 'play' then -- If the game is in the play state
			vx = player.speed * -1 -- Change the hoizontal velocity of the player
			player.anim = player.animations.left -- Update the current animation to left
			isMoving = true -- Update isMoving to true
		end
	end

	-- Walking Down
	if love.keyboard.isDown('s') then -- If the S key is pressed 
		if state == 'play' then -- If the game is in the play state
			vy = player.speed -- Change the vertical velocity of the player
			player.anim = player.animations.down -- Update the current animation to down 
			isMoving = true -- Update isMoving to true
		end
	end

	-- Walking Right
	if love.keyboard.isDown('d') then -- If the D key is pressed
		if state == 'play' then -- If the game is in the play state
			vx = player.speed -- Change the horizontal velocity of the player
			player.anim = player.animations.right -- Update the current animation to right
			isMoving = true -- Update isMoving to true 
		end
	end

	-- Pausing the game
	if love.keyboard.isDown('p') then -- If the P key is pressed
		if state == 'play' then -- If the game is in the play state
			state = 'pause' -- Change the state to pause
		end
	end

	-- Showing the world 
	if love.keyboard.isDown('1') then -- If the 1 key is pressed
		if state == 'play' then -- If the game is in the play state
			show_WRLD = true -- Update show_WRLD to true 
		end
	end

	-- Hiding the world
	if love.keyboard.isDown('2') then -- If the 1 key is pressed
		if state == 'play' then -- If the game is in the play state
			show_WRLD = false -- Update show_WRLD to false
		end
	end
	
	-- Sprinting 
	if love.keyboard.isDown('lshift') then -- If the Left Shift key is pressed
		player.speed = 45 -- Change the players speed 
	else -- Otherwise if the Left Shift key is not pressed
		player.speed = 30 -- Keep the players speed at its normal value
	end

	
	-- Pause Menu
	-- Quitting to menu
	if love.keyboard.isDown('q') then -- If the Q key is pressed
		if state == 'pause' then -- If the game is in the pause state
			state = 'menu' -- Change the state to menu
			sounds.theForest:pause() -- Pause the game music
			sounds.menu:play() -- Play the menu music
		end
	end

	-- Resuming the game
	if love.keyboard.isDown('r') then -- If the R key is pressed
		if state == 'pause' then -- If the game is in the pause state
			state = 'play' -- Change the state to play
		end
	end



	-- <<<<< PLAYER MOVEMENT >>>>>

	player.collider:setLinearVelocity(vx, vy) -- Updating the players linear velocity

	if isMoving == false then -- If the player is not moving
		player.anim:gotoFrame(1) -- Go to the still frame
	end

	

	-- <<<< UPDATING THE WORLD >>>>>

	world:update(dt)



	-- <<<<< UPDATING THE PLAYER >>>>>
	
	player.x = player.collider:getX() -- Updating the players x to its colliders x
	player.y = player.collider:getY() -- Updating the players y to its colliders y
	
	player.anim:update(dt) -- Update the current animation
	


	-- <<<<< UPDATING THE CAMERA >>>>>
	
	cam:lookAt(player.x, player.y) -- Makes the camera look at the player
	
	local w = love.graphics.getWidth() / zoom_scale -- Width of the window (divided by zoom scale)
	local h = love.graphics.getHeight() / zoom_scale -- Height of the window (divided by zoom scale)

	local mapW = gameMap.width * gameMap.tilewidth -- Width of the map
	local mapH = gameMap.height * gameMap.tileheight -- Height of the map


	-- The following code checks to see if the camera is viewing areas beyond the map.
	-- If it is, it is checking what edge it is going past.
	-- It then locks the cameras x or y value at the edge it went beyond.


	-- Left border
	if cam.x < w/2 then -- If the cameras x passes the left edge of the map	
		cam.x = w/2 -- Update the cameras x to the left edge of the map
	end


	-- Top border
	if cam.y < h/2 then -- If the cameras y passes the top edge of the map
		cam.y = h/2 -- Update the cameras y to the top edge of the map
	end


	-- Right border
	if cam.x > (mapW - w/2) then -- If the cameras x passes the right edge of the map
		cam.x = (mapW - w/2) -- Update the cameras x to the right edge of the map
	end


	-- Bottom border
	if cam.y > (mapH - h/2) then -- If the cameras y passes the bottom edge of the map
		cam.y = (mapH - w/2) -- Update the cameras y to the bottom edge of the map
	end



end



-- DRAWING THE GAME 

-- This section of the code is used to draw what you want to the window.
function love.draw()

	-- <<<<< DRAWING THE MENU MENU >>>>>

	if state == 'menu' then -- If the game is in the menu state

		-- Background
		love.graphics.setBackgroundColor( 0.251, 0.627, 1, 1 ) -- Set the background colour to this blue

		-- Printing text
		love.graphics.setFont(title_font) -- Set the font to the title font
		love.graphics.printf('Hello World', 0, window_h / 2 - 146, window_w, 'center') -- Print the title
		love.graphics.setFont(menu_font) -- Set the font to the menu font
		love.graphics.printf('Press [Space] To Start', 0, window_h / 2 + 10, window_w, 'center') -- Print this
		love.graphics.printf('[ESC] Exit', 0, window_h - 64, window_w, 'center') -- Print this

		-- Drawing images
		love.graphics.draw(pixel_map, (window_w - 512), (window_h - 256)) -- Draw the image

	end



	-- <<<<< DRAWING THE GAME >>>>>

	if state == 'play' then -- If the game is in the play state

		-- Everything drawn within the camera being attached and detached is affected by the camera setings.
		cam:attach() -- Attach the camera

			gameMap:drawLayer(gameMap.layers['ground']) -- Draw the ground layer of the game map
			-- The player is drawn before the next layer of the map so it can appear as if the player can go behind objects			
			player.anim:draw(player.spriteSheet, player.x, player.y, nil, nil, nil, 8, 8) -- Draw the player 
			gameMap:drawLayer(gameMap.layers['buildings and objects']) -- Draw the buildings and objects layer of the game map
	
			if show_WRLD == true then -- If show_WRLD is true
				world:draw() -- Draw the world, which shows the colliders
			end

		cam:detach() --Detach the camera

	end



	-- <<<<< DRAWING THE PAUSE MENU >>>>>

	if state == 'pause' then -- If the game is in the pause state

		-- Background
		love.graphics.setBackgroundColor( 0.251, 0.627, 1, 1 ) -- Set the background colour to this blue

		-- Printing text
		love.graphics.setColor(0, 0, 0, 1) -- Set the colour to black
		love.graphics.setFont(menu_font_l) -- Set the font to the large menu font
		love.graphics.printf('Paused', 0, 128, window_w, 'center') -- Print this
		love.graphics.setFont(menu_font) -- Set the font to the menu font
		love.graphics.printf('[R] Resume', 0, 288, window_w, 'center') -- Print this
		love.graphics.printf('[Q] Quit To Main Menu', 0, 352, window_w, 'center') -- Print this

		-- Drawing shapes
		love.graphics.setColor(1, 1, 1, 1) -- Set the colour to white
		love.graphics.rectangle('fill', (fc_pos - 32), (window_h - 160), (64 * 12), 128) -- Draw this rectangle
		love.graphics.setColor(0, 0, 0, 1) -- Set the colour to black
		love.graphics.rectangle('line', (fc_pos - 32), (window_h - 160), (64 * 12), 128) -- Draw this rectangle
	
		-- Drawing images
		love.graphics.setColor(1, 1, 1, 1) -- Set the colour to white
		love.graphics.draw( cross, fc_pos, (window_h - 128) ) -- Draw an empty cross at position fc_pos
		love.graphics.draw( cross, gc_pos, (window_h - 128) ) -- Draw an empty cross at position gc_pos
		love.graphics.draw( cross, ic_pos, (window_h - 128) ) -- Draw an empty cross at position ic_pos
		love.graphics.draw( cross, rc_pos, (window_h - 128) ) -- Draw an empty cross at position rc_pos
		love.graphics.draw( cross, sc_pos, (window_h - 128) ) -- Draw an empty cross at position sc_pos
		love.graphics.draw( cross, wc_pos, (window_h - 128) ) -- Draw an empty cross at position wc_pos
	
		-- Checking claims
		-- This section checks to see if the crosses have been claimed.
		-- If they have, their image in the pause menu get updated.
		-- I tried elseif statements for this but it didn't work.

		-- Forest cross
		if fc_claimed == true then -- If the forest cross has been claimed
			love.graphics.draw( f_cross, fc_pos, (window_h - 128) ) -- Draw f_cross at position fc_pos
		end
	
		-- Grass cross
		if gc_claimed == true then -- If the grass cross has been claimed
			love.graphics.draw( g_cross, gc_pos, (window_h - 128) ) -- Draw g_cross at position gc_pos
		end

		-- Ice cross 
		if ic_claimed == true then -- If the ice cross has been claimed
			love.graphics.draw( i_cross, ic_pos, (window_h - 128) ) -- Draw i_cross at position ic_pos
		end

		-- Rock cross
		if rc_claimed == true then -- If the rock cross has been claimed
			love.graphics.draw( r_cross, rc_pos, (window_h - 128) ) -- Draw r_cross at position rc_pos
		end
	
		-- Sand cross
		if sc_claimed == true then -- If the sand cross has been claimed
			love.graphics.draw( s_cross, sc_pos, (window_h - 128) ) -- Draw s_cross at position sc_pos
		end
	
		-- Witch cross 
		if wc_claimed == true then -- If the witch cross has been claimed
			love.graphics.draw( w_cross, wc_pos, (window_h - 128) ) -- Draw w_cross at position wc_pos
		end

	end

end
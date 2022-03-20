-- Explorer v1



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
	gameMap = sti('maps/map.lua') -- Loading the map of the game 


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
	player.spriteSheet = love.graphics.newImage('sprites/player.png') -- Loading the sprite sheet for the player
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
	sounds.theForest = love.audio.newSource('sounds/TheForest.wav', 'stream') -- The music that plays in the play state
	sounds.menu = love.audio.newSource('sounds/menu.mp3', 'stream') -- The music that plays in the menu state
	sounds.bonus = love.audio.newSource('sounds/bonusgame.wav', 'stream') -- The music that plays in the end state
	sounds.collect = love.audio.newSource('sounds/collect.mp3', 'static') -- The sound that plays when a cross is claimed
	sounds.press = love.audio.newSource('sounds/press.mp3', 'static') -- The sound that plays when a key is pressed in the menus
	

	-- Playing Sounds
	sounds.theForest:setLooping(true) -- Set the track theForest to loop when it is played
	sounds.menu:setLooping(true) -- Set the tract menu to loop when it is played
	sounds.bonus:setLooping(true) -- Set the track bonus to loop when it is played
	sounds.menu:play() -- Play the menu music
	


	--  <<<<< GRAPHICS >>>>>

	-- Main Meu 
	pixel_map = love.graphics.newImage('images/pixel_map.png') -- Blocky map overview image


	-- Pause Menu
	cross = love.graphics.newImage('images/cross.png') -- Empty cross image
	


	-- <<<<< VARIABLES >>>>> 	

	-- Playing Game
	show_WRLD = false -- Set show_WRLD to false


	-- Pause Menu
	gap = 64 -- Gap between each cross


	-- Loading
	rec_w = 300 -- Width of the loading bar rectangle
	rec_h = 15 -- Height of the loading bar rectangle
	percent = 0 -- Set percent to 0
	loading = false -- Set loading to false

	-- Info
	page = 1 -- Set the page to 1



	-- <<<<< CROSS  >>>>>

	-- Forest Cross
	fc = {} -- Creating a table called fc
	fc.x = 2416 -- Forest cross x position on the map
	fc.y = 432 -- Forest cross y position on the map
	fc.pos = ((window_w / 2) - 32) - (gap * 5) -- Forest cross positon in pause menu
	fc.img = love.graphics.newImage('images/f_cross.png') -- Forest cross image 
	fc.claim = false -- Setting fc.claim to false
	

	-- Grass Cross
	gc = {} -- Creating a table called gc
	gc.x = 2052 -- Grass cross x position on the map
	gc.y = 1536 -- Grass cross y position on the map
	gc.pos = ((window_w / 2) - 32) - (gap * 3) -- Grass cross position in pause menu
	gc.img = love.graphics.newImage('images/g_cross.png') -- Grass cross image
	gc.claim = false -- Setting gc.claim to false


	-- Ice Cross
	ic = {} -- Creating a table called ic
	ic.x = 112 -- Ice cross x position on the map
	ic.y = 64 -- Ice cross y position on the map
	ic.pos = ((window_w / 2) - 32) - (gap * 1) -- Ice cross position in pause menu
	ic.img = love.graphics.newImage('images/i_cross.png') -- Ice cross image 
	ic.claim = false -- Setting ic.claim to false
	

	-- Rock Cross
	rc = {} -- Creating a table called rc
	rc.x = 1504 -- Rock cross x position on the map
	rc.y = 2192 -- Rock cross y position on the map
	rc.pos = ((window_w / 2) + 32) + (gap * 0) -- Rock cross position in pause menu
	rc.img = love.graphics.newImage('images/r_cross.png') -- Rock cross image
	rc.claim = false -- Setting rc.claim to false
	

	-- Sand Cross
	sc = {} -- Creating a table called sc
	sc.x = 4864 -- Sand cross x position on the map
	sc.y = 2448 -- Sand cross y position on the map
	sc.pos = ((window_w / 2) + 32) + (gap * 2) -- Sand cross position in pause menu
	sc.img = love.graphics.newImage('images/s_cross.png') -- Sand cross image
	sc.claim = false -- Setting sc.claim to false


	-- Witch Cross
	wc = {} -- Creating a table called wc
	wc.x = 1904 -- Witch cross x position on the map
	wc.y = 432 -- Witch cross y position on the map
	wc.pos = ((window_w / 2) + 32) + (gap * 4) -- Witch cross position in pause menu
	wc.img = love.graphics.newImage('images/w_cross.png') -- Witch cross image
	wc.claim = false -- Setting wc.claim to false



	-- <<<<< STATE >>>>> 

	state = 'menu' -- Set the starting game state to menu
	tempState = '' -- Set tempState to empty



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
	-- Going to info
	if love.keyboard.isDown('space') then -- If the space bar is pressed
		if state == 'menu' then -- If the game is in the menu state
			sounds.menu:stop() -- Stop the menu menu
			sounds.press:play() -- Play the press sound
			changeState('info') -- Pass info into changeState
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
			sounds.press:play() -- Play the press sound
			state = 'pause' -- Change the state to pause
		end
	end
	
	-- Sprinting 
	if love.keyboard.isDown('lshift') then -- If the Left Shift key is pressed
		player.speed = 45 -- Change the players speed 
	else -- Otherwise if the Left Shift key is not pressed
		player.speed = 30 -- Keep the players speed at its normal value
	end

	-- Getting to the end game
	if love.keyboard.isDown('f') then -- If the F key is pressed
		if state == 'play' then -- If the game is in the play state
			if complete == true then -- If complete is true
				sounds.theForest:stop() -- Stop the game music
				sounds.press:play() -- Play the press sound
				changeState('end') -- Pass end into changeState
			end
		end
	end
	

	-- Pause Menu
	-- Quitting to menu
	if love.keyboard.isDown('q') then -- If the Q key is pressed
		if state == 'pause' then -- If the game is in the pause state
			sounds.theForest:stop() -- Stop the game music
			sounds.press:play() -- Play the press sound
			gameReset() -- Call the game reset function
			changeState('menu') -- Pass menu into changeState
		end
	end

	-- Resuming the game
	if love.keyboard.isDown('r') then -- If the R key is pressed
		if state == 'pause' then -- If the game is in the pause state
			sounds.press:play() -- Play the press sound
			state = 'play' -- Change the state to play
		end
	end


	-- End Game
	-- Quitting to the main menu
	if love.keyboard.isDown('e') then -- If the E key is pressed 
		if state == 'end' then -- If the game is in the end state
			sounds.bonus:stop() -- Stop the end music
			sounds.press:play() -- Play the press sound
			gameReset() -- Call the game reset function		
			changeState('menu') -- Pass menu into changeState
		end
	end


	-- Info
	-- Starting the game
	if love.keyboard.isDown('return') then -- If enter / return is pressed
		if state == 'info' then -- If the game is in the info state
			sounds.press:play() -- Play the press sound
			changeState('play') -- Pass play into changeState
		end
	end

	-- Going to page 1
	if love.keyboard.isDown('1') then -- If the 1 key is pressed
		if state == 'info' then -- If the game is in the info state
			page = 1 -- Set page to 1
		end
	end

	-- Going to page 2
	if love.keyboard.isDown('2') then -- If the 1 key is pressed
		if state == 'info' then -- If the game is in info state
			page = 2 -- Set page to 1
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



	-- <<<<< GAME PROGRESSION >>>>>

	local cArea = 16 -- The size of the area around the crosses

	-- Checking if the player is near any of the crosses	
	-- Forest Cross
	if player.x > (fc.x - cArea)  and -- Checking if the player is on the right of the left side
	player.x < (fc.x + (cArea * 2)) and -- Checking if the player is also on the left of the right side
	player.y > (fc.y - cArea) and -- Checking if the player is also underneath the top edge
	player.y < (fc.y + (cArea * 2)) then -- Checking if the player is also above the bottom edge
		if fc.claim == false then -- If not already claimed
			sounds.collect:play() -- Play the collect sound
			fc.claim = true -- Update fc.claim to true
		end
	end

	-- Grass Cross
	if player.x > (gc.x - cArea)  and -- Checking if the player is on the right of the left side
	player.x < (gc.x + (cArea * 2)) and -- Checking if the player is also on the left of the right side
	player.y > (gc.y - cArea) and -- Checking if the player is also underneath the top edge
	player.y < (gc.y + (cArea * 2)) then  -- Checking if the player is also above the bottom edge
		if gc.claim == false then -- If not already claimed
			sounds.collect:play() -- Play the collect sound
			gc.claim = true -- Update gc.claim to true
		end
	end

	-- Ice Cross
	if player.x > (ic.x - cArea)  and -- Checking if the player is on the right of the left side
	player.x < (ic.x + (cArea * 2)) and -- Checking if the player is also on the left of the right side
	player.y > (ic.y - cArea) and -- Checking if the player is also underneath the top edge
	player.y < (ic.y + (cArea * 2)) then  -- Checking if the player is also above the bottom edge
		if ic.claim == false then -- If not already claimed
			sounds.collect:play() -- Play the collect sound
			ic.claim = true -- Update ic.claim to true
		end
	end

	-- Rock Cross
	if player.x > (rc.x - cArea)  and -- Checking if the player is on the right of the left side
	player.x < (rc.x + (cArea * 2)) and -- Checking if the player is also on the left of the right side
	player.y > (rc.y - cArea) and -- Checking if the player is also underneath the top edge
	player.y < (rc.y + (cArea * 2)) then  -- Checking if the player is also above the bottom edge
		if rc.claim == false then -- If not already claimed
			sounds.collect:play() -- Play the collect sound
			rc.claim = true -- Update rc.claim to true
		end
	end

	-- Sand Cross
	if player.x > (sc.x - cArea)  and -- Checking if the player is on the right of the left side
	player.x < (sc.x + (cArea * 2)) and -- Checking if the player is also on the left of the right side
	player.y > (sc.y - cArea) and -- Checking if the player is also underneath the top edge
	player.y < (sc.y + (cArea * 2)) then  -- Checking if the player is also above the bottom edge
		if sc.claim == false then -- If not already claimed
			sounds.collect:play() -- Play the collect sound
			sc.claim = true -- Update sc.claim to true
		end
	end

	-- Witch Cross
	if player.x > (wc.x - cArea)  and -- Checking if the player is on the right of the left side
	player.x < (wc.x + (cArea * 2)) and -- Checking if the player is also on the left of the right side
	player.y > (wc.y - cArea) and -- Checking if the player is also underneath the top edge
	player.y < (wc.y + (cArea * 2)) then  -- Checking if the player is also above the bottom edge
		if wc.claim == false then -- If not already claimed
			sounds.collect:play() -- Play the collect sound
			wc.claim = true -- Update wc.claim to true
		end
	end

	-- When all crosses have been claimed
	if fc.claim == true and 
	gc.claim == true and
	ic.claim == true and
	rc.claim == true and
	sc.claim == true and
	wc.claim == true then
		complete = true -- Update complete to true
	end



	-- <<<<< LOADING >>>>>
	
	if loading == true then -- If loading is true 
		if percent >= 300 then -- If percent has reached or passed 300
			loading = false -- Update loading to false
			state = tempState -- Set the current state to the contents of temp state
			
			if state == 'menu' then -- If the game is in the menu state
				sounds.menu:play() -- Play the menu music			 
			end
			
			if state == 'play' then -- If the game is in the play state
				sounds.theForest:play() -- Play the game music
			end

			if state == 'end' then -- If the game is in the end state
				sounds.bonus:play() -- Play the end music
			end
	
			tempState = '' -- Set tempState to empty
			percent = 0 -- Reset percent back to 0
		else
			percent = percent + 1.5 -- Increment percent
		end
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
		love.graphics.setColor(1, 1, 1, 1)
		love.graphics.setFont(title_font) -- Set the font to the title font
		love.graphics.printf('Explorer', 0, window_h / 2 - 146, window_w, 'center') -- Print the title
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
			gameMap:drawLayer(gameMap.layers['ground2']) -- Draw the ground2 layer of the game map
			-- The player is drawn before the next layer of the map so it can appear as if the player can go behind objects			
			player.anim:draw(player.spriteSheet, player.x, player.y, nil, nil, nil, 8, 8) -- Draw the player 
			gameMap:drawLayer(gameMap.layers['buildings and objects']) -- Draw the buildings and objects layer of the game map
	
			if show_WRLD == true then -- If show_WRLD is true
				world:draw() -- Draw the world, which shows the colliders
			end

		cam:detach() --Detach the camera

		-- Everything drawn outside of the camera will stay fixed to the screen and remain unaffected by camera settings.
		-- This is all of the games UI that is constantly affixed to the users screen.
		love.graphics.setColor(0, 0, 0, 0.6) -- Set the colour to black with a lower opacity
		love.graphics.rectangle('fill', window_w - 210, 10, 180, 42) -- Draw this rectangle
		love.graphics.setColor(1, 1, 1, 1) -- Set the colour to white
		love.graphics.setFont(menu_font) -- Set the font to the menu font		
		love.graphics.print('[P] Pause', window_w - 200, 20) -- Print this
		
		if complete == true then -- If complete is true 
			love.graphics.setColor(0, 0, 0, 0.6) -- Set the colour to black with a lower opacity
			love.graphics.rectangle('fill', 10, 10, 240, 42) -- Draw the rectangle
			love.graphics.setColor(1, 1, 1, 1) -- Set the colour to white
			love.graphics.setFont(menu_font) -- Set the font to the menu font
			love.graphics.print('[F] End Game', 20, 20) -- Print this
		end

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
		love.graphics.rectangle('fill', (fc.pos - 32), (window_h - 160), (64 * 12), 128) -- Draw this rectangle
		love.graphics.setColor(0, 0, 0, 1) -- Set the colour to black
		love.graphics.rectangle('line', (fc.pos - 32), (window_h - 160), (64 * 12), 128) -- Draw this rectangle
	
		-- Drawing images
		love.graphics.setColor( 1, 1, 1, 1 ) -- Set the colour to white
		love.graphics.draw( cross, fc.pos, (window_h - 128) ) -- Draw an empty cross at position fc_pos
		love.graphics.draw( cross, gc.pos, (window_h - 128) ) -- Draw an empty cross at position gc_pos
		love.graphics.draw( cross, ic.pos, (window_h - 128) ) -- Draw an empty cross at position ic_pos
		love.graphics.draw( cross, rc.pos, (window_h - 128) ) -- Draw an empty cross at position rc_pos
		love.graphics.draw( cross, sc.pos, (window_h - 128) ) -- Draw an empty cross at position sc_pos
		love.graphics.draw( cross, wc.pos, (window_h - 128) ) -- Draw an empty cross at position wc_pos
	
		-- Checking claims
		-- This section checks to see if the crosses have been claimed.
		-- If they have, their image in the pause menu get updated.

		-- Forest cross
		if fc.claim == true then -- If the forest cross has been claimed
			love.graphics.draw( fc.img, fc.pos, (window_h - 128) ) -- Draw f_cross at position fc_pos
		end
	
		-- Grass cross
		if gc.claim == true then -- If the grass cross has been claimed
			love.graphics.draw( gc.img, gc.pos, (window_h - 128) ) -- Draw g_cross at position gc_pos
		end

		-- Ice cross 
		if ic.claim == true then -- If the ice cross has been claimed
			love.graphics.draw( ic.img, ic.pos, (window_h - 128) ) -- Draw i_cross at position ic_pos
		end

		-- Rock cross
		if rc.claim == true then -- If the rock cross has been claimed
			love.graphics.draw( rc.img, rc.pos, (window_h - 128) ) -- Draw r_cross at position rc_pos
		end
	
		-- Sand cross
		if sc.claim == true then -- If the sand cross has been claimed
			love.graphics.draw( sc.img, sc.pos, (window_h - 128) ) -- Draw s_cross at position sc_pos
		end
	
		-- Witch cross 
		if wc.claim == true then -- If the witch cross has been claimed
			love.graphics.draw( wc.img, wc.pos, (window_h - 128) ) -- Draw w_cross at position wc_pos
		end

	end



	-- <<<<< DRAWING THE END SCREEN >>>>>

	if state == 'end' then -- If the game is in the pause state
		
		-- Background
		love.graphics.setBackgroundColor( 0.251, 0.627, 1, 1 ) -- Set the background colour to this blue

		-- Printing text
		love.graphics.setColor(1, 1, 1, 1) -- Set the colour to white
		love.graphics.setFont(title_font) -- Set the font to the title font
		love.graphics.printf('Explorer', 0, window_h / 2 - 146, window_w, 'center') -- Print this 
		love.graphics.setFont(menu_font) -- Set the font to the menu font
		love.graphics.printf('Thank You For Playing', 0, window_h / 2 - 170, window_w, 'center') -- Print this
		love.graphics.printf('By Zack Langley', 0, window_h / 2 - 22, window_w,'center') -- Print this
		love.graphics.printf('Press [E] To Return To The Main Menu', 0, window_h - 100, window_w, 'center') -- Print this

	end



	-- <<<<< DRAWING THE LOADING SCREEN >>>>>

	if state == 'loading' then -- If the game is in the loading state

		-- Background
		love.graphics.setBackgroundColor( 0.251, 0.627, 1, 1 ) -- Set the background colour to this blue
		
		-- Printing text
		love.graphics.setFont(menu_font_l) -- Set the font to the large menu font
		love.graphics.printf('Loading...', 0, window_h / 2 - 146, window_w, 'center') -- Print this 
	
		-- Drawing shapes
		love.graphics.setColor(0, 0, 0, 1) -- Set the colour to black
		love.graphics.rectangle('line', (((window_w / 2) - (rec_w / 2)) - 4), (((window_h / 2) - (rec_h / 2)) - 4), (rec_w + 8), (rec_h + 8)) -- Draw this
		
		-- Loading bar
		-- The rectangle below has a width of percent, a constantly increasing value while loading is true		
		love.graphics.setColor(1, 1, 1, 1) -- Set the colour to white
		love.graphics.rectangle('fill', ((window_w / 2) - (rec_w / 2)), ((window_h / 2) - (rec_h / 2)), percent, rec_h) -- Draw this rectangele

	end



	-- <<<<< DRAWING THE INFO SCREENS >>>>>

	if state == 'info' then -- If the game is in the info state
	
		if page == 1 then -- If page is equal to 1
			
			-- Background
			love.graphics.setBackgroundColor(0.251, 0.627, 1, 1) -- Set the background colour to this blue
			
			-- Printing text		
			love.graphics.setFont(menu_font) -- Set the font to menu font
			love.graphics.setColor(1, 1, 1, 1) -- Set the colour to white
			love.graphics.printf('Explore the map', 0, 200, window_w, 'center') -- Print this
			love.graphics.printf('Collect the crosses by walking up to them', 0, 300, window_w, 'center') -- Print this	
			love.graphics.printf('Use the pause menu to see how many you have', 0, 400, window_w, 'center')	-- Print this
			love.graphics.printf('[2] Next page', 0, window_h - 50, window_w, 'center') -- Print this

		end

		if page == 2 then -- If page is equal to 2

			-- Background
			love.graphics.setBackgroundColor(0.251, 0.627, 1, 1) -- Set the background colour to this blue 

			-- Printing text
			love.graphics.setFont(menu_font) -- Set the font to menu font
			love.graphics.setColor(1, 1, 1, 1) -- Set the colour to white
			love.graphics.printf('WARNING: Once you return to the menu, all progress will be lost', 0, 200, window_w, 'center') -- Print this
			love.graphics.printf('You cannot save at any point', 0, 300, window_w, 'center') -- Print this	
			love.graphics.printf('Press [ENTER] to continue', 0, 400, window_w, 'center') -- Print this		
			love.graphics.printf('[1] Previous page', 0, window_h - 50, window_w, 'center') -- Print this
			
		end
	
	end

end



-- CHANGING THE STATE
	
-- This function acts as a sort of buffer between states where certain things take place.
-- The function is not always needed when a change of state occurs.
function changeState(newState)

	loading = true -- Update loading to true
	tempState = newState -- Assign the passed in value to tempState
	state = 'loading' -- Set the current state to loading

end



-- RESETING THE GAME

-- This function resets the fundamental variables of the game that becom altered when playing.
-- The function ensures the game is reset whenever the user returns to the menu.
function gameReset()


	player.x = 2704 -- Set the players x positon to 2704
	player.y = 594 -- Set the players y position to 594
	player.collider:destroy() -- Destroy the players collider
	player.collider = world:newBSGRectangleCollider(2704, 594, 14, 14, 2) -- Create a new player collider
	fc.claim = false -- Update fc.claim to false
	gc.claim = false -- Update gc.claim to false
	ic.claim = false -- Update ic.claim to false
	rc.claim = false -- Update rc.claim to false
	sc.claim = false -- Update sc.claim to false
	wc.claim = false -- Update wc.claim to false
	complete = false -- Update complete to false
	show_world = false -- Update show_world to false

end




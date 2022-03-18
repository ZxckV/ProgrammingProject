function love.load()
	
	love.window.setMode(600, 400, {fullscreen=true, vsync=true})

	anim8 = require 'libraries/anim8' -- Requiring Anim8
	love.graphics.setDefaultFilter('nearest', 'nearest') -- Setting a filter so the scaled sprite appears clearly

	player = {} -- Creating a table to store the players variables
	player.x = 600 -- Starting x pos of the player
	player.y = 400 -- Starting y pos of the player
	player.w = 64 -- The width of the player
	player.h = 64 -- The height of the player
	player.speed = 5 -- The amount of pixels the player will move

	player.spriteSheet = love.graphics.newImage('sprites/player.png') -- Loading the sprite sheet for the player
	player.grid = anim8.newGrid( 16, 16, player.spriteSheet:getWidth(), player.spriteSheet:getHeight() ) -- Creating a grid to be used with Anim8

	player.animations = {} -- Creating a new player animation
	player.animations.down = anim8.newAnimation(player.grid('1-3', 1), 0.2) -- Player animation for down
	player.animations.right = anim8.newAnimation(player.grid('1-3', 2), 0.2) -- Player animation for right
	player.animations.left = anim8.newAnimation(player.grid('1-3', 3), 0.2) -- Player animation for left
	player.animations.up = anim8.newAnimation(player.grid('1-3', 4), 0.2) -- Player animation for up

	player.anim = player.animations.down -- Setting the players animation to a random one for the start of the game

end

function love.update(dt)

	local isMoving = false

	if love.keyboard.isDown('w') then
		player.y = player.y - player.speed
		player.anim = player.animations.up -- Update the current animation to up
		isMoving = true -- Update isMoving to true 
	end

	if love.keyboard.isDown('a') then
		player.x = player.x - player.speed
		player.anim = player.animations.left -- Update the current animation to up
		isMoving = true -- Update isMoving to true 
	end
	
	if love.keyboard.isDown('s') then
		player.y = player.y + player.speed
		player.anim = player.animations.down -- Update the current animation to up
		isMoving = true -- Update isMoving to true 
	end

	if love.keyboard.isDown('d') then
		player.x = player.x + player.speed
		player.anim = player.animations.right -- Update the current animation to up
		isMoving = true -- Update isMoving to true 
	end

	-- Included to allow me to quit the program
	if love.keyboard.isDown('escape') then
 		love.event.quit()
 	end

	if isMoving == false then -- If the player is not moving
		player.anim:gotoFrame(1) -- Go to the still frame
	end
	
	player.anim:update(dt)

end

function love.draw()

	love.graphics.setBackgroundColor( 0.2, 0.6, 0.4, 1) 
 	player.anim:draw(player.spriteSheet, player.x, player.y, nil, 4, nil, 8, 8) -- Draw the player 

end


-- Box Draw

	love.graphics.setBackgroundColor(0.2, 0.6, 0.4, 1)
	love.graphics.rectangle('fill', 600, 400, 32, 32)


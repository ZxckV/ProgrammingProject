function love.load()

	love.window.setMode(600, 400, {fullscreen=true, vsync=true})
	window_h = love.graphics.getHeight()
	window_w = love.graphics.getWidth()

	title_font = love.graphics.newFont('fonts/title_font.ttf', 96)
	menu_font = love.graphics.newFont('fonts/menu_font.ttf', 32)
end

function love.update(dt)

	if love.keyboard.isDown('escape') then
		love.event.quit()	
	end
end

function love.draw()

	love.graphics.setBackgroundColor( 0.251, 0.627, 1, 1 )

	love.graphics.setColor(1, 1, 1, 1)
	love.graphics.setFont(title_font) -- Set the font to the title font
	love.graphics.printf('Explorer', 0, window_h / 2 - 146, window_w, 'center') -- Print the title
	love.graphics.setFont(menu_font)
	love.graphics.printf('Thank You For Playing', 0, window_h / 2 - 170, window_w, 'center')
	love.graphics.printf('Press [ESC] To Return To The Main Menu', 0, window_h - 100, window_w, 'center')
end
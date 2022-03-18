function love.load()

	love.window.setMode(600, 400, {fullscreen=true, vsync=true})
	window_h = love.graphics.getHeight()
	window_w = love.graphics.getWidth()

	title_font = love.graphics.newFont('fonts/title_font.ttf', 96)
	menu_font = love.graphics.newFont('fonts/menu_font.ttf', 96)
end

function love.update(dt)

	if love.keyboard.isDown('escape') then
		love.event.quit()	
	end
end

function love.draw()

	love.graphics.setBackgroundColor(1, 1, 1, 1)

	love.graphics.setColor(0, 0, 0, 1)
	love.graphics.setFont(title_font) 
	love.graphics.print('Title Font', 20, window_h / 2 - 150)
	love.graphics.setFont(menu_font)
	love.graphics.print('Menu Font', 20, window_h / 2)

end


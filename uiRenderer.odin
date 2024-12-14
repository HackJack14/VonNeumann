package main

import rl "vendor:raylib"

renderShipButton :: proc(button: ShipButton) {
	alpha: u8 = 0
	if button.hovered {
		alpha = 200
	} else {
		alpha = 150
	}
	rl.DrawRectangleRec(button.bounds, rl.Color{150, 160, 170, alpha})
	width := f32(textures[.STARSHIP].width)
	height := f32(textures[.STARSHIP].height)
	rotation: f32 = 0
	source := rl.Rectangle {
		x      = 0,
		y      = 0,
		width  = width,
		height = height,
	}
	origin := rl.Vector2{width / 2, height / 2}
	dest := rl.Rectangle {
		x      = button.bounds.x + (button.bounds.width / 2),
		y      = button.bounds.y + (button.bounds.height / 2),
		width  = width,
		height = height,
	}
	rotation = 0
	rl.DrawTexturePro(textures[.STARSHIP], source, dest, origin, rotation, rl.WHITE)
}

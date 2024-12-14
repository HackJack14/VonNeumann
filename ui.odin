package main

import rl "vendor:raylib"

ShipButtonCallback :: proc(ship: ^Starship)

ShipButton :: struct {
	ship:     ^Starship,
	bounds:   rl.Rectangle,
	hovered:  bool,
	callback: ShipButtonCallback,
}

updateUI :: proc() {

}

updateShipButton :: proc(button: ^ShipButton) {
	mousePos := rl.GetMousePosition()
	button.hovered = rl.CheckCollisionPointRec(mousePos, button.bounds)

	if button.hovered {
		if rl.IsMouseButtonPressed(rl.MouseButton.LEFT) && (button.callback != nil) {
			button.callback(button.ship)
		}
	}
}

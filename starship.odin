package main

import "core:fmt"
import "core:math"
import rl "vendor:raylib"

shipStarStatus :: enum {
	RESIDING,
	TRAVELLING,
}

Starship :: struct {
	shipSys: ShipSystem,
	shipGal: ShipGalaxy,
}

BaseShip :: struct {
	position: rl.Vector2,
	rotation: f32,
	speed:    f32,
	moving:   bool,
	movingTo: rl.Vector2,
}

ShipSystem :: struct {
	base:    BaseShip,
	visible: bool,
}

ShipGalaxy :: struct {
	base:       BaseShip,
	targetStar: ^StarSystem,
	status:     shipStarStatus,
}

updateShipSystem :: proc(ship: ^Starship, cam: ^Camera, dt: f32) {
	if rl.IsMouseButtonPressed(rl.MouseButton.RIGHT) {
		mousePos := getAbsVec(cam, rl.GetMousePosition())
		ship.shipSys.base.movingTo = mousePos
		rotateToVec(&ship.shipSys.base, ship.shipSys.base.movingTo)
		ship.shipSys.base.moving = true
	}

	if ship.shipSys.base.moving {
		moveToVec(&ship.shipSys.base, ship.shipSys.base.movingTo, dt)
	}

	ship.shipSys.visible = ship.shipGal.targetStar == cam.star
}

updateShipGalaxy :: proc(ship: ^Starship, cam: ^Camera, dt: f32) {
	if rl.IsMouseButtonPressed(rl.MouseButton.RIGHT) {
		mousePos := getAbsVec(cam, rl.GetMousePosition())
		isHovering, star := tryGetMouseHoveredStar(&currChunks, cam)
		if isHovering {
			ship.shipGal.targetStar = star
			ship.shipGal.base.movingTo = star.position
			rotateToVec(&ship.shipGal.base, ship.shipGal.base.movingTo)
			ship.shipGal.base.moving = true
			ship.shipGal.status = .TRAVELLING
		}
	}
	if ship.shipGal.base.moving {
		moveToVec(&ship.shipGal.base, ship.shipGal.base.movingTo, dt)
		if ship.shipGal.status == .TRAVELLING {
			if ship.shipGal.base.position == ship.shipGal.targetStar.position {
				ship.shipGal.status = .RESIDING
			}
		}
	} else {
		ship.shipGal.base.position = ship.shipGal.targetStar.position
	}
}

rotateToVec :: proc(ship: ^BaseShip, vec: rl.Vector2) {
	vecRel := ship.position - vec
	angle := math.atan2(vecRel.x, vecRel.y)
	angle = -angle * 180 / math.PI
	ship.rotation = angle
}

moveToVec :: proc(ship: ^BaseShip, vec: rl.Vector2, dt: f32) {
	speed := ship.speed * dt
	distance := rl.Vector2Distance(ship.position, vec)
	delta := rl.Vector2Normalize(vec - ship.position)
	if speed < distance {
		delta = delta * speed
		ship.position = ship.position + delta
	} else {
		ship.position = vec
		ship.moving = false
	}
}

package main

import "core:fmt"
import "core:math"
import "core:math/linalg"
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
		mousePos := rl.GetMousePosition()
		ship.shipSys.base.movingTo = mousePos
		rotateToVec(&ship.shipSys.base, ship.shipSys.base.movingTo)
		ship.shipSys.base.moving = true
	}

	if ship.shipSys.base.moving {
		moveToVec(&ship.shipSys.base, ship.shipSys.base.movingTo, dt)
	}

	ship.shipSys.visible =
		(ship.shipGal.targetStar == cam.star) && (ship.shipGal.status == .RESIDING)
}

updateShipGalaxy :: proc(ship: ^Starship, cam: ^Camera, dt: f32) {
	if rl.IsMouseButtonPressed(rl.MouseButton.RIGHT) {
		mousePos := getAbsVec(cam, rl.GetMousePosition())
		isHovering, star := tryGetMouseHoveredStar(&currChunks, cam)
		if isHovering && (star != ship.shipGal.targetStar) {
			ship.shipGal.targetStar = star
			ship.shipGal.base.movingTo = star.position
			rotateToVec(&ship.shipGal.base, ship.shipGal.base.movingTo)
			ship.shipGal.base.moving = true
			ship.shipGal.status = .TRAVELLING
			ship.shipSys.base.moving = false
		}
	}
	if ship.shipGal.base.moving {
		moveToVec(&ship.shipGal.base, ship.shipGal.base.movingTo, dt)
		if ship.shipGal.status == .TRAVELLING {
			if ship.shipGal.base.position == ship.shipGal.targetStar.position {
				setShipResidingStar(ship, ship.shipGal.targetStar)
			}
		}
	} else {
		ship.shipGal.base.position = ship.shipGal.targetStar.position
	}
}

rotateToVec :: proc(ship: ^BaseShip, vec: rl.Vector2) {
	vecRel := ship.position - vec
	angle := math.atan2(vecRel.x, vecRel.y)
	angle = -linalg.to_degrees(angle)
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

setShipResidingStar :: proc(ship: ^Starship, star: ^StarSystem) {
	ship.shipGal.status = .RESIDING
	origin := rl.Vector2{f32(screenWidth) / 2, f32(screenHeight) / 2}
	offset := rl.Vector2{0, -450}
	rotatedOffset := rl.Vector2Rotate(offset, linalg.to_radians(ship.shipGal.base.rotation - 180))
	ship.shipSys.base.position = origin + rotatedOffset
	fmt.println(ship.shipGal.base.rotation)
	fmt.println(rotatedOffset)
	fmt.println(ship.shipSys.base.position)
}

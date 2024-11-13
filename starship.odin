package main

import rl "vendor:raylib"
import "core:math"

Starship :: struct {
  position: rl.Vector2,
  rotation: f32,
  speed: f32,
  moving: bool,
  movingTo: rl.Vector2,
}

updateStarship :: proc(ship: ^Starship, cam: ^Camera, dt: f32) {
  if rl.IsMouseButtonPressed(rl.MouseButton.RIGHT) {
    mousePos := rl.GetMousePosition()
    ship.movingTo = getAbsVec(cam, mousePos)
    rotateToVec(ship, ship.movingTo)
    ship.moving = true
  }
  if ship.moving {
    moveToVec(ship, ship.movingTo, dt)
  }
}

rotateToVec :: proc(ship: ^Starship, vec: rl.Vector2) {
  vecRel := ship.position - vec
  angle := math.atan2(vecRel.x, vecRel.y)
  angle = -angle * 180/math.PI
  ship.rotation = angle
}

moveToVec :: proc(ship: ^Starship, vec: rl.Vector2, dt: f32) {
  speed := ship.speed * dt
  distance := rl.Vector2Distance(ship.position, vec)
  delta := rl.Vector2Normalize(vec - ship.position)
  if speed < distance {
    delta = delta * speed
  } else {
    delta = distance
    ship.moving = false
  }
  ship.position = ship.position + delta
}

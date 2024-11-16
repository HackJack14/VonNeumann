package main

import rl "vendor:raylib"
import "core:math"
import "core:fmt"

Starship :: struct {
  position: rl.Vector2,
  rotation: f32,
  speed: f32,
  moving: bool,
  movingTo: rl.Vector2,
  residingStar: ^StarSystem,
  travellingStar: ^StarSystem,
}

updateStarship :: proc(ship: ^Starship, chunks: ^Chunks, cam: ^Camera, dt: f32) {
  if rl.IsKeyPressed(.K) {
    fmt.println(ship.position)
    if ship.travellingStar != nil {
      fmt.println("found travelling star")
      fmt.println(ship.travellingStar.position)
    } else {
      fmt.println("found residing star")
      fmt.println(ship.residingStar.position)
    }
  }
  
  if rl.IsMouseButtonPressed(rl.MouseButton.RIGHT) { 
    mousePos := getAbsVec(cam, rl.GetMousePosition())
    switch cam.mode {
      case .Galaxy:
        isHovering, star := tryGetMouseHoveredStar(chunks, cam)
        if isHovering {
          setResidingStar(ship, nil)
          ship.travellingStar = star
          ship.movingTo = star.position
          rotateToVec(ship, ship.movingTo)
          ship.moving = true
        }
      case .StarSystem:
        ship.movingTo = mousePos
        rotateToVec(ship, ship.movingTo)
        ship.moving = true
    }
  }
  if ship.moving {
    moveToVec(ship, ship.movingTo, dt)
    if ship.travellingStar != nil {
      updateArrivalTravellingStar(ship)
    }
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
    ship.position = ship.position + delta
  } else {
    ship.position = vec
    ship.moving = false
  }
}

updateArrivalTravellingStar :: proc(ship: ^Starship) {
  if ship.position == ship.travellingStar.position {
    setResidingStar(ship, ship.travellingStar)
  }
} 

setResidingStar :: proc(ship: ^Starship, star: ^StarSystem) {
  ship.residingStar = star
  ship.travellingStar = nil
  if star != nil {
    ship.position = star.position
  }
}

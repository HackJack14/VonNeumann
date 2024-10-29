package main

import rl "vendor:raylib"

Camera :: struct {
  bounds: rl.Rectangle,
}

updateCamera :: proc(cam: ^Camera, dt: f32) {
  if rl.IsKeyDown(rl.KeyboardKey.W) {
    cam.bounds.y -= 500 * dt
  }
  if rl.IsKeyDown(rl.KeyboardKey.S) {
    cam.bounds.y += 500 * dt
  }
  if rl.IsKeyDown(rl.KeyboardKey.A) {
    cam.bounds.x -= 500 * dt
  }
  if rl.IsKeyDown(rl.KeyboardKey.D) {
    cam.bounds.x += 500 * dt
  }
}

getRelX :: proc(cam: ^Camera, posX: f32) -> f32 {
  return posX - cam.bounds.x
}

getRelY :: proc(cam: ^Camera, posY: f32) -> f32 {
  return posY - cam.bounds.y
}

getRelVec :: proc(cam: ^Camera, vec: rl.Vector2) -> rl.Vector2 {
  return rl.Vector2{ getRelX(cam, vec.x), getRelY(cam, vec.y) }
}

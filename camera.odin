package main

import rl "vendor:raylib"
import "core:fmt"

CamMode :: enum { Galaxy, StarSystem }
DebugMode :: enum { ChunkOuline }
DebugModes :: bit_set[DebugMode]

CamModeString :: [CamMode]string {
  .Galaxy = "Galaxy",
  .StarSystem = "Star System",
}

Camera :: struct {
  bounds: rl.Rectangle,
  mode: CamMode,
  debugModes: DebugModes,
  star: StarSystem,
}

updateCamera :: proc(cam: ^Camera, dt: f32) {
  switch cam.mode {
  case .Galaxy:
    if rl.IsKeyDown(.W) {
      cam.bounds.y -= 500 * dt
    }
    if rl.IsKeyDown(.S) {
      cam.bounds.y += 500 * dt
    }
    if rl.IsKeyDown(.A) {
      cam.bounds.x -= 500 * dt
    }
    if rl.IsKeyDown(.D) {
      cam.bounds.x += 500 * dt
    }
    
    if rl.IsKeyPressed(.O) {
      if DebugMode.ChunkOuline in cam.debugModes {
        cam.debugModes = cam.debugModes - { .ChunkOuline }
      } else {
        cam.debugModes = cam.debugModes + { .ChunkOuline }
      }
    }
  case .StarSystem:
    
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

getAbsX :: proc(cam: ^Camera, posX: f32) -> f32 {
  return posX + cam.bounds.x
}

getAbsY :: proc(cam: ^Camera, posY: f32) -> f32 {
  return posY + cam.bounds.y
}

getAbsVec :: proc(cam: ^Camera, vec: rl.Vector2) -> rl.Vector2 {
  return rl.Vector2{ getAbsX(cam, vec.x), getAbsY(cam, vec.y) }
}

switchToStarView :: proc(cam: ^Camera, star: ^StarSystem) {
  cam.mode = .StarSystem
  populateStarSystem(star)
  cam.star = star^
}

switchToGalaxyView :: proc(cam: ^Camera) {
  cam.mode = .Galaxy
  deinitStarSystem(&cam.star)
}

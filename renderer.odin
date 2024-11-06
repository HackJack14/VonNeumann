package main

import rl "vendor:raylib"
import "core:strings"

renderStarFromGalaxy :: proc(star: StarSystem, cam: ^Camera) {
  rl.DrawCircleV(getRelVec(cam, star.position), star.radius, star.color)
}

renderStarSystem :: proc(star: StarSystem, cam: ^Camera) {
  // Draw star in the middle of screen
  rl.DrawCircle(screenWidth/2, screenHeight/2, star.radius * 4, star.color)

  //Draw planets around star
  for pl in star.planets {
    rl.DrawCircleV(pl.position, star.radius, rl.RED)
  }
}

renderChunk :: proc(chunk: Chunk, cam: ^Camera) {
  for star in chunk.stars {
    renderStarFromGalaxy(star, cam)
  }
}

renderDebugLines :: proc(ch: Chunk, cam: ^Camera) {
  rl.DrawLineV(getRelVec(cam, topLeft(ch.bounds)), getRelVec(cam, topRight(ch.bounds)), rl.RED);
  rl.DrawLineV(getRelVec(cam, topRight(ch.bounds)), getRelVec(cam, botRight(ch.bounds)), rl.RED);
  rl.DrawLineV(getRelVec(cam, botRight(ch.bounds)), getRelVec(cam, botLeft(ch.bounds)), rl.RED);
  rl.DrawLineV(getRelVec(cam, botLeft(ch.bounds)), getRelVec(cam, topLeft(ch.bounds)), rl.RED);
}

renderCamMode :: proc(cam: ^Camera) {
  camModePrefix : string : "Cam mode: "
  modeLookup := CamModeString
  modeAsString := strings.concatenate({camModePrefix, modeLookup[cam.mode]})
  defer delete(modeAsString)
  modeAsCString := strings.clone_to_cstring(modeAsString)
  defer delete(modeAsCString)
  
  rl.DrawText(modeAsCString, 10, 30, 20, rl.GREEN)
}

clearBackgroundTexture :: proc(texture: ^rl.Texture2D) {
  rl.DrawTexture(texture^, 0, 0, rl.Color{0, 0, 0, 0})
}

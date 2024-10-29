package main

import rl "vendor:raylib"

renderPlanet :: proc(pl: Planet, cam: ^Camera) {
  rl.DrawCircle(i32(getRelX(cam, pl.position.x)), i32(getRelY(cam, pl.position.y)), pl.radius, rl.SKYBLUE)
}

renderChunk :: proc(ch: Chunk, cam: ^Camera) {
  for planet in ch.planets {
    renderPlanet(planet, cam)
  }
}

renderDebugLines :: proc(ch: Chunk, cam: ^Camera) {
  rl.DrawLineV(getRelVec(cam, topLeft(ch.bounds)), getRelVec(cam, topRight(ch.bounds)), rl.RED);
  rl.DrawLineV(getRelVec(cam, topRight(ch.bounds)), getRelVec(cam, botRight(ch.bounds)), rl.RED);
  rl.DrawLineV(getRelVec(cam, botRight(ch.bounds)), getRelVec(cam, botLeft(ch.bounds)), rl.RED);
  rl.DrawLineV(getRelVec(cam, botLeft(ch.bounds)), getRelVec(cam, topLeft(ch.bounds)), rl.RED);
}

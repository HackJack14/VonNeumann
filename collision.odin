package main

import rl "vendor:raylib"

checkCollisionChunk :: proc(star: StarSystem, chunk: Chunk) -> bool {
  for otherStar in chunk.stars {
    collision := rl.CheckCollisionCircles(star.position, star.radius, otherStar.position, otherStar.radius)
    if collision {
      return true
    }
  }
  return false
}

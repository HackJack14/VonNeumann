package main

import rl "vendor:raylib"

//Rectangle helper
topLeft :: proc(rect: rl.Rectangle) -> rl.Vector2 {
  return rl.Vector2{ rect.x, rect.y }
}

topRight :: proc(rect: rl.Rectangle) -> rl.Vector2 {
  return rl.Vector2{ rect.x + rect.width, rect.y }
}

botLeft :: proc(rect: rl.Rectangle) -> rl.Vector2 {
  return rl.Vector2{ rect.x, rect.y + rect.height }
}

botRight :: proc(rect: rl.Rectangle) -> rl.Vector2 {
  return rl.Vector2{ rect.x + rect.width, rect.y + rect.height }
}

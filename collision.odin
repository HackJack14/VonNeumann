package main

import rl "vendor:raylib"

CheckCollisionPointCircleASD :: proc(point: rl.Vector2, center: rl.Vector2, radius: f32) -> bool {
  return rl.Vector2Distance(point, center) < radius
}

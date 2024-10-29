package main

import "core:fmt"
import "core:mem"
import rl "vendor:raylib"

screenWidth: i32 = 1600
screenHeight: i32 = 900

cam := Camera{
	bounds = rl.Rectangle{
		x = -800,
		y = -450,
		width = f32(screenWidth),
		height = f32(screenHeight),
	}
}

currChunks: Chunks

main :: proc() {
	when ODIN_DEBUG {
		track: mem.Tracking_Allocator
		mem.tracking_allocator_init(&track, context.allocator)
		context.allocator = mem.tracking_allocator(&track)

		defer {
			if len(track.allocation_map) > 0 {
				fmt.eprintf("=== %v allocations not freed: ===\n", len(track.allocation_map))
				for _, entry in track.allocation_map {
					fmt.eprintf("- %v bytes @ %v\n", entry.size, entry.location)
				}
			}
			if len(track.bad_free_array) > 0 {
				fmt.eprintf("=== %v incorrect frees: ===\n", len(track.bad_free_array))
				for entry in track.bad_free_array {
					fmt.eprintf("- %p @ %v\n", entry.memory, entry.location)
				}
			}
			mem.tracking_allocator_destroy(&track)
		}
	}

	currChunks = Chunks{
		createChunk(f32(-screenWidth), f32(-screenHeight), 15),
		createChunk(0, f32(-screenHeight), 15),
		createChunk(f32(-screenWidth), 0, 15),
		createChunk(0, 0, 15),
	}
	
	populateChunk(&currChunks.topLeft)
	populateChunk(&currChunks.topRight)
	populateChunk(&currChunks.botLeft)
	populateChunk(&currChunks.botRight)

	rl.InitWindow(screenWidth, screenHeight, "VonNeumann")
	rl.SetWindowState({.VSYNC_HINT})

	for !rl.WindowShouldClose() {	
		update(rl.GetFrameTime())
		render()
	}

	deinitChunk(&currChunks.topLeft)
	deinitChunk(&currChunks.topRight)
	deinitChunk(&currChunks.botLeft)
	deinitChunk(&currChunks.botRight)
}

update :: proc(dt: f32) {
	updateCamera(&cam, rl.GetFrameTime())
	updateChunks(&currChunks, &cam)
}

render :: proc() {
	rl.BeginDrawing()

	rl.ClearBackground(rl.RAYWHITE)
	
	rl.DrawFPS(10, 10)
	renderChunk(currChunks.topLeft, &cam)
	renderChunk(currChunks.topRight, &cam)
	renderChunk(currChunks.botLeft, &cam)
	renderChunk(currChunks.botRight, &cam)
	renderDebugLines(currChunks.topLeft, &cam)
	renderDebugLines(currChunks.topRight, &cam)
	renderDebugLines(currChunks.botLeft, &cam)
	renderDebugLines(currChunks.botRight, &cam)

	rl.EndDrawing()
}

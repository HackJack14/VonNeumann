package main

import "core:fmt"
import "core:mem"
import rl "vendor:raylib"

screenWidth: i32 = 1600
screenHeight: i32 = 900

cam := Camera {
	bounds = rl.Rectangle {
		x = -800,
		y = -450,
		width = f32(screenWidth),
		height = f32(screenHeight),
	},
}

currChunks: Chunks
backgroundTexture: rl.Texture2D

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

	currChunks.named = ChunksNamed {
		createChunk(f32(-screenWidth), f32(-screenHeight), 15),
		createChunk(0, f32(-screenHeight), 15),
		createChunk(f32(-screenWidth), 0, 15),
		createChunk(0, 0, 15),
	}

	for &star in currChunks.index {
		populateChunk(&star)
	}

	rl.InitWindow(screenWidth, screenHeight, "VonNeumann")
	rl.SetWindowState({.VSYNC_HINT})

	backgroundImg := rl.LoadImage("res/background.png")
	rl.ImageResize(&backgroundImg, screenWidth, screenHeight)
	backgroundTexture = rl.LoadTextureFromImage(backgroundImg)
	rl.UnloadImage(backgroundImg)

	for !rl.WindowShouldClose() {
		update(rl.GetFrameTime())
		render()
	}
	rl.CloseWindow()
	
	for &star in currChunks.index {
		deinitChunk(&star)
	}
	rl.UnloadTexture(backgroundTexture)
}

update :: proc(dt: f32) {
	updateCamera(&cam, rl.GetFrameTime())
	updateChunks(&currChunks, &cam)
}

render :: proc() {
	rl.BeginDrawing()

	rl.ClearBackground(rl.WHITE)
	renderBackgroundTexture(&backgroundTexture)

	rl.DrawFPS(10, 10)
	renderCamMode(&cam)

	switch cam.mode {
	case .Galaxy:
		for chunk in currChunks.index {
			renderChunk(chunk, &cam)
			if DebugMode.ChunkOuline in cam.debugModes {
				renderDebugLines(chunk, &cam)
			}
		}
	case .StarSystem:
		renderStarSystem(cam.star, &cam)
	}
	
	rl.EndDrawing()
}

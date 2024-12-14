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
ship: Starship
button: ShipButton

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

	ship = Starship {
		shipGal = ShipGalaxy {
			base = BaseShip{position = rl.Vector2{0, 0}, rotation = 0, speed = 200},
			targetStar = &currChunks.named.topLeft.stars[0],
			status = .RESIDING,
		},
		shipSys = ShipSystem {
			base = BaseShip{position = rl.Vector2{200, 200}, rotation = 0, speed = 200},
		},
	}

	button = ShipButton {
		ship = &ship,
		bounds = rl.Rectangle{x = 0, y = 0, width = 75, height = 75},
		hovered = false,
		callback = proc(ship: ^Starship) {
			cam.bounds.x = ship.shipGal.base.position.x - cam.bounds.width / 2
			cam.bounds.y = ship.shipGal.base.position.y - cam.bounds.height / 2
		},
	}
	button.bounds.x = f32(screenWidth) / 2 - button.bounds.width / 2
	button.bounds.y = f32(screenHeight) - button.bounds.height

	for &star in currChunks.index {
		populateChunk(&star)
	}

	rl.InitWindow(screenWidth, screenHeight, "VonNeumann")
	rl.SetWindowState({.VSYNC_HINT})
	initTextures()
	initShaders()

	for !rl.WindowShouldClose() {
		update(rl.GetFrameTime())
		render()
	}

	switch cam.mode {
	case .Galaxy:
	case .StarSystem:
		delete(cam.star.planets)
	}
	for &chunk in currChunks.index {
		deinitChunk(&chunk)
	}
	deinitTextures()
	deinitShaders()

	rl.CloseWindow()
}

update :: proc(dt: f32) {
	updateCamera(&cam, dt)
	updateChunks(&currChunks, &cam)
	switch cam.mode {
	case .Galaxy:
		updateShipGalaxy(&ship, &cam, dt)
	case .StarSystem:
		updateShipSystem(&ship, &cam, dt)
	}
	updateShipButton(&button)
}

render :: proc() {
	rl.BeginDrawing()

	rl.ClearBackground(rl.WHITE)

	renderCamMode(&cam)

	switch cam.mode {
	case .Galaxy:
		renderBackgroundTexture()
		for chunk in currChunks.index {
			renderChunk(chunk, &cam)
			if DebugMode.ChunkOuline in cam.debugModes {
				renderDebugLines(chunk, &cam)
			}
		}
		renderShipGalaxy(&ship.shipGal, &cam)
	case .StarSystem:
		renderStarBackgroundTexture()
		renderStarSystem(cam.star^, &cam)
		if ship.shipSys.visible {
			renderShipSystem(&ship.shipSys, &cam)
		}
	}
	renderShipButton(button)

	rl.DrawFPS(10, 10)

	rl.EndDrawing()
}

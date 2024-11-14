package main

import rl "vendor:raylib"

Planet :: struct {
	position: rl.Vector2,
	radius:   f32,
}

StarSystem :: struct {
	position: rl.Vector2,
	radius:   f32,
	planets:  []Planet,
	color:    rl.Color,
	ship:     ^Starship,
}

Chunk :: struct {
	bounds:   rl.Rectangle,
	stars:    []StarSystem,
	numStars: u32,
}

Chunks :: struct #raw_union {
	named: ChunksNamed,
	index: ChunksIndex,
}

ChunksNamed :: struct {
	topLeft:  Chunk,
	topRight: Chunk,
	botLeft:  Chunk,
	botRight: Chunk,
}

ChunksIndex :: [4]Chunk

populateStarSystem :: proc(star: ^StarSystem) {
	star.planets = make([]Planet, 5)
	rl.SetRandomSeed(hashPosition(star.position.x, star.position.y))
	for &planet in star.planets {
		planet = Planet {
			position = rl.Vector2 {
				f32(rl.GetRandomValue(0, screenWidth)),
				f32(rl.GetRandomValue(0, screenHeight)),
			},
			radius   = 30,
		}
	}
}

createChunk :: proc(x: f32, y: f32, numStars: u32) -> Chunk {
	return Chunk {
		bounds = rl.Rectangle{x = x, y = y, width = f32(screenWidth), height = f32(screenHeight)},
		numStars = numStars,
		stars = make([]StarSystem, 15),
	}
}

populateChunk :: proc(chunk: ^Chunk) {
	rl.SetRandomSeed(hashPosition(chunk.bounds.x, chunk.bounds.y))
	for &star in chunk.stars {
		star = StarSystem {
			position = rl.Vector2 {
				f32(rl.GetRandomValue(i32(chunk.bounds.x), i32(chunk.bounds.x) + screenWidth)),
				f32(rl.GetRandomValue(i32(chunk.bounds.y), i32(chunk.bounds.y) + screenHeight)),
			},
			radius   = 15,
			planets  = nil,
			color    = randomStarColor(),
			ship     = nil
		}
	}
}

hashPosition :: proc(x: f32, y: f32) -> u32 {
	ux := transmute(u32)x
	uy := transmute(u32)y
	uy64: u64 = u64(uy << 32)
	ux ~= uy
	return (u32)(ux >> 16)
}

randomStarColor :: proc() -> rl.Color {
	switch rl.GetRandomValue(0, 2) {
	case 0:
		return rl.Color { 94, 190, 235, 220 }
	case 1:
		return rl.Color { 245, 117, 12, 220 }
	case 2:
		return rl.Color { 250, 226, 7, 220 }
	}
	return rl.Color { 250, 226, 7, 220 }
}

starMouseHovered :: proc(star: ^StarSystem, cam: ^Camera) -> bool {
	mousePos := rl.GetMousePosition()
	mousePos = getAbsVec(cam, mousePos)
	return rl.CheckCollisionPointCircle(mousePos, star.position, star.radius)
}

deinitChunk :: proc(chunk: ^Chunk) {
	delete(chunk.stars)
}

deinitStarSystem :: proc(star: ^StarSystem) {
	delete(star.planets)
}

updateChunks :: proc(chunks: ^Chunks, cam: ^Camera) {
	if rl.IsMouseButtonPressed(rl.MouseButton.LEFT) {
		for chunk in chunks.index {
			for &star in chunk.stars {
				if starMouseHovered(&star, cam) {
					switchToStarView(cam, &star)
				}
			}
		}
	}
	if rl.IsKeyPressed(.Q) {
		switchToGalaxyView(cam)
	}
	loadNewChunks(&chunks.named, cam)
}

loadNewChunks :: proc(chunks: ^ChunksNamed, cam: ^Camera) {
	// Check if camera is out of bounds horizontally
	if chunks.topLeft.bounds.x > cam.bounds.x {
		deinitChunk(&chunks.topRight)
		deinitChunk(&chunks.botRight)
		chunks.topRight = chunks.topLeft
		chunks.botRight = chunks.botLeft
		chunks.topLeft = createChunk(
			chunks.topRight.bounds.x - chunks.topRight.bounds.width,
			chunks.topRight.bounds.y,
			15,
		)
		chunks.botLeft = createChunk(
			chunks.botRight.bounds.x - chunks.botRight.bounds.width,
			chunks.botRight.bounds.y,
			15,
		)
		populateChunk(&chunks.topLeft)
		populateChunk(&chunks.botLeft)
	} else if chunks.topRight.bounds.x + chunks.topRight.bounds.width <
	   cam.bounds.x + cam.bounds.width {
		deinitChunk(&chunks.topLeft)
		deinitChunk(&chunks.botLeft)
		chunks.topLeft = chunks.topRight
		chunks.botLeft = chunks.botRight
		chunks.topRight = createChunk(
			chunks.topLeft.bounds.x + chunks.topLeft.bounds.width,
			chunks.topLeft.bounds.y,
			15,
		)
		chunks.botRight = createChunk(
			chunks.botLeft.bounds.x + chunks.botLeft.bounds.width,
			chunks.botLeft.bounds.y,
			15,
		)
		populateChunk(&chunks.topRight)
		populateChunk(&chunks.botRight)
	}

	// Check if camera is out of bounds vertically
	if chunks.topLeft.bounds.y > cam.bounds.y {
		deinitChunk(&chunks.botLeft)
		deinitChunk(&chunks.botRight)
		chunks.botLeft = chunks.topLeft
		chunks.botRight = chunks.topRight
		chunks.topLeft = createChunk(
			chunks.botLeft.bounds.x,
			chunks.botLeft.bounds.y - chunks.botLeft.bounds.height,
			15,
		)
		chunks.topRight = createChunk(
			chunks.botRight.bounds.x,
			chunks.botRight.bounds.y - chunks.botRight.bounds.height,
			15,
		)
		populateChunk(&chunks.topLeft)
		populateChunk(&chunks.topRight)
	} else if chunks.botLeft.bounds.y + chunks.botLeft.bounds.height <
	   cam.bounds.y + cam.bounds.height {
		deinitChunk(&chunks.topLeft)
		deinitChunk(&chunks.topRight)
		chunks.topLeft = chunks.botLeft
		chunks.topRight = chunks.botRight
		chunks.botLeft = createChunk(
			chunks.topLeft.bounds.x,
			chunks.topLeft.bounds.y + chunks.topLeft.bounds.height,
			15,
		)
		chunks.botRight = createChunk(
			chunks.topRight.bounds.x,
			chunks.topRight.bounds.y + chunks.topRight.bounds.height,
			15,
		)
		populateChunk(&chunks.botLeft)
		populateChunk(&chunks.botRight)
	}
}


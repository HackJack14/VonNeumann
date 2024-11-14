package main

import "core:strings"
import rl "vendor:raylib"
import gl "vendor:raylib/rlgl"

textureType :: enum {
	BACKGROUND,
	STAR_GALAXY,
	STARSHIP,
}
texturesArray :: [textureType]rl.Texture
textures: texturesArray

shaderType :: enum {
	STAR_GALAXY,
}
shaderArray :: [shaderType]rl.Shader
shaders: shaderArray

initTextures :: proc() {
	//Background texture
	backgroundImg := rl.LoadImage("res/background.png")
	rl.ImageResize(&backgroundImg, screenWidth, screenHeight)
	textures[.BACKGROUND] = rl.LoadTextureFromImage(backgroundImg)
	rl.UnloadImage(backgroundImg)

	//Star texture
	starImg := rl.GenImageColor(60, 60, rl.RED)
	textures[.STAR_GALAXY] = rl.LoadTextureFromImage(starImg)
	rl.UnloadImage(starImg)
	
	//Starship texture
	starshipImg := rl.LoadImage("res/starship.png")
	rl.ImageResize(&starshipImg, 35, 40)
	textures[.STARSHIP] = rl.LoadTextureFromImage(starshipImg)
	rl.UnloadImage(starshipImg)
}

deinitTextures :: proc() {
  for texture in textures {
    rl.UnloadTexture(texture)
  }
}

initShaders :: proc() {
	//Star shader
	shaders[.STAR_GALAXY] = rl.LoadShader(nil, "shader/sunbloom.fs")
}

deinitShaders :: proc() {
	for shader in shaders {
		rl.UnloadShader(shader)
	}
}

renderStarFromGalaxy :: proc(star: StarSystem, starRadiusLocation: i32, cam: ^Camera) {
	starRadius := star.radius
	starRadius = starRadius/f32(textures[.STAR_GALAXY].width)
	rl.SetShaderValue(shaders[.STAR_GALAXY], starRadiusLocation, &starRadius, .FLOAT)
	vec := getRelVec(cam, star.position)
	vec.x -= f32(textures[.STAR_GALAXY].width)/2
	vec.y -= f32(textures[.STAR_GALAXY].height)/2
	rl.DrawTextureV(textures[.STAR_GALAXY], vec, star.color)
	
	if star.ship != nil {
		shipPos := vec
		shipPos.x += f32(textures[.STAR_GALAXY].width)/2
		shipPos.y += f32(textures[.STAR_GALAXY].height)/2
		rl.DrawTextureV(textures[.STARSHIP], shipPos, rl.WHITE)
	}
}

renderStarSystem :: proc(star: StarSystem, cam: ^Camera) {
	// Draw star in the middle of screen
	rl.DrawCircle(screenWidth / 2, screenHeight / 2, star.radius * 4, star.color)

	//Draw planets around star
	for pl in star.planets {
		rl.DrawCircleV(pl.position, star.radius, rl.RED)
	}
}

renderChunk :: proc(chunk: Chunk, cam: ^Camera) {
	starRadiusLocation := rl.GetShaderLocation(shaders[.STAR_GALAXY], "starRadius")
	rl.BeginShaderMode(shaders[.STAR_GALAXY])
	for star in chunk.stars {
		renderStarFromGalaxy(star, starRadiusLocation, cam)
	}
	rl.EndShaderMode()
}

renderDebugLines :: proc(ch: Chunk, cam: ^Camera) {
	rl.DrawLineV(getRelVec(cam, topLeft(ch.bounds)), getRelVec(cam, topRight(ch.bounds)), rl.RED)
	rl.DrawLineV(getRelVec(cam, topRight(ch.bounds)), getRelVec(cam, botRight(ch.bounds)), rl.RED)
	rl.DrawLineV(getRelVec(cam, botRight(ch.bounds)), getRelVec(cam, botLeft(ch.bounds)), rl.RED)
	rl.DrawLineV(getRelVec(cam, botLeft(ch.bounds)), getRelVec(cam, topLeft(ch.bounds)), rl.RED)
}

renderCamMode :: proc(cam: ^Camera) {
	camModePrefix: string : "Cam mode: "
	modeLookup := CamModeString
	modeAsString := strings.concatenate({camModePrefix, modeLookup[cam.mode]})
	defer delete(modeAsString)
	modeAsCString := strings.clone_to_cstring(modeAsString)
	defer delete(modeAsCString)

	rl.DrawText(modeAsCString, 10, 30, 20, rl.GREEN)
}

renderBackgroundTexture :: proc() {
	rl.DrawTexture(textures[.BACKGROUND], 0, 0, rl.WHITE)
}

renderStarShip :: proc(ship: Starship, cam: ^Camera) {
	width := f32(textures[.STARSHIP].width)
	height := f32(textures[.STARSHIP].height)
	source := rl.Rectangle {
		x = 0,
		y = 0,
		width = width,
		height = height,
	}
	dest := rl.Rectangle {
		x = getRelX(cam, ship.position.x),
		y = getRelY(cam, ship.position.y),
		width = width,
		height = height,
	}
	origin := rl.Vector2 {
		width/2,
		height/2,
	}

	rl.DrawLineEx(getRelVec(cam, ship.position), getRelVec(cam, ship.movingTo), 2, rl.WHITE)
	rl.DrawTexturePro(textures[.STARSHIP], source, dest, origin, ship.rotation, rl.WHITE)
}

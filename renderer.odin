package main

import "core:strings"
import rl "vendor:raylib"

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
	rl.ImageResize(&starshipImg, 30, 30)
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
	vec.y -= f32(textures[.STAR_GALAXY].width)/2
	rl.DrawTextureV(textures[.STAR_GALAXY], vec, star.color)
	// rl.DrawCircleV(getRelVec(cam, star.position), star.radius, rl.RED)
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
	rl.DrawTextureEx(textures[.STARSHIP], getRelVec(cam, ship.position), ship.rotation, 1, rl.WHITE)
}

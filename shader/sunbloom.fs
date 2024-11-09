#version 330

in vec2 fragTexCoord;
in vec4 fragColor;

uniform sampler2D texture0;
uniform vec4 colDiffuse;
// Fraction of the texture that the starRadius takes up
uniform float starRadius;

out vec4 finalColor;

void main() 
{
  float dist = distance(vec2(0.5, 0.5), fragTexCoord);
  float alpha = 1 + starRadius - dist;
  if (dist > (starRadius + 0.1)) alpha = 0;
  finalColor = vec4(1.0, 1.0, 1.0, alpha) * fragColor;
}

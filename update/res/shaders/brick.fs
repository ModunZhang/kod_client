#ifdef GL_ES
precision mediump float;
#endif

varying vec4 v_fragmentColor;
varying vec2 v_texCoord;

uniform vec3 BrickColor, MortarColor;
uniform vec2 BrickSize;
uniform vec2 BrickPct;

varying vec2 MCposition;

void main(void)
{
	vec3 color;
	vec2 position, useBrick;
	position = MCposition / BrickSize;
	if (fract(position.y * 0.5) > 0.5) {
		position.x += 0.5;
	}

	position = fract(position);
	useBrick = step(position, BrickPct);
	color = mix(MortarColor, BrickColor, useBrick.x * useBrick.y);
	float is_alpha = step(0.01, texture2D(CC_Texture0, v_texCoord).a);
	gl_FragColor = mix(vec4(0.0), vec4(color, 1.0), is_alpha) * v_fragmentColor;
}

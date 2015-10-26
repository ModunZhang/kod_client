#ifdef GL_ES
precision highp float;
#endif

varying vec4 v_fragmentColor;
varying vec2 v_texCoord;
uniform vec4 size;
uniform sampler2D terrain;
mat4 ranges = mat4(
	vec4(0.0, 0.0, 0.5, 0.5),
	vec4(0.5, 0.0, 1.0, 0.5),
	vec4(0.0, 0.5, 0.5, 1.0),
	vec4(0.5, 0.5, 1.0, 1.0)
);

vec2 getpos( vec4 range, float x, float y ) {
	return vec2(x * (range.z - range.x) + range.x, y * (range.w - range.y) + range.y);
}
void main(void) {
	float x = mod( v_texCoord.x, size.z ) * size.x;
	float y = mod( v_texCoord.y, size.w ) * size.y;
	float X = floor(v_texCoord.x / size.z) / 42.0;
	float Y = floor(v_texCoord.y / size.w) / 42.0;
	vec4 range = ranges[int(floor(texture2D(terrain, vec2(X, Y)).r / 0.24))];
	gl_FragColor = texture2D(CC_Texture0, getpos(range, x, y));
}

#ifdef GL_ES
precision mediump float;
#endif

varying vec4 v_fragmentColor;
varying vec2 v_texCoord;
uniform float unit_count;
uniform float percent;
void main(void)
{
	float origin_y = mod(v_texCoord.y, 1.0 / unit_count) * unit_count;
	origin_y = mod(origin_y + percent, 1.0);
	vec2 new_tex = vec2(v_texCoord.x, origin_y);
	gl_FragColor = texture2D(CC_Texture0, new_tex);
}

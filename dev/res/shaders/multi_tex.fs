#ifdef GL_ES
precision mediump float;
#endif

varying vec4 v_fragmentColor;
varying vec2 v_texCoord;

const float unit = 100.0;

void main(void)
{
	float len = 1.0 / unit;
	float time = CC_Time[1];
	float origin_y = mod(v_texCoord.y, len) / len;
	float real_y = mod(origin_y + fract(time), 1.0);
	vec2 new_tex = vec2(v_texCoord.x, real_y);
	gl_FragColor = texture2D(CC_Texture0, new_tex);
}

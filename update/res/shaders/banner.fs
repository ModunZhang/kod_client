#ifdef GL_ES
precision highp float;
#endif

varying vec4 v_fragmentColor;
varying vec2 v_texCoord;
void main(void)
{
	gl_FragColor = vec4(vec3(0.0), (1.0 - smoothstep(0.5, 1.0, v_texCoord.x / 1.0)) * 0.5);
}

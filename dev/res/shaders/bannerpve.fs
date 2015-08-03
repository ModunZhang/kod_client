#ifdef GL_ES
precision highp float;
#endif

varying vec4 v_fragmentColor;
varying vec2 v_texCoord;
void main(void)
{
	gl_FragColor = vec4(vec3(0.0), smoothstep(0.2, 1.0, 1.0 - abs(v_texCoord.x - 0.5) * 2.0) * 0.6);
}

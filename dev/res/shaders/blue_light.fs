#ifdef GL_ES
precision mediump float;
#endif

varying vec4 v_fragmentColor;
varying vec2 v_texCoord;
void main(void)
{
	float a = smoothstep(0.0, 1.0, (1.0-v_texCoord.y));
	gl_FragColor = vec4(0.4, 0.54901960784314, 0.81960784313725, 0.3) * a;
}






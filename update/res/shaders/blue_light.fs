#ifdef GL_ES
precision mediump float;
#endif

varying vec4 v_fragmentColor;
varying vec2 v_texCoord;
void main(void)
{
	vec4 texColor = texture2D(CC_Texture0, v_texCoord);
	gl_FragColor = texColor;
}






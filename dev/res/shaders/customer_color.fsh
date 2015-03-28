#ifdef GL_ES
precision mediump float;
#endif

varying vec4 v_fragmentColor;
varying vec2 v_texCoord;
uniform vec3 color;

void main(void)
{
	vec4 texColor = texture2D(CC_Texture0, v_texCoord);
	gl_FragColor = vec4(color,1) * texColor.a * v_fragmentColor.a;
}

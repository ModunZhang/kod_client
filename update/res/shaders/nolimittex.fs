#ifdef GL_ES
precision highp float;
#endif

varying vec4 v_fragmentColor;
varying vec2 v_texCoord;
uniform float unit_count;
uniform float unit_len;
void main(void)
{
	float y = mod( v_texCoord.y, unit_len ) * unit_count;
	gl_FragColor = texture2D( CC_Texture0, vec2( v_texCoord.x, y ) );
}

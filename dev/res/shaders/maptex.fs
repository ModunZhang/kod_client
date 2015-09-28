#ifdef GL_ES
precision highp float;
#endif

varying vec4 v_fragmentColor;
varying vec2 v_texCoord;
uniform vec4 size;
uniform sampler2D textures[4];
void main(void)
{
	float X = v_texCoord.x / size.z;

	float x = mod( v_texCoord.x, size.z ) * size.x * floor(X);
	float y = mod( v_texCoord.y, size.w ) * size.y;
	gl_FragColor = texture2D( textures[0], vec2( x, y ) );
}

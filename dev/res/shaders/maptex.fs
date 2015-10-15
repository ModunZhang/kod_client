#ifdef GL_ES
precision highp float;
#endif

varying vec4 v_fragmentColor;
varying vec2 v_texCoord;
uniform vec4 size;
uniform sampler2D textures5;
void main(void)
{
	float x = mod( v_texCoord.x, size.z ) * size.x;
	float y = mod( v_texCoord.y, size.w ) * size.y;
	float X = floor(v_texCoord.x / size.z);
	float Y = floor(v_texCoord.y / size.w);
	gl_FragColor = texture2D(CC_Texture0, vec2( x, y ));
	// float tex = floor(texture2D(textures5, vec2(X/42.0, Y/41.0)).r / 0.24);
	// if ( step(0.5, tex) < 1.0 ) {
	// 	// gl_FragColor = texture2D(textures[1], vec2( x, y ));
	// 	gl_FragColor = vec4(1.0, 0.0, 0.0, 1.0);
	// 	return;
	// } else if ( step(1.1, tex) < 1.0 ) {
	// 	// gl_FragColor = texture2D(textures[0], vec2( x, y ));
	// 	gl_FragColor = vec4(0.0, 1.0, 0.0, 1.0);
	// 	return;
	// } else if ( step(2.1, tex) < 1.0 ) {
	// 	// gl_FragColor = texture2D(textures[0], vec2( x, y ));
	// 	gl_FragColor = vec4(0.0, 0.0, 1.0, 1.0);
	// 	return;
	// } else if ( step(3.1, tex) < 1.0 ) {
	// 	// gl_FragColor = texture2D(textures[0], vec2( x, y ));
	// 	gl_FragColor = vec4(1.0, 1.0, 1.0, 1.0);
	// 	return;
	// }
}

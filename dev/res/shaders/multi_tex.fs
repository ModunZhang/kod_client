#ifdef GL_ES
precision mediump float;
#endif

varying vec4 v_fragmentColor;
varying vec2 v_texCoord;
uniform float unit_count;
uniform float unit_len;
uniform float percent;
uniform float elapse;
void main(void)
{
	gl_FragColor = texture2D( CC_Texture0, vec2( v_texCoord.x, mod( mod( v_texCoord.y, unit_len ) * unit_count + percent, 1.0 ) ) ) * smoothstep(elapse - 0.1, elapse, 1.0 - v_texCoord.y);
}

#ifdef GL_ES
precision mediump float;
#endif

varying vec4 v_fragmentColor;
varying vec2 v_texCoord;
uniform vec4 param;
void main(void) {
    gl_FragColor = texture2D( CC_Texture0, vec2(mod(v_texCoord.x, param.x) * param.z, mod(v_texCoord.y, param.y) * param.w));
}







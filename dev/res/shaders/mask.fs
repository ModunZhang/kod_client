#ifdef GL_ES
precision mediump float;
#endif

varying vec4 v_fragmentColor;
varying vec2 v_texCoord;
uniform vec4 rect;
uniform float enable;
const float EDGE = 0.005;
void main(void) {
	if ( enable < 1.0 ) {
		gl_FragColor = vec4(0.0,0.0,0.0,0.6);
		return ;	
	}
	float a = 0.;
	a = step(v_texCoord.x - rect.x, 0.0) * smoothstep(0.0, EDGE, rect.x - v_texCoord.x);
	a += step(v_texCoord.y - rect.y, 0.0) * smoothstep(0.0, EDGE, rect.y - v_texCoord.y);
	a += step(0.0, v_texCoord.x - rect.x - rect.z) * smoothstep(0.0, EDGE, v_texCoord.x - rect.x - rect.z);
	a += step(0.0, v_texCoord.y - rect.y - rect.w) * smoothstep(0.0, EDGE, v_texCoord.y - rect.y - rect.w);
    gl_FragColor = vec4(0.0,0.0,0.0,min(a, 0.6));
}







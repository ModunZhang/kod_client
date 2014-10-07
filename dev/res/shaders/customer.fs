#ifdef GL_ES
precision mediump float;
#endif

varying vec4 v_fragmentColor;
varying vec2 v_texCoord;

uniform vec2 resolution;

void main(void)
{
	vec4 texColor = texture2D(CC_Texture0, v_texCoord);
	vec2 coord = gl_FragCoord.xy / resolution.xy;
	
	// if(texColor.r > 0.5)
	// {
	// 	gl_FragColor = texColor;
	// }
	// else
	// {
	// 	gl_FragColor = vec4(1.0, 1.0, 0.0, 1.0);
	// }
	gl_FragColor = vec4(0, coord, 1);

	// if(gl_FragCoord.x <= resolution.x / 2.0)
	// {
	// }
	// else
	// {
	// 	gl_FragColor = vec4(0, 1, 0, 1);
	// }
}

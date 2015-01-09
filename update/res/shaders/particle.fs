#ifdef GL_ES
precision mediump float;
#endif

varying vec4 v_fragmentColor;
varying vec2 v_texCoord;

uniform vec2 iResolution;


// float noise( in float x )
// {
// 	return texture2D( CC_Texture0, v_texCoord).x;
// }

void main(void)
{
	vec2 p = gl_FragCoord.xy / iResolution.xy;
	vec2 q = (p - vec2( 0.5, 0.5 )) * 4.0;
	float time = CC_Time[1];

	// vec2 uv = gl_FragCoord.xy / iResolution.xy - 0.5;
	// vec2 q = vec2(uv.x * iResolution.x / iResolution.y, uv.y);
	// float f = 8.0;
	// vec2 m = vec2(mod(time, f) / f - 0.5, sin(time) * 0.5);

	vec2 coord = vec2( q.x, tan(q.x) );
	float d = smoothstep( 0.02, 0.02, distance( q, coord ) );

	vec3 col = vec3( d );

	// float r = 0.2 + 0.1 * cos( atan(q.y, q.x) * 4.0);
	// col *= smoothstep( r, r + 0.01, length( q ) );


	gl_FragColor = vec4( col, 1.0 );
}











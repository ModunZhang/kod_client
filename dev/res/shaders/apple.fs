#ifdef GL_ES
precision mediump float;
#endif

varying vec4 v_fragmentColor; 
varying vec2 v_texCoord; 

uniform vec2 iResolution;



vec2 intersect( in vec3 ro, in vec3 rd )
{
	for ( float t = 0.0; t < 6.0; )
	{
		vec2 h = map( ro + t * td );
	}
}


void main(void)
{
	vec2 q = gl_FragCoord.xy / iResolution.xy;

	vec3 co = vec3( 0.0, 0.0, 0.0 );
	vec3 rd = normalize( vec3( -1.0+2.0*q, -1.5 ) );

	vec2 t = interset( ro, rd );
	vec3 col = vec3(0.0);
	if ( t.y > 0.5 )
	{
		col = vec3(0.5);
	}

	gl_FragColor = vec4(col, 1.0);
}







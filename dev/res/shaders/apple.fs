#ifdef GL_ES
precision mediump float;
#endif

varying vec4 v_fragmentColor; 
varying vec2 v_texCoord; 

uniform vec2 iResolution;


vec2 map( in vec3 p )
{
	vec2 dl = vec2( length(p) - 1.0, 1.0 );
	return dl;
}

vec3 calcNormal( in vec3 p )
{
	vec3 e = vec3(0.001, 0.0, 0.0);
	vec3 n;
	n.x = map( p + e.xyy ).x - map( p - e.xyy ).x;
	n.y = map( p + e.yxy ).x - map( p - e.yxy ).x;
	n.z = map( p + e.yyx ).x - map( p - e.yyx ).x;
	return normalize( n );
}

vec2 intersect( in vec3 ro, in vec3 rd )
{
	for ( float t = 0.0; t < 6.0; )
	{
		vec2 h = map( ro + t * rd );
		if ( h.x < 0.0001 ) return vec2(t,h.y);
		t += h.x;
	}
	return vec2(0.0);
}


void main(void)
{
	vec2 q = gl_FragCoord.xy / iResolution.xy;

	vec3 ro = vec3( 0.0, 0.0, 4.0 );
	vec3 rd = normalize( vec3( (-1.0+2.0*q) * vec2(1.0, 1.2), -1.5 ) );

	vec2 t = intersect( ro, rd );
	vec3 col = vec3(0.0);
	if ( t.y > 0.5 )
	{
		vec3 pos = ro + t.x * rd;
		vec3 nor = calcNormal( pos );
		col = vec3(0.5 + 0.5 * nor.x);
	}

	gl_FragColor = vec4(col, 1.0);
}







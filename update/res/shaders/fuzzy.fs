#ifdef GL_ES
precision mediump float;
#endif


varying vec4 v_fragmentColor; 
varying vec2 v_texCoord; 

uniform vec2 iResolution;

vec4 l(vec2 point, vec2 x_len)
{
	float sx = x_len.x;
	float ex = x_len.y;
	float x = point.x;
	float y = ( x - sx ) * step( sx, x ) * ( 1.0 - step( ex, x ) ) / ( ex - sx ) * 0.5 ;
	y += step(0.0, y) * step( ex, x ) * 0.5;
	return vec4(vec3(1.0 - step(0.002, abs(y - point.y))), 1.0);
}

void main(void)
{
	vec2 point = gl_FragCoord.xy / iResolution - vec2(0.0, 0.5);
	vec2 origin = vec2(0.0, 0.0);
	vec4 color = vec4(vec3(1.0 - step(0.001, abs((origin - point)).y)), 1.0);
	color += vec4(vec3(1.0 - step(0.001, abs((origin - point)).x)), 1.0);
	// float r = 15.0;
	// float l = 0.002;
	// float add_off = sin((point.x + l) * r - CC_Time[1]) / r;
	// float sub_off = sin((point.x - l) * r - CC_Time[1]) / r;
	// float maxy = max(add_off, sub_off);
	// float miny = min(add_off, sub_off);
	// float halfy = (maxy - miny) * 0.5;
	// color += vec4(vec3(1.0 - step(halfy, abs(abs(point.y - (maxy + miny) * 0.5) - halfy))) * 1.0, 1.0);
	// float y = mix( sx, 1.0 - sx, (point.x - sx) / (1.0 - sx) );
 	color += l(point, vec2(0.5, 0.8));
 	color += l(point, vec2(0.1, 0.3));
	gl_FragColor = color;
}







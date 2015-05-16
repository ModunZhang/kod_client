#ifdef GL_ES
precision highp float;
#endif

varying vec2 v_texCoord;
uniform float curTime;


float snoise(vec3 uv, float res) {
	const vec3 s = vec3(1e0, 1e2, 1e3);
	
	uv *= res;
	
	vec3 uv0 = floor(mod(uv, res))*s;
	vec3 uv1 = floor(mod(uv+vec3(1.), res))*s;
	
	vec3 f = fract(uv); f = f*f*(3.0-2.0*f);

	vec4 v = vec4(uv0.x+uv0.y+uv0.z, uv1.x+uv0.y+uv0.z,
		      	  uv0.x+uv1.y+uv0.z, uv1.x+uv1.y+uv0.z);

	vec4 r = fract(sin(v*1e-1)*1e3);
	float r0 = mix(mix(r.x, r.y, f.x), mix(r.z, r.w, f.x), f.y);
	
	r = fract(sin((v + uv1.z - uv0.z)*1e-1)*1e3);
	float r1 = mix(mix(r.x, r.y, f.x), mix(r.z, r.w, f.x), f.y);
	
	return mix(r0, r1, f.z)*2.-1.;
}



#define COLRO_RADIUS 3.0
#define CIRCLE_RADIUS 3.0
#define ROUND3 5.0

void main(void) {
	vec2 p = -.5 + v_texCoord;
	// p.x *= iResolution.x/iResolution.y;
	
	float a = COLRO_RADIUS - (COLRO_RADIUS*length(CIRCLE_RADIUS*p));
	
	vec3 coord = vec3(atan(p.x,p.y)/6.2832+.5, length(p)*.4, .5);
	
	for(int i = 1; i <= 5; i++)
	{
		float power = pow(2.0, float(i));
		a += (1.5 / power) * snoise(coord + vec3(0.,-curTime*.05, curTime*.01), power*16.);
	}

	float g = pow(max(a,0.),2.)*0.4;
	float b = pow(max(a,0.),3.)*0.15;


	gl_FragColor = vec4( a, g, b , step(0.1, min(min(a, g), b)) * 1.0);
}






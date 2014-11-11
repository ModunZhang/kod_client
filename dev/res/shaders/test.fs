#ifdef GL_ES
precision mediump float;
#endif

varying vec4 v_fragmentColor;
varying vec2 v_texCoord;

uniform vec2 iResolution;

void main(void)
{
	// float time = CC_Time[1];
	// float random = CC_Random01[1];
	vec2 tex = vec2(v_texCoord.x, v_texCoord.y);
	gl_FragColor = texture2D(CC_Texture0, tex);
}



// float noise( in vec3 x ) // From iq
// {
//     vec3 p = floor(x);
//     vec3 f = fract(x);
// 	f = f*f*(3.0-2.0*f);
	
// 	vec2 uv = (p.xy+vec2(37.0,17.0)*p.z) + f.xy;
// 	// vec2 rg = texture2D( iChannel1, (uv+0.5)/256.0, -100.0 ).yx;
// 	vec2 rg = vec2(CC_Random01[0], CC_Random01[1]);
// 	return mix( rg.x, rg.y, f.z )*2.0 - 1.0;
// }

// vec2 offset(vec2 p, float phase) {
// 	/*return vec2(sin(p.x*29.2532)+cos(p.y*28.4356), 
// 				cos(p.y*26.9854)+sin(p.x*27.1084))
// 		*0.02*phase;*/
// 	//return vec2(0.05*phase, 0.0);
// 	return vec2(noise(vec3(p.xy*10.0,phase)), noise(vec3(p.yx*10.0,phase)))*0.025;
// }

// void main(void)
// {
// 	float iGlobalTime = CC_Time[1];
// 	vec2 p = gl_FragCoord.xy / iResolution.xy;
// 	//p.x *= iResolution.x / iResolution.y;
// 	float phase = iGlobalTime*0.25;
// 	vec4 s1 = texture2D(CC_Texture0, p + offset(p, fract(phase)), -100.0);
// 	vec4 s2 = texture2D(CC_Texture0, p + offset(p, fract(phase+0.5)), -100.0);
// 	gl_FragColor = mix(s1, s2, abs(mod(phase*2.0, 2.0)-1.0));
// }




// float snoise(vec3 uv, float res)
// {
// 	const vec3 s = vec3(1e0, 1e2, 1e3);
	
// 	uv *= res;
	
// 	vec3 uv0 = floor(mod(uv, res))*s;
// 	vec3 uv1 = floor(mod(uv+vec3(1.), res))*s;
	
// 	vec3 f = fract(uv); f = f*f*(3.0-2.0*f);

// 	vec4 v = vec4(uv0.x+uv0.y+uv0.z, uv1.x+uv0.y+uv0.z,
// 		      	  uv0.x+uv1.y+uv0.z, uv1.x+uv1.y+uv0.z);

// 	vec4 r = fract(sin(v*1e-1)*1e3);
// 	float r0 = mix(mix(r.x, r.y, f.x), mix(r.z, r.w, f.x), f.y);
	
// 	r = fract(sin((v + uv1.z - uv0.z)*1e-1)*1e3);
// 	float r1 = mix(mix(r.x, r.y, f.x), mix(r.z, r.w, f.x), f.y);
	
// 	return mix(r0, r1, f.z)*2.-1.;
// }

// void main(void) 
// {
// 	float iGlobalTime = CC_Time[1];
// 	vec2 p = -.5 + gl_FragCoord.xy / iResolution.xy;
// 	p.x *= iResolution.x/iResolution.y;
	
// 	float color = 3.0 - (3.*length(2.*p));
	
// 	vec3 coord = vec3(atan(p.x,p.y)/6.2832+.5, length(p)*.4, .5);
	
// 	for(int i = 1; i <= 7; i++)
// 	{
// 		float power = pow(2.0, float(i));
// 		color += (1.5 / power) * snoise(coord + vec3(0.,-iGlobalTime*.05, iGlobalTime*.01), power*16.);
// 	}
// 	gl_FragColor = vec4( color, pow(max(color,0.),2.)*0.4, pow(max(color,0.),3.)*0.15 , 1.0);
// }




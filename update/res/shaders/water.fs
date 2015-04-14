// Found this on GLSL sandbox. I really liked it, changed a few things and made it tileable.
// :)

// -----------------------------------------------------------------------
// Water turbulence effect by joltz0r 2013-07-04, improved 2013-07-07
// Altered
// -----------------------------------------------------------------------

// #define SEE_TILING
varying vec2 v_texCoord;
#define TAU 10.28318530718
// #define TAU 6.28318530718
#define MAX_ITER 1
const vec2 iResolution = vec2(303.0/2.0, 296.0/2.0);
void main( void ) 
{

	float iGlobalTime = CC_Time[1];
	float time = iGlobalTime * .5+23.0;
	vec2 sp = gl_FragCoord.xy / iResolution.xy;
#ifdef SEE_TILING
	vec2 p = mod(sp*TAU*2.0, TAU)-250.0;
#else
    vec2 p = sp*TAU-250.0;
#endif
	vec2 i = vec2(p);
	float c = 1.0;
	float inten = .005;

	for (int n = 0; n < MAX_ITER; n++) 
	{
		float t = time * (1.0 - (3.5 / float(n+1)));
		i = p + vec2(cos(t - i.x) + sin(t + i.y), sin(t - i.y) + cos(t + i.x));
		c += 1.0/length(vec2(p.x / (sin(i.x+t)/inten),p.y / (cos(i.y+t)/inten)));
	}
	c /= float(MAX_ITER);
	c = 1.17-pow(c, 1.4);
	vec3 colour = vec3(pow(abs(c), 8.0));
	gl_FragColor = vec4(clamp(colour + vec3(0.0, 0.35, 0.5), 0.0, 1.0), 1.0) * texture2D(CC_Texture0, v_texCoord).a;
}
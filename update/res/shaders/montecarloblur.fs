#ifdef GL_ES
precision mediump float;
#endif

varying vec4 v_fragmentColor;
varying vec2 v_texCoord;


uniform vec2 u_resolution;

#define ITER 8
#define SIZE 16.0

void srand(vec2 a, out float r)
{
	r=sin(dot(a,vec2(1233.224,1743.335)));
}

float rand(inout float r)
{
	r=fract(3712.65*r+0.61432);
	return (r-0.5)*2.0;
}

void main(void)
{
	vec2 uv = gl_FragCoord.xy / u_resolution.xy;
	vec2 p=SIZE/u_resolution*(sin(CC_Time[1]/2.0)+1.0);
	vec4 c=vec4(0.0);
	float r;
	srand(uv, r);
	vec2 rv=vec2(0.0);
	for(int i=0;i<ITER;i++)
	{
		r=fract(3712.65*r+0.61432);
		rv.x = (r-0.5)*2.0;
		r=fract(3712.65*r+0.61432);
		rv.y = (r-0.5)*2.0;
		c+=texture2D(CC_Texture0, uv+rv*p)/float(ITER);
	}
	gl_FragColor = c * v_fragmentColor;
}
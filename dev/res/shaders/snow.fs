// Copyright (c) 2013 Andrew Baldwin (twitter: baldand, www: http://thndl.com)
// License = Attribution-NonCommercial-ShareAlike (http://creativecommons.org/licenses/by-nc-sa/3.0/deed.en_US)

// "Just snow"
// Simple (but not cheap) snow made from multiple parallax layers with randomly positioned 
// flakes and directions. Also includes a DoF effect. Pan around with mouse.
#ifdef GL_ES
precision mediump float;
#endif

varying vec4 v_fragmentColor;
varying vec2 v_texCoord;

#define BLIZZARD // Comment this out for a blizzard

#ifdef LIGHT_SNOW
	#define LAYERS 2
	#define DEPTH .5
	#define WIDTH .01
	#define SPEED .6
#else // BLIZZARD
	#define LAYERS 1
	#define DEPTH .5
	#define WIDTH 0.9
	#define SPEED 0.9
#endif

uniform vec2 u_resolution;
uniform vec2 u_position;


void main(void)
{
	float time = CC_Time[1];
	const mat3 p = mat3(13.323122,23.5112,21.71123,21.1212,28.7312,11.9312,21.8112,14.7212,61.3934);
	vec2 uv = u_position + vec2(1.,u_resolution.y/u_resolution.x)*gl_FragCoord.xy / u_resolution.xy * vec2(10.0);
	vec3 acc = vec3(0.0);
	float dof = 5.*sin(time*.1);
	for (int i=0;i<LAYERS;i++) {
		float fi = float(i);
		float depth = fi*DEPTH;
		vec2 q = uv*(1.+depth);
		q += vec2(q.y*(WIDTH*mod(fi*7.238917,1.)-WIDTH*.5),SPEED*time/(1.+depth*.03));
		vec3 n = vec3(floor(q),31.189+fi);
		vec3 m = floor(n)*.00001 + fract(n);
		vec3 r = fract((31.4159+m)/fract(p*m));
		vec2 s = abs(mod(q,1.)-.5+.9*r.xy-.45);
		s += .01*abs(2.*fract(10.*q.yx)-1.); 
		float d = .6*max(s.x-s.y,s.x+s.y)+max(s.x,s.y)-.01;
		float edge = .005+.05*min(.5*abs(fi-5.-dof),1.);
		float v3 = smoothstep(edge,-edge,d);
		float ra = (r.x/(1.+.02*depth));
		acc += vec3(v3*ra);
	}
	acc *= 3.0;
	vec3 alpha = acc / 3.0;
	float is_alpha = alpha.x + alpha.y + alpha.z;
	gl_FragColor = vec4(acc, is_alpha) * v_fragmentColor;
}
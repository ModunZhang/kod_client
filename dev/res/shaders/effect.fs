//Ether by nimitz (twitter: @stormoid)
#ifdef GL_ES
precision highp float;
#endif

varying vec2 v_texCoord;
uniform float curTime;



mat2 m(float a){float c=cos(a), s=sin(a);return mat2(c,-s,s,c);}
float map(vec3 p){
    p.xz*= m(curTime*0.4);p.xy*= m(curTime*0.3);
    vec3 q = p*2.+curTime*1.;
    return length(p+vec3(sin(curTime*0.7)))*log(length(p)+1.) + sin(q.x+sin(q.z+sin(q.y)))*0.5 - 1.;
}





void main(void) {	
	vec2 p = v_texCoord.xy - vec2(.5,.5);
    vec3 cl = vec3(0.);
    float d = 2.5;
    for(int i=0; i<=10; i++)	{
		vec3 p1 = vec3(0,0,5.) + normalize(vec3(p, -1.))*d;
        float rz = map(p1);
		float f =  clamp((rz - map(p1+.1))*0.5, -.1, 1. );
        vec3 l = vec3(0.1,0.3,.4) + vec3(5., 2.5, 3.)*f;
        cl = cl*l + (1.-smoothstep(0., 2.5, rz))*.7*l;
		d += min(rz, 1.);
	}
    gl_FragColor = vec4(cl, 1.);
}





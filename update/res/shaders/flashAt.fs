#ifdef GL_ES
precision highp float;
#endif

varying vec2 v_texCoord;
uniform float startTime;
uniform float lastTime;
uniform float curTime;
uniform vec4 rect;
uniform vec4 srm;
void main(void)
{
	float angle = radians(srm.z);
	vec2 real = vec2((v_texCoord.x - rect.x) * srm.x, (v_texCoord.y - rect.y) * srm.y);
	real = vec2(real.x * cos(angle) - real.y * sin(angle), real.x * sin(angle) + real.y * cos(angle));
    float f1 = step(real.x - rect.z, 0.0) * step(0.0, real.x);
    float f2 = step(real.y - rect.w, 0.0) * step(0.0, real.y);
    vec4 col = texture2D(CC_Texture0, v_texCoord);
    float ratio = (mod(curTime - startTime, lastTime) / lastTime);
    float mid = step(0.5, ratio);
    float r = smoothstep(0.0, 1.0, ratio * (1.0 - mid) / 0.5) * (1.0 - mid) + smoothstep(0.0, 1.0, (1.0 - ratio) * mid / 0.5) * mid;
    gl_FragColor = vec4(col.rgb * (r * srm.w * f1 * f2 + 1.0) , col.a) ;
}





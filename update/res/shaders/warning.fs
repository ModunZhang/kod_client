#ifdef GL_ES
precision mediump float;
#endif

varying vec4 v_fragmentColor;
varying vec2 v_texCoord;

// 分辨率
uniform vec2 iResolution;
uniform float ratio;
float RADIUS = distance(vec2(0.5), vec2(0.0));
vec2 MIDDLE = vec2(0.5, 0.5);
const float len = 0.4;
const float transit = 0.2;

void main(void)
{
	vec2 point = gl_FragCoord.xy/iResolution.xy - MIDDLE;
	float d = max(abs(point.x) - len, abs(point.y) - len);
	float alpha = smoothstep(0.0, transit, (d / RADIUS)) * ratio;
	gl_FragColor = vec4(1.0 * alpha, 0.14 * alpha, 0.0, alpha);
}

// void main(void)
// {
// 	// 全局时间
// 	float iGlobalTime = CC_Time[1];

// 	float PI = 3.14159265359;
	
// 	float as = iResolution.x / iResolution.y;
	
// 	vec2 coords = gl_FragCoord.xy / iResolution.xy;
// 	vec2 gcoords = vec2(as, 1.0)*(coords - vec2(0.5, 0.5));
	
// 	float r = 0.35*((1.0+sin(iGlobalTime))/2.0)+0.055;
// 	float thickness = 0.08;
	
// 	float fi = mod((atan(gcoords.y, gcoords.x)-((iGlobalTime*4.0)+PI)), PI) / (2.0*PI); // 0..1
			
// 	if (abs(distance(gcoords, vec2(0.0, 0.0)) - r) < thickness*fi) {
// 	  gl_FragColor = vec4(fi, fi, fi, 1.0);	
// 	} else {
// 	  gl_FragColor = vec4(0.0, 0.0, 0.0, 1.0);	
// 	}
	
// }






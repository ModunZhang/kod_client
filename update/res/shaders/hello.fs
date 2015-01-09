#ifdef GL_ES
precision mediump float;
#endif

varying vec4 v_fragmentColor;
varying vec2 v_texCoord;

// 分辨率
uniform vec2 iResolution;

//

const float max_height = 0.5;

float get_height()
{
	vec2 point = gl_FragCoord.xy/iResolution.xy;	
	vec2 mid_point = vec2(0.5);
	float radius = distance(mid_point, vec2(0.0));
	float alpha = 1.0 - distance(point, mid_point) / radius;
	return pow(alpha, 16.0) * max_height;
}
void main(void)
{
	float height = get_height();
	vec3 camera_dir = normalize(vec3(-1.0, 1.0, 0.0));
	// vec2 correct = v_texCoord.xy;
	vec2 correct = v_texCoord.xy + camera_dir.xy * height;
	vec4 texColor = texture2D(CC_Texture0, correct);
	// gl_FragColor = vec4(1.0, 0.0, 0.0, height);
	gl_FragColor = vec4(vec3(-texColor.rgb * height + texColor.rgb), texColor.a);
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






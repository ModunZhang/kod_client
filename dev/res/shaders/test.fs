#ifdef GL_ES
precision mediump float;
#endif


varying vec4 v_fragmentColor; 
varying vec2 v_texCoord; 

uniform vec2 iResolution;

struct ray_
{
	vec3 origin;
	vec3 dir;
};

struct camera_
{
	vec3 eye;
	vec3 front;
	vec3 up;
	float fov;
} camera = camera_(vec3(0.0, 10.0, 10.0), vec3(0.0, 0.0, -1.0), vec3(0.0, 1.0, 0.0), 45.0);

ray_ getRay(vec2 pixel)
{
	vec3 right = cross(camera.front, camera.up);
	vec3 up = cross(right, camera.front);
	float fovScale = tan(camera.fov * 0.5 * 3.1415926535 / 180.0) * 2.0;
	vec2 point = pixel - 0.5;
	vec3 r = right * point.x * fovScale;
	vec3 u = up * point.y * fovScale;
	return ray_(camera.eye, normalize(camera.front + r + u));
}

void main(void)
{
	vec2 point = vec2(gl_FragCoord.x, gl_FragCoord.y) / iResolution;
	// ray_ ray = getRay(point);
	// vec3 center = vec3(0.0, 10.0, -10.0);
	// vec3 norm = vec3(0.0, 0.0, 1.0);
	// float t = dot((center - ray.origin), norm) / dot(norm, ray.dir);
	// if(t > 0.0){
	// 	vec3 intersect = ray.dir * t + ray.origin;
	// 	float dis = distance(intersect, center);
	// 	float e = 1.0 - step(2.0, dis);
	// 	gl_FragColor = vec4(1.0 * e, 1.0, 1.0, 1.0);
	// }else{
	// 	gl_FragColor = vec4(.0);
	// }
	vec4 texColor = texture2D(CC_Texture0, v_texCoord);
	gl_FragColor = texColor;
}







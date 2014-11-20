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
} camera = camera_(vec3(0.0, 0.0, 0.0), vec3(0.0, 0.0, -1.0), vec3(0.0, 1.0, 0.0), 45.0);

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
	vec2 point = gl_FragCoord.xy / iResolution;
	ray_ ray = getRay(point);
	vec3 lightPos = vec3(0.0, 10.0, -55.0);
	vec3 center = vec3(0.0, 0.0, -50.0);
	vec3 norm = vec3(0.0, 1.0, 1.0);
	// vec3 norm = vec3(0.0, 1.0, (sin(CC_Time[1]) + 1.0) * 0.5);
	float radius = 10.0;
	float t = dot((center - ray.origin), norm) / dot(norm, ray.dir);
	if(t > 0.0){
		vec3 intersect = ray.dir * t + ray.origin;

		vec3 lightDir = vec3(0.0, -1.0, 1.0);
		vec3 lightHalf = vec3(camera.eye + lightDir);
		// diffuse
		vec4 ab = vec4(0.5, 0.0, 0.0, 0.0);
		vec4 lc = vec4(1.0, 1.0, 1.0, 0.0);
		float dotd = dot(norm, normalize(lightDir));
		float ndotd = dot(-norm, normalize(lightDir));
		vec4 diffuse = vec4(0.0);
		diffuse += step(0.0, dotd) * dotd * lc;
		// diffuse += step(0.0, ndotd) * ndotd * lc;

		float shiness = 0.5;
		float dots = dot(norm, normalize(lightHalf));
		float ndots = dot(-norm, normalize(lightHalf));
		vec4 specular = vec4(0.0);
		specular += pow(step(0.0, dots) * dots, shiness) * lc;
		// specular += pow(step(0.0, ndots) * ndots, shiness) * lc;

		float dis = distance(intersect, center);
		// vec4 color = vec4((1.0 - vec3(ray.origin.z - intersect.z) / 80.0), 1.0);
		vec4 color = vec4(0.0, 0.0, 0.0, 1.0);
		color += ab;
		color += diffuse;
		color += specular;
		gl_FragColor = color * (1.0 - step(radius, dis));
	}else{
		gl_FragColor = vec4(.0);
	}
}







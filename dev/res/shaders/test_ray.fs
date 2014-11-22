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
};

struct sphere_
{
	vec3 center;
	float radius;
};

struct plane_
{
	vec3 normal;
	vec3 p;
};

struct light_
{
	vec3 pos;
	vec3 dir;
	vec3 color;
} light = light_(vec3(0.0, 0.0, 0.0), vec3(1.0, 0.0, 1.0), vec3(1.0, 1.0, 1.0));


sphere_ sp1= sphere_(vec3(0.0, 10.0, -10.0), 10.0);
sphere_ sp2= sphere_(vec3(10.0, 10.0, -10.0), 10.0);


ray_ getRay(vec2 pixel, camera_ camera)
{
	vec3 right = cross(camera.front, camera.up);
	vec3 up = cross(right, camera.front);
	float fovScale = tan(camera.fov * 0.5 * 3.1415926535 / 180.0) * 2.0;
	vec2 point = pixel;
	vec3 r = right * point.x * fovScale;
	vec3 u = up * point.y * fovScale;
	return ray_(camera.eye, normalize(camera.front + r + u));
}

float intersect_sphere(ray_ ray, sphere_ sphere, inout vec4 color)
{
	vec3 v = ray.origin - sphere.center;
	float a0 = dot(v, v) - sphere.radius * sphere.radius;
	float DdotV = dot(ray.dir, v);

	if (DdotV <= 0.0){
		float discr = DdotV * DdotV - a0;
		if (discr >= 0.0){
			float distance = -DdotV - sqrt(discr);
			vec3 pos = ray.origin + ray.dir * distance;
			vec3 normal = normalize(pos - sphere.center);

			// float depth = 255.0 - min((distance / 20.0) * 255.0, 255.0);
			// color = vec4((normal + 1.0) * 0.5, 1.0);
			// color = vec4(vec3(depth / 255.0), 1.0);

			float NdotL = dot(normal, light.dir);
			vec3 H = normalize(light.dir - ray.dir);
			float NdotH = dot(normal, H);
			vec3 diffuse = vec3(1.0, 0.0, 0.0) * max(NdotL, 0.0);
			vec3 specular = vec3(1.0, 1.0, 1.0) * pow(max(NdotH, 0.0), 32.0);
        	color = vec4(vec3(light.color * (diffuse + specular)), 1.0);
			return 1.0;
		}
	}
	return 0.0;
}
float intersect_plane(ray_ ray, plane_ plane, inout vec4 color)
{
	float t = dot((plane.p - ray.origin), plane.normal) / dot(plane.normal, ray.dir);
	if(t > 0.0){
		vec3 intersect = ray.dir * t + ray.origin;
		if (abs(mod(floor(intersect.x * 0.1) + floor(intersect.z * 0.1), 2.0)) < 1.0){
			color = vec4(vec3(0.0), 1.0);
		}else{
			color = vec4(vec3(1.0), 1.0);
		}
		float reflectiveness = 0.25;
		color *= (1.0 - reflectiveness);
		ray_ r = ray_(intersect, normalize(ray.dir - 2.0 * dot(ray.dir, plane.normal) * plane.normal));

		vec4 c = vec4(0.0);
		float hit = 0.0;
		hit = intersect_sphere(r, sp1, c);
		color += reflectiveness * c * hit;

		// hit = intersect_sphere(r, sp2, c);
		// color += reflectiveness * c * hit;
		return 1.0;
	}
	return 0.0;
}

void main(void)
{
	vec2 point = (2.0*gl_FragCoord.xy - iResolution.xy)/iResolution.x;
	float r = radians(mod(CC_Time[1] * 50.0, 360.0));
	vec3 lookat = vec3(0.0, 10.0, -10.0);
	float looklen = 30.0;
	vec3 position = vec3(lookat.z + cos(r) * looklen, sin(r) * 10.0 + 10.0, lookat.x + sin(r) * looklen - 10.0);
	camera_ camera = camera_(position, normalize(lookat - position), vec3(0.0, 1.0, 0.0), 90.0);
	ray_ ray = getRay(point, camera);
	vec4 result = vec4(0.0);
	vec4 color = vec4(0.0);
	float hit = 0.0;
	hit = intersect_plane(ray, plane_(vec3(0.0, 1.0, 0.0), vec3(0.0, -10.0, 0.0)), color);
	if (hit > 0.0){ result = vec4(0.0);}
	result = color * hit;
	hit = intersect_sphere(ray, sp1, color);
	if (hit > 0.0){ result = vec4(0.0);}
	result += color * hit;
	// hit = intersect_sphere(ray, sp2, color);
	// if (hit > 0.0){ result = vec4(0.0);}
	// result += color * hit;	
	gl_FragColor = result;
}







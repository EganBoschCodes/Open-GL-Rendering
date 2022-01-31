#version 330 core


layout(location = 0) out vec4 color;

in vec4 pos;

uniform float time;
uniform float frames;

uniform vec3 camera_position;
uniform vec3 camera_heading_x;
uniform vec3 camera_heading_y;
uniform vec3 camera_heading_z;

vec3 ray = vec3(0, 0, 500);
vec3 direction = normalize(vec3(pos.x * pos.w, pos.y, -1));

float true_mod(float inp, int modulo) {
	if (inp < 0) {
		inp -= floor(inp/modulo) * modulo;
	}
	return int(inp) % modulo;
}

float double_mod(float inp, int modulo) {
	float inp2 = true_mod(inp, modulo * 2);
	if (inp2 > modulo) {
		inp2 = 2 * modulo - inp2;
	}
	return inp2;
};
	
int grid_size = 200;
vec2 boing_pos = vec2(double_mod(frames * 2, int(pos.w * 1000)) - pos.w * 500, double_mod(frames*0.8, 1000) - 500);
vec2 boing_pos2 = vec2(double_mod(frames * 1.8 + 300, int(pos.w * 1000)) - pos.w * 500, double_mod(frames*2 + 900, 1000) - 500);
vec2 boing_pos3 = vec2(double_mod(frames * 3.24 + 900, int(pos.w * 1000)) - pos.w * 500, double_mod(frames*0.76 + 200, 1000) - 500);

float height_map (vec2 pos) {
	float height_1 = 1000000/(dot(vec2(pos.x - boing_pos.x, pos.y - boing_pos.y), vec2(pos.x - boing_pos.x, pos.y - boing_pos.y)) + 10000);
	float height_2 = 1000000/(dot(vec2(pos.x - boing_pos2.x, pos.y - boing_pos2.y), vec2(pos.x - boing_pos2.x, pos.y - boing_pos2.y)) + 10000);
	float height_3 = 1000000/(dot(vec2(pos.x - boing_pos3.x, pos.y - boing_pos3.y), vec2(pos.x - boing_pos3.x, pos.y - boing_pos3.y)) + 10000);

	return height_1 + height_2 + height_3;
};


float step_size (vec3 pos) {
	return pos.z > 300 ? 50 : 20;
};


void main()
{
	float last_step;
	float last_offset;
	float current_height;
	while (ray.z > (current_height = height_map(ray.xy))) {
		last_offset = ray.z - current_height;
		last_step = step_size(ray);
		ray += last_step * direction;
	}


	//Overstep Correction (Approximate, but it's pretty good)
	ray -= last_step * direction * (current_height - ray.z) / (current_height - ray.z + last_offset);

	//Determining what color tile the point lies on.
	float checker = clamp(float(((true_mod(ray.x - frames/3, grid_size * 2) > grid_size ? 1 : 0) + (true_mod(ray.y - frames/5, grid_size * 2) > grid_size ? 1 : 0)) % 2), 0.1, 1.0);

	//Lighting Things
	vec3 light_source = vec3(-800, 800, 400);
	vec3 lighting_vector = normalize(light_source - ray);

	vec3 surface_dx = vec3(ray.xy, height_map(ray.xy)) - vec3(ray.x + 0.001, ray.y, height_map(vec2(ray.x + 0.001, ray.y)));
	vec3 surface_dy = vec3(ray.xy, height_map(ray.xy)) - vec3(ray.x, ray.y + 0.001, height_map(vec2(ray.x, ray.y + 0.001)));

	vec3 surface_normal = normalize(cross(surface_dx, surface_dy));


	float diffuse_lighting = clamp(dot(surface_normal, lighting_vector), 0, 1) * 0.9 + 0.1;


	vec3 shadow_checker = ray;
	float deepest_incision = -20;
	float num_steps = 0;
	
	shadow_checker += lighting_vector * step_size(shadow_checker);

	while (dot(shadow_checker - light_source, lighting_vector) > 0) {
		shadow_checker += lighting_vector * step_size(shadow_checker);

		deepest_incision = max(height_map(shadow_checker.xy) - shadow_checker.z, deepest_incision);
	}

	


	//vec3 half_vector = normalize(normalize(vec3(0, 0, 500) - ray) + lighting_vector);
	//float specular_lighting = pow(clamp(dot(surface_normal, half_vector), 0, 1), 20);

	color = vec4(vec3(checker) * (deepest_incision < 0 ? diffuse_lighting : 0), 1);
	
	
}

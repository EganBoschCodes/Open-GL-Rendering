#version 330 core


layout(location = 0) out vec4 color;

in vec4 pos;

uniform float time;
uniform float frames;

uniform vec3 camera_position;
uniform vec3 camera_heading_x;
uniform vec3 camera_heading_y;
uniform vec3 camera_heading_z;

const float shadow_intensity = 0.0;

vec3 light_pos = vec3(200, 240, 280);
float box_size = 800;






float modBetween(float a, float mn, float mx) {
	return mod(a-mn,mx-mn) + mn;
}

float union(float a, float b) {
	return min(a,b);
}

float smin(float a, float b, float k) {
  float h = clamp(0.5 + 0.5*(a-b)/k, 0.0, 1.0);
  return mix(a, b, h) - k*h*(1.0-h);
}

float intersection(float a, float b) {
	return max(a, b);
}

float removal(float a, float b) {
	return max(a, -b);
}

float saturate(float a) {
	return clamp((a+1)/2, 0, 1);
}

float bind(vec3 loc) {
	return min(box_size - loc.x, min(loc.x + box_size, min(box_size - loc.y, min(loc.y + box_size, min(box_size - loc.z, loc.z + box_size)))));
}




vec4 solids[3];



float sphereDist(vec3 loc, vec4 sphere) {
	return length(loc - sphere.xyz) - sphere.w;
}

float cubeDist(vec3 loc, vec4 cube) {
	loc -= cube.xyz;
	float maxOut = max(abs(loc.x), max(abs(loc.y), abs(loc.z)));
	return maxOut - cube.w/2;
}

float torusDist(vec3 loc, float[5] torus) {
	loc -= vec3(torus[0], torus[1], torus[2]);
	float lenHoriz = length(loc.xz);
	return length(vec2(lenHoriz - torus[3], loc.y)) - torus[4];
}



float distEstimator(vec3 loc) {
	return union(union(union(torusDist(loc, float[5](0, -40, 100, 50, 20)), smin(sphereDist(loc, solids[2]), sphereDist(loc, solids[2] + vec4(-30,40,-30,10)), 30)), cubeDist(loc, solids[1])), abs(loc.x) < 3000 && abs(loc.z) < 3000 ? loc.y + 400 : 10000);
}


vec3 getColor(vec3 loc) {

	return torusDist(loc, float[5](0, -40, 100, 50, 20)) < 1 ? vec3(1, 0.00, 0.00) : cubeDist(loc, solids[1]) < 1 ? vec3(0.00, 1, 0.02) : loc.y < -200 ? vec3(1, 1.01, 0.99) : vec3(0.00, 0.00, 1);
	//return clamp(loc.x, -box_size+10, box_size-10) == loc.x && clamp(loc.y, -box_size+10, box_size-10) == loc.y && clamp(loc.z, -box_size+10, box_size-10) == loc.z ? vec3(1, 0.5, 0.2) : vec3(0.2, 0.2, 0.2);
}

vec4 getMaterialProperties(vec3 loc) {
	return loc.y < -200 ? vec4(0.4, 0.6, 0.0, 0.4) : vec4(0.8, 0.2, 2.5, 0.7);
}



float normEpsilon = 0.001;

vec3 normAt(vec3 loc) {
	float dx = distEstimator(vec3(loc.x + normEpsilon, loc.yz)) - distEstimator(vec3(loc.x - normEpsilon, loc.yz));
	float dy = distEstimator(vec3(loc.x, loc.y + normEpsilon, loc.z)) - distEstimator(vec3(loc.x, loc.y - normEpsilon, loc.z));
	float dz = distEstimator(vec3(loc.xy, loc.z + normEpsilon)) - distEstimator(vec3(loc.xy, loc.z - normEpsilon));

	return normalize(vec3(dx, dy, dz));
}

float lastSteps = 0;

vec3 ray = camera_position;
vec3 direction = normalize(camera_heading_x*pos.x *pos.w + camera_heading_y*pos.y + camera_heading_z*pos.z);

bool clearBetween(vec3 a, vec3 b) {
	vec3 c = a;
	float de = distEstimator(a);
	vec3 dir = normalize(b - a);
	
	lastSteps = 0;
	while(de > 0.01 && length(b - c) >= length(b - a)) {
		lastSteps++;
		a += dir * de;
		de = distEstimator(a);
	}

	return (de < 0.01) ? length(a - b) < 1 : true;
}

vec3 traceOut() {
	vec3 original = ray;
	ray += direction * 10;
	while(length(ray-original) < 8000) {
		float stepSize = distEstimator(ray);
		if(stepSize <= 0.01) {
			vec3 norm = normAt(ray);
			vec3 light_vec = normalize(ray - light_pos);

			bool clear = clearBetween(light_pos, ray);

			float light_dot = saturate(dot(norm, -light_vec));

			vec3 specular_reflection = reflect(direction, norm);
			float specular_dot = pow(saturate(dot(specular_reflection, -light_vec)), 32);

			direction = normalize(specular_reflection);

			//x: diffuse light, y: ambient light, z: specular light, w: reflectiveness
			vec4 mat_properties = getMaterialProperties(ray);

			vec3 finalColor = getColor(ray);
			finalColor *=  light_dot * mat_properties.x * (clear ? clamp((1-lastSteps/60) * (1-shadow_intensity), 0, 1 - shadow_intensity) + shadow_intensity : shadow_intensity) + mat_properties.y;
			finalColor += vec3(1, 1, 1) * specular_dot * mat_properties.z * (clear ? 1.0 : 0.0);

			return finalColor;
		}
		ray += direction * stepSize;
	}
	return vec3(0, 0, 0);
}

void main()
{
	solids[0] = vec4(0, 0, 180, 60);
	solids[1] = vec4(100, 20, 300, 70);
	solids[2] = vec4(-90, 30, 150, 30);

	vec3 colorOutput = vec3(0, 0, 0);

	float continuedReflectiveness = 1;


	
	vec3 colorData;
	while (continuedReflectiveness > 0.05) {
		vec3 colorData = traceOut();
		float reflectiveness = getMaterialProperties(ray).w;
		if(length(colorData) > 0 && reflectiveness < 1) {
			colorOutput += reflectiveness * continuedReflectiveness * colorData;
			continuedReflectiveness *= 1 - reflectiveness;
		}
		else if(length(colorData) > 0) {
			colorOutput += colorData * continuedReflectiveness;
			break;
		}
		else {
			break;
		}
	}
	colorOutput += colorData * continuedReflectiveness;
	color = vec4(colorOutput, 1);
}
#version 330 core


layout(location = 0) out vec4 color;

in vec4 pos;

uniform float time;

float modBetween(float a, float mn, float mx) {
	return mod(a-mn,mx-mn) + mn;
}

float sphereDist(vec3 loc, vec4 sphere) {
	float dx = modBetween(loc.x - sphere.x - time/5, -200, 200);
	float dy = modBetween(loc.y - sphere.y, -200, 200);
	float dz = modBetween(loc.z - sphere.z, -200, 200);
	return length(vec3(dx, dy, dz))-sphere.w + sin(loc.x/17) * 10 + cos(loc.y/21) * 10;
}

float union(float a, float b) {
	return min(a, b);
}

float intersection(float a, float b) {
	return max(a, b);
}

float removal(float a, float b) {
	return max(a, -b);
}




vec4 spheres[3];

float distEstimator(vec3 loc) {
	return union(sphereDist(loc, spheres[1]), union(sphereDist(loc, spheres[0]), sphereDist(loc, spheres[2])));
}



float normEpsilon = 0.01;

vec3 normAt(vec3 loc) {
	float dx = distEstimator(vec3(loc.x + normEpsilon, loc.yz)) - distEstimator(vec3(loc.x - normEpsilon, loc.yz));
	float dy = distEstimator(vec3(loc.x, loc.y + normEpsilon, loc.z)) - distEstimator(vec3(loc.x, loc.y - normEpsilon, loc.z));
	float dz = distEstimator(vec3(loc.xy, loc.z + normEpsilon)) - distEstimator(vec3(loc.xy, loc.z - normEpsilon));
	return normalize(vec3(dx, dy, dz));
}

vec3 lightVec = normalize(vec3(1.4f, -0.2f, 1.0f));

void main()
{
	spheres[0] = vec4(0, 0, 130, 60);
	spheres[1] = vec4(100, 40, 180, 30);
	spheres[2] = vec4(-90, 10, 150, 30);

	vec3 ray = vec3(0.0, 0.0, -50.0);
	vec3 direction = normalize(vec3(pos.x * pos.w, pos.yz));
	
	float steps = 0;
	while(length(ray) < 8000) {
		steps++;
		float stepSize = distEstimator(ray);
		ray += direction * stepSize;
		if(stepSize <= 1) {
			vec3 norm = normAt(ray);
			float intensity = pow((1-dot(norm, lightVec))/2, 1.5);
			color = vec4(mix(intensity * (norm.x/2+0.5) + 0.2, pos.x, length(ray)/8000), mix(intensity * (norm.y/2+0.5)+ 0.2, pos.y, length(ray)/8000), mix(intensity * (norm.z/2+0.5)+ 0.2, 0.5, length(ray)/8000), 1.0);
			return;
		}
	}
	
	color = vec4(pos.xy, 0.5, 1.0);
}
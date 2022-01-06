#version 400 core


layout(location = 0) out vec4 color;

in vec2 pos;

vec2 TRUEAIM = vec2(-1.2553147581206017, -0.38219839880487066);

vec2 getTruePos() {
	return pos.xy;
}

vec2 sq(vec2 z) {
	return vec2(z.x * z.x - z.y * z.y, z.x * z.y * 2);
}

float mod2(float a) {
	return a - floor(a/2)*2;
}

vec3 HSBtoRGB(vec3 inColor) {
	float C = inColor.z * inColor.y;
	float X = C * (1 - abs(mod(inColor.x * 6, 2) - 1));
	float m = inColor.z - C;

	vec3 RGBPrime;
	if(inColor.x < 1.0/6.0) {
		RGBPrime = vec3(C, X, 0);
	}
	else if(inColor.x < 2.0/6.0) {
		RGBPrime = vec3(X, C, 0);
	}
	else if(inColor.x < 3.0/6.0) {
		RGBPrime = vec3(0, C, X);
	}
	else if(inColor.x < 4.0/6.0) {
		RGBPrime = vec3(0, X, C);
	}
	else if(inColor.x < 5.0/6.0) {
		RGBPrime = vec3(X, 0, C);
	}
	else {
		RGBPrime = vec3(C, 0, X);
	}
	return (vec3(m, m, m) + RGBPrime);
}


void main() {
	vec2 c = getTruePos();
	vec2 z = vec2(c.x, c.y);

	int i;
	double zmag_diff;
	int INTERVALS = 1000;
	for(i = 0; i <= INTERVALS; i++) {
		z = sq(z) + vec2(c.x, c.y);
		if(z.x * z.x + z.y * z.y > 4){
			break;
		}

	}

	if(z.x * z.x + z.y * z.y < 4) {
		color = vec4(HSBtoRGB(vec3(0, 0, 0)), 1);
	}
	else {
		color = vec4(HSBtoRGB(vec3(mod(log(log(INTERVALS - i))*20, 1.0), 1.0, 1.0)), 1.0);

		//color = vec4((pos.x+1)/2, 0, 0, 1);
	}
}
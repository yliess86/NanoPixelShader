#version 430

#ifdef GL_ES
precision mediump float;
#endif

#if defined VERTEX_SHADER

in vec3 in_vert;
in vec2 in_uv;

out vec2 v_uv;

void main() {
    gl_Position = vec4(in_vert.xyz, 1.0);
    v_uv = in_uv;
}

#elif defined FRAGMENT_SHADER

uniform float u_aspect;
uniform float u_time;
uniform vec3  u_date;

in vec2 v_uv;

out vec4 f_color;

#define BIG        10000
#define SCALE      vec2(1.0, 5.0)
#define ORIGIN     vec2(0.0, 0.0)
#define CONF       vec2(0.3, 0.3)
#define ITERATIONS 1000

#define COLOR_1 vec3(0.1, 0.2, 1.0)
#define COLOR_2 vec3(0.2, 0.4, 1.0)
#define COLOR_3 vec3(0.4, 0.6, 1.0)
#define COLOR_4 vec3(0.6, 0.8, 1.0)
#define COLOR_5 vec3(0.8, 1.0, 1.0)
#define COLOR_6 vec3(1.0, 1.0, 1.0)

#define STEP_1 0.5
#define STEP_2 0.6
#define STEP_3 0.7
#define STEP_4 0.8

vec2 rotate(vec2 v, float a) {
	float s = sin(a);
	float c = cos(a);
	mat2 m = mat2(c, -s, s, c);
	return m * v;
}

vec2 complex_mul(in vec2 a, in vec2 b) {
    return vec2(a.x * a.x - a.y * a.y, a.x * a.y + a.y * a.x);
}

float julia_set(in vec2 p) {
    float d = BIG;
    for(int i = 0; i < ITERATIONS; i++) {
        p = complex_mul(p, p) + CONF;
        if(dot(p, p) > (2 * 2))
            d = min(d, i);
    }
    return d / ITERATIONS;
}

vec3 color_ramp(in float v) {
    if(v < STEP_1) return mix(COLOR_1, COLOR_2, v / (STEP_1 - 0.0   )) * v;
    if(v < STEP_2) return mix(COLOR_2, COLOR_3, v / (STEP_2 - STEP_1)) * v;
    if(v < STEP_3) return mix(COLOR_3, COLOR_4, v / (STEP_3 - STEP_2)) * v;
    if(v < STEP_4) return mix(COLOR_4, COLOR_5, v / (STEP_4 - STEP_3)) * v;
    return mix(COLOR_5, COLOR_6, v / (1.0 - STEP_4)) * v;
}

void main() {
    vec2 uv = (v_uv - vec2(0.5)) * vec2(u_aspect, 1.0);
    uv = rotate(uv, 0.1 * sin(u_time));

    float t = 0.5 * sin(0.1 * u_time) + 0.5;
    vec2 xy = (uv - ORIGIN) * ((SCALE.y - SCALE.x) * t + SCALE.x);

    float julia = julia_set(xy);
    float value = clamp(1.0 - julia * 100, 0.0, 1.0);
    
    vec3 color = color_ramp(value);
    f_color = vec4(color, 1.0);
}

#endif
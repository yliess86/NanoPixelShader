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

#define EPS            0.0001
#define PI             3.141592
#define SUN_RADIUS     0.1
#define VENUS_RADIUS   0.020
#define EARTH_RADIUS   0.030
#define MOON_RADIUS    0.010
#define VENUS_ORBITAL  0.2
#define EARTH_ORBITAL  0.4
#define MOON_ORBITAL   0.05
#define PATH_THICKNESS 0.001

struct planet  { vec2 pos; float radius; };
struct orbital { vec2 pos; float radius; };

float op_onion(in float d, in float r) { return abs(d) - r; }

float sdf_circle(in vec2 p, in float r) { return length(p) - r; }
float sdf_planet(in planet p, in orbital o) {
    float sdf_obj = sdf_circle(p.pos, p.radius);
    float sdf_path = op_onion(sdf_circle(o.pos, o.radius), PATH_THICKNESS);
    return min(sdf_obj, sdf_path);
}
float sdf_scene(in vec2 p) {
    float venus_t = PI + 2.0 * PI * u_date.x;
    float earth_t = PI + 2.0 * PI * u_date.y;
    float moon_t  = PI + 2.0 * PI * u_date.z;

    vec2 perturb   = 0.1 * vec2(0.26 * sin(0.21 * u_time), 0.23 * cos(0.27 * u_time));
    vec2 sun_pos   = p         + perturb;
    vec2 venus_pos = sun_pos   + VENUS_ORBITAL * vec2(sin(venus_t), cos(venus_t));
    vec2 earth_pos = sun_pos   + EARTH_ORBITAL * vec2(sin(earth_t), cos(earth_t));
    vec2 moon_pos  = earth_pos + MOON_ORBITAL  * vec2(sin(moon_t ), cos(moon_t ));

    float sdf_sun   = sdf_planet(planet(sun_pos - 0.25 * perturb, SUN_RADIUS  ), orbital(p,         0.0          ));
    float sdf_venus = sdf_planet(planet(venus_pos,                VENUS_RADIUS), orbital(sun_pos,   VENUS_ORBITAL));
    float sdf_earth = sdf_planet(planet(earth_pos,                EARTH_RADIUS), orbital(sun_pos,   EARTH_ORBITAL));
    float sdf_moon  = sdf_planet(planet(moon_pos,                 MOON_RADIUS ), orbital(earth_pos, MOON_ORBITAL ));
    
    return min(min(min(sdf_sun, sdf_venus), sdf_earth), sdf_moon);
}

void main() {
    vec2 uv = (v_uv - vec2(0.5)) * vec2(u_aspect, 1.0);
    float dist = clamp(sdf_scene(uv) * 1000, 0.0 ,1.0);

    f_color = vec4(vec3(dist), 1.0);
}

#endif
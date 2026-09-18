shader_type canvas_item;
render_mode unshaded;

uniform float clock = 0.0;
uniform float camera_left = 0.0;
uniform bool effects_enabled = true;

float hash(vec2 p) {
    return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453);
}

float noise(vec2 p) {
    vec2 cell = floor(p);
    vec2 f = fract(p);
    f = f * f * (3.0 - 2.0 * f);
    return mix(mix(hash(cell), hash(cell + vec2(1.0, 0.0)), f.x),
        mix(hash(cell + vec2(0.0, 1.0)), hash(cell + vec2(1.0)), f.x), f.y);
}

void fragment() {
    vec2 px = UV * vec2(1280.0, 720.0);
    float world_x = px.x + camera_left;
    float n = noise(vec2(world_x * 0.002 - clock * 0.018, UV.y * 7.0));
    float fine = noise(vec2(world_x * 0.006 + clock * 0.028, UV.y * 16.0));
    float fog = smoothstep(0.70, 1.0, UV.y) * (0.13 + n * 0.25 + fine * 0.07);
    fog += exp(-pow((UV.y - 0.59 - n * 0.055) * 25.0, 2.0)) * 0.035;

    // Rain falls only through the four broken roof spans.
    float opening = max(max(step(285.0, world_x) * step(world_x, 485.0),
        step(1365.0, world_x) * step(world_x, 1570.0)),
        max(step(2090.0, world_x) * step(world_x, 2260.0),
        step(2990.0, world_x) * step(world_x, 3200.0)));
    float column = floor((world_x + px.y * 0.12) / 11.0);
    float seed = hash(vec2(column, 3.0));
    float streak_x = fract((world_x + px.y * 0.12) / 11.0);
    float streak_y = fract(px.y / 145.0 - clock * (2.4 + seed) + seed * 8.0);
    float rain = step(0.95, streak_x) * smoothstep(0.77, 0.96, streak_y)
        * step(streak_y, 0.98) * opening * smoothstep(0.06, 0.16, UV.y) * 0.27;

    float edge = pow(abs(UV.x - 0.5) * 2.0, 4.0) * 0.16;
    vec3 color = mix(vec3(0.30, 0.39, 0.44), vec3(0.58, 0.65, 0.73), rain * 2.0);
    float alpha = fog + rain;
    color = mix(color, vec3(0.018, 0.027, 0.05), edge / max(alpha + edge, 0.001));
    COLOR = vec4(color, effects_enabled ? alpha + edge : 0.0);
}

// Threshold shader

vec4 effect(vec4 color, Image tex, vec2 tc, vec2 sc) {
    vec4 pixel = Texel(tex, tc);
    return vec4(pixel.r, pixel.g, pixel.b, 1.0);
}

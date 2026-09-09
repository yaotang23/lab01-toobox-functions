const float TAU = 6.28318530718;

mat2 rotate(float angle) {
    float c = cos(angle), s = sin(angle);
    return mat2(c, s, -s, c);
}

float petalMask(vec2 p, float count, float base, float depth) {
    float r = length(p);
    float angle = r > 0.00001 ? atan(p.y, p.x) : 0.0;
    float radius = base + depth * pow(0.5 + 0.5 * cos(count * angle), 0.7);
    float edge = r - radius;
    float aa = max(2.0 / iResolution.y, min(fwidth(edge), 0.03));
    return 1.0 - smoothstep(-aa, aa, edge);
}

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 p = (2.0 * fragCoord - iResolution.xy) / iResolution.y;
    float r = length(p);
    float angle = r > 0.00001 ? atan(p.y, p.x) : 0.0;
    float breath = 1.0 + 0.045 * sin(1.7 * iTime);
    vec3 color = mix(vec3(0.015, 0.032, 0.075), vec3(0.065, 0.16, 0.21), exp(-2.8 * r * r));
    color += vec3(0.035, 0.13, 0.12) * exp(-15.0 * abs(r - 0.69 * breath));

    // Draw the outer layer first, then composite progressively smaller whorls.
    for (int layer = 0; layer < 4; layer++) {
        float k = float(layer);
        float scale = (1.0 - 0.19 * k) * breath;
        float turn = (mod(k, 2.0) < 0.5 ? 1.0 : -1.0) * 0.10 * iTime + 0.26 * k;
        vec2 q = rotate(turn) * p / scale;
        float mask = petalMask(q, 10.0 + 2.0 * k, 0.28, 0.37);
        float radial = clamp((length(q) - 0.18) / 0.48, 0.0, 1.0);
        vec3 root = mix(vec3(0.14, 0.20, 0.47), vec3(0.62, 0.19, 0.35), k / 3.0);
        vec3 tip = mix(vec3(0.33, 0.91, 0.81), vec3(1.0, 0.71, 0.45), k / 3.0);
        vec3 petalColor = mix(root, tip, smoothstep(0.0, 1.0, radial));
        // Fine radial veins remain attached to their rotating layer.
        float qa = length(q) > 0.00001 ? atan(q.y, q.x) : 0.0;
        float veins = pow(0.5 + 0.5 * cos((10.0 + 2.0 * k) * qa), 5.0);
        petalColor += 0.09 * veins * radial;
        color = mix(color, petalColor, mask);
    }

    float aa = 2.0 / iResolution.y;
    float center = 1.0 - smoothstep(0.095 - aa, 0.095 + aa, r);
    float seeds = 0.5 + 0.5 * sin(140.0 * r - 0.5 * iTime) * cos(16.0 * angle + 13.0 * r);
    vec3 pollen = mix(vec3(0.94, 0.42, 0.16), vec3(1.0, 0.86, 0.46), seeds);
    color = mix(color, pollen, center);

    for (int i = 0; i < 18; i++) {
        float id = float(i);
        float phase = TAU * id / 18.0 + 0.13 * iTime;
        float orbit = 0.79 + 0.045 * sin(iTime + 2.3 * id);
        vec2 position = orbit * vec2(cos(phase), sin(phase));
        float distanceToPollen = length(p - position);
        float dotMask = 1.0 - smoothstep(0.006, 0.006 + aa, distanceToPollen);
        color += vec3(0.65, 0.85, 0.49) * (0.6 * dotMask + 0.12 * exp(-100.0 * distanceToPollen));
    }
    fragColor = vec4(color, 1.0);
}

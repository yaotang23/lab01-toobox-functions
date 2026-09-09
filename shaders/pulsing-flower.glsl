
void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    // Divide both axes by the height so the flower stays circular on wide screens.
    vec2 p = (2.0 * fragCoord - iResolution.xy) / iResolution.y;
    float r = length(p);
    float angle = r > 0.00001 ? atan(p.y, p.x) : 0.0;

    // A periodic envelope grows twenty petals out of a circular silhouette.
    float pulse = pow(0.5 - 0.5 * cos(2.0 * iTime), 3.0);
    float petals = pow(0.5 + 0.5 * cos(20.0 * angle), 1.5);
    float radius = mix(0.50, 0.31 + 0.34 * petals, pulse);
    float edge = r - radius;
    // Bound the derivative near the polar origin, where atan changes rapidly.
    float aa = max(2.0 / iResolution.y, min(fwidth(edge), 0.03));
    float flower = 1.0 - smoothstep(-aa, aa, edge);

    vec3 background = vec3(1.0, 1.0, 0.83);
    vec3 petalColor = vec3(0.90, 0.16, 0.25);
    fragColor = vec4(mix(background, petalColor, flower), 1.0);
}

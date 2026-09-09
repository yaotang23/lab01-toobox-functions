void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 p = (2.0 * fragCoord - iResolution.xy) / iResolution.y;
    float r = length(p);
    float angle = (r > 0.00001 ? atan(p.y, p.x) : 0.0) - 0.8 * iTime;

    // Subtract time from the polar angle to rotate the five-petal silhouette.
    // A slower oscillation changes petal depth and scale, like the reference.
    float bloom = 0.5 - 0.5 * cos(1.4 * iTime);
    float size = 0.85 + 0.20 * sin(0.9 * iTime);
    // Fold the angle into one of five sectors. Two circular arcs meet at
    // each tip, giving the pointed, broad petals of the reference flower.
    const float sector = 6.28318530718 / 5.0;
    float localAngle = mod(angle + 0.5 * sector, sector) - 0.5 * sector;
    float petalRadius = 0.68 * cos(localAngle) - 0.26 * abs(sin(localAngle));
    float radius = size * mix(0.48, petalRadius, bloom);
    float edge = r - radius;
    float aa = max(2.0 / iResolution.y, min(fwidth(edge), 0.03));
    float flower = 1.0 - smoothstep(-aa, aa, edge);

    fragColor = vec4(mix(vec3(1.0, 1.0, 0.83), vec3(0.90, 0.16, 0.25), flower), 1.0);
}

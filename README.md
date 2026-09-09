# Lab 01 — Flower Studies

**Team members: Yao Tang and Zhuoyang Pan**

Three animated flowers made with GLSL toolbox functions: polar coordinates, trigonometry, interpolation, and smooth thresholds. Every solution is a standalone Shadertoy **Image** shader using only `iResolution` and `iTime`; no textures or extra buffers are required.

## Shadertoy demos

| Solution | Shadertoy link |
| --- | --- |
| 1. Pulsing Flower | [NXtGDr](https://www.shadertoy.com/view/NXtGDr) |
| 2. Spinning Flower | [N3dGDr](https://www.shadertoy.com/view/N3dGDr) |
| 3. Moonlit Dahlia (Original Flower) | [fXdGDr](https://www.shadertoy.com/view/fXdGDr) |

![Pulsing Flower, Spinning Flower, and Moonlit Dahlia](screenshots/flower-studies.png)

## Solutions

| Prompt | Shader source | Implementation |
| --- | --- | --- |
| 1. Pulsing Flower | [pulsing-flower.glsl](shaders/pulsing-flower.glsl) | A cosine envelope blends a circle into a twenty-petal radial silhouette. |
| 2. Spinning Flower | [spinning-flower.glsl](shaders/spinning-flower.glsl) | Subtracting time from the polar angle rotates five petals; slower oscillations change their depth and the flower's size. |
| 3. Original Flower | [moonlit-dahlia.glsl](shaders/moonlit-dahlia.glsl) | Four counter-rotating petal layers with turquoise-to-coral gradients, radial veins, a patterned gold center, a breathing halo, and orbiting pollen. |

Coordinates use the canvas height on both axes to preserve the flower's proportions. `smoothstep` and `fwidth` soften silhouette edges at different resolutions. The first two studies use the cream background and red silhouettes of the assignment references.

## References

- [Original lab and submission instructions](ASSIGNMENT.md)
- [Flower Puzzle](https://www.shadertoy.com/view/NsVBzy), linked by the assignment. The shaders here are standalone implementations of the supplied visual prompts.
- [The Book of Shaders: Shapes](https://thebookofshaders.com/07/) for polar shapes and smooth thresholds.

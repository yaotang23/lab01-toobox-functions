// A small Shadertoy-compatible host for reviewing all three Image shaders locally.
const vertexSource = `#version 300 es
void main() {
  vec2 p = vec2(float((gl_VertexID << 1) & 2), float(gl_VertexID & 2));
  gl_Position = vec4(p * 2.0 - 1.0, 0.0, 1.0);
}`;
const views = [];
let paused = false;
let time = 0;
let previous = performance.now();

function compile(gl, type, source) {
  const shader = gl.createShader(type);
  gl.shaderSource(shader, source);
  gl.compileShader(shader);
  if (!gl.getShaderParameter(shader, gl.COMPILE_STATUS)) {
    const message = gl.getShaderInfoLog(shader);
    gl.deleteShader(shader);
    throw new Error(message);
  }
  return shader;
}

async function setup(article) {
  const canvas = article.querySelector('canvas');
  try {
    const response = await fetch(`shaders/${article.dataset.shader}.glsl`);
    if (!response.ok) throw new Error(`Cannot load shader (HTTP ${response.status}).`);
    const source = await response.text();
    const gl = canvas.getContext('webgl2', {alpha: false, antialias: false});
    if (!gl) throw new Error('WebGL 2 is required to preview this flower.');
    const program = gl.createProgram();
    const vertex = compile(gl, gl.VERTEX_SHADER, vertexSource);
    const fragment = compile(gl, gl.FRAGMENT_SHADER, `#version 300 es
precision highp float;
uniform vec3 iResolution;
uniform float iTime;
out vec4 outColor;
${source}
void main() { mainImage(outColor, gl_FragCoord.xy); }
`);
    gl.attachShader(program, vertex);
    gl.attachShader(program, fragment);
    gl.linkProgram(program);
    gl.deleteShader(vertex);
    gl.deleteShader(fragment);
    if (!gl.getProgramParameter(program, gl.LINK_STATUS)) throw new Error(gl.getProgramInfoLog(program));
    gl.useProgram(program);
    views.push({canvas, gl, resolution: gl.getUniformLocation(program, 'iResolution'), clock: gl.getUniformLocation(program, 'iTime')});
    article.querySelector('.copy').addEventListener('click', async () => {
      const status = document.getElementById('copy-status');
      try {
        await navigator.clipboard.writeText(source);
        status.textContent = `${article.querySelector('h2').textContent} copied. Paste into Shadertoy’s Image tab.`;
      } catch {
        status.textContent = 'Clipboard is unavailable. Open “View GLSL” and copy the shader text.';
      }
    });
    article.dataset.ready = 'true';
  } catch (error) {
    const message = article.querySelector('.error');
    message.hidden = false;
    message.textContent = String(error);
    console.error(error);
  }
}

function draw(now) {
  const delta = Math.min((now - previous) / 1000, 0.1);
  previous = now;
  if (!paused) time += delta;
  for (const {canvas, gl, resolution, clock} of views) {
    const pixelRatio = Math.min(window.devicePixelRatio || 1, 2);
    const width = Math.max(1, Math.round(canvas.clientWidth * pixelRatio));
    const height = Math.max(1, Math.round(canvas.clientHeight * pixelRatio));
    if (canvas.width !== width || canvas.height !== height) {
      canvas.width = width;
      canvas.height = height;
    }
    gl.viewport(0, 0, width, height);
    gl.uniform3f(resolution, width, height, 1);
    gl.uniform1f(clock, time);
    gl.drawArrays(gl.TRIANGLES, 0, 3);
  }
  requestAnimationFrame(draw);
}

document.getElementById('pause').addEventListener('click', (event) => {
  paused = !paused;
  event.currentTarget.textContent = paused ? 'Resume' : 'Pause';
  event.currentTarget.setAttribute('aria-pressed', String(paused));
  document.getElementById('playback-status').textContent = paused ? 'Paused' : 'Animating';
});
document.getElementById('restart').addEventListener('click', () => { time = 0; });
await Promise.all([...document.querySelectorAll('article')].map(setup));
previous = performance.now();
requestAnimationFrame(draw);

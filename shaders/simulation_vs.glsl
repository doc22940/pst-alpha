#version 300 es

precision highp float;
precision highp int;

layout(location = 0) in vec4 aPosition;

void main() {
  gl_Position = aPosition;
}

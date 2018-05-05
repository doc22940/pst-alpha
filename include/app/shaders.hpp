#pragma once

const char *shader_source_mesh = R"GLSL(precision highp float;

#ifdef VERTEX_SHADER

layout(location = 0) in vec3 a_position;
layout(location = 1) in vec3 a_normal;
layout(location = 2) in vec2 a_texcoord;

out vec3 v_normal;
out vec2 v_texcoord;

uniform mat4 u_mvp_matrix;
uniform mat3 u_normal_matrix;

void main() {
  v_texcoord = a_texcoord;
  v_normal = normalize(u_normal_matrix * a_normal);

  gl_Position = u_mvp_matrix * vec4(a_position, 1.0);
}

#endif

#ifdef FRAGMENT_SHADER

in vec3 v_normal;
in vec2 v_texcoord;

out vec4 fragColor;

void main() {
  fragColor = vec4(v_texcoord, 0.0, 1.0);
}

#endif
)GLSL";

const char *shader_source_render = R"GLSL(precision highp float;

#ifdef VERTEX_SHADER

uniform sampler2D u_position;
uniform sampler2D u_color;

uniform mat4 u_mvp_matrix;

layout(location = 0) in vec3 a_position;
layout(location = 1) in ivec2 a_texcoord;

out vec4 v_color;

void main() {
  v_color = texelFetch(u_color, a_texcoord, 0);
  gl_Position = u_mvp_matrix * texelFetch(u_position, a_texcoord, 0);
  gl_PointSize = 4.0;
}

#endif

#ifdef FRAGMENT_SHADER
in vec4 v_color;

out vec4 o_fragcolor;

void main() {
  o_fragcolor = v_color;
}
#endif
)GLSL";

const char *shader_source_simulate = R"GLSL(precision highp float;

#ifdef VERTEX_SHADER

layout(location = 0) in vec4 a_position;

void main() {
  gl_Position = a_position;
}

#endif

#ifdef FRAGMENT_SHADER

uniform sampler2D u_position;
uniform sampler2D u_position_prev;
uniform sampler2D u_color;
uniform sampler2D u_color_prev;

uniform ivec2 u_resolution;

layout (std140) uniform SimulationFrameData {
  int u_frame;
  float u_time;
  float u_time_delta;
};

layout(location = 0) out vec4 o_position;
layout(location = 1) out vec4 o_color;

void main() {
  ivec2 texcoord = ivec2(gl_FragCoord);

  vec4 pos = texelFetch(u_position, texcoord, 0);
  vec4 pos_prev = texelFetch(u_position_prev, texcoord, 0);

  vec4 color = texelFetch(u_color, texcoord, 0);
  vec4 color_prev = texelFetch(u_color_prev, texcoord, 0);

  vec3 vel = pos.xyz - pos_prev.xyz;
  vel *= 0.9;

  vec2 uv = gl_FragCoord.xy / vec2(u_resolution);
  o_position = vec4(pos.xyz + vel, 1.0);
  o_color = vec4(sin(u_time + uv.x), cos(u_time + uv.y), 0.0, 1.0);
}

#endif
)GLSL";

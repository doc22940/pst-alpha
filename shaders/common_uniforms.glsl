layout(std140) uniform CommonUniforms {
  mat4 iModelViewProjection;
  mat4 iModelView;
  mat4 iProjection;
  mat4 iInverseModelViewProjection;
  mat4 iInverseModelView;
  mat4 iInverseProjection;

  mat4 iControllerTransform[2]; // [Left, Right]
  vec4 iControllerVelocity[2];
  vec4 iControllerButtons[2];

  ivec2 iSize;

  float iTime;
  float iTimeDelta;
  int iFrame;
};

uniform sampler2D iFragData[6];
uniform ivec2 iResolution;

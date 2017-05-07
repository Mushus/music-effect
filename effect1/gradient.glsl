varying vec4 vertTexCoord;
uniform float light;
uniform vec3 deepColor;
uniform vec3 liteColor;

void main()
{
  vec2 p = vec2(vertTexCoord.x, vertTexCoord.y);
  vec2 o = vec2(0.5);
  float len = length(o - p);
  float c = len * len * light;
  vec4 color = vec4(liteColor * c + deepColor * (1 - c), 1f);
  gl_FragColor = color;
}

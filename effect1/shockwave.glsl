uniform sampler2D texture;
uniform float ratio;
uniform float size;
uniform vec2 opos;
varying vec4 vertTexCoord;

void main()
{
  vec2 p = vec2((vertTexCoord.x - 0.5) * ratio + 0.5, vertTexCoord.y);
  vec2 target;
  float len = length(opos - p) / size;
  target.x = p.x + (opos.x - p.x) / pow(len - 0.1, 3) * 0.001;
  target.y = p.y + (opos.y - p.y) / pow(len - 0.1, 3) * 0.001;
  target.x = (target.x - 0.5) / ratio + 0.5;
  vec4 color = texture2D(texture, target);
  float c = clamp(len - 0.19, 0f, 0.001f) * 1000;
  gl_FragColor = vec4(color.rgb * c, 1);
}

//
// Shader.fsh
//

// UNIFORMS
uniform sampler2D uSampler0;
uniform sampler2D uSampler1;

// Varyings
varying lowp vec4 vColor;
varying lowp vec2 vTextureCoord0;
varying lowp vec2 vTextureCoord1;

void main() {
    // 从纹理单元 0 和 1 中获取采样颜色
    lowp vec4 color0 = texture2D(uSampler0, vTextureCoord0);
    lowp vec4 color1 = texture2D(uSampler1, vTextureCoord1);

    // 使用纹理颜色的 alpha 分量混合两个采样颜色，然后乘以浅色
    gl_FragColor = mix(color0, color1, color1.a) * vColor;
}

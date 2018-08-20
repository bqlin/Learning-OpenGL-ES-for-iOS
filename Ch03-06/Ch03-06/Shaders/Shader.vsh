//
// Shader.vsh
//

// VERTEX ATTRIBUTES
attribute vec4 aPosition;
attribute vec3 aNormal;
attribute vec2 aTextureCoord0;
attribute vec2 aTextureCoord1;

// Varyings
varying lowp vec4 vColor;
varying lowp vec2 vTextureCoord0;
varying lowp vec2 vTextureCoord1;

// UNIFORMS
uniform mat4 uModelViewProjectionMatrix;
uniform mat3 uNormalMatrix;

void main() {
	// 收集浅色所需的信息
	vec3 eyeNormal = normalize(uNormalMatrix * aNormal);
	vec3 lightPosition = vec3(0, 0, 1);
	vec4 diffuseColor = vec4(.7, .7, .7, 1);

	// 计算片元浅色
	float nDotVP = max(.0, dot(eyeNormal, lightPosition)); // 类型不对都不会编译通过！
	vColor = vec4((diffuseColor * nDotVP).xyz, diffuseColor.a);

	// 传递两组纹理坐标给为修改的片元着色器
	vTextureCoord0 = aTextureCoord0.st;
	vTextureCoord1 = aTextureCoord1.st;

	// 通过组合 模型-视图-投影，转换传入的顶点位置，以在“颜色缓冲区”中生成片元位置
	gl_Position = uModelViewProjectionMatrix * aPosition;
}
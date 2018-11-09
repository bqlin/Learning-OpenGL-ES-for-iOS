// 纹理
#define MAX_TEXURES 2
#define MAX_TEX_COORDS 2

// 传入的 uniform 值
uniform highp mat4 u_modelviewMatrix;
uniform highp mat4 u_mvpMatrix;
uniform highp mat3 u_normalMatrix;

uniform highp mat4 u_tex0Matrix;
uniform highp mat4 u_tex1Matrix;

uniform sampler2D u_unit2d[MAX_TEXURES];

uniform lowp float u_tex0Enabled;
uniform lowp float u_tex1Enabled;

uniform lowp vec4 u_globalAmbient;

uniform highp vec3 u_light0EyePos;
uniform lowp vec3 u_light0NormalEyeDirection;
uniform lowp vec4 u_light0Diffuse;
uniform lowp vec4 u_light0Ambient;
uniform highp float u_light0Cutoff;
uniform highp float u_light0Exponent;

uniform highp vec3 u_light1EyePos;
uniform lowp vec3 u_light1NormalEyeDirection;
uniform lowp vec4 u_light1Diffuse;
uniform lowp vec4 u_light1Ambient;
uniform highp float u_light1Cutoff;
uniform highp float u_light1Exponent;

uniform highp vec3 u_light2EyePos;
uniform lowp vec4 u_light2Diffuse;

// 变量
varying highp vec2 v_texCoord[MAX_TEX_COORDS];
varying lowp vec3 v_normal;

varying lowp vec3 v_vertexToLight0;
varying lowp vec4 v_diffuseColor0;

varying lowp vec3 v_vertexToLight1;
varying lowp vec4 v_diffuseColor1;

varying lowp vec4 v_diffuseColor2;

void main() {
	// 纹理0中的颜色
	lowp vec2 texCoords = v_texCoord[0];
	lowp vec4 texCoordVec4 = vec4(texCoords.s, texCoords.t, 0, 1);
	texCoordVec4 = u_tex0Matrix * texCoordVec4;
	texCoords = texCoordVec4.st;
	lowp vec4 texColor0 = texture2D(u_unit2d[0], texCoords);
	texColor0 = u_tex0Enabled * texColor0;

	// 纹理1中的颜色
	texCoords = v_texCoord[1];
	texCoordVec4 = vec4(texCoords.s, texCoords.t, 0, 1);
	texCoordVec4 = u_tex1Matrix * texCoordVec4;
	texCoords = texCoordVec4.st;
	lowp vec4 texColor1 = texture2D(u_unit2d[1], texCoords);
	texColor1 = u_tex1Enabled * texColor1;

	// 组合纹理中的颜色
	lowp vec4 combinedTexColor;
	combinedTexColor.rgb = (texColor0.rgb * (1.0 - texColor1.a)) + (texColor1.rgb * texColor1.a);
	combinedTexColor.rgb += (1.0 - max(u_tex0Enabled, u_tex1Enabled)) * vec3(1, 1, 1);
	combinedTexColor.a = max(texColor0.a, texColor1.a);

	lowp vec3 renormalizedNormal = normalize(v_normal);

	// 光照0
	highp float nDotL = max(dot(renormalizedNormal, normalize(v_vertexToLight0)), .0);
	lowp vec3 vertexDir = -v_vertexToLight0;
	lowp float cosCutoff = cos(u_light0Cutoff);
	lowp float vertexDirDotSpotDir = max(dot(vertexDir, u_light0NormalEyeDirection), .0);
	highp float spotFactor = .0;

	if (vertexDirDotSpotDir >= cosCutoff) {
		spotFactor = pow(vertexDirDotSpotDir, u_light0Exponent);
	}

	lowp vec4 diffusecolor = spotFactor * nDotL * v_diffuseColor0;

	// 光照1
	nDotL = max(dot(renormalizedNormal, normalize(v_vertexToLight1)), .0);
	vertexDir = -v_vertexToLight1;
	cosCutoff = cos(u_light1Cutoff);
	vertexDirDotSpotDir = max(dot(vertexDir, u_light1NormalEyeDirection), .0);
	spotFactor = .0;

	if (vertexDirDotSpotDir >= cosCutoff) {
		spotFactor = pow(vertexDirDotSpotDir, u_light1Exponent);
	}
	diffusecolor += (spotFactor * nDotL * v_diffuseColor1);

	// 光照2
	diffusecolor += v_diffuseColor2;

	// 混合光照和纹理
	gl_FragColor.rgb = (diffusecolor.rgb + u_globalAmbient.rgb) * combinedTexColor.rgb;
	gl_FragColor.a = combinedTexColor.a;
}

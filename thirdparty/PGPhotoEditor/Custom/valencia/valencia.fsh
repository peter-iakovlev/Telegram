uniform sampler2D inputImageTexture2; //map
uniform sampler2D inputImageTexture3; //gradientmap

mat3 saturateMatrix = mat3(
    1.1402,
    -0.0598,
    -0.061,
    -0.1174,
    1.0826,
    -0.1186,
    -0.0228,
    -0.0228,
    1.1772);

vec3 lumaCoeffs = vec3(.3, .59, .11);

vec4 filter(vec4 color)
{

    vec3 texel = color.rgb;

    texel = vec3(
        texture2D(inputImageTexture2, vec2(texel.r, .1666666)).r,
        texture2D(inputImageTexture2, vec2(texel.g, .5)).g,
        texture2D(inputImageTexture2, vec2(texel.b, .8333333)).b
    );

    texel = saturateMatrix * texel;
    float luma = dot(lumaCoeffs, texel);
    texel = vec3(
        texture2D(inputImageTexture3, vec2(luma, texel.r)).r,
        texture2D(inputImageTexture3, vec2(luma, texel.g)).g,
        texture2D(inputImageTexture3, vec2(luma, texel.b)).b);

    return vec4(texel, 1.0);
}

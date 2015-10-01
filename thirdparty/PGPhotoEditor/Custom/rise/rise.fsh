uniform sampler2D inputImageTexture2; //map
uniform sampler2D inputImageTexture3; //overlaymap
uniform sampler2D inputImageTexture4; //blackboard

vec4 filter(vec4 texel)
{
    vec3 bbTexel = texture2D(inputImageTexture4, texCoord).rgb;

    texel.r = texture2D(inputImageTexture3, vec2(bbTexel.r, texel.r)).r;
    texel.g = texture2D(inputImageTexture3, vec2(bbTexel.g, texel.g)).g;
    texel.b = texture2D(inputImageTexture3, vec2(bbTexel.b, texel.b)).b;

    vec4 mapped;
    mapped.r = texture2D(inputImageTexture2, vec2(texel.r, .16666)).r;
    mapped.g = texture2D(inputImageTexture2, vec2(texel.g, .5)).g;
    mapped.b = texture2D(inputImageTexture2, vec2(texel.b, .83333)).b;
    mapped.a = 1.0;

    return mapped;
}

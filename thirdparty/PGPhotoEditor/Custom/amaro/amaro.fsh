uniform sampler2D inputImageTexture2; //map
uniform sampler2D inputImageTexture3; //overlaymap
uniform sampler2D inputImageTexture4; //blackboard

vec4 filter(vec4 color)
{
    vec3 texel = color.rgb;

    vec3 bbTexel = texture2D(inputImageTexture4, texCoord).rgb;

    texel.r = texture2D(inputImageTexture3, vec2(bbTexel.r, texel.r)).r;
    texel.g = texture2D(inputImageTexture3, vec2(bbTexel.g, texel.g)).g;
    texel.b = texture2D(inputImageTexture3, vec2(bbTexel.b, texel.b)).b;

    texel = vec3(
        texture2D(inputImageTexture2, vec2(texel.r, .16666)).r,
        texture2D(inputImageTexture2, vec2(texel.g, .5)).g,
        texture2D(inputImageTexture2, vec2(texel.b, .83333)).b);


    return vec4(texel, 1.0);
}

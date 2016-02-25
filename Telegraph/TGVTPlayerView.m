#import "TGVTPlayerView.h"

#import <SSignalKit/SSignalKit.h>
#import <GLKit/GLKit.h>
#import <OpenGLES/ES2/gl.h>
#import <OpenGLES/ES2/glext.h>
#import <AVFoundation/AVFoundation.h>

typedef enum {
    UniformIndex_Y = 0,
    UniformIndex_UV,
    UniformIndex_RotationAngle,
    UniformIndex_ColorConversionMatrix,
    UniformIndex_NumUniforms
} UniformIndex;

typedef enum {
    AttributeIndex_Vertex = 0,
    AttributeIndex_TextureCoordinates,
    AttributeIndex_NumAttributes
} AttributeIndex;

// BT.601, which is the standard for SDTV.
static GLfloat colorConversion601[] = {
    1.164f, 1.164f, 1.164f,
    0.0f, -0.392f, 2.017f,
    1.596f, -0.813f, 0.0f
};

// BT.709, which is the standard for HDTV.
static GLfloat colorConversion709[] = {
    1.164f, 1.164f, 1.164f,
    0.0f, -0.213f, 2.112f,
    1.793f, -0.533f, 0.0f
};

static NSData *fragmentShaderSource() {
    static NSData *value = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        value = [[NSData alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"VTPlayer/VTPlayer_Shader" ofType:@"fsh"]];
    });
    return value;
}

static NSData *vertexShaderSource() {
    static NSData *value = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        value = [[NSData alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"VTPlayer/VTPlayer_Shader" ofType:@"vsh"]];
    });
    return value;
}

@interface TGVTPlayerView () {
    SQueue *_queue;
    
    CAEAGLLayer *_layer;
    
    bool _initialized;
    
    EAGLContext *_context;
    CVOpenGLESTextureRef _lumaTexture;
    CVOpenGLESTextureRef _chromaTexture;
    CVOpenGLESTextureCacheRef _videoTextureCache;
    
    int _backingWidth;
    int _backingHeight;
    uint _frameBufferHandle;
    uint _colorBufferHandle;
    
    GLfloat *_preferredConversion;
    GLint _uniforms[UniformIndex_NumUniforms];
    
    int _program;
}

@end

@implementation TGVTPlayerView

+ (Class)layerClass {
    return [CAEAGLLayer class];
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self != nil) {
        _queue = [[SQueue alloc] init];
        _layer = (CAEAGLLayer *)self.layer;
        
        _layer.drawableProperties = @{(NSString *)kEAGLDrawablePropertyRetainedBacking: @false, (NSString *)kEAGLDrawablePropertyColorFormat: (NSString *)kEAGLColorFormatRGBA8};
        [_queue dispatch:^{
            _context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
            _preferredConversion = colorConversion709;
        }];
    }
    return self;
}

- (void)dealloc {
    CVOpenGLESTextureRef lumaTexture = _lumaTexture;
    CVOpenGLESTextureRef chromaTexture = _chromaTexture;
    CVOpenGLESTextureCacheRef videoTextureCache = _videoTextureCache;
    
    [_queue dispatch:^{
        if (lumaTexture) {
            CFRelease(lumaTexture);
        }
        
        if (chromaTexture) {
            CFRelease(chromaTexture);
        }
        
        CVOpenGLESTextureCacheFlush(videoTextureCache, 0);
    }];
}

- (void)setupGL {
    [EAGLContext setCurrentContext:_context];
    
    [self setupBuffers];
    [self loadShaders];
    
    glUseProgram(_program);
    
    // 0 and 1 are the texture IDs of lumaTexture and chromaTexture respectively.
    glUniform1i(_uniforms[UniformIndex_Y], 0);
    glUniform1i(_uniforms[UniformIndex_UV], 1);
    
    glUniform1f(_uniforms[UniformIndex_RotationAngle], 0.0f);
    
    glUniformMatrix3fv(_uniforms[UniformIndex_ColorConversionMatrix], 1, false, _preferredConversion);
    
    CVOpenGLESTextureCacheCreate(kCFAllocatorDefault, NULL, _context, NULL, &_videoTextureCache);
}

- (void)setupBuffers {
    glDisable(GL_DEPTH_TEST);
    
    glEnableVertexAttribArray(AttributeIndex_Vertex);
    glVertexAttribPointer(AttributeIndex_Vertex, 2, GL_FLOAT, false, 2 * sizeof(GLfloat), NULL);
    
    glEnableVertexAttribArray(AttributeIndex_TextureCoordinates);
    
    glVertexAttribPointer(AttributeIndex_TextureCoordinates, 2, GL_FLOAT, false, 2 * sizeof(GLfloat), NULL);
    
    glGenFramebuffers(1, &_frameBufferHandle);
    glBindFramebuffer(GL_FRAMEBUFFER, _frameBufferHandle);
    
    glGenRenderbuffers(1, &_colorBufferHandle);
    glBindRenderbuffer(GL_RENDERBUFFER, _colorBufferHandle);
    
    [_context renderbufferStorage:GL_RENDERBUFFER fromDrawable:_layer];
    
    glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_WIDTH, &_backingWidth);
    glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_HEIGHT, &_backingHeight);
    
    glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_RENDERBUFFER, _colorBufferHandle);
    
    if (glCheckFramebufferStatus(GL_FRAMEBUFFER) != GL_FRAMEBUFFER_COMPLETE) {
        TGLog(@"Failed to make complete framebuffer object");
    }
}

- (bool)compileShaderWithType:(int)shaderType outShader:(int *)outShader {
    int shader = 0;
    
    NSData *source = (shaderType == GL_FRAGMENT_SHADER) ? fragmentShaderSource() : vertexShaderSource();
    if (source == nil) {
        return false;
    }
			
    shader = glCreateShader(shaderType);
    GLchar const *bytes = (GLchar const *)source.bytes;
    GLint length = (GLint)source.length;
    glShaderSource(shader, 1, &bytes, &length);
    glCompileShader(shader);
    
    GLsizei logLength = 0;
    glGetShaderInfoLog(shader, 0, &logLength, NULL);
    if (logLength != 0) {
        GLchar *log = malloc(logLength);
        glGetShaderInfoLog(shader, logLength, &logLength, log);
        NSString *logString = [[NSString alloc] initWithBytes:log length:logLength encoding:NSUTF8StringEncoding];
        TGLog(@"Shader compile log: %@", logString);
        free(log);
    }
    
    if (outShader != NULL) {
        *outShader = shader;
    }
    
    return true;
}

- (bool)loadShaders {
    int vertShader;
    int fragShader;
    
    _program = glCreateProgram();
    
    // Create and compile the vertex shader.
    if (![self compileShaderWithType:GL_VERTEX_SHADER outShader:&vertShader]) {
        TGLog(@"Failed to compile vertex shader");
        return false;
    }
    
    // Create and compile fragment shader.
    if (![self compileShaderWithType:GL_FRAGMENT_SHADER outShader:&fragShader]) {
        TGLog(@"Failed to compile fragment shader");
        return false;
    }
    
    glAttachShader(_program, vertShader);
    glAttachShader(_program, fragShader);
    
    glBindAttribLocation(_program, AttributeIndex_Vertex, "position");
    glBindAttribLocation(_program, AttributeIndex_TextureCoordinates, "texCoord");
    
    glLinkProgram(_program);
    
    
    int status;
    glGetProgramiv(_program, GL_LINK_STATUS, &status);
    bool ok = (status != 0);
    if (ok) {
        _uniforms[UniformIndex_Y] = glGetUniformLocation(_program, "SamplerY");
        _uniforms[UniformIndex_UV] = glGetUniformLocation(_program, "SamplerUV");
        _uniforms[UniformIndex_RotationAngle] = glGetUniformLocation(_program, "preferredRotation");
        _uniforms[UniformIndex_ColorConversionMatrix] = glGetUniformLocation(_program, "colorConversionMatrix");
    }
    if (vertShader != 0) {
        glDetachShader(_program, vertShader);
        glDeleteShader(vertShader);
    }
    if (fragShader != 0) {
        glDetachShader(_program, fragShader);
        glDeleteShader(fragShader);
    }
    if (!ok) {
        glDeleteProgram(_program);
        _program = 0;
    }
    
    return ok;
}

- (void)cleanupTextures {
    if (_lumaTexture) {
        CFRelease(_lumaTexture);
        _lumaTexture = NULL;
    }
    
    if (_chromaTexture) {
        CFRelease(_chromaTexture);
        _chromaTexture = NULL;
    }
    
    CVOpenGLESTextureCacheFlush(_videoTextureCache, 0);
}

- (void)displayPixelBuffer:(CVPixelBufferRef)pixelBuffer
{
    if (pixelBuffer != NULL) {
        CFRetain(pixelBuffer);
    }
    
    [_queue dispatch:^{
        [EAGLContext setCurrentContext:_context];
        
        if (!_initialized) {
            [self setupGL];
            _initialized = true;
        }
        
        if (pixelBuffer != NULL) {
            int frameWidth = (int)CVPixelBufferGetWidth(pixelBuffer);
            int frameHeight = (int)CVPixelBufferGetHeight(pixelBuffer);
            
            if (_videoTextureCache == NULL) {
                TGLog(@"No video texture cache");
                return;
            }
            
            [self cleanupTextures];
            
            CFTypeRef colorAttachments = CVBufferGetAttachment(pixelBuffer, kCVImageBufferYCbCrMatrixKey, NULL);
            if (colorAttachments == kCVImageBufferYCbCrMatrix_ITU_R_601_4) {
                _preferredConversion = colorConversion601;
            } else {
                _preferredConversion = colorConversion709;
            }
            
            glActiveTexture(GL_TEXTURE0);
            CVOpenGLESTextureCacheCreateTextureFromImage(kCFAllocatorDefault, _videoTextureCache, pixelBuffer, NULL, GL_TEXTURE_2D, GL_RED_EXT, frameWidth, frameHeight, GL_RED_EXT, GL_UNSIGNED_BYTE, 0, &_lumaTexture);
            if (_lumaTexture == NULL) {
                TGLog(@"Error at CVOpenGLESTextureCache.TextureFromImage");
            }
            
            glBindTexture(CVOpenGLESTextureGetTarget(_lumaTexture), CVOpenGLESTextureGetName(_lumaTexture));
            glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
            glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
            glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
            glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
            
            glActiveTexture(GL_TEXTURE1);
            
            CVOpenGLESTextureCacheCreateTextureFromImage(kCFAllocatorDefault, _videoTextureCache, pixelBuffer, NULL, GL_TEXTURE_2D, GL_RG_EXT, frameWidth / 2, frameHeight / 2, GL_RG_EXT, GL_UNSIGNED_BYTE, 1, &_chromaTexture);
            
            if (_chromaTexture == NULL) {
                TGLog(@"Error at CVOpenGLESTextureCache.TextureFromImage");
            }
            
            glBindTexture(CVOpenGLESTextureGetTarget(_chromaTexture), CVOpenGLESTextureGetName(_chromaTexture));
            glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
            glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
            glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
            glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
            
            glBindFramebuffer(GL_FRAMEBUFFER, _frameBufferHandle);
            glViewport(0, 0, _backingWidth, _backingHeight);
            
            CFRelease(pixelBuffer);
        }
        
        glClearColor(0.0f, 0.0f, 0.0f, 1.0f);
        glClear(GL_COLOR_BUFFER_BIT);
        
        glUseProgram(_program);
        glUniform1f(_uniforms[UniformIndex_RotationAngle], 0.0f);
        glUniformMatrix3fv(_uniforms[UniformIndex_ColorConversionMatrix], 1, false, _preferredConversion);
        
        // Set up the quad vertices with respect to the orientation and aspect ratio of the video.
        CGRect vertexSamplingRect = AVMakeRectWithAspectRatioInsideRect(self.layer.bounds.size, self.layer.bounds);
        
        // Compute normalized quad coordinates to draw the frame into.
        CGSize normalizedSamplingSize = CGSizeMake(0.0, 0.0);
        CGSize cropScaleAmount = CGSizeMake(vertexSamplingRect.size.width / self.layer.bounds.size.width, vertexSamplingRect.size.height/self.layer.bounds.size.height);
        
        // Normalize the quad vertices.
        if (cropScaleAmount.width > cropScaleAmount.height) {
            normalizedSamplingSize.width = 1.0;
            normalizedSamplingSize.height = cropScaleAmount.height/cropScaleAmount.width;
        }
        else {
            normalizedSamplingSize.width = 1.0;
            normalizedSamplingSize.height = cropScaleAmount.width/cropScaleAmount.height;
        }
        
        /*
         The quad vertex data defines the region of 2D plane onto which we draw our pixel buffers.
         Vertex data formed using (-1,-1) and (1,1) as the bottom left and top right coordinates respectively, covers the entire screen.
         */
        GLfloat quadVertexData [] = {
            (GLfloat)(-1 * normalizedSamplingSize.width), (GLfloat)(-1 * normalizedSamplingSize.height),
            (GLfloat)normalizedSamplingSize.width, (GLfloat)(-1 * normalizedSamplingSize.height),
            (GLfloat)(-1 * normalizedSamplingSize.width), (GLfloat)(normalizedSamplingSize.height),
            (GLfloat)(normalizedSamplingSize.width), (GLfloat)(normalizedSamplingSize.height),
        };
        
        // Update attribute values.
        glVertexAttribPointer(AttributeIndex_Vertex, 2, GL_FLOAT, 0, 0, quadVertexData);
        glEnableVertexAttribArray(AttributeIndex_Vertex);
        
        /*
         The texture vertices are set up such that we flip the texture vertically. This is so that our top left origin buffers match OpenGL's bottom left texture coordinate system.
         */
        CGRect textureSamplingRect = CGRectMake(0, 0, 1, 1);
        GLfloat quadTextureData[] = {
            (GLfloat)CGRectGetMinX(textureSamplingRect), (GLfloat)CGRectGetMaxY(textureSamplingRect),
            (GLfloat)CGRectGetMaxX(textureSamplingRect), (GLfloat)CGRectGetMaxY(textureSamplingRect),
            (GLfloat)CGRectGetMinX(textureSamplingRect), (GLfloat)CGRectGetMinY(textureSamplingRect),
            (GLfloat)CGRectGetMaxX(textureSamplingRect), (GLfloat)CGRectGetMinY(textureSamplingRect)
        };
        
        glVertexAttribPointer(AttributeIndex_TextureCoordinates, 2, GL_FLOAT, 0, 0, quadTextureData);
        glEnableVertexAttribArray(AttributeIndex_TextureCoordinates);
        
        glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
        
        glBindRenderbuffer(GL_RENDERBUFFER, _colorBufferHandle);
        [_context presentRenderbuffer:GL_RENDERBUFFER];
    }];
}

@end

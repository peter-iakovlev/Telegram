#import "PGPhotoGaussianBlurFIlter.h"

#import "PGPhotoProcessPass.h"

NSString *const PGPhotoGaussianBlurFilterVertexShaderString = PGShaderString
(
 attribute vec4 position;
 attribute vec4 inputTexCoord;
 
 uniform float texelWidthOffset;
 uniform float texelHeightOffset;
 
 varying vec2 blurCoordinates[9];
 
 void main()
 {
     gl_Position = position;
     
     vec2 singleStepOffset = vec2(texelWidthOffset, texelHeightOffset);
     blurCoordinates[0] = inputTexCoord.xy;
     blurCoordinates[1] = inputTexCoord.xy + singleStepOffset * 1.458430;
     blurCoordinates[2] = inputTexCoord.xy - singleStepOffset * 1.458430;
     blurCoordinates[3] = inputTexCoord.xy + singleStepOffset * 3.403985;
     blurCoordinates[4] = inputTexCoord.xy - singleStepOffset * 3.403985;
     blurCoordinates[5] = inputTexCoord.xy + singleStepOffset * 5.351806;
     blurCoordinates[6] = inputTexCoord.xy - singleStepOffset * 5.351806;
     blurCoordinates[7] = inputTexCoord.xy + singleStepOffset * 7.302940;
     blurCoordinates[8] = inputTexCoord.xy - singleStepOffset * 7.302940;
 }
 );

NSString *const PGPhotoGaussianBlurFilterFragmentShaderString = PGShaderString
(
 uniform sampler2D sourceImage;
 uniform highp float texelWidthOffset;
 uniform highp float texelHeightOffset;
 
 varying highp vec2 blurCoordinates[9];
 
 void main()
 {
     lowp vec4 sum = vec4(0.0);
     sum += texture2D(sourceImage, blurCoordinates[0]) * 0.133571;
     sum += texture2D(sourceImage, blurCoordinates[1]) * 0.233308;
     sum += texture2D(sourceImage, blurCoordinates[2]) * 0.233308;
     sum += texture2D(sourceImage, blurCoordinates[3]) * 0.135928;
     sum += texture2D(sourceImage, blurCoordinates[4]) * 0.135928;
     sum += texture2D(sourceImage, blurCoordinates[5]) * 0.051383;
     sum += texture2D(sourceImage, blurCoordinates[6]) * 0.051383;
     sum += texture2D(sourceImage, blurCoordinates[7]) * 0.012595;
     sum += texture2D(sourceImage, blurCoordinates[8]) * 0.012595;
     gl_FragColor = sum;
 }
);

@interface PGPhotoGaussianBlurFilter ()
{
    GPUImageFramebuffer *_secondOutputFramebuffer;
    
    GLProgram *_secondFilterProgram;
    GLint _secondFilterPositionAttribute;
    GLint _secondFilterTextureCoordinateAttribute;
    GLint _secondFilterInputTextureUniform;
    
    GLint _verticalPassTexelWidthOffsetUniform;
    GLint _verticalPassTexelHeightOffsetUniform;
    GLint _horizontalPassTexelWidthOffsetUniform;
    GLint _horizontalPassTexelHeightOffsetUniform;

    GLfloat _verticalPassTexelWidthOffset;
    GLfloat _verticalPassTexelHeightOffset;
    GLfloat _horizontalPassTexelWidthOffset;
    GLfloat _horizontalPassTexelHeightOffset;
    
    CGFloat _verticalTexelSpacing;
    CGFloat _horizontalTexelSpacing;
    
    NSMutableDictionary *_secondProgramUniformStateRestorationBlocks;
}

@end

@implementation PGPhotoGaussianBlurFilter

- (instancetype)init
{
    return [self initWithFirstStageVertexShaderFromString:PGPhotoGaussianBlurFilterVertexShaderString firstStageFragmentShaderFromString:PGPhotoGaussianBlurFilterFragmentShaderString secondStageVertexShaderFromString:PGPhotoGaussianBlurFilterVertexShaderString secondStageFragmentShaderFromString:PGPhotoGaussianBlurFilterFragmentShaderString];
}

- (instancetype)initWithFirstStageVertexShaderFromString:(NSString *)firstStageVertexShaderString firstStageFragmentShaderFromString:(NSString *)firstStageFragmentShaderString secondStageVertexShaderFromString:(NSString *)secondStageVertexShaderString secondStageFragmentShaderFromString:(NSString *)secondStageFragmentShaderString
{
    if (!(self = [super initWithVertexShaderFromString:firstStageVertexShaderString fragmentShaderFromString:firstStageFragmentShaderString]))
    {
        return nil;
    }
    
    _secondProgramUniformStateRestorationBlocks = [NSMutableDictionary dictionaryWithCapacity:10];
    
    runSynchronouslyOnVideoProcessingQueue(^{
        [GPUImageContext useImageProcessingContext];
        
        _secondFilterProgram = [[GPUImageContext sharedImageProcessingContext] programForVertexShaderString:secondStageVertexShaderString fragmentShaderString:secondStageFragmentShaderString];
        
        if (!_secondFilterProgram.initialized)
        {
            [self initializeSecondaryAttributes];
            
            if (![_secondFilterProgram link])
            {
                NSString *progLog = [_secondFilterProgram programLog];
                NSLog(@"Program link log: %@", progLog);
                NSString *fragLog = [_secondFilterProgram fragmentShaderLog];
                NSLog(@"Fragment shader compile log: %@", fragLog);
                NSString *vertLog = [_secondFilterProgram vertexShaderLog];
                NSLog(@"Vertex shader compile log: %@", vertLog);
                _secondFilterProgram = nil;
                NSAssert(NO, @"Filter shader link failed");
            }
        }
        
        _secondFilterPositionAttribute = [_secondFilterProgram attributeIndex:@"position"];
        _secondFilterTextureCoordinateAttribute = [_secondFilterProgram attributeIndex:@"inputTexCoord"];
        _secondFilterInputTextureUniform = [_secondFilterProgram uniformIndex:@"sourceImage"];
        
        _verticalPassTexelWidthOffsetUniform = [filterProgram uniformIndex:@"texelWidthOffset"];
        _verticalPassTexelHeightOffsetUniform = [filterProgram uniformIndex:@"texelHeightOffset"];
        
        _horizontalPassTexelWidthOffsetUniform = [_secondFilterProgram uniformIndex:@"texelWidthOffset"];
        _horizontalPassTexelHeightOffsetUniform = [_secondFilterProgram uniformIndex:@"texelHeightOffset"];
        
        [GPUImageContext setActiveShaderProgram:_secondFilterProgram];
        
        glEnableVertexAttribArray(_secondFilterPositionAttribute);
        glEnableVertexAttribArray(_secondFilterTextureCoordinateAttribute);
    });
    
    _verticalTexelSpacing = 1.0f;
    _horizontalTexelSpacing = 1.0f;
    
    [self setupFilterForSize:[self sizeOfFBO]];
    
    return self;
}

- (instancetype)initWithFirstStageFragmentShaderFromString:(NSString *)firstStageFragmentShaderString secondStageFragmentShaderFromString:(NSString *)secondStageFragmentShaderString
{
    if (!(self = [self initWithFirstStageVertexShaderFromString:kGPUImageVertexShaderString firstStageFragmentShaderFromString:firstStageFragmentShaderString secondStageVertexShaderFromString:kGPUImageVertexShaderString secondStageFragmentShaderFromString:secondStageFragmentShaderString]))
    {
        return nil;
    }
    
    return self;
}

- (void)initializeSecondaryAttributes
{
    [_secondFilterProgram addAttribute:@"position"];
    [_secondFilterProgram addAttribute:@"inputTexCoord"];
}

- (GPUImageFramebuffer *)framebufferForOutput
{
    return _secondOutputFramebuffer;
}

- (void)removeOutputFramebuffer
{
    _secondOutputFramebuffer = nil;
}

- (void)renderToTextureWithVertices:(const GLfloat *)vertices textureCoordinates:(const GLfloat *)textureCoordinates
{
    if (self.preventRendering)
    {
        [firstInputFramebuffer unlock];
        return;
    }
    
    [GPUImageContext setActiveShaderProgram:filterProgram];
    
    outputFramebuffer = [[GPUImageContext sharedFramebufferCache] fetchFramebufferForSize:[self sizeOfFBO]
                                                                           textureOptions:self.outputTextureOptions
                                                                              onlyTexture:false];
    [outputFramebuffer activateFramebuffer];
    
    [self setUniformsForProgramAtIndex:0];
    
    glClearColor(backgroundColorRed, backgroundColorGreen, backgroundColorBlue, backgroundColorAlpha);
    glClear(GL_COLOR_BUFFER_BIT);
    
    glActiveTexture(GL_TEXTURE2);
    glBindTexture(GL_TEXTURE_2D, [firstInputFramebuffer texture]);
    
    glUniform1i(filterInputTextureUniform, 2);
    
    glVertexAttribPointer(filterPositionAttribute, 2, GL_FLOAT, 0, 0, vertices);
    glVertexAttribPointer(filterTextureCoordinateAttribute, 2, GL_FLOAT, 0, 0, textureCoordinates);
    
    glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
    
    [firstInputFramebuffer unlock];
    firstInputFramebuffer = nil;
    
    _secondOutputFramebuffer = [[GPUImageContext sharedFramebufferCache] fetchFramebufferForSize:[self sizeOfFBO]
                                                                                  textureOptions:self.outputTextureOptions
                                                                                     onlyTexture:false];
    [_secondOutputFramebuffer activateFramebuffer];
    [GPUImageContext setActiveShaderProgram:_secondFilterProgram];
    if (usingNextFrameForImageCapture)
        [_secondOutputFramebuffer lock];
    
    [self setUniformsForProgramAtIndex:1];
    
    glActiveTexture(GL_TEXTURE3);
    glBindTexture(GL_TEXTURE_2D, [outputFramebuffer texture]);
    glVertexAttribPointer(_secondFilterTextureCoordinateAttribute, 2, GL_FLOAT, 0, 0, [GPUImageFilter textureCoordinatesForRotation:kGPUImageNoRotation]);
    
    glUniform1i(_secondFilterInputTextureUniform, 3);
    
    glVertexAttribPointer(_secondFilterPositionAttribute, 2, GL_FLOAT, 0, 0, vertices);
    
    glClearColor(0.0f, 0.0f, 0.0f, 1.0f);
    glClear(GL_COLOR_BUFFER_BIT);
    
    glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
    [outputFramebuffer unlock];
    outputFramebuffer = nil;
    
    if (usingNextFrameForImageCapture)
        dispatch_semaphore_signal(imageCaptureSemaphore);
}

- (void)setAndExecuteUniformStateCallbackAtIndex:(GLint)uniform forProgram:(GLProgram *)shaderProgram toBlock:(dispatch_block_t)uniformStateBlock
{
    if (shaderProgram == filterProgram)
        [uniformStateRestorationBlocks setObject:[uniformStateBlock copy] forKey:[NSNumber numberWithInt:uniform]];
    else
        [_secondProgramUniformStateRestorationBlocks setObject:[uniformStateBlock copy] forKey:[NSNumber numberWithInt:uniform]];
    
    uniformStateBlock();
}

- (void)setUniformsForProgramAtIndex:(NSUInteger)programIndex
{
    if (programIndex == 0)
    {
        [uniformStateRestorationBlocks enumerateKeysAndObjectsUsingBlock:^(__unused id key, id obj, __unused BOOL *stop)
        {
            dispatch_block_t currentBlock = obj;
            currentBlock();
        }];
    }
    else
    {
        [_secondProgramUniformStateRestorationBlocks enumerateKeysAndObjectsUsingBlock:^(__unused id key, id obj, __unused BOOL *stop)
        {
            dispatch_block_t currentBlock = obj;
            currentBlock();
        }];
    }
    
    if (programIndex == 0)
    {
        glUniform1f(_verticalPassTexelWidthOffsetUniform, _verticalPassTexelWidthOffset);
        glUniform1f(_verticalPassTexelHeightOffsetUniform, _verticalPassTexelHeightOffset);
    }
    else
    {
        glUniform1f(_horizontalPassTexelWidthOffsetUniform, _horizontalPassTexelWidthOffset);
        glUniform1f(_horizontalPassTexelHeightOffsetUniform, _horizontalPassTexelHeightOffset);
    }
}

- (void)setupFilterForSize:(CGSize)filterFrameSize
{
    runSynchronouslyOnVideoProcessingQueue(^
    {
        if (GPUImageRotationSwapsWidthAndHeight(inputRotation))
        {
            _verticalPassTexelWidthOffset = (GLfloat)(_verticalTexelSpacing / filterFrameSize.height);
            _verticalPassTexelHeightOffset = 0.0;
        }
        else
        {
            _verticalPassTexelWidthOffset = 0.0;
            _verticalPassTexelHeightOffset = (GLfloat)(_verticalTexelSpacing / filterFrameSize.height);
        }
       
        _horizontalPassTexelWidthOffset = (GLfloat)(_horizontalTexelSpacing / filterFrameSize.width);
        _horizontalPassTexelHeightOffset = 0.0;
    });
}

@end

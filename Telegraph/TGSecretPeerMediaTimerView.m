#import "TGSecretPeerMediaTimerView.h"

#import <LegacyComponents/TGFont.h>
#import <LegacyComponents/TGImageUtils.h>

#import "TGCircularProgressView.h"

@interface TGSecretPeerMediaTimerView () {
}

@end

@implementation TGSecretPeerMediaTimerView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self != nil) {
        static UIImage *timeBackgroundImage = nil;
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^
        {
            CGFloat side = 28.0f;
            UIGraphicsBeginImageContextWithOptions(CGSizeMake(side, side), false, 0.0f);
            CGContextRef context = UIGraphicsGetCurrentContext();
            
            CGContextSetFillColorWithColor(context, UIColorRGBA(0x000000, 0.6f).CGColor);
            CGContextFillEllipseInRect(context, CGRectMake(0.0f, 0.0f, side, side));
            
            timeBackgroundImage = [UIGraphicsGetImageFromCurrentImageContext() stretchableImageWithLeftCapWidth:(int)(side / 2) topCapHeight:(int)(side / 2)];
            UIGraphicsEndImageContext();
        });
        
        _infoBackgroundView = [[UIImageView alloc] initWithImage:timeBackgroundImage];
        [self addSubview:_infoBackgroundView];
        
        _progressView = [[TGSecretPeerMediaProgressView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 26.0f, 26.0f)];
        [_progressView setProgress:1.0f];
        [self addSubview:_progressView];
    }
    return self;
}

@end


@interface TGSecretPeerMediaParticle : NSObject
{
@public
    CGPoint _position;
    CGPoint _direction;
    CGFloat _velocity;
    
    CGFloat _alpha;
    CGFloat _lifeTime;
    CGFloat _currentTime;
}
@end

const NSInteger TGSecretPeerMediaProgressParticlesCount = 40;

@interface TGSecretPeerMediaProgressView ()
{
    NSMutableArray<TGSecretPeerMediaParticle *> *_particlesPool;
    NSMutableArray<TGSecretPeerMediaParticle *> *_particles;
    NSMutableIndexSet *_particlesToRelease;
    
    CGFloat _previousTime;
}
@end

@implementation TGSecretPeerMediaProgressView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self != nil)
    {
        self.backgroundColor = [UIColor clearColor];
        self.opaque = false;
        self.contentMode = UIViewContentModeRedraw;
        
        _particlesPool = [[NSMutableArray alloc] init];
        _particles = [[NSMutableArray alloc] init];
        _particlesToRelease = [[NSMutableIndexSet alloc] init];
        
        for (NSUInteger i = 0; i < TGSecretPeerMediaProgressParticlesCount; i++)
        {
            [_particlesPool addObject:[[TGSecretPeerMediaParticle alloc] init]];
        }
    }
    return self;
}

- (void)setProgress:(CGFloat)progress
{
    _progress = progress;
    [self setNeedsDisplay];
}

- (void)particlesTick:(NSTimeInterval)dt
{
    NSUInteger i = -1;
    for (TGSecretPeerMediaParticle *particle in _particles)
    {
        i++;
        
        if (particle->_currentTime > particle->_lifeTime)
        {
            if (_particlesPool.count < TGSecretPeerMediaProgressParticlesCount)
                [_particlesPool addObject:particle];
            
            [_particlesToRelease addIndex:i];
            continue;
        }
        
        CGFloat input = particle->_currentTime / particle->_lifeTime;
        CGFloat decelerated = (1.0f - (1.0f - input) * (1.0f - input));
        particle->_alpha = 1.0f - decelerated;
        
        CGPoint p = particle->_position;
        CGPoint d = particle->_direction;
        CGFloat v = particle->_velocity;
        p = CGPointMake(p.x + d.x * v * dt / 1000.0f, p.y + d.y * v * dt / 1000.0f);
        particle->_position = p;
        
        particle->_currentTime += dt;
    }
    
    [_particles removeObjectsAtIndexes:_particlesToRelease];
    [_particlesToRelease removeAllIndexes];
}

- (void)drawRect:(CGRect)__unused rect
{
    CGRect allRect = self.bounds;
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetFillColorWithColor(context, [UIColor whiteColor].CGColor);
    CGContextSetStrokeColorWithColor(context, [UIColor whiteColor].CGColor);
    CGContextSetLineWidth(context, 1.75f);
    CGContextSetLineCap(context, kCGLineCapRound);
    CGContextSetLineJoin(context, kCGLineJoinMiter);
    CGContextSetMiterLimit(context, 10);
    
    CGPoint center = CGPointMake(allRect.size.width / 2, allRect.size.height / 2);
    CGFloat radius = 10.5f;
    
    CGFloat startAngle = -M_PI_2;
    CGFloat endAngle = -M_PI_2 + 2 * M_PI * (1.0f - self.progress);
    
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathAddArc(path, NULL, center.x, center.y, radius, startAngle, endAngle, true);
    CGContextAddPath(context, path);
    CGPathRelease(path);
    CGContextStrokePath(context);
    
    
    for (TGSecretPeerMediaParticle *particle in _particles)
    {
        CGFloat size = 1.0f;
        CGContextSetAlpha(context, particle->_alpha);
        CGContextFillEllipseInRect(context, CGRectMake(particle->_position.x - size / 2.0f, particle->_position.y - size / 2.0f, size, size));
    }
    
    CGPoint v = CGPointMake(sin(endAngle), -cos(endAngle));
    CGPoint c = CGPointMake(-v.y * radius + center.x, v.x * radius + center.y);
    
    const NSInteger newParticlesCount = 1;
    for (NSInteger i = 0; i < newParticlesCount; i++)
    {
        TGSecretPeerMediaParticle *newParticle = nil;
        if (_particlesPool.count > 0)
        {
            newParticle = [_particlesPool lastObject];
            [_particlesPool removeLastObject];
        }
        else
        {
            newParticle = [[TGSecretPeerMediaParticle alloc] init];
        }
        
        newParticle->_position = c;
        
        CGFloat degrees = (CGFloat)arc4random_uniform(140) - 70.0f;
        CGFloat angle = degrees * (CGFloat)M_PI / 180.0f;
        
        newParticle->_direction = CGPointMake(v.x * cos(angle) - v.y * sin(angle), v.x * sin(angle) + v.y * cos(angle));
        
        newParticle->_alpha = 1.0f;
        newParticle->_currentTime = 0;
        
        newParticle->_lifeTime = 400 + arc4random_uniform(100);
        newParticle->_velocity = 20.0f + (double)arc4random() / UINT32_MAX * 4.0f;
        
        [_particles addObject:newParticle];
    }
    
    CGFloat currentTime = CFAbsoluteTimeGetCurrent() * 1000.0f;
    if (_previousTime > DBL_EPSILON)
        [self particlesTick:currentTime - _previousTime];
    _previousTime = currentTime;
    
    CGContextSetAlpha(context, 1.0f);
    UIImage *flameImage = TGImageNamed(@"SecretTimerFlame");
    [flameImage drawAtPoint:CGPointMake(floor((allRect.size.width - flameImage.size.width) / 2.0f), floor((allRect.size.height - flameImage.size.height) / 2.0f))];
}

@end

@implementation TGSecretPeerMediaParticle

@end


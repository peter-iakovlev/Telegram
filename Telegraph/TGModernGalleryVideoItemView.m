/*
 * This is the source code of Telegram for iOS v. 1.1
 * It is licensed under GNU GPL v. 2 or later.
 * You should have received a copy of the license in this archive (see LICENSE).
 *
 * Copyright Peter Iakovlev, 2013.
 */

#import "TGModernGalleryVideoItemView.h"

#import <AVFoundation/AVFoundation.h>

#import "TGImageUtils.h"
#import "TGRemoteImageView.h"

#import "TGModernGalleryVideoItem.h"
#import "TGVideoMediaAttachment.h"

#import "TGVideoDownloadActor.h"

@interface TGModernGalleryVideoItemView ()
{
    AVPlayerLayer *_playerLayer;
    NSUInteger _currentLoopCount;
}

@end

@implementation TGModernGalleryVideoItemView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self != nil)
    {
        _imageView = [[TGRemoteImageView alloc] init];
        _imageView.contentMode = UIViewContentModeScaleAspectFit;
        [self addSubview:_imageView];
    }
    return self;
}

- (void)prepareForRecycle
{
    [super prepareForRecycle];
    
    [self cleanupCurrentPlayer];
    
    _currentLoopCount = 0;
}

- (void)cleanupCurrentPlayer
{
    if (_player != nil)
    {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:AVPlayerItemDidPlayToEndTimeNotification object:[_player currentItem]];
        
        [_player pause];
        _player = nil;
    }
    
    if (_playerLayer != nil)
    {
        [_playerLayer removeFromSuperlayer];
        _playerLayer = nil;
    }
    
    _videoDimenstions = CGSizeZero;
    
    [_imageView loadImage:nil];
}

- (void)addPlayerObserver
{
    if (_player != nil)
    {
    }
}

- (void)removePlayerObserver
{
    if (_player != nil)
    {
    }
}

- (void)setItem:(TGModernGalleryVideoItem *)item
{
    [super setItem:item];
    
    [self cleanupCurrentPlayer];
    
    NSString *videoPath = [TGVideoDownloadActor localPathForVideoUrl:[item.videoMedia.videoInfo urlWithQuality:0 actualQuality:NULL actualSize:NULL]];
    
    if (videoPath != nil && item.videoMedia.dimensions.width > FLT_EPSILON && item.videoMedia.dimensions.height > FLT_EPSILON)
    {
        _videoDimenstions = item.videoMedia.dimensions;
        
        NSString *previewUri = nil;
        if (item.videoMedia.videoId != 0)
            previewUri = [[NSString alloc] initWithFormat:@"video-thumbnail-remote%llx.jpg", item.videoMedia.videoId];
        else if (item.videoMedia.localVideoId != 0)
            previewUri = [[NSString alloc] initWithFormat:@"video-thumbnail-local%llx.jpg", item.videoMedia.localVideoId];
        
        [_imageView loadImage:previewUri filter:nil placeholder:nil];
        
        _player = [[AVPlayer alloc] initWithURL:[NSURL fileURLWithPath:videoPath]];
        _player.actionAtItemEnd = AVPlayerActionAtItemEndNone;
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playerItemDidPlayToEndTime:) name:AVPlayerItemDidPlayToEndTimeNotification object:[_player currentItem]];
        
        _playerLayer = [AVPlayerLayer playerLayerWithPlayer:_player];
        _playerLayer.videoGravity = AVLayerVideoGravityResize;
        [self.layer insertSublayer:_playerLayer above:_imageView.layer];
        
        [_player play];
        
        [self setNeedsLayout];
    }
}

- (void)playerItemDidPlayToEndTime:(NSNotification *)notification
{
    _currentLoopCount++;
    
    if ([self shouldLoopVideo:_currentLoopCount])
    {
        AVPlayerItem *p = [notification object];
        [p seekToTime:kCMTimeZero];
    }
    else
        [_player pause];
}

- (bool)shouldLoopVideo:(NSUInteger)__unused currentLoopCount
{
    return false;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    if (_videoDimenstions.width > FLT_EPSILON && _videoDimenstions.height > FLT_EPSILON)
    {
        CGSize fittedSize = TGFitSize(TGFillSize(_videoDimenstions, self.bounds.size), self.bounds.size);
        
        _imageView.frame = CGRectMake(CGFloor((self.bounds.size.width - fittedSize.width) / 2.0f), CGFloor((self.bounds.size.height - fittedSize.height) / 2.0f), fittedSize.width, fittedSize.height);
        _playerLayer.frame = CGRectMake(CGFloor((self.bounds.size.width - fittedSize.width) / 2.0f), CGFloor((self.bounds.size.height - fittedSize.height) / 2.0f), fittedSize.width, fittedSize.height);
    }
}

@end

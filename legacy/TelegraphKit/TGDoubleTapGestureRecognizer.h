/*
 * This is the source code of Telegram for iOS v. 1.1
 * It is licensed under GNU GPL v. 2 or later.
 * You should have received a copy of the license in this archive (see LICENSE).
 *
 * Copyright Peter Iakovlev, 2013.
 */

#import <UIKit/UIKit.h>

@interface TGDoubleTapGestureRecognizer : UIGestureRecognizer

@property (nonatomic) bool consumeSingleTap;
@property (nonatomic) bool doubleTapped;
@property (nonatomic) bool longTapped;
@property (nonatomic) bool avoidControls;

- (bool)canScrollViewStealTouches;

@end

@protocol TGDoubleTapGestureRecognizerDelegate <NSObject>

@optional

- (int)gestureRecognizer:(TGDoubleTapGestureRecognizer *)recognizer shouldFailTap:(CGPoint)point;
- (void)gestureRecognizer:(TGDoubleTapGestureRecognizer *)recognizer shouldBeginAtPoint:(CGPoint)point;
- (void)gestureRecognizer:(TGDoubleTapGestureRecognizer *)recognizer didBeginAtPoint:(CGPoint)point;
- (void)gestureRecognizerDidFail:(TGDoubleTapGestureRecognizer *)recognizer;
- (bool)gestureRecognizerShouldHandleLongTap:(TGDoubleTapGestureRecognizer *)recognizer;
- (void)doubleTapGestureRecognizerSingleTapped:(TGDoubleTapGestureRecognizer *)recognizer;
- (bool)gestureRecognizerShouldLetScrollViewStealTouches:(TGDoubleTapGestureRecognizer *)recognizer;
- (bool)gestureRecognizerShouldFailOnMove:(TGDoubleTapGestureRecognizer *)recognizer;

@end

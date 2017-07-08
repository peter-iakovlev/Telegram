/*
 * This is the source code of Telegram for iOS v. 1.1
 * It is licensed under GNU GPL v. 2 or later.
 * You should have received a copy of the license in this archive (see LICENSE).
 *
 * Copyright Peter Iakovlev, 2013.
 */

//
//  HPTextView.h
//
//  Created by Hans Pinckaers on 29-06-10.
//
//	MIT License
//
//	Copyright (c) 2011 Hans Pinckaers
//
//	Permission is hereby granted, free of charge, to any person obtaining a copy
//	of this software and associated documentation files (the "Software"), to deal
//	in the Software without restriction, including without limitation the rights
//	to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//	copies of the Software, and to permit persons to whom the Software is
//	furnished to do so, subject to the following conditions:
//
//	The above copyright notice and this permission notice shall be included in
//	all copies or substantial portions of the Software.
//
//	THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//	IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//	FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//	AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//	LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//	OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//	THE SOFTWARE.

#import <UIKit/UIKit.h>

@class TGShareGrowingTextView;
@class TGShareTextViewInternal;

@protocol TGShareGrowingTextViewDelegate <NSObject>

@optional

- (BOOL)growingTextViewShouldBeginEditing:(TGShareGrowingTextView *)growingTextView;
- (void)growingTextViewDidBeginEditing:(TGShareGrowingTextView *)growingTextView;
- (void)growingTextViewDidEndEditing:(TGShareGrowingTextView *)growingTextView;
- (BOOL)growingTextViewEnabled:(TGShareGrowingTextView *)growingTextView;

- (BOOL)growingTextView:(TGShareGrowingTextView *)growingTextView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text;
- (void)growingTextViewDidChange:(TGShareGrowingTextView *)growingTextView afterSetText:(bool)afterSetText afterPastingText:(bool)afterPastingText;

- (void)growingTextView:(TGShareGrowingTextView *)growingTextView willChangeHeight:(CGFloat)height duration:(NSTimeInterval)duration animationCurve:(int)animationCurve;

- (void)growingTextViewDidChangeSelection:(TGShareGrowingTextView *)growingTextView;
- (BOOL)growingTextViewShouldReturn:(TGShareGrowingTextView *)growingTextView;

- (void)growingTextView:(TGShareGrowingTextView *)growingTextView didPasteImages:(NSArray *)images andText:(NSString *)text;
- (void)growingTextView:(TGShareGrowingTextView *)growingTextView didPasteData:(NSData *)data;

- (void)growingTextView:(TGShareGrowingTextView *)growingTextView receivedReturnKeyCommandWithModifierFlags:(UIKeyModifierFlags)flags;

@end

@interface TGAttributedTextRange : NSObject

@property (nonatomic, strong, readonly) id attachment;

- (instancetype)initWithAttachment:(id)attachment;

@end

@interface TGShareGrowingTextView : UIView <UITextViewDelegate>

@property (nonatomic, strong) UIView *placeholderView;
@property (nonatomic, assign) bool showPlaceholderWhenFocussed;

@property (nonatomic) int minNumberOfLines;
@property (nonatomic) int maxNumberOfLines;
@property (nonatomic) CGFloat maxHeight;
@property (nonatomic) CGFloat minHeight;
@property (nonatomic) BOOL animateHeightChange;
@property (nonatomic) NSTimeInterval animationDuration;
@property (nonatomic, strong) TGShareTextViewInternal *internalTextView;

@property (nonatomic) bool oneTimeLongAnimation;

@property (nonatomic, weak) id<TGShareGrowingTextViewDelegate> delegate;
@property (nonatomic,strong) NSString *text;
@property (nonatomic, strong) NSAttributedString *attributedText;
@property (nonatomic,strong) UIFont *font;
@property (nonatomic,strong) UIColor *textColor;
@property (nonatomic) NSTextAlignment textAlignment;

@property (nonatomic, readonly) bool ignoreChangeNotification;

@property (nonatomic, assign) bool receiveKeyCommands;

- (void)refreshHeight:(bool)textChanged;
- (void)notifyHeight;

- (void)setText:(NSString *)newText animated:(bool)animated;
- (void)setAttributedText:(NSAttributedString *)newText animated:(bool)animated;
- (void)selectRange:(NSRange)range;

@end

/*
 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook, 3.0 Edition
 BSD License, Use at your own risk
 */


#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

CGPoint CGRectGetCenter(CGRect rect);
CGRect  CGRectMoveToCenter(CGRect rect, CGPoint center);

@interface UIView (ViewFrameGeometry)
@property CGPoint originS;
@property CGSize sizeS;

@property (readonly) CGPoint bottomLeftS;
@property (readonly) CGPoint bottomRightS;
@property (readonly) CGPoint topRightS;

@property CGFloat heightS;
@property CGFloat widthS;

@property CGFloat topS;
@property CGFloat leftS;

@property CGFloat bottomS;
@property CGFloat rightS;

- (void) moveBy: (CGPoint) delta;
- (void) scaleBy: (CGFloat) scaleFactor;
- (void) fitInSize: (CGSize) aSize;
@end
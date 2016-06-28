//
//  MyWindow.h
//  WKAlertViewDemo
//
//  Created by 王琨 on 15-3-11.
//  Copyright (c) 2015年 王琨. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Enum.h"

/**
 *  @Author wang kun
 *
 *  点击效果
 *
 *  @param buttonIndex 样式
 */
typedef void (^callBack)(MyWindowClick buttonIndex);



@protocol WKAlertViewDelegate <NSObject>

- (void)alertViewClick:(WKAlertViewStyle)type;

@end


@interface WKAlertView : UIView

@property (nonatomic, copy) callBack clickBlock ;/// 按钮点击事件的回调
@property (nonatomic, assign) id <WKAlertViewDelegate> WKAlertViewDelegate;
@property (nonatomic, assign) WKAlertViewNoticStyle noticStyle;

+ (instancetype)shared;
- (void)show;
/**
 *  @Author wang kun
 *
 *  创建AlertView并展示
 *
 *  @param style    绘制的图片样式
 *  @param noticStyle 提示动画样式——现有两种经典、小人
 *  @param title    警示标题
 *  @param detail   警示内容
 *  @param canle    取消按钮标题
 *  @param ok       确定按钮标题
 *  @param callBack 按钮点击时间回调
 *
 *  @return AlertView
 */
+ (instancetype)showAlertViewWithStyle:(WKAlertViewStyle)style
                            noticStyle:(WKAlertViewNoticStyle)noticStyle
                                 title:(NSString *)title
                                detail:(NSString *)detail
                      canleButtonTitle:(NSString *)canle
                         okButtonTitle:(NSString *)ok
                             callBlock:(callBack)callBack;

+ (instancetype)showAlertViewWithStyle:(WKAlertViewStyle)style
                                 title:(NSString *)title
                                detail:(NSString *)detail
                      canleButtonTitle:(NSString *)canle
                         okButtonTitle:(NSString *)ok
                             callBlock:(callBack)callBack;


/// 默认样式创建AlertView
+ (instancetype)showAlertViewWithTitle:(NSString *)title detail:(NSString *)detail canleButtonTitle:(NSString *)canle okButtonTitle:(NSString *)ok callBlock:(callBack)callBack;

+ (instancetype)showAlertViewWithStyle:(WKAlertViewStyle)style title:(NSString *)title detail:(NSString *)detail canleButtonTitle:(NSString *)canle okButtonTitle:(NSString *)ok delegate:(id<WKAlertViewDelegate>)delegate;


@end

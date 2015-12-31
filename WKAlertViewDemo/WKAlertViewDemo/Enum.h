//
//  Enum.h
//  WKAlertViewDemo
//
//  Created by apple on 15-3-30.
//  Copyright (c) 2015年 王琨. All rights reserved.
//

#ifndef WKAlertViewDemo_Enum_h
#define WKAlertViewDemo_Enum_h

/**
 *  @Author wang kun
 *
 *  点击样式
 */
typedef NS_ENUM(NSInteger, MyWindowClick){
    /**
     *
     *  @点击确定按钮
     */
    MyWindowClickForOK = 0,
    /**
     *
     *  @点击取消按钮
     */
    MyWindowClickForCancel
};


typedef NS_ENUM(NSInteger, WKAlertViewNoticStyle)
{
    WKAlertViewNoticStyleClassic ,//经典提示 默认
    WKAlertViewNoticStyleFace//小人脸提示
};



/**
 *  @Author wang kun
 *
 *  @提示框显示样式
 */
typedef NS_ENUM(NSInteger, WKAlertViewStyle)
{
    /**
     *
     *  默认样式——成功
     */
    WKAlertViewStyleDefalut = 0,
    /**
     *  成功
     */
    WKAlertViewStyleSuccess,//成功
    /**
     *  失败
     */
    WKAlertViewStyleFail,//失败
    /**
     *  警告
     */
    WKAlertViewStyleWaring//警告
};

#endif

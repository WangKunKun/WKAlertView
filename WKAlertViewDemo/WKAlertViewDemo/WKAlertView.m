//
//  MyWindow.m
//  WKAlertViewDemo
//
//  Created by 王琨 on 15-3-11.
//  Copyright (c) 2015年 王琨. All rights reserved.
//

//  经 fyd 指点 修改于 15-11-13
//  1.修改隐藏动画实现方式，与显示动画逆向即可
//  2.路径不必每次都重新创建，每次只是擦除之前显示现在的即可
//  3.优化代码结构，添加program mark
//  4.修改一些类名、变量名

//添加小人脸提示样式

#import "WKAlertView.h"
//按钮颜色
#define OKBUTTON_BGCOLOR [UIColor colorWithRed:158/255.0 green:214/255.0 blue:243/255.0 alpha:1]
#define CANCELBUTTON_BGCOLOR [UIColor colorWithRed:255/255.0 green:20/255.0 blue:20/255.0 alpha:1]
//按钮起始tag
#define TAG 100

#define SCREEN_Width   [UIScreen mainScreen].bounds.size.width
#define SCREEN_Height   [UIScreen mainScreen].bounds.size.height

//window的显示等级
#define SHOW_LEVEL 1000

//画笔宽度
#define FACELINEWIDTH     2
#define CLASSICLLINEWIDTH 3





//Logo半径（画布）
NSInteger const Logo_View_Size = 100;


NSInteger const Logo_Size = Logo_View_Size /6.0;

NSInteger const Button_Font = Logo_View_Size / 11;
NSInteger const Title_Font = Logo_View_Size / 10;
NSInteger const Detial_Font = Button_Font;

NSUInteger const Button_Size_Width = Logo_View_Size / 2.0;
NSUInteger const Button_Size_Height = Button_Size_Width / 3.0;

@interface WKAlertView ()
{
    UIView * _logoView;//画布
    UILabel * _titleLabel;//标题
    UILabel * _detailLabel;//详情
    UIButton * _OkButton;//确定按钮
    UIButton * _canleButton;//取消按钮
    NSMutableArray * _showLayerArray;
    
}
@property (nonatomic, assign) WKAlertViewStyle style;

@end


@implementation WKAlertView



+ (instancetype)showAlertViewWithStyle:(WKAlertViewStyle)style
                            noticStyle:(WKAlertViewNoticStyle)noticStyle
                                 title:(NSString *)title
                                detail:(NSString *)detail
                      canleButtonTitle:(NSString *)canle
                         okButtonTitle:(NSString *)ok
                             callBlock:(callBack)callBack
{
    WKAlertView * temp =  [self shared];
    temp.noticStyle = noticStyle;
    temp.hidden = YES;
    temp.style = style;
    [temp isShowLayer:YES];
    [temp addButtonTitleWithCancle:canle OK:ok];
    [temp addTitle:title detail:detail];
    [temp isShowControls:YES];
    [temp setClickBlock:nil];//释放掉之前的Block
    [temp setClickBlock:callBack];
    
    return  [self shared];
}

/**
 *  生成警告提示框的提示视图
 *
 *  @param style    警告视图样式
 *  @param title    视图提示标题
 *  @param detail   提示详细内容
 *  @param canle    取消按钮的显示文本
 *  @param ok       确定按钮的显示文本
 *  @param callBack 点击事件回调Block
 *
 *  @return WkAlertView
 */
+ (instancetype)showAlertViewWithStyle:(WKAlertViewStyle)style
                                 title:(NSString *)title
                                detail:(NSString *)detail
                      canleButtonTitle:(NSString *)canle
                         okButtonTitle:(NSString *)ok
                             callBlock:(callBack)callBack
{
    return [self showAlertViewWithStyle:style noticStyle:WKAlertViewNoticStyleClassic title:title detail:detail canleButtonTitle:canle okButtonTitle:ok callBlock:callBack];
}

+ (instancetype)showAlertViewWithTitle:(NSString *)title
                                detail:(NSString *)detail
                      canleButtonTitle:(NSString *)canle
                         okButtonTitle:(NSString *)ok
                             callBlock:(callBack)callBack
{
  return [self showAlertViewWithStyle:WKAlertViewStyleSuccess title:title detail:detail canleButtonTitle:canle okButtonTitle:ok callBlock:callBack];
}

+ (instancetype)showAlertViewWithStyle:(WKAlertViewStyle)style
                                 title:(NSString *)title
                                detail:(NSString *)detail
                      canleButtonTitle:(NSString *)canle
                         okButtonTitle:(NSString *)ok
                              delegate:(id<WKAlertViewDelegate>)delegate
{
    WKAlertView * temp = [self showAlertViewWithStyle:style title:title detail:detail canleButtonTitle:canle okButtonTitle:ok callBlock:nil];
    temp.WKAlertViewDelegate = delegate;
    return temp;
}
//单例
+ (instancetype)shared
{
    static dispatch_once_t once = 0;
    static WKAlertView *alert;
    dispatch_once(&once, ^{
        alert = [[WKAlertView alloc] init];
    });
    return alert;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.frame = (CGRect) {{0.f,0.f}, [[UIScreen mainScreen] bounds].size};
        self.alpha = 1;
        [self setBackgroundColor:[UIColor clearColor]];
        self.hidden = NO;//不隐藏
        _showLayerArray = [NSMutableArray new];
        [self setInterFace];
    }
    
    return self;
}

/**
 *  接受到提示样式时，再生成提示图
 *
 *  @param noticStyle 提示样式
 */
- (void)setNoticStyle:(WKAlertViewNoticStyle)noticStyle
{
    _noticStyle = noticStyle;
    [self layerInit];
}

#pragma mark 界面初始化
/**
 *  @author by wangkun, 15-03-11 17:03:18
 *
 *  界面初始化
 */
- (void)setInterFace
{
    [self logoInit];
    [self controlsInit];
}

/**
 *  初始化图层，便于后续上色以及隐藏显示
 */
- (void)layerInit
{
    
    [_showLayerArray removeAllObjects];
    switch (self.noticStyle) {

        case WKAlertViewNoticStyleFace:
        {
            [self initPathForRightShapeLayerWithFace];
            [self initPathForWrongShapeLayerWithFace];
            [self initPathForWaringShapeLayerWithFace];
            break;
        }
        default:
        case WKAlertViewNoticStyleClassic: {
            [self initPathForRightShapeLayer];
            [self initPathForWrongShapeLayer];
            [self initPathForWaringShapeLayer];
            break;
        }
    }

}


#warning 勾画路径，可自行添加路径样式
#pragma mark 通用

- (CAShapeLayer *)layerConfig
{
    CAShapeLayer * showLayer = [CAShapeLayer new];
    showLayer.fillColor = [UIColor clearColor].CGColor;
    showLayer.strokeColor = [UIColor clearColor].CGColor;
    showLayer.lineWidth = _noticStyle == WKAlertViewNoticStyleClassic ? CLASSICLLINEWIDTH : FACELINEWIDTH;
    return showLayer;
}

#pragma mark 小人脸提示
- (UIBezierPath *)FacePath
{
    CGPoint pathCenter = CGPointMake(_logoView.frame.size.width/2, _logoView.frame.size.height/4);
    UIBezierPath * path = [UIBezierPath bezierPathWithArcCenter:pathCenter radius:Logo_Size startAngle:0 endAngle:M_PI*2 clockwise:YES];
    
    path.lineCapStyle = kCGLineCapRound;
    path.lineJoinStyle = kCGLineJoinRound;
    
    CGFloat x = pathCenter.x  * 0.8;
    CGFloat y = pathCenter.y  * 0.8;
    
    [path moveToPoint:CGPointMake(x, y)];
    
    [path addArcWithCenter:CGPointMake(x, y) radius:FACELINEWIDTH / 2.0 startAngle:0 endAngle:M_PI*2 clockwise:YES];
    
    x = pathCenter.x  * 1.2;
    [path moveToPoint:CGPointMake(x, y)];
    [path addArcWithCenter:CGPointMake(x, y) radius:FACELINEWIDTH / 2.0 startAngle:0 endAngle:M_PI*2 clockwise:YES];
    
    return path;

}

- (void)initPathForRightShapeLayerWithFace
{

    CAShapeLayer * showLayer = [self layerConfig];
    UIBezierPath * path = [self FacePath];
    
    CGPoint pathCenter = CGPointMake(_logoView.frame.size.width/2, _logoView.frame.size.height/4);

    
    CGFloat x = pathCenter.x  ;
    CGFloat y = pathCenter.y * 1.05 ;
    
    UIBezierPath * path1 = [UIBezierPath bezierPathWithArcCenter:CGPointMake(x, y) radius:Logo_Size/2.0 startAngle:M_PI*2 endAngle:M_PI clockwise:YES];
    
    [path appendPath:path1];

    //新建图层——绘制上面的圆圈和勾
    showLayer.strokeColor = [UIColor greenColor].CGColor;
    showLayer.path = path.CGPath;
    
    [_showLayerArray addObject:showLayer];

}


- (void)initPathForWrongShapeLayerWithFace
{
    CAShapeLayer * showLayer = [self layerConfig];

    
    UIBezierPath * path = [self FacePath];
    
    
    CGPoint pathCenter = CGPointMake(_logoView.frame.size.width/2, _logoView.frame.size.height/4);
    
    
    CGFloat x = pathCenter.x  ;
    CGFloat y = pathCenter.y * 1.5 ;
    
    UIBezierPath * path1 = [UIBezierPath bezierPathWithArcCenter:CGPointMake(x, y) radius:Logo_Size/2.0 startAngle:M_PI endAngle:M_PI * 2 clockwise:YES];
    
    [path appendPath:path1];
    
    //新建图层——绘制上面的圆圈和勾
    showLayer.strokeColor = [UIColor redColor].CGColor;
    showLayer.path = path.CGPath;
    
    [_showLayerArray addObject:showLayer];
    
}

- (void)initPathForWaringShapeLayerWithFace
{
    CAShapeLayer * showLayer = [self layerConfig];

    
    UIBezierPath *path = [self FacePath];
    
    CGPoint pathCenter = CGPointMake(_logoView.frame.size.width/2, _logoView.frame.size.height/4);
    
    
    CGFloat x = pathCenter.x * 0.9 ;
    CGFloat y = pathCenter.y * 1.4 ;
    
    [path moveToPoint:CGPointMake(x, y)];
    [path addLineToPoint:CGPointMake(x*1.2, y)];
    
    
    
    //新建图层——绘制上面的圆圈和勾
    showLayer.strokeColor = [UIColor orangeColor].CGColor;
    showLayer.path = path.CGPath;
    
    [_showLayerArray addObject:showLayer];
}

#pragma mark 经典提示
- (void)initPathForRightShapeLayer
{
    
    CAShapeLayer * showLayer = [self layerConfig];

    
    CGPoint pathCenter = CGPointMake(_logoView.frame.size.width/2, _logoView.frame.size.height/4);
    UIBezierPath *path = [UIBezierPath bezierPathWithArcCenter:pathCenter radius:Logo_Size startAngle:0 endAngle:M_PI*2 clockwise:YES];
    
    path.lineCapStyle = kCGLineCapRound;
    path.lineJoinStyle = kCGLineJoinRound;
    
    pathCenter.x -= 3;
    
    CGFloat x = pathCenter.x * 0.88;
    CGFloat y = pathCenter.y * 1.13;
    //勾的起点
    [path moveToPoint:CGPointMake(x, y)];
    //勾的最底端
    CGPoint p1 = CGPointMake(pathCenter.x, pathCenter.y * 1.3);
    [path addLineToPoint:p1];
    //勾的最上端
    CGPoint p2 = CGPointMake(pathCenter.x * 1.2,pathCenter.y * 0.8);
    [path addLineToPoint:p2];
    //新建图层——绘制上面的圆圈和勾
    showLayer.strokeColor = [UIColor greenColor].CGColor;
    showLayer.path = path.CGPath;
    
    [_showLayerArray addObject:showLayer];
}

- (void)initPathForWrongShapeLayer
{
    
    CAShapeLayer * showLayer = [self layerConfig];

    
    CGFloat x = _logoView.frame.size.width / 2 - Logo_Size;
    CGFloat y = Logo_Size / 2.0;
    
    //圆角矩形
    UIBezierPath * path = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(x, y, Logo_Size * 2, Logo_Size * 2) cornerRadius:5];
    path.lineCapStyle = kCGLineCapRound;
    path.lineJoinStyle = kCGLineJoinRound;
    
    CGFloat space = Logo_Size / 2;
    //斜线1
    [path moveToPoint:CGPointMake(x + space, y + space)];
    CGPoint p1 = CGPointMake(x + Logo_Size * 2 - space, y + Logo_Size * 2 - space);
    [path addLineToPoint:p1];
    //斜线2
    [path moveToPoint:CGPointMake(x + Logo_Size * 2 - space , y + space)];
    CGPoint p2 = CGPointMake(x + space, y + Logo_Size * 2 - space);
    [path addLineToPoint:p2];
    
    //新建图层——绘制上述路径
    showLayer.strokeColor = [UIColor redColor].CGColor;
    showLayer.path = path.CGPath;
    [_showLayerArray addObject:showLayer];
    
}

- (void)initPathForWaringShapeLayer
{
    CAShapeLayer * showLayer = [self layerConfig];

    
    UIBezierPath *path = [UIBezierPath bezierPath];
    path.lineCapStyle = kCGLineCapRound;
    path.lineJoinStyle = kCGLineJoinRound;
    
    //绘制三角形
    CGFloat x = _logoView.frame.size.width/2;
    CGFloat y = Logo_Size / 2.0;
    //三角形起点（上方）
    [path moveToPoint:CGPointMake(x, y)];
    //左边
    CGPoint p1 = CGPointMake(x - Logo_Size , x * 0.8);
    [path addLineToPoint:p1];
    //右边
    CGPoint p2 = CGPointMake(x + Logo_Size , x * 0.8);
    [path addLineToPoint:p2];
    //关闭路径
    [path closePath];
    
    //绘制感叹号
    //绘制直线
    [path moveToPoint:CGPointMake(x, x * 0.3)];
    CGPoint p4 = CGPointMake(x, x * 0.6);
    [path addLineToPoint:p4];
    //绘制实心圆
    [path moveToPoint:CGPointMake(x, x * 0.7)];
    [path addArcWithCenter:CGPointMake(x, x * 0.7) radius:2 startAngle:0 endAngle:M_PI*2 clockwise:YES];
    //新建图层——绘制上述路径
    showLayer.strokeColor = [UIColor orangeColor].CGColor;
    showLayer.path = path.CGPath;
    [_showLayerArray addObject:showLayer];
}

/**
 *  @Author wang kun
 *
 *  初始化控件
 */
- (void)controlsInit
{
    
    CGFloat x = _logoView.frame.origin.x;
    CGFloat y = _logoView.frame.origin.y;
    CGFloat height = _logoView.frame.size.height;
    CGFloat width = _logoView.frame.size.width;
    
    _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(x ,y + height / 2, width, Title_Font)];
    [_titleLabel setFont:[UIFont systemFontOfSize:Title_Font]];
    [_titleLabel setTextAlignment:NSTextAlignmentCenter];

    _detailLabel  = [[UILabel alloc] initWithFrame:CGRectMake(x ,_titleLabel.bottomS + 5, width, Detial_Font )];
    _detailLabel.textColor = [UIColor grayColor];
    [_detailLabel setFont:[UIFont systemFontOfSize:Detial_Font]];
    [_detailLabel setTextAlignment:NSTextAlignmentCenter];

    CGFloat centerY = _detailLabel.center.y + 20;
    
    _OkButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _OkButton.layer.cornerRadius = 5;
    _OkButton.titleLabel.font = [UIFont systemFontOfSize:Button_Font];
    _OkButton.center = CGPointMake(_detailLabel.center.x + 50, centerY);
    _OkButton.bounds = CGRectMake(0, 0, Button_Size_Width, Button_Size_Height);
    _OkButton.backgroundColor = OKBUTTON_BGCOLOR;

    
    _canleButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _canleButton.center = CGPointMake(_detailLabel.center.x - 50, centerY);
    _canleButton.bounds = CGRectMake(0, 0, Button_Size_Width, Button_Size_Height);
    _canleButton.backgroundColor = CANCELBUTTON_BGCOLOR;
    _canleButton.layer.cornerRadius = 5;
    _canleButton.titleLabel.font = [UIFont systemFontOfSize:Button_Font];
    

    [self addSubview:_titleLabel];
    [self addSubview:_detailLabel];
    [self addSubview:_OkButton];
    [self addSubview:_canleButton];
    _titleLabel.alpha = 0;
    _detailLabel.alpha = 0;
    _OkButton.alpha = 0;
    _canleButton.alpha = 0;

    _canleButton.hidden = YES;
    _OkButton.hidden = YES;
    
    _OkButton.tag = TAG;
    _canleButton.tag = TAG + 1;
    
    [_OkButton addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
    [_canleButton addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];

}

/**
 *  @Author wang kun
 *
 *  初始化logo视图——画布
 */
- (void)logoInit
{
        //新建画布
        _logoView                     = [UIView new];
        _logoView.center              = self.center;
        _logoView.bounds              = CGRectMake(0, 0, Logo_View_Size, Logo_View_Size);
        _logoView.backgroundColor     = [UIColor whiteColor];
        _logoView.layer.cornerRadius  = 10;
        _logoView.layer.shadowColor   = [UIColor blackColor].CGColor;
        _logoView.layer.shadowOffset  = CGSizeMake(0, 5);
        _logoView.layer.shadowOpacity = 0.3f;
        _logoView.layer.shadowRadius  = 10.0f;
        [self addSubview:_logoView];
}
/**
 *  @author by wangkun, 15-03-11 17:03:53
 *
 *  添加按钮
 *
 *  @param cancle 按钮标题
 *  @param ok     按钮标题
 */
- (void) addButtonTitleWithCancle:(NSString *)cancle OK:(NSString *)ok
{
    BOOL flag = NO;
    if (cancle == nil && ok != nil ) {
        flag = YES;
    }
    
    CGFloat centerY = _detailLabel.bottomS + Button_Size_Height / 2.0 + 5;

    if (flag) {
        _OkButton.center = CGPointMake(_detailLabel.center.x, centerY);
        _OkButton.bounds = CGRectMake(0, 0, Button_Size_Width, Button_Size_Height);
        _canleButton.hidden = YES;
        
    }
    else{
        _canleButton.hidden = NO;
        [_canleButton setTitle:cancle forState:UIControlStateNormal];
        _OkButton.center = CGPointMake(_detailLabel.center.x + 50, centerY);
        _OkButton.bounds = CGRectMake(0, 0, Button_Size_Width, Button_Size_Height);
    }
    _OkButton.hidden = NO;
    [_OkButton setTitle:ok forState:UIControlStateNormal];

}
/**
 *  @author by wangkun, 15-03-11 17:03:30
 *
 *  添加标题信息和详细信息
 *
 *  @param title  标题内容
 *  @param detail 详细内容
 */
- (void)addTitle:(NSString *)title detail:(NSString *)detail
{
    
    _titleLabel.text  = title;
    _detailLabel.text = detail;

}


- (void)show
{    
    [KEYWINDOW addSubview:self];
    self.hidden = NO;
}

- (void)hide
{
    [self isShowLayer:NO];
    [self isShowControls:NO];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.55 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self removeFromSuperview];
        self.hidden = YES;
    });
}
- (void)isShowControls:(BOOL)show
{
    NSUInteger alpha = show ? 1 : 0;
    
    [UIView animateWithDuration:0.5 animations:^{
        _titleLabel.alpha = alpha;
        _detailLabel.alpha = alpha;
        _OkButton.alpha = alpha;
        _canleButton.alpha = alpha;
        _logoView.alpha = alpha;
    } ];
}

- (void)isShowLayer:(BOOL)show
{
    
    //strokeEnd
    //通过对from，to赋值，可让贝塞尔动画从终点至起点，或起点至终点
    NSNumber * from = show ? @0 : @1;
    NSNumber * to = show ? @1 : @0;
    
    [_logoView.layer removeAllAnimations];
    [_logoView.layer.sublayers makeObjectsPerformSelector:@selector(removeFromSuperlayer)];
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:NSStringFromSelector(@selector(strokeEnd))];
    animation.fromValue = from;
    animation.toValue = to;
    animation.duration = 0.5;
    NSUInteger index = (NSUInteger)self.style;
    CAShapeLayer * layer = [_showLayerArray objectAtIndex:(index > 0 ? index - 1 :index)];
    [layer addAnimation:animation forKey:NSStringFromSelector(@selector(strokeEnd))];
    [_logoView.layer addSublayer:layer];
}

#pragma mark 按钮点击代理
/**
 *  @author by wangkun, 15-03-11 17:03:29
 *
 *  按钮点击事件
 *
 *  @param sender 按钮
 */

- (void)buttonClick:(UIButton *)sender
{
    [self hide];

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        self.hidden = YES;
        if (_WKAlertViewDelegate && [_WKAlertViewDelegate respondsToSelector:@selector(alertViewClick:)] ) {
            [_WKAlertViewDelegate alertViewClick:sender.tag - TAG ];
        }
        else if(_clickBlock != nil)
        {
            self.clickBlock(sender.tag - TAG);
        }
    });
    
}


@end

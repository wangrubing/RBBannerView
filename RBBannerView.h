//
//  RBBannerView.h
//  KeLuTravelProgram
//
//  Created by qianfeng on 15/10/26.
//  Copyright © 2015年 wrb. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RBBannerView : UIView
@property (nonatomic, strong) NSArray *imageArray;
@property (nonatomic, copy) void (^imageViewTouchBlock)(RBBannerView *bannerView, NSInteger index);
-(void)setImageViewTouchBlock:(void (^)(RBBannerView *bannerView, NSInteger index))imageViewTouchBlock;
-(void)scaleHeaderViewWithOffset:(CGFloat)offset;
@end

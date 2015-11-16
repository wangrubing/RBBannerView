//
//  RBBannerView.m
//  KeLuTravelProgram
//
//  Created by qianfeng on 15/10/26.
//  Copyright © 2015年 wrb. All rights reserved.
//

#import "RBBannerView.h"
#import "UIImageView+AFNetworking.h"
#import "UIViewAdditions.h"

#define ScreenWidth [UIScreen mainScreen].bounds.size.width
#define BannerHeight 200.

@interface RBBannerView ()<UIScrollViewDelegate>
@property (nonatomic, weak) UIScrollView *scrollView;
@property (nonatomic, weak) UIPageControl *pageControl;
@property (nonatomic, weak) NSTimer *timer;
@property (nonatomic, strong) NSArray *imageViewArray;
@end

@implementation RBBannerView

-(void)willMoveToSuperview:(UIView *)newSuperview
{
    self.frame = CGRectMake(0, 0, ScreenWidth, BannerHeight);
}

-(void)setImageArray:(NSArray *)imageArray
{
    _imageArray = imageArray;
    
    [self createUI];
}

-(void)createUI
{
    [self scrollView];
    [self pageControl];
    
    NSMutableArray *imageArray = [NSMutableArray array];
    [imageArray addObject:[self.imageArray lastObject]];
    [imageArray addObjectsFromArray:self.imageArray];
    [imageArray addObject:[self.imageArray firstObject]];
    
    NSMutableArray *imageViewArray = [NSMutableArray array];
    
    float x = 0;
    for (NSInteger i=0; i<imageArray.count; i++)
    {
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(x, 0, self.width, self.height)];
        
        NSString *imageUrl = imageArray[i];
        
        [imageView setImageWithURL:[NSURL URLWithString:imageUrl]];
        
        [self.scrollView addSubview:imageView];
        
        x += self.width;
        
        imageView.tag = i;
        imageView.userInteractionEnabled = YES;
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(imageViewTouch:)];
        [imageView addGestureRecognizer:tap];
        
        [imageViewArray addObject:imageView];
    }
    [imageViewArray removeObjectAtIndex:0];
    [imageViewArray removeLastObject];
    self.imageViewArray = imageViewArray;
    
    self.scrollView.contentSize = CGSizeMake(x, self.height);
    self.scrollView.contentOffset = CGPointMake(self.width, 0);
    
    [self startScroll];
}

#pragma mark - imageView点击手势事件
-(void)imageViewTouch:(UIGestureRecognizer *)gesture
{
    NSLog(@"%ld",gesture.view.tag);
    if (self.imageViewTouchBlock)
    {
    
    }
}

#pragma mark - 视图控件懒加载
-(UIScrollView *)scrollView
{
    if (_scrollView == nil)
    {
        //创建scrollView
        UIScrollView *scrollView = [[UIScrollView alloc] init];
        [self addSubview:scrollView];
        _scrollView = scrollView;
        scrollView.frame = self.bounds;
        scrollView.pagingEnabled = YES;
        scrollView.showsHorizontalScrollIndicator = NO;
        scrollView.delegate = self;
    }
    return _scrollView;
}

-(UIPageControl *)pageControl
{
    if (_pageControl == nil)
    {
        //创建pageControl
        UIPageControl *pageControl = [[UIPageControl alloc] init];
        [self addSubview:pageControl];
        _pageControl = pageControl;
        CGFloat pageX = 130;
        CGFloat pageH = 20;
        CGFloat pageY = self.height - pageH - 10;
        CGFloat pageW = 100;
        pageControl.frame = CGRectMake(pageX, pageY, pageW, pageH);
        pageControl.numberOfPages = self.imageArray.count;
        pageControl.currentPage = 0;
    }
    return _pageControl;
}

#pragma mark - 自动滚动
-(void)autoScroll
{
    NSInteger currentPage = self.pageControl.currentPage >=self.imageArray.count-1? 0:self.pageControl.currentPage+1;
    
    self.pageControl.currentPage = currentPage;
    
    CGFloat pointX = self.scrollView.width * (currentPage + 1);
    
    self.scrollView.contentOffset = CGPointMake(pointX, 0);
}

-(void)startScroll
{
    if (self.timer == nil)
    {
        NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:2 target:self selector:@selector(autoScroll) userInfo:nil repeats:YES];
        
        [[NSRunLoop mainRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
        
        self.timer = timer;
    }
}

-(void)stopScroll

{
    [self.timer invalidate];
    self.timer = nil;
}

-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView

{
    NSInteger page = scrollView.contentOffset.x / scrollView.width - 1;
    
    self.pageControl.currentPage  = page;
    
    if (page == self.imageArray.count)
    {
        self.pageControl.currentPage = 0;
        
        [self.scrollView setContentOffset:CGPointMake(self.width, 0) animated:NO];
    }
    else if (page == -1)
    {
        self.pageControl.currentPage = self.imageArray.count;
        
        [self.scrollView setContentOffset:CGPointMake(self.width * self.imageArray.count, 0) animated:NO];
    }
}

-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView

{
    [self stopScroll];
}

-(void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    [self startScroll];
}

-(void)scaleHeaderViewWithOffset:(CGFloat)offset
{
    if (offset < 0)
    {
        [self stopScroll];
        NSInteger count = _pageControl.currentPage;
        
        CGRect selfFrame = self.frame;
        selfFrame.origin.y = offset;
        selfFrame.size.height = BannerHeight - offset;
        self.frame = selfFrame;
        
        _scrollView.frame = selfFrame;
        
        UIImageView *imageView = _imageViewArray[count];
        CGRect imageFrame = imageView.frame;
        imageFrame.size.width = ScreenWidth - offset;
        imageFrame.size.height = BannerHeight - offset;
        imageView.frame = imageFrame;
    }
    else
    {
        [self startScroll];
    }
}

@end

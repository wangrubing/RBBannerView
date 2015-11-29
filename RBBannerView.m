
#import "RBBannerView.h"
#import "UIImageView+AFNetworking.h"
#import "Masonry.h"

#define ScreenWidth [UIScreen mainScreen].bounds.size.width
#define BannerHeight 200.

@interface RBBannerView ()<UIScrollViewDelegate>
@property (nonatomic, weak) UIScrollView *scrollView;
@property (nonatomic, weak) UIPageControl *pageControl;
@property (nonatomic, weak) UIView *leftView;
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

-(UIView *)leftView
{
    if (_leftView == nil)
    {
        UIView *view = [[UIView alloc] initWithFrame:CGRectZero];
        _leftView = view;
    }
    return _leftView;
}

-(void)createUI
{
    [self scrollView];
    [self pageControl];
    
    NSMutableArray *imageArray = [NSMutableArray array];
    if (self.imageArray.count != 0)
    {
        [imageArray addObject:[self.imageArray lastObject]];
        [imageArray addObjectsFromArray:self.imageArray];
        [imageArray addObject:[self.imageArray firstObject]];
    }
    
    NSMutableArray *imageViewArray = [NSMutableArray array];
    
    float x = 0;
    for (NSInteger i=0; i<imageArray.count; i++)
    {
        UIImageView *imageView = [[UIImageView alloc] init];
        NSString *imageUrl = imageArray[i];
        [imageView setImageWithURL:[NSURL URLWithString:imageUrl]];
        [self.scrollView addSubview:imageView];
        
        imageView.tag = i;
        imageView.userInteractionEnabled = YES;
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(imageViewTouch:)];
        [imageView addGestureRecognizer:tap];
        
        [imageViewArray addObject:imageView];
    }
    
    for (NSInteger i=0; i<imageArray.count; i++)
    {
        UIImageView *imageView = imageViewArray[i];
        UIView *leftView = i==0?self.leftView:imageViewArray[i-1];
        [imageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(leftView.mas_right);
            make.top.equalTo(@(0));
            make.width.equalTo(@(ScreenWidth));
            make.height.equalTo(@(BannerHeight));
        }];
        x += ScreenWidth;
    }
    
    if (imageViewArray.count != 0)
    {
        [imageViewArray removeObjectAtIndex:0];
        [imageViewArray removeLastObject];
        self.imageViewArray = imageViewArray;
    }
    
    self.scrollView.contentSize = CGSizeMake(x, self.frame.size.height);
    self.scrollView.contentOffset = CGPointMake(self.frame.size.width, 0);
    
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
        CGFloat pageY = self.frame.size.height - pageH - 10;
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
    
    CGFloat pointX = self.scrollView.frame.size.width * (currentPage + 1);
    
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
    NSInteger page = scrollView.contentOffset.x / scrollView.frame.size.width - 1;
    
    self.pageControl.currentPage  = page;
    
    if (page == self.imageArray.count)
    {
        self.pageControl.currentPage = 0;
        
        [self.scrollView setContentOffset:CGPointMake(self.frame.size.width, 0) animated:NO];
    }
    else if (page == -1)
    {
        self.pageControl.currentPage = self.imageArray.count;
        
        [self.scrollView setContentOffset:CGPointMake(self.frame.size.width * self.imageArray.count, 0) animated:NO];
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
        selfFrame.origin.x = offset/2;
        selfFrame.size.width = ScreenWidth - offset;
        self.frame = selfFrame;
        
        _scrollView.frame = selfFrame;
        
        UIImageView *imageView = _imageViewArray[count];
        [imageView mas_updateConstraints:^(MASConstraintMaker *make) {
             make.width.equalTo(@(ScreenWidth-offset));
             make.height.equalTo(@(BannerHeight-offset));
        }];
    }
    else
    {
        [self startScroll];
    }
}

@end

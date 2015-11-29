# RBBannerView
传入一个图片地址数组，快速创建头部循环自动滚动广告视图
使用时需要引入Masonry和UIImageView+AFNetworking
#define BannerHeight 200 .m文件中有广告视图的高度宏定义，可根据需求修改宏定义。

快速创建无限轮播视图的代码
RBBannerView *bannerView = [[RBBannerView alloc] init];
self.tableView.tableHeaderView = bannerView;
self.bannerView = bannerView;
self.bannerView.imageArray = 图片地址数组;

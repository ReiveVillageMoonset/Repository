//
//  ViewController.m
//  AFNetworking使用
//
//  Created by qianfeng on 15/12/4.
//  Copyright © 2015年 ZHY. All rights reserved.
//

#import "ViewController.h"
#import "AFNetworking.h"

#define SCREEN_WIDTH [UIScreen mainScreen].bounds.size.width
#define RANDOM_COLOR [UIColor colorWithRed:arc4random_uniform(256)/255.0 green:arc4random_uniform(256)/255.0 blue:arc4random_uniform(256)/255.0 alpha:1]

static NSString *const QQDownloadURL = @"http://dldir1.qq.com/qqfile/qq/QQ7.9/16621/QQ7.9.exe";
static NSString *const ImageURL = @"http://images.cnitblog.com/i/607542/201404/050759358125578.png";

@interface ViewController ()

@property (nonatomic, strong) NSURLSessionDownloadTask *downloadTask;
@property (nonatomic, strong) UIProgressView *progressView;
@property (nonatomic, strong) AFURLSessionManager *manager;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self backstageDownloads];
//    [self downloadImageWithAFHTTPRequestOperation];
//    [self downloadQQWithAFHTTPSessionManager];
}

//在后台进行上传或者下载任务的会话,是被系统的程序管理而不是应用本身来管理的.所以呢,当app挂了,推出了甚至崩溃了,这个下载还是继续着的
- (void)backstageDownloads {
    
    //进行后台下载会话配置
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration backgroundSessionConfigurationWithIdentifier:@"downloads"];
    //初始化SessionManager管理器
    _manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:configuration];
    //获取添加到SessionManager管理器中的下载任务
    NSArray *downloadTasks = [_manager downloadTasks];
    //如果有下载任务
    if (downloadTasks.count) {
        
        NSLog(@"downloadTasks:%@", downloadTasks);
        //继续全部的下载
        for (NSURLSessionDownloadTask *downloadTask in downloadTasks) {
            
            [downloadTask resume];
        }
    }
    
    //点击按钮添加一个下载任务到manager中
    _progressView = [[UIProgressView alloc] initWithFrame:CGRectMake(50, 100, SCREEN_WIDTH - 100, 5)];
    [self.view addSubview:_progressView];
    
    UIButton *resumeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    resumeButton.backgroundColor = RANDOM_COLOR;
    [resumeButton setTitle:@"Start" forState:UIControlStateNormal];
    [resumeButton addTarget:self action:@selector(startDownload) forControlEvents:UIControlEventTouchUpInside];
    resumeButton.frame = CGRectMake(50, 150, 100, 30);
    [self.view addSubview:resumeButton];
    
    UIButton *suspendButton = [UIButton buttonWithType:UIButtonTypeCustom];
    suspendButton.backgroundColor = RANDOM_COLOR;
    [suspendButton setTitle:@"Suspend" forState:UIControlStateNormal];
    [suspendButton addTarget:self action:@selector(suspendSuspend) forControlEvents:UIControlEventTouchUpInside];
    suspendButton.frame = CGRectMake(SCREEN_WIDTH - 150, 150, 100, 30);
    [self.view addSubview:suspendButton];
    
    NSLog(@"%@", NSHomeDirectory());
    
    NSProgress *progress;
    //组织URL
    NSURL *url = [NSURL URLWithString:QQDownloadURL];
    //组织请求
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    //给SessionManager管理器添加一个下载任务
    _downloadTask = [_manager downloadTaskWithRequest:request progress:&progress destination:^NSURL * _Nonnull(NSURL * _Nonnull targetPath, NSURLResponse * _Nonnull response) {
        
        NSURL *documentPath = [NSURL fileURLWithPath:[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject]];
        return [documentPath URLByAppendingPathComponent:response.suggestedFilename];
    } completionHandler:^(NSURLResponse * _Nonnull response, NSURL * _Nullable filePath, NSError * _Nullable error) {
        
        [progress removeObserver:self forKeyPath:NSStringFromSelector(@selector(fractionCompleted))];
    }];
    
    [progress setUserInfoObject:@"doSomething" forKey:@"ZHY"];
    
    [progress addObserver:self
               forKeyPath:NSStringFromSelector(@selector(fractionCompleted))
                  options:NSKeyValueObservingOptionNew
                  context:NULL];
}

- (void)downloadImageWithAFHTTPRequestOperation {
    
    //组织一个请求
    NSURL *url = [NSURL URLWithString:ImageURL];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
    //创建请求操作
    AFHTTPRequestOperation *requestOperation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    
    //进行操作的配置(下载图片还是其他类型)
    requestOperation.responseSerializer = [AFImageResponseSerializer serializer];
    
    //设置获取数据的block
    [requestOperation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation * _Nonnull operation, UIImage * _Nonnull responseObject) {
        
        
    } failure:^(AFHTTPRequestOperation * _Nonnull operation, NSError * _Nonnull error) {
        
        NSLog(@"%@", error);
    }];
    
    [requestOperation start];
}

- (void)downloadQQWithAFHTTPSessionManager {
    
    _progressView = [[UIProgressView alloc] initWithFrame:CGRectMake(50, 100, SCREEN_WIDTH - 100, 5)];
    [self.view addSubview:_progressView];
    
    UIButton *resumeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    resumeButton.backgroundColor = RANDOM_COLOR;
    [resumeButton setTitle:@"Start" forState:UIControlStateNormal];
    [resumeButton addTarget:self action:@selector(startDownload) forControlEvents:UIControlEventTouchUpInside];
    resumeButton.frame = CGRectMake(50, 150, 100, 30);
    [self.view addSubview:resumeButton];
    
    UIButton *suspendButton = [UIButton buttonWithType:UIButtonTypeCustom];
    suspendButton.backgroundColor = RANDOM_COLOR;
    [suspendButton setTitle:@"Suspend" forState:UIControlStateNormal];
    [suspendButton addTarget:self action:@selector(suspendSuspend) forControlEvents:UIControlEventTouchUpInside];
    suspendButton.frame = CGRectMake(SCREEN_WIDTH - 150, 150, 100, 30);
    [self.view addSubview:suspendButton];
    
    NSLog(@"%@", NSHomeDirectory());
    
    //AFNetworking使用
    
    //定义一个progress指针
    NSProgress *progress;
    //创建一个URL链接
    NSURL *url = [NSURL URLWithString:QQDownloadURL];
    
    //初始化一个请求
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
    //获取一个Session管理器
    AFHTTPSessionManager *session = [AFHTTPSessionManager manager];
    
    //创建下载任务
    _downloadTask = [session downloadTaskWithRequest:request progress:&progress destination:^NSURL * _Nonnull(NSURL * _Nonnull targetPath, NSURLResponse * _Nonnull response) {
        
        //拼接一个文件夹路径
        NSURL *documentsDirectoryURL = [[NSFileManager defaultManager] URLForDirectory:NSDocumentDirectory inDomain:NSUserDomainMask appropriateForURL:nil create:NO error:nil];
        
        //根据网址信息拼接成一个完整的文件存储路径并返回给block
        return [documentsDirectoryURL URLByAppendingPathComponent:[response suggestedFilename]];
    } completionHandler:^(NSURLResponse * _Nonnull response, NSURL * _Nullable filePath, NSError * _Nullable error) {
        
        //结束后移除此progress
        [progress removeObserver:self forKeyPath:NSStringFromSelector(@selector(fractionCompleted))];
    }];
    
    //设置此progress的唯一标示符
    [progress setUserInfoObject:@"someThing" forKey:@"ZHY"];
    
    //给此progress添加监听任务
    [progress addObserver:self
               forKeyPath:NSStringFromSelector(@selector(fractionCompleted))
                  options:NSKeyValueObservingOptionNew
                  context:NULL];
}

- (void)startDownload {
    
    [_downloadTask resume];
}

- (void)suspendSuspend {
    
    [_downloadTask suspend];
}

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object change:(NSDictionary<NSString *,id> *)change
                       context:(void *)context {
    
    if ([keyPath isEqualToString:NSStringFromSelector(@selector(fractionCompleted))] &&
        [object isKindOfClass:[NSProgress class]]) {
        
        NSProgress *progress = (NSProgress *)object;
//        NSLog(@"Progress is %.1f", progress.fractionCompleted);
        dispatch_async(dispatch_get_main_queue(), ^{
            
            _progressView.progress = progress.fractionCompleted;
        });
        
        
        //打印此唯一标示符
//        NSLog(@"%@", progress.userInfo);
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

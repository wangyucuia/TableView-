//
//  ViewController.m
//  TableView 动画
//
//  Created by 王玉翠 on 16/8/9.
//  Copyright © 2016年 王玉翠. All rights reserved.
//

#import "ViewController.h"

#import <AVFoundation/AVFoundation.h>

@interface ViewController ()

//AVCaptureSession对象来执行输入设备和输出设备之间的数据传输
@property (nonatomic,strong) AVCaptureSession *session;

//AVCaptureDeviceInput对象是输入流
@property (nonatomic, strong) AVCaptureDeviceInput *videoInput;

//照片输出流对象
@property (nonatomic, strong) AVCaptureStillImageOutput *stillImageOutput;

//预览图层,来显示照相机拍摄到的画面
@property (nonatomic, strong) AVCaptureVideoPreviewLayer *previewLayer;

//切换前后摄像头的按钮
@property (nonatomic, strong) UIButton *toggleButton;

//拍照按钮
@property (nonatomic, strong) UIButton *shutterButton;

//放置预览图层的view
@property (nonatomic, strong) UIView *cameraShowView;

//用来展示拍照获取到的照片

@property (nonatomic, strong) UIImageView *imageShowView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}


- (instancetype)init
{
    self = [super init];
    if (self) {
        [self initialSession];
        [self initCameraShowView];
        [self initButton];
        [self initImageShowView];
        
    }
    return self;
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self setUpCemeraLayer];
    
}


-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    if (self.session) {
        [self.session stopRunning];
        
    }
    
}

-(void)initialSession{
    
    self.session = [[AVCaptureSession alloc] init];
    self.videoInput = [[AVCaptureDeviceInput alloc] initWithDevice:[self backCamera] error:nil];
    self.stillImageOutput = [[AVCaptureStillImageOutput alloc] init];
    // 这里输出流的设置参数AVVideoCodecJPEG 参数表示以JPEG的图片格式输出图片
    NSDictionary *outputSettings = [[NSDictionary alloc] initWithObjectsAndKeys:AVVideoCodecJPEG,AVVideoCodecKey, nil];
    [self.stillImageOutput setOutputSettings:outputSettings];
    
    if ([self.session canAddInput:self.videoInput]) {
        [self.session addInput:self.videoInput];
    }
    if ([self.session canAddOutput:self.stillImageOutput]) {
        [self.session addOutput:self.stillImageOutput];
        
    }
}


-(void)initCameraShowView{
    
    self.cameraShowView = [[UIView alloc] initWithFrame:self.view.frame];
    [self.view addSubview:self.cameraShowView];
}

-(void)initImageShowView{
    
    self.imageShowView = [[UIImageView alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height - 200, 200, 200)];
    self.imageShowView.contentMode = UIViewContentModeScaleToFill;
    self.imageShowView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.imageShowView];
    
    
}

-(void)initButton{
    
    self.shutterButton = [UIButton buttonWithType:UIButtonTypeSystem];
    self.shutterButton.frame = CGRectMake(10, 30, 60, 30);
    self.shutterButton.backgroundColor = [UIColor cyanColor];
    [self.shutterButton setTitle:@"拍照" forState:UIControlStateNormal];
    [self.shutterButton addTarget:self action:@selector(shutterCamera) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.shutterButton];
    
    
    self.toggleButton = [UIButton buttonWithType:(UIButtonTypeSystem)];
    self.toggleButton.frame = CGRectMake(80, 30, 60, 30);
    self.toggleButton.backgroundColor = [UIColor cyanColor];
    [self.toggleButton setTitle:@"切换摄像头" forState:(UIControlStateNormal)];
    [self.toggleButton addTarget:self action:@selector(toggleCamera) forControlEvents:(UIControlEventTouchUpInside)];
    
    [self.view addSubview:self.toggleButton];
}


//这是获取前后摄像头对象的方法
-(AVCaptureDevice *)cameraWithPosition:(AVCaptureDevicePosition)position{
    
    NSArray *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    for (AVCaptureDevice *device in devices) {
        if (device.position == position) {
            return device;
        }
    }
    
    return nil;
}

-(AVCaptureDevice *)frontCamera{
    
    return [self cameraWithPosition:AVCaptureDevicePositionFront];
    
}


-(AVCaptureDevice *)backCamera{
    
    return [self cameraWithPosition:AVCaptureDevicePositionBack];
    
}


-(void)setUpCemeraLayer{
    
    if (self.previewLayer == nil) {
        self.previewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:self.session];
        UIView *view = self.cameraShowView;
        CALayer *viewLayer = [view layer];
        //UIView的clipsToBounds 属性和CALayer的setMaskeToBounds属性表示的意思是一直的,决定子视图的显示范围,当取值为YES的时候,裁剪超出父视图范围的子视图部分,当取值为NO时,不裁剪视图
        [viewLayer setMasksToBounds:YES];
        
        CGRect bounds = [view bounds];
        [self.previewLayer setFrame:bounds];
        [self.previewLayer setVideoGravity:AVLayerVideoGravityResizeAspect];
        
        [viewLayer addSublayer:self.previewLayer];
        
        
    }
    
    
}

//这是拍照按钮的方法
-(void)shutterCamera{
    AVCaptureConnection *videoConnection = [self.stillImageOutput connectionWithMediaType:AVMediaTypeVideo];
    if (!videoConnection) {
        return ;
    }
    
    [self.stillImageOutput captureStillImageAsynchronouslyFromConnection:videoConnection completionHandler:^(CMSampleBufferRef imageDataSampleBuffer, NSError *error) {
        if (imageDataSampleBuffer == NULL) {
            return ;
        }
        NSData *imageData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageDataSampleBuffer];
        UIImage *imagae = [UIImage imageWithData:imageData];
        NSLog(@"image size = %@",NSStringFromCGSize(imagae.size));
        self.imageShowView.image = imagae;
        
    }];
    
}


//这是切换镜头的按钮方法
-(void)toggleCamera{
    NSInteger cameraCount = [[AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo] count];
    if (cameraCount > 1) {
        NSError *error;
        AVCaptureDeviceInput *newVideoInput;
        AVCaptureDevicePosition position = [[_videoInput device]position];
        if (position == AVCaptureDevicePositionBack) {
            newVideoInput = [[AVCaptureDeviceInput alloc] initWithDevice:[self frontCamera] error:&error];
        }else if (position == AVCaptureDevicePositionFront){
            newVideoInput = [[AVCaptureDeviceInput alloc] initWithDevice:[self backCamera] error:&error];
            
        }else{
            
            return ;
            
        }
        
        if (newVideoInput != nil) {
            [self.session beginConfiguration];
            [self.session removeInput:self.videoInput];
            if ([self.session canAddInput:newVideoInput]) {
                [self.session addInput:newVideoInput];
                self.videoInput = newVideoInput;
            }else{
                [self.session addInput:self.videoInput];
                
            }
            [self.session addInput:self.videoInput];
        }else if(error){
            NSLog(@"toggle carema failed,error = %@",error);
            
        }
        
    }
    
    
}


-(void)httpHead{
    
    NSString *string = @"dhd";
    NSURL *url = [NSURL URLWithString:string];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    //请求头
    //头字段的值
    //field： 头字段的名字。为了跟HTTP RFC保持一致，这里头字段的名字忽略大小写。
    
    [request addValue:@"sssss" forHTTPHeaderField:@""];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

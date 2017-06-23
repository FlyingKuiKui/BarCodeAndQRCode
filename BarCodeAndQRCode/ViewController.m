//
//  ViewController.m
//  BarCodeAndQRCode
//
//  Created by 王盛魁 on 2017/6/23.
//  Copyright © 2017年 WangShengKui. All rights reserved.
//

#import "ViewController.h"
#import "BarCodeAndQRCodeManager.h"
#import <AVFoundation/AVFoundation.h>
#import "QRScanView.h"
@interface ViewController ()<AVCaptureMetadataOutputObjectsDelegate>
@property (nonatomic,assign) BOOL isQRCodeCaptured;
@property (nonatomic, assign) CGRect scanRect;
@property (nonatomic,strong) UILabel *lbl;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.lbl = [[UILabel alloc]initWithFrame:CGRectMake(10, 70, 300, 50)];
    self.lbl.textColor = [UIColor darkTextColor];
    self.lbl.numberOfLines = 0;
    self.lbl.backgroundColor = [UIColor darkGrayColor];
    self.lbl.font = [UIFont systemFontOfSize:12];
    [self.view addSubview:self.lbl];
    /*
     生成二维码、条形码
     */
//        [self testGenerateCode];
    
    /*
     识别图片中的二维码、条形码
     */
        [self decodeQRCode];
    
    /*
     从摄像头中获取二维码
     */
//    [self getImageMessageFromCamera];

    /*
     测试手电筒的开关
     */
    UIButton *torchBtn = [[UIButton alloc]initWithFrame:CGRectMake(10, 200, 200, 50)];
    torchBtn.backgroundColor = [UIColor blueColor];
    [torchBtn setTitle:@"手电筒开关" forState:UIControlStateNormal];
    [torchBtn setTintColor:[UIColor whiteColor]];
    [torchBtn addTarget:self action:@selector(openOrCloseTorchlight) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:torchBtn];
    // Do any additional setup after loading the view, typically from a nib.
}
#pragma mark - 从摄像头中获取二维码
// 记得导入AVFoundation框架
- (void)getImageMessageFromCamera{
    self.isQRCodeCaptured = NO;
    self.scanRect = CGRectMake(60.0f, 100.0f, self.view.bounds.size.width-120.f, self.view.bounds.size.width-120.f);
    AVAuthorizationStatus authorizationStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    switch (authorizationStatus) {
        case AVAuthorizationStatusNotDetermined: {
            [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler: ^(BOOL granted) {
                if (granted) {
                    [self startCapture];
                } else {
                    NSLog(@"访问受限");
                }
            }];
            break;
        }
        case AVAuthorizationStatusAuthorized: {
            [self startCapture];
            break;
        }
        case AVAuthorizationStatusRestricted:
        case AVAuthorizationStatusDenied: {
            NSLog(@"访问受限");
            break;
        }
        default: {
            break;
        }
    }
    
}
- (void)startCapture{
    AVCaptureSession *session = [[AVCaptureSession alloc] init];
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    NSError *error;
    AVCaptureDeviceInput *deviceInput = [AVCaptureDeviceInput deviceInputWithDevice:device error:&error];
    if (deviceInput) {
        [session addInput:deviceInput];
        AVCaptureMetadataOutput *metadataOutput = [[AVCaptureMetadataOutput alloc] init];
        [metadataOutput setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
        [session addOutput:metadataOutput]; // 这行代码要在设置 metadataObjectTypes 前
        metadataOutput.metadataObjectTypes = @[AVMetadataObjectTypeQRCode,AVMetadataObjectTypeCode128Code]; // 设置识别图片类型
        AVCaptureVideoPreviewLayer *previewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:session];
        previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
        previewLayer.frame = self.view.frame;
        [self.view.layer insertSublayer:previewLayer atIndex:0];
        __weak typeof(self) weakSelf = self;
        [[NSNotificationCenter defaultCenter] addObserverForName:AVCaptureInputPortFormatDescriptionDidChangeNotification
                                                          object:nil
                                                           queue:[NSOperationQueue currentQueue]
                                                      usingBlock: ^(NSNotification *_Nonnull note) {
                                                          metadataOutput.rectOfInterest = [previewLayer metadataOutputRectOfInterestForRect:weakSelf.scanRect];
                                                          // 如果不设置，整个屏幕都可以扫
                                                      }];
        // 设置扫描界面布局
        QRScanView *scanView = [[QRScanView alloc] initWithScanRect:self.scanRect];
        [self.view addSubview:scanView];
        [session startRunning];
        
    } else {
        NSLog(@"%@", error);
    }
}
#pragma mark - AVCaptureMetadataOutputObjectsDelegate
- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection{
    AVMetadataMachineReadableCodeObject *metadataObject = metadataObjects.firstObject;
    // 成功后系统不会停止扫描，用isQRCodeCaptured变量来控制。
    if (self.isQRCodeCaptured == NO) {
        self.isQRCodeCaptured = YES;
        NSString *decodeMessage = nil;
        if ([metadataObject.type isEqualToString:AVMetadataObjectTypeQRCode]) {
            // 二维码
            decodeMessage = metadataObject.stringValue;
        }else if ([metadataObject.type isEqualToString:AVMetadataObjectTypeCode128Code]){
            // 条形码
            decodeMessage = metadataObject.stringValue;
        }
        self.lbl.text =decodeMessage;
        NSLog(@"%@",decodeMessage);
    }
}

#pragma mark - 生成二维码、条形码
- (void)testGenerateCode{
    UIImageView *qrCode = [[UIImageView alloc]init];
    // 生成二维码
    //    qrCode.image = [BarCodeAndQRCodeManager generateQRCodeWithInputMessage:@"本人手机号\n13600000006\n账号10000100001\n生成于某年某月某日\n我这只是个测试\n看看能打多少行\n" Width:200 Height:200];
    //    qrCode.image = [BarCodeAndQRCodeManager generateQRCodeWithInputMessage:@"自动那天起，我就一直在这里等待着你，你究竟在干吗，我也不知道啊！也许，maybe，谁都会被骄傲不的开会吧安徽的安徽的差得很安徽的被查看不到爱好的不好撒比电话吧的好不哈不动产爱好的不插卡的爱好的不好卡尔此" Width:200 Height:200 AndCenterImage:[UIImage imageNamed:@"center.png"]];
    // 生成条形码
    qrCode.image = [BarCodeAndQRCodeManager generateBarcodeWithInputMessage:@"10128500623161204184453" Width:self.view.bounds.size.width-10 Height:100];
    NSLog(@"%f",qrCode.image.size.width);
    qrCode.frame = CGRectMake(5, 100, qrCode.image.size.width, qrCode.image.size.height);
    [self.view addSubview:qrCode];
}
#pragma mark - 识别图片中的二维码
- (void)decodeQRCode{
    // 二维码
    NSString *outputString = [BarCodeAndQRCodeManager decodeQRCodeWithPhotoCodeImage:[UIImage imageNamed:@"CESHI.png"]];
    
    NSLog(@"%@",outputString);
    
}
// 开启或者关闭手电筒
- (void)openOrCloseTorchlight{
    Class captureDeviceClass = NSClassFromString(@"AVCaptureDevice");
    if (captureDeviceClass != nil) {
        AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
        if (device.hasTorch){
            [device lockForConfiguration:nil];
            if (device.torchMode == AVCaptureTorchModeOn) {
                [device setTorchMode:AVCaptureTorchModeOff];
            }else{
                [device setTorchMode:AVCaptureTorchModeOn];
            }
            [device unlockForConfiguration];
        }
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end

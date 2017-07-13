//
//  CodeDiscernViewController.m
//  BarCodeAndQRCode
//
//  Created by 王盛魁 on 2017/7/12.
//  Copyright © 2017年 WangShengKui. All rights reserved.
//

#import "CodeDiscernViewController.h"
#import <AVFoundation/AVFoundation.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import "QRScanView.h"
#import "BarCodeAndQRCodeManager.h"

@interface CodeDiscernViewController ()<AVCaptureMetadataOutputObjectsDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate>

@property (nonatomic,assign) BOOL isQRCodeCaptured;
@property (nonatomic, assign) CGRect scanRect;
@property (nonatomic,strong) UILabel *lbl;
@property (nonatomic,strong) UIImagePickerController *imagePickerController;

@end

@implementation CodeDiscernViewController
- (UIImagePickerController *)imagePickerController{
    if (_imagePickerController == nil) {
        _imagePickerController = [[UIImagePickerController alloc]init];
        _imagePickerController.delegate = self;
        _imagePickerController.allowsEditing = YES;
    }
    return _imagePickerController;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.lbl = [[UILabel alloc]initWithFrame:CGRectMake(0, 64, self.view.bounds.size.width, 40)];
    self.lbl.textColor = [UIColor redColor];
    self.lbl.backgroundColor = [UIColor whiteColor];
    self.lbl.numberOfLines = 0;
    self.lbl.text = @"扫码的内容";
    self.lbl.textAlignment = NSTextAlignmentCenter;
    self.lbl.font = [UIFont systemFontOfSize:16.f];

    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"相册" style:UIBarButtonItemStyleDone target:self action:@selector(alertSheetWithAction)];
    
    [self getImageMessageFromCamera];
    // Do any additional setup after loading the view.
}
#pragma mark - 从摄像头中获取二维码
// 记得导入AVFoundation框架
- (void)getImageMessageFromCamera{
    self.isQRCodeCaptured = NO;
    self.scanRect = CGRectMake(60.0f, 170.f, self.view.bounds.size.width-120.f, self.view.bounds.size.width-120.f);
    AVAuthorizationStatus authorizationStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    switch (authorizationStatus) {
        case AVAuthorizationStatusNotDetermined: {
            [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler: ^(BOOL granted) {
                if (granted) {
                    [self startCapture];
                } else {
                    [self alertMessage:@"访问受限"];
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
            [self alertMessage:@"访问受限"];
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
        metadataOutput.metadataObjectTypes = @[AVMetadataObjectTypeQRCode,AVMetadataObjectTypeCode128Code,AVMetadataObjectTypeEAN13Code]; // 设置识别图片类型
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
        [self.view addSubview:self.lbl];
        /*
         测试手电筒的开关
         */
        UIButton *torchBtn = [[UIButton alloc]initWithFrame:CGRectMake(0,0, 200, 50)];
        torchBtn.center = CGPointMake([UIScreen mainScreen].bounds.size.width/2, self.view.bounds.size.width+80.f);
        [torchBtn setTitle:@"手电筒开关" forState:UIControlStateNormal];
        [torchBtn setTintColor:[UIColor blackColor]];
        [torchBtn addTarget:self action:@selector(openOrCloseTorchlight) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:torchBtn];
    } else {
        NSLog(@"%@", error);
        [self alertMessage:error.localizedDescription];
    }
}

#pragma mark - AVCaptureMetadataOutputObjectsDelegate
- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection{
    AVMetadataMachineReadableCodeObject *metadataObject = metadataObjects.firstObject;
    // 成功后系统不会停止扫描，用isQRCodeCaptured变量来控制。
    if (self.isQRCodeCaptured == NO) {
        self.isQRCodeCaptured = YES;
        NSString *decodeMessage = @"未扫描到二维码、条形码";
        if ([metadataObject.type isEqualToString:AVMetadataObjectTypeQRCode]) {
            // 二维码
            decodeMessage = metadataObject.stringValue;
        }else if ([metadataObject.type isEqualToString:AVMetadataObjectTypeCode128Code]){
            // 条形码
            decodeMessage = metadataObject.stringValue;
        }else if ([metadataObject.type isEqualToString:AVMetadataObjectTypeEAN13Code]){
            // ISBN书号条码、EAN13码
            decodeMessage = metadataObject.stringValue;
        }
        self.lbl.text =decodeMessage;
        NSLog(@"%@",decodeMessage);
    }
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
- (void)alertMessage:(NSString *)message{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"温馨提示" message:message preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
    UIAlertAction *otherAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
    }];
    [alert addAction:cancelAction];
    [alert addAction:otherAction];
    [self presentViewController:alert animated:YES completion:nil];
    
}

- (void)alertSheetWithAction{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"选择图片来源" message:@"" preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction *cameraAction = [UIAlertAction actionWithTitle:@"相机" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self selectImageFromCamera];
    }];
    
    UIAlertAction *photoAction = [UIAlertAction actionWithTitle:@"相册" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self selectImageFromAlbum];
    }];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
    [alertController addAction:cameraAction];
    [alertController addAction:photoAction];
    [alertController addAction:cancelAction];
    [self presentViewController:alertController animated:YES completion:nil];
}
// 打开相机
- (void)selectImageFromCamera{
    self.imagePickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
    self.imagePickerController.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
//    UIImageView *overlayView = [[UIImageView alloc]initWithFrame:CGRectMake(20, 50, [UIScreen mainScreen].bounds.size.width-40, [UIScreen mainScreen].bounds.size.height-50-130)];
//    overlayView.image = [UIImage imageNamed:@"Rectangle"];
//    overlayView.userInteractionEnabled = YES;
//    self.imagePickerController.cameraOverlayView = overlayView;
    self.imagePickerController.mediaTypes = @[(NSString *)kUTTypeMovie,(NSString *)kUTTypeImage];
    [self presentViewController:self.imagePickerController animated:YES completion:nil];
}
- (void)selectImageFromAlbum{
    self.imagePickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
//    self.imagePickerController.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
    self.imagePickerController.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
    [self presentViewController:self.imagePickerController animated:YES completion:nil];
}
#pragma mark - UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info{
    NSString *mediaType = [info objectForKey:UIImagePickerControllerMediaType];
    if ([mediaType isEqualToString:(NSString *)kUTTypeImage]){
        UIImage *image = info[UIImagePickerControllerOriginalImage];
        NSString *imageStr = [BarCodeAndQRCodeManager decodeQRCodeWithPhotoCodeImage:image];
        self.lbl.text = imageStr;
        [self dismissViewControllerAnimated:true completion:nil];
    }else{
        NSURL *mediaUrl = info[UIImagePickerControllerMediaURL];
        //保存视频至相册（异步线程）
        NSString *urlStr = [mediaUrl path];
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            if (UIVideoAtPathIsCompatibleWithSavedPhotosAlbum(urlStr)) {
                UISaveVideoAtPathToSavedPhotosAlbum(urlStr, self, @selector(video:didFinishSavingWithError:contextInfo:), nil);
            }
        });
    }
}
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    [self dismissViewControllerAnimated:YES completion:nil];
}
#pragma mark - 相机录制视频，保存完毕
- (void)video:(NSString *)videoPath didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextIn {
    if (error) {
        NSLog(@"保存视频过程中发生错误，错误信息:%@",error.localizedDescription);
    }else{
        NSLog(@"视频保存成功.");
    }
    [self dismissViewControllerAnimated:true completion:nil];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end

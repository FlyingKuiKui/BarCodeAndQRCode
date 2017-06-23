//
//  BarCodeAndQRCodeManager.m
//  BarCodeAndQRCode
//
//  Created by 王盛魁 on 2017/6/23.
//  Copyright © 2017年 WangShengKui. All rights reserved.
//
/**
 inputCorrectionLevel
 等级  容错率
 L     7%
 M     15%  默认值
 Q     25%
 H     30%
 */

#import "BarCodeAndQRCodeManager.h"

@implementation BarCodeAndQRCodeManager
// QRCode
+ (UIImage *)generateQRCodeWithInputMessage:(NSString *)inputMessage
                                      Width:(CGFloat)width
                                     Height:(CGFloat)height{
    NSData *inputData = [inputMessage dataUsingEncoding:NSUTF8StringEncoding];
    CIFilter *filter = [CIFilter filterWithName:@"CIQRCodeGenerator"];
    [filter setValue:inputData forKey:@"inputMessage"];
    //    [filter setValue:@"H" forKey:@"inputCorrectionLevel"]; // 设置二维码不同级别的容错率
    
    CIImage *ciImage = filter.outputImage;
    // 消除模糊
    CGFloat scaleX = MIN(width, height)/ciImage.extent.size.width;
    CGFloat scaleY = MIN(width, height)/ciImage.extent.size.height;
    ciImage = [ciImage imageByApplyingTransform:CGAffineTransformScale(CGAffineTransformIdentity, scaleX, scaleY)];
    UIImage *returnImage = [UIImage imageWithCIImage:ciImage];
    return returnImage;
}
+ (UIImage *)generateQRCodeWithInputMessage:(NSString *)inputMessage
                                      Width:(CGFloat)width
                                     Height:(CGFloat)height
                             AndCenterImage:(UIImage *)centerImage{
    UIImage *backImage = [self generateQRCodeWithInputMessage:inputMessage Width:width Height:height];
    UIGraphicsBeginImageContext(backImage.size);
    [backImage drawInRect:CGRectMake(0, 0, backImage.size.width, backImage.size.height)];
    CGFloat centerImageWH = MIN(backImage.size.width, backImage.size.height) * 0.15;
    [centerImage drawInRect:CGRectMake((backImage.size.width - centerImageWH)*0.5, (backImage.size.height - centerImageWH)*0.5, centerImageWH, centerImageWH)];
    UIImage *returnImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return returnImage;
}
+ (NSString *)decodeQRCodeWithPhotoCodeImage:(UIImage *)codeImage{
    NSString *outputString = nil;
    CIDetector *detector = [CIDetector detectorOfType:CIDetectorTypeQRCode context:nil options:@{CIDetectorAccuracy:CIDetectorAccuracyHigh}];
    CIImage *image = [[CIImage alloc] initWithImage:codeImage];
    NSArray *features = [detector featuresInImage:image];
    for (CIQRCodeFeature *feature in features) {
        outputString = feature.messageString;
    }
    return outputString;
}

// BarCode
+ (UIImage *)generateBarcodeWithInputMessage:(NSString *)inputMessage
                                       Width:(CGFloat)width
                                      Height:(CGFloat)height{
    NSData *inputData = [inputMessage dataUsingEncoding:NSISOLatin1StringEncoding allowLossyConversion:false];
    CIFilter *filter = [CIFilter filterWithName:@"CICode128BarcodeGenerator"];
    [filter setValue:inputData forKey:@"inputMessage"]; // 设置条形码内容
    //    [filter setValue:@(50) forKey:@"inputQuietSpace"]; // 设置条形码上下左右margin值
    //    [filter setValue:@(height) forKey:@"inputBarcodeHeight"]; // 设置条形码高度
    CIImage *ciImage = filter.outputImage;
    CGFloat scaleX = width/ciImage.extent.size.width;
    CGFloat scaleY = height/ciImage.extent.size.height;
    ciImage = [ciImage imageByApplyingTransform:CGAffineTransformScale(CGAffineTransformIdentity, scaleX, scaleY)];
    UIImage *returnImage = [UIImage imageWithCIImage:ciImage];
    return returnImage;
}

@end

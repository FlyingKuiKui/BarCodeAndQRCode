//
//  BarCodeAndQRCodeManager.h
//  BarCodeAndQRCode
//
//  Created by 王盛魁 on 2017/6/23.
//  Copyright © 2017年 WangShengKui. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface BarCodeAndQRCodeManager : NSObject
// QRCode
+ (UIImage *)generateQRCodeWithInputMessage:(NSString *)inputMessage
                                      Width:(CGFloat)width
                                     Height:(CGFloat)height;
+ (UIImage *)generateQRCodeWithInputMessage:(NSString *)inputMessage
                                      Width:(CGFloat)width
                                     Height:(CGFloat)height
                             AndCenterImage:(UIImage *)centerImage;
+ (NSString *)decodeQRCodeWithPhotoCodeImage:(UIImage *)codeImage;
// BarCode
+ (UIImage *)generateBarcodeWithInputMessage:(NSString *)inputMessage
                                       Width:(CGFloat)width
                                      Height:(CGFloat)height;
/*
 目前并不支持，还未写完
 */
+ (NSString *)decodeBarcodeWithPhotoBarcodeImage:(UIImage *)barcodeImage;

@end

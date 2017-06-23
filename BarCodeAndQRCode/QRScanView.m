//
//  QRScanView.m
//  BarCodeAndQRCode
//
//  Created by 王盛魁 on 2017/6/23.
//  Copyright © 2017年 WangShengKui. All rights reserved.
//

#import "QRScanView.h"

@interface QRScanView ()

@property (nonatomic, assign) CGRect scanRect;

@end

@implementation QRScanView

- (instancetype)initWithScanRect:(CGRect)rect {
	self = [super initWithFrame:[UIScreen mainScreen].bounds];
	if (self) {
		self.backgroundColor = [UIColor clearColor];
		_scanRect = rect;
	}
	return self;
}

- (void)drawRect:(CGRect)rect {
	CGContextRef ctx = UIGraphicsGetCurrentContext();
	[[[UIColor blackColor] colorWithAlphaComponent:0.5] setFill];
    
	CGMutablePathRef screenPath = CGPathCreateMutable();
	CGPathAddRect(screenPath, NULL, self.bounds);
    
	CGMutablePathRef scanPath = CGPathCreateMutable();
	CGPathAddRect(scanPath, NULL, self.scanRect);

	CGMutablePathRef path = CGPathCreateMutable();
	CGPathAddPath(path, NULL, screenPath);
	CGPathAddPath(path, NULL, scanPath);
    
	CGContextAddPath(ctx, path);
	CGContextDrawPath(ctx, kCGPathEOFill);

	CGPathRelease(screenPath);
	CGPathRelease(scanPath);
	CGPathRelease(path);
}

@end

//
//  ViewController.m
//  BarCodeAndQRCode
//
//  Created by 王盛魁 on 2017/6/23.
//  Copyright © 2017年 WangShengKui. All rights reserved.
//

#import "ViewController.h"
#import "BarCodeAndQRCodeManager.h"

#import "CodeDiscernViewController.h"

@interface ViewController ()


@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"生成二维码/条形码";
    UIButton *goToNext = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 300, 40)];
    goToNext.center = CGPointMake([UIScreen mainScreen].bounds.size.width/2, 90);
    goToNext.backgroundColor = [UIColor grayColor];
    [goToNext setTitle:@"识别二维码/条形码" forState:UIControlStateNormal];
    [goToNext setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    [goToNext addTarget:self action:@selector(goToNextAction) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:goToNext];
    
    
    // 生成二维码
    [self creatQRCode];
    
    // 生成条形码
    [self creatBarCode];
    
    // Do any additional setup after loading the view, typically from a nib.
}
- (void)goToNextAction{
    CodeDiscernViewController *codeDiscernVC = [[CodeDiscernViewController alloc]init];
    [self.navigationController pushViewController:codeDiscernVC animated:YES];
}
#pragma mark - 生成二维码
- (void)creatQRCode{
    UIImageView *QRCodeImageView = [[UIImageView alloc]init];
    QRCodeImageView.image = [BarCodeAndQRCodeManager generateQRCodeWithInputMessage:@"本人手机号\n1234567890\n账号10000100001\n生成于某年某月某日\n我这只是个测试\n看看能打多少行\n" Width:200 Height:200];
//    QRCodeImageView.image = [BarCodeAndQRCodeManager generateQRCodeWithInputMessage:@"自动那天起，我就一直在这里等待着你，你究竟在干吗，我也不知道啊！也许，maybe，谁都会被骄傲不的开会吧安徽的安徽的差得很安徽的被查看不到爱好的不好撒比电话吧的好不哈不动产爱好的不插卡的爱好的不好卡尔此" Width:200 Height:200 AndCenterImage:[UIImage imageNamed:@"center.png"]];
    QRCodeImageView.frame = CGRectMake(0, 0, QRCodeImageView.image.size.width, QRCodeImageView.image.size.height);
    QRCodeImageView.center = CGPointMake([UIScreen mainScreen].bounds.size.width/2, 220);
    [self.view addSubview:QRCodeImageView];

}
#pragma mark - 生成条形码
- (void)creatBarCode{
    UIImageView *barCodeImageView = [[UIImageView alloc]init];
    barCodeImageView.image = [BarCodeAndQRCodeManager generateBarcodeWithInputMessage:@"10128500623161204184453" Width:self.view.bounds.size.width-50 Height:100];
    barCodeImageView.frame = CGRectMake(0, 0, barCodeImageView.image.size.width, barCodeImageView.image.size.height);
    barCodeImageView.center = CGPointMake([UIScreen mainScreen].bounds.size.width/2, 400);
    [self.view addSubview:barCodeImageView];

}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end

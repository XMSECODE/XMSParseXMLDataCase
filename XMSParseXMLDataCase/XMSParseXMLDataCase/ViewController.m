//
//  ViewController.m
//  XMSParseXMLDataCase
//
//  Created by xiangmingsheng on 16/10/17.
//  Copyright © 2016年 xiangmingsheng. All rights reserved.
//

#import "ViewController.h"
#import "loadXMLData.h"

#define test01XMLURLString @"https://raw.githubusercontent.com/XMS2016/XMLFile/master/attrs.xml"
#define test02XMLURLString @"https://raw.githubusercontent.com/XMS2016/XMLFile/master/book.xml"
#define test03XMLURLString @"http://www.runoob.com/try/xml/plant_catalog.xml"
#define test04XMLURLString @"http://www.runoob.com/try/xml/cd_catalog.xml"
#define test05XMLURLString @"http://www.runoob.com/try/xml/simple.xml"
#define test06XMLURLString @"https://raw.githubusercontent.com/XMS2016/XMLFile/master/中国省市表.xml"
#define test07XMLURLString @"https://raw.githubusercontent.com/XMS2016/XMLFile/master/中国天气网城市代码表.xml"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    NSString* urlStr = test07XMLURLString;
    [loadXMLData loadXMLDataWithUrlString:urlStr withCompleteBlock:^(NSArray *array) {
        NSLog(@"%@",array);

    }];
}

@end

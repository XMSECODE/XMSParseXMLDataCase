//
//  loadXMLData.h
//  XML解析-----向明升------
//
//  Created by xiangmingsheng on 16/9/6.
//  Copyright © 2016年 xiangmingsheng. All rights reserved.
//  优化最终数据数据，假如该数组只有一个元素且该元素替代父节点在祖父节点中的位置，减少取数据遍历的层级

#import <Foundation/Foundation.h>

typedef void(^completeBlock)(NSArray* array);

@interface loadXMLData : NSObject

//解析指定url地址的数据并回调一个block（必须实现completeBlock）
+(void)loadXMLDataWithUrlString:(NSString*)urlString withCompleteBlock:(completeBlock)completeblock;

//解析xml二进制数据，返回数组
+(NSArray*)loadXMLDataWithData:(NSData*)data;

@end

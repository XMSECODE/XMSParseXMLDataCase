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

#pragma mark - 优化得到的结果（已自动优化一次）
//遍历数组中的每一个元素及子元素---- 假如该数组只有一个元素且该元素替代父节点在祖父节点中的位置
-(NSMutableArray*)mergeDict:(NSMutableArray*)array;

//如果数组下的字典没有相同的键则把下面的字典合并为一个字典
-(NSMutableArray*)enumerateArray:(NSMutableArray*)array;
@end

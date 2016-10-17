//
//  loadXMLData.m
//  XML解析
//
//  Created by xiangmingsheng on 16/9/6.
//  Copyright © 2016年 xiangmingsheng. All rights reserved.
//

#import "loadXMLData.h"

@interface loadXMLData ()<NSXMLParserDelegate>

//根数组
@property (nonatomic,strong) NSMutableArray      * rootArrayM;
//拼接的信息体中的字符串
@property (nonatomic,strong) NSMutableString     * bodyString;
//保存当前信息体中的键值对
@property (nonatomic,copy  ) NSString            * BodyStringKey;
@property (nonatomic,copy  ) NSString            * BodyStringValue;
//保存信息头中的附加字典
@property (nonatomic,strong) NSMutableDictionary * headerDicM;
//保存当前操作的对象的栈的数组
@property (nonatomic,strong) NSMutableArray      * ObjectStackArrayM;
//当前操作的对象在栈数组中的位置
@property (nonatomic,assign) int                 currentObjectIndexAtStack;
//当前操作的对象
@property (nonatomic,strong) id                  currentObj;
//当前操作的的字典对象
@property (nonatomic,strong) NSMutableDictionary * bodyDictionary;

@end

@implementation loadXMLData

#pragma mark - 解析xml

+(void)loadXMLDataWithUrlString:(NSString*)urlString withCompleteBlock:(completeBlock)completeblock{
    loadXMLData* obj = [loadXMLData new];
    urlString = [urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSURL* url = [NSURL URLWithString:urlString];
    NSURLRequest* urlR = [NSURLRequest requestWithURL:url];
    [NSURLConnection sendAsynchronousRequest:urlR queue:[NSOperationQueue new] completionHandler:^(NSURLResponse * _Nullable response, NSData * _Nullable data, NSError * _Nullable connectionError) {
        NSArray* arr = [obj loadXMLDataWithData:data];
        dispatch_async(dispatch_get_main_queue(), ^{
            completeblock(arr);
        });
    }];
}

-(NSArray*)loadXMLDataWithData:(NSData*)data{
    NSXMLParser* xmlParser = [[NSXMLParser alloc] initWithData:data];
    xmlParser.delegate = self;
    //开始解析
    [xmlParser parse];
    //优化数据
    NSArray* resArr = [self optimizeRootArrayM:self.rootArrayM];
    return resArr;
}

+(NSArray*)loadXMLDataWithData:(NSData*)data{
    NSXMLParser* xmlParser = [[NSXMLParser alloc] initWithData:data];
    loadXMLData* obj = [loadXMLData new];
    xmlParser.delegate = obj;
    //开始解析
    [xmlParser parse];
    //优化数据
    NSArray* resArr = [obj optimizeRootArrayM:obj.rootArrayM];
    return resArr;
}

#pragma mark - NSXMLParser代理方法
- (void)parserDidStartDocument:(NSXMLParser *)parser{
    [self whenStart];
}

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(nullable NSString *)namespaceURI qualifiedName:(nullable NSString *)qName attributes:(NSDictionary<NSString *, NSString *> *)attributeDict{
    //保存头部的字典
    if (attributeDict.count > 0) {
        self.headerDicM = [attributeDict mutableCopy];
    }
    [self whenHead];
    self.BodyStringKey = elementName;
    self.bodyString = [NSMutableString string];
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string{
    [self.bodyString appendString:string];
    [self whenBody];
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(nullable NSString *)namespaceURI qualifiedName:(nullable NSString *)qName{
    self.BodyStringValue = self.bodyString;
    self.BodyStringKey = elementName;
    [self whenFoot];
    self.bodyString = nil;
}

- (void)parserDidEndDocument:(NSXMLParser *)parser{
    [self whenEnd];
}


#pragma mark - 拼接数组数据
-(void)whenStart{
    self.currentObj = self.rootArrayM;
    self.ObjectStackArrayM[self.currentObjectIndexAtStack] = self.currentObj;
}

-(void)whenHead{
    //创建数组
    NSMutableArray* arr = [NSMutableArray array];    
    [self.currentObj addObject:arr];
    self.currentObj = arr;
    self.currentObjectIndexAtStack++;
    self.ObjectStackArrayM[self.currentObjectIndexAtStack] = self.currentObj;
    if (self.headerDicM.count > 0) {
        [self.currentObj addObject:self.headerDicM];
        self.headerDicM = nil;
    }
}

-(void)whenBody{
    
}

-(void)whenFoot{
    if (self.BodyStringValue.length > 0 && self.BodyStringKey != nil) {
        if (self.bodyDictionary == nil) {
            self.bodyDictionary = [NSMutableDictionary dictionary];
            [self.currentObj addObject:self.bodyDictionary];
        }
        [self.bodyDictionary setObject:self.BodyStringValue forKey:self.BodyStringKey];
        self.BodyStringKey =nil;
        self.BodyStringValue = nil;
        self.bodyDictionary = nil;
    }
    self.currentObjectIndexAtStack--;
    self.currentObj = self.ObjectStackArrayM[self.currentObjectIndexAtStack];
}

-(void)whenEnd{
}

#pragma mark - 懒加载数据
-(NSMutableArray *)rootArrayM{
    if (_rootArrayM == nil) {
        _rootArrayM = [NSMutableArray array];
    }
    return _rootArrayM;
}

-(NSMutableArray *)ObjectStackArrayM{
    if (_ObjectStackArrayM == nil) {
        _ObjectStackArrayM = [NSMutableArray array];
    }
    return _ObjectStackArrayM;
}

#pragma mark - 优化处理最终数据
-(NSArray*)optimizeRootArrayM:(NSMutableArray*)array{
    array = [self enumerateArray:array];
    array = [self mergeDict:array];
    array = [self enumerateArray:array];
    return array;
}

#pragma mark - 遍历数组中的每一个元素及子元素---- 假如该数组只有一个元素且该元素替代父节点在祖父节点中的位置
-(NSMutableArray*)enumerateArray:(NSMutableArray*)array{
    //取得数组，若数组为空则直接返回
    NSInteger lenth = array.count;
    if (lenth == 0) {
        return nil;
    }

    //遍历元素
    for (int i = 0; i < lenth; i++) {
        //判断是否为字典，若为字典则直接返回
        if ([array[i] isKindOfClass:[NSArray class]]) {
            array[i] = [self enumerateArray:array[i]];
        }
    }
    //数组只有一个元素则该元素替代父节点
    if (lenth == 1) {
        return array[0];
    }
    return array;
}

#pragma mark - 如果数组下的字典没有相同的键则把下面的字典合并为一个字典

-(NSMutableArray*)mergeDict:(NSMutableArray*)array{
    
    NSInteger lenth = array.count;
    //遍历元素
    for (int i = 0; i < lenth; i++) {
        //判断是否为字典，若为字典则直接返回
        if ([array[i] isKindOfClass:[NSArray class]]) {
            array[i] = [self mergeDict:array[i]];
        }
    }
    
    //声明一个数组保存数组下所有的字典的值
    NSMutableArray* keyArray = [NSMutableArray array];
    //保存字典的值
    //遍历数组
    for (int i = 0; i < array.count; i++) {
        id obj = array[i];
        if ([obj isKindOfClass:[NSDictionary class]]) {
            NSDictionary* dic = (NSDictionary*)obj;
            NSArray* arr = [dic allKeys];
            for (int i = 0; i < arr.count; i++) {
                [keyArray addObject:arr[i]];
            }
        }
    }
    //判断是否数组中有相同的字符串
    BOOL issame = [self isSameObjInArray:keyArray];
    if (issame == YES) {
        return array;
    }else{
        return [self hebingArray:array];
    }
}

#pragma mark - 合并字典元素
-(NSMutableArray*)hebingArray:(NSMutableArray*)array{
    //遍历数组
    NSMutableDictionary* dic = [NSMutableDictionary dictionary];
    //遍历数组中的字典
    NSInteger temcount = array.count;
    for (int i = 0; i < temcount; i++) {
        id obj = array[i];
        //如果是字典则添加至字典，且删除数组中的字典
        if ([obj isKindOfClass:[NSDictionary class]]) {
            for (id key in obj) {
                id valua = [obj objectForKey:key];
                [dic setObject:valua forKey:key];
            }            [array removeObject:obj];
            i--;
            temcount--;
        }
    }
    //最后数组如果只有一个元素则直接添加进数组即可
    if (dic.count == 0) {
        return array;
    }
    [array addObject:dic];
    NSInteger arraycount = array.count;
    if (arraycount == 1) {
    }else{
        for(int i = 0; i < arraycount - 1; i++) {
            array[arraycount - i - 1] = array[arraycount - i - 2];
        }
        array[0] = dic;
    }
    return array;
}

#pragma mark - 判断数组中的字符串是否存在相同的值
-(BOOL)isSameObjInArray:(NSArray*)array{
    BOOL isSame = NO;
    for (int i = 0; i < array.count; i++) {
        for (int j = i+1; j < array.count; j++) {
            if ([array[i] isEqualToString:array[j]]) {
                isSame = YES;
                return isSame;
            }
        }
    }
    return isSame;
}


@end

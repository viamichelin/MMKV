/*
 * Tencent is pleased to support the open source community by making
 * MMKV available.
 *
 * Copyright (C) 2018 THL A29 Limited, a Tencent company.
 * All rights reserved.
 *
 * Licensed under the BSD 3-Clause License (the "License"); you may not use
 * this file except in compliance with the License. You may obtain a copy of
 * the License at
 *
 *       https://opensource.org/licenses/BSD-3-Clause
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

#import "MMKVDemo-Swift.h"
#import "ViewController+TestCaseBad.h"
#import <MMKV/MMKV.h>
#import "TestMMKVCpp.hpp"

@interface TestNSArchive : NSObject <NSSecureCoding>
@property(nonatomic, strong) NSString *m_username;
@property(nonatomic, assign) int32_t m_age;
@property(nonatomic, assign) float m_score;
@end

@implementation TestNSArchive

- (id)initWithCoder:(NSCoder *)decoder {
    self = [super init];
    if (!self) {
        return nil;
    }

    self.m_username = [decoder decodeObjectForKey:@"m_username"];
    self.m_age = [decoder decodeInt32ForKey:@"m_age"];
    self.m_score = [decoder decodeFloatForKey:@"m_score"];

    return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder {
    [encoder encodeObject:self.m_username forKey:@"m_username"];
    [encoder encodeInteger:self.m_age forKey:@"m_age"];
    [encoder encodeFloat:self.m_score forKey:@"m_score"];
}

+ (BOOL)supportsSecureCoding {
    return YES;
}

@end

@implementation ViewController {
    NSMutableArray *m_arrStrings;
    NSMutableArray *m_arrStrKeys;
    NSMutableArray *m_arrIntKeys;
    NSMutableArray *m_arrObjKeys;
    NSMutableArray *m_arrNSCodingObjs;

    int m_loops;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(updateTodayContent)
                                                 name:UIApplicationDidBecomeActiveNotification
                                               object:nil];

    [self functionTestCpp];
    [self funcionalTest:NO];
    [self testReKey];
    [self testImportFromUserDefault];
    // [self testCornerSize];
    // [self testFastRemoveCornerSize];
    // [self testChineseCharKey];
    // [self testItemSizeHolderOverride];
    [self testAutoExpire];
    // [self testAutoExpireWildPtr];

    DemoSwiftUsage *swiftUsageDemo = [[DemoSwiftUsage alloc] init];
    [swiftUsageDemo testSwiftFunctionality];
    [swiftUsageDemo testSwiftAutoExpire];

    [self testMultiProcess];
    // [self testMultiProcess];
    [self testBackup];
    [self testRestore];
    [self testExpectedCapacity];
    [self onlyOneKeyTest];
    [self overrideTest];
    [self testCompareBeforeSet];

    [self testClearAllWithKeepingSpace];
    [self testRemoveStorage];
    [self testReadOnly:NO];

    m_loops = 10000;
    m_arrStrings = [NSMutableArray arrayWithCapacity:m_loops];
    m_arrStrKeys = [NSMutableArray arrayWithCapacity:m_loops];
    m_arrIntKeys = [NSMutableArray arrayWithCapacity:m_loops];
    m_arrObjKeys = [NSMutableArray arrayWithCapacity:m_loops];
    m_arrNSCodingObjs = [NSMutableArray arrayWithCapacity:m_loops];
    for (size_t index = 0; index < m_loops; index++) {
        // auto str = @"[MMKV] [Info]<MemoryFile_OSX.cpp:36>: protection on [/var/mobile/Containers/Data/Application/B93F2BD3-E0DB-49B3-9BB0-C662E2FC11D9/Documents/mmkv/cips_commoncache] is NSFileProtectionCompleteUntilFirstUserAuthentication";
        // str = [str stringByAppendingFormat:@", %s-%d", __FILE__, rand()];
        NSString *str = [NSString stringWithFormat:@"%s-%d", __FILE__, rand()];
        [m_arrStrings addObject:str];

        NSString *strKey = [NSString stringWithFormat:@"str-%zu", index];
        [m_arrStrKeys addObject:strKey];

        NSString *intKey = [NSString stringWithFormat:@"int-%zu", index];
        [m_arrIntKeys addObject:intKey];
        /*
        NSString *objKey = [NSString stringWithFormat:@"obj-%zu", index];
        [m_arrObjKeys addObject:objKey];
        
        TestNSArchive *obj = [[TestNSArchive alloc] init];
        obj.m_username = str;
        obj.m_age = rand();
        obj.m_age = rand() * rand() * 0.5;
        [m_arrNSCodingObjs addObject:obj];*/
    }
    //getMMKVForBatchTest();
}

- (void)funcionalTest:(BOOL)decodeOnly {
    auto path = [MMKV mmkvBasePath];
    path = [path stringByDeletingLastPathComponent];
    path = [path stringByAppendingPathComponent:@"mmkv_2"];
    NSData *key_1 = [@"Key_seq_1" dataUsingEncoding:NSUTF8StringEncoding];
    auto mmkv = [MMKV mmkvWithID:@"test/case_aes" cryptKey:key_1 rootPath:path];

    if (!decodeOnly) {
        [mmkv setBool:YES forKey:@"bool"];
    }
    NSLog(@"bool:%d", [mmkv getBoolForKey:@"bool"]);

    if (!decodeOnly) {
        [mmkv setInt32:-1024 forKey:@"int32"];
    }
    NSLog(@"int32:%d", [mmkv getInt32ForKey:@"int32"]);

    if (!decodeOnly) {
        [mmkv setUInt32:std::numeric_limits<uint32_t>::max() forKey:@"uint32"];
    }
    NSLog(@"uint32:%u", [mmkv getUInt32ForKey:@"uint32"]);

    if (!decodeOnly) {
        [mmkv setInt64:std::numeric_limits<int64_t>::min() forKey:@"int64"];
    }
    NSLog(@"int64:%lld", [mmkv getInt64ForKey:@"int64"]);

    if (!decodeOnly) {
        [mmkv setUInt64:std::numeric_limits<uint64_t>::max() forKey:@"uint64"];
    }
    NSLog(@"uint64:%llu", [mmkv getInt64ForKey:@"uint64"]);

    if (!decodeOnly) {
        [mmkv setFloat:-3.1415926 forKey:@"float"];
    }
    NSLog(@"float:%f", [mmkv getFloatForKey:@"float"]);

    if (!decodeOnly) {
        [mmkv setDouble:std::numeric_limits<double>::max() forKey:@"double"];
    }
    NSLog(@"double:%f", [mmkv getDoubleForKey:@"double"]);

    if (!decodeOnly) {
        [mmkv setString:@"hello, mmkv" forKey:@"string"];
    }
    NSLog(@"string:%@", [mmkv getStringForKey:@"string"]);

    if (!decodeOnly) {
        [mmkv setObject:nil forKey:@"string"];
        NSLog(@"string after set nil:%@, containsKey:%d",
              [mmkv getObjectOfClass:NSString.class
                              forKey:@"string"],
              [mmkv containsKey:@"string"]);
    }

    if (!decodeOnly) {
        [mmkv setDate:[NSDate date] forKey:@"date"];
    }
    NSLog(@"date:%@", [mmkv getDateForKey:@"date"]);

    if (!decodeOnly) {
        auto str = @"[MMKV] [Info]<MemoryFile_OSX.cpp:36>: protection on [/var/mobile/Containers/Data/Application/B93F2BD3-E0DB-49B3-9BB0-C662E2FC11D9/Documents/mmkv/cips_commoncache] is NSFileProtectionCompleteUntilFirstUserAuthentication";
        [mmkv setData:[str dataUsingEncoding:NSUTF8StringEncoding] forKey:@"data"];
    }
    NSData *data = [mmkv getDataForKey:@"data"];
    NSLog(@"data:%@", [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
    NSLog(@"data length:%zu, value size consumption:%zu", data.length, [mmkv getValueSizeForKey:@"data" actualSize:NO]);

    if (!decodeOnly) {
        [mmkv setObject:[NSData data] forKey:@"data"];
        NSLog(@"data after set empty data:%@, containsKey:%d",
              [mmkv getObjectOfClass:NSData.class
                              forKey:@"data"],
              [mmkv containsKey:@"data"]);
    }

    if (!decodeOnly) {
        auto array = @[ @"1984", @"2046", @"Move" ];
        [mmkv setObject:array forKey:@"array"];
    }
    NSArray *array = [mmkv getObjectOfClass:NSArray.class forKey:@"array"];
    NSLog(@"array:%@", array);

    if (!decodeOnly) {
        [mmkv removeValueForKey:@"bool"];
        NSLog(@"bool:%d", [mmkv getBoolForKey:@"bool"]);
        [mmkv removeValuesForKeys:@[ @"int32", @"uint64" ]];
        NSLog(@"allKeys %@", [mmkv allKeys]);
    }

    [mmkv close];
}

- (void)functionTestCpp {
    functionalTest(false);
}

- (void)testMMKV:(NSString *)mmapID withCryptKey:(NSData *)cryptKey decodeOnly:(BOOL)decodeOnly {
    MMKV *mmkv = [MMKV mmkvWithID:mmapID cryptKey:cryptKey];
    [ViewController testMMKV:mmkv decodeOnly:decodeOnly];

    NSLog(@"isFileValid[%@]: %d", mmapID, [MMKV isFileValid:mmapID]);
}

+ (void)testMMKV:(MMKV *)mmkv decodeOnly:(BOOL)decodeOnly {
    if (!decodeOnly) {
        [mmkv setInt32:-1024 forKey:@"int32"];
    }
    NSLog(@"int32:%d", [mmkv getInt32ForKey:@"int32"]);

    if (!decodeOnly) {
        [mmkv setUInt32:std::numeric_limits<uint32_t>::max() forKey:@"uint32"];
    }
    NSLog(@"uint32:%u", [mmkv getUInt32ForKey:@"uint32"]);

    if (!decodeOnly) {
        [mmkv setInt64:std::numeric_limits<int64_t>::min() forKey:@"int64"];
    }
    NSLog(@"int64:%lld", [mmkv getInt64ForKey:@"int64"]);

    if (!decodeOnly) {
        [mmkv setUInt64:std::numeric_limits<uint64_t>::max() forKey:@"uint64"];
    }
    NSLog(@"uint64:%llu", [mmkv getInt64ForKey:@"uint64"]);

    if (!decodeOnly) {
        [mmkv setFloat:-3.1415926 forKey:@"float"];
    }
    NSLog(@"float:%f", [mmkv getFloatForKey:@"float"]);

    if (!decodeOnly) {
        [mmkv setDouble:std::numeric_limits<double>::max() forKey:@"double"];
    }
    NSLog(@"double:%f", [mmkv getDoubleForKey:@"double"]);

    if (!decodeOnly) {
        [mmkv setObject:@"An efficient, small mobile key-value storage framework developed by WeChat. Works on Android, iOS, macOS, Windows, and POSIX." forKey:@"string"];
    }
    NSLog(@"string:%@", [mmkv getObjectOfClass:NSString.class forKey:@"string"]);

    if (!decodeOnly) {
        [mmkv setObject:[NSDate date] forKey:@"date"];
    }
    NSLog(@"date:%@", [mmkv getObjectOfClass:NSDate.class forKey:@"date"]);

    if (!decodeOnly) {
        [mmkv setObject:[@"An efficient, small mobile key-value storage framework developed by WeChat(微信). Works on Android, iOS, macOS, Windows, and POSIX." dataUsingEncoding:NSUTF8StringEncoding] forKey:@"data"];
    }
    NSData *data = [mmkv getObjectOfClass:NSData.class forKey:@"data"];
    NSLog(@"data:%@", [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);

    if (!decodeOnly) {
        [mmkv removeValueForKey:@"bool"];
    }
    NSLog(@"bool:%d", [mmkv getBoolForKey:@"bool"]);

    NSLog(@"containsKey[string]: %d", [mmkv containsKey:@"string"]);

    [mmkv removeValuesForKeys:@[ @"int", @"long" ]];
    [mmkv clearMemoryCache];
}

- (void)testReKey {
    NSString *mmapID = @"testAES_reKey";
    [self testMMKV:mmapID withCryptKey:nullptr decodeOnly:NO];

    MMKV *kv = [MMKV mmkvWithID:mmapID cryptKey:nullptr];
    NSData *key_1 = [@"Key_seq_1" dataUsingEncoding:NSUTF8StringEncoding];
    [kv reKey:key_1];
    [kv clearMemoryCache];
    [self testMMKV:mmapID withCryptKey:key_1 decodeOnly:YES];

    NSData *key_2 = [@"Key_seq_2" dataUsingEncoding:NSUTF8StringEncoding];
    [kv reKey:key_2];
    [kv clearMemoryCache];
    [self testMMKV:mmapID withCryptKey:key_2 decodeOnly:YES];

    [kv reKey:nullptr];
    [kv clearMemoryCache];
    [self testMMKV:mmapID withCryptKey:nullptr decodeOnly:YES];
}

- (void)testImportFromUserDefault {
    NSUserDefaults *userDefault = [[NSUserDefaults alloc] initWithSuiteName:@"testNSUserDefaults1"];
    [userDefault setBool:YES forKey:@"bool"];
    [userDefault setInteger:std::numeric_limits<NSInteger>::max() forKey:@"NSInteger"];
    [userDefault setFloat:3.14 forKey:@"float"];
    [userDefault setDouble:std::numeric_limits<double>::max() forKey:@"double"];
    [userDefault setObject:@"hello, NSUserDefaults" forKey:@"string"];
    [userDefault setObject:[NSDate date] forKey:@"date"];
    [userDefault setObject:[@"hello, NSUserDefaults again" dataUsingEncoding:NSUTF8StringEncoding] forKey:@"data"];
    [userDefault setURL:[NSURL URLWithString:@"https://mail.qq.com"] forKey:@"url"];

    NSNumber *number = [NSNumber numberWithBool:YES];
    [userDefault setObject:number forKey:@"number_bool"];

    number = [NSNumber numberWithChar:std::numeric_limits<char>::min()];
    [userDefault setObject:number forKey:@"number_char"];

    number = [NSNumber numberWithUnsignedChar:std::numeric_limits<unsigned char>::max()];
    [userDefault setObject:number forKey:@"number_unsigned_char"];

    number = [NSNumber numberWithShort:std::numeric_limits<short>::min()];
    [userDefault setObject:number forKey:@"number_short"];

    number = [NSNumber numberWithUnsignedShort:std::numeric_limits<unsigned short>::max()];
    [userDefault setObject:number forKey:@"number_unsigned_short"];

    number = [NSNumber numberWithInt:std::numeric_limits<int>::min()];
    [userDefault setObject:number forKey:@"number_int"];

    number = [NSNumber numberWithUnsignedInt:std::numeric_limits<unsigned int>::max()];
    [userDefault setObject:number forKey:@"number_unsigned_int"];

    number = [NSNumber numberWithLong:std::numeric_limits<long>::min()];
    [userDefault setObject:number forKey:@"number_long"];

    number = [NSNumber numberWithUnsignedLong:std::numeric_limits<unsigned long>::max()];
    [userDefault setObject:number forKey:@"number_unsigned_long"];

    number = [NSNumber numberWithLongLong:std::numeric_limits<long long>::min()];
    [userDefault setObject:number forKey:@"number_long_long"];

    number = [NSNumber numberWithUnsignedLongLong:std::numeric_limits<unsigned long long>::max()];
    [userDefault setObject:number forKey:@"number_unsigned_long_long"];

    number = [NSNumber numberWithFloat:3.1415];
    [userDefault setObject:number forKey:@"number_float"];

    number = [NSNumber numberWithDouble:std::numeric_limits<double>::max()];
    [userDefault setObject:number forKey:@"number_double"];

    number = [NSNumber numberWithInteger:std::numeric_limits<NSInteger>::min()];
    [userDefault setObject:number forKey:@"number_NSInteger"];

    number = [NSNumber numberWithUnsignedInteger:std::numeric_limits<NSUInteger>::max()];
    [userDefault setObject:number forKey:@"number_NSUInteger"];

    auto mmkv = [MMKV mmkvWithID:@"testImportNSUserDefaults1"];
    [mmkv migrateFromUserDefaultsDictionaryRepresentation:userDefault.dictionaryRepresentation];
    [mmkv clearMemoryCache];
    NSLog(@"%@", [mmkv allKeys]);

    NSLog(@"migrate from NSUserDefault begin");

    NSLog(@"bool = %d", [mmkv getBoolForKey:@"bool"]);
    NSLog(@"NSInteger = %lld", [mmkv getInt64ForKey:@"NSInteger"]);
    NSLog(@"float = %f", [mmkv getFloatForKey:@"float"]);
    NSLog(@"double = %f", [mmkv getDoubleForKey:@"double"]);
    NSLog(@"string = %@", [mmkv getStringForKey:@"string"]);
    NSLog(@"date = %@", [mmkv getDateForKey:@"date"]);
    NSLog(@"data = %@", [[NSString alloc] initWithData:[mmkv getDataForKey:@"data"] encoding:NSUTF8StringEncoding]);
    NSLog(@"url = %@", [NSKeyedUnarchiver unarchivedObjectOfClass:NSURL.class fromData:[mmkv getDataForKey:@"url"] error:nil]);
    NSLog(@"number_bool = %d", [mmkv getBoolForKey:@"number_bool"]);
    NSLog(@"number_char = %d", [mmkv getInt32ForKey:@"number_char"]);
    NSLog(@"number_unsigned_char = %d", [mmkv getInt32ForKey:@"number_unsigned_char"]);
    NSLog(@"number_short = %d", [mmkv getInt32ForKey:@"number_short"]);
    NSLog(@"number_unsigned_short = %d", [mmkv getInt32ForKey:@"number_unsigned_short"]);
    NSLog(@"number_int = %d", [mmkv getInt32ForKey:@"number_int"]);
    NSLog(@"number_unsigned_int = %u", [mmkv getUInt32ForKey:@"number_unsigned_int"]);
    NSLog(@"number_long = %lld", [mmkv getInt64ForKey:@"number_long"]);
    NSLog(@"number_unsigned_long = %llu", [mmkv getUInt64ForKey:@"number_unsigned_long"]);
    NSLog(@"number_long_long = %lld", [mmkv getInt64ForKey:@"number_long_long"]);
    NSLog(@"number_unsigned_long_long = %llu", [mmkv getUInt64ForKey:@"number_unsigned_long_long"]);
    NSLog(@"number_float = %f", [mmkv getFloatForKey:@"number_float"]);
    NSLog(@"number_double = %f", [mmkv getDoubleForKey:@"number_double"]);
    NSLog(@"number_NSInteger = %lld", [mmkv getInt64ForKey:@"number_NSInteger"]);
    NSLog(@"number_NSUInteger = %llu", [mmkv getUInt64ForKey:@"number_NSUInteger"]);

    NSLog(@"migrate from NSUserDefault end");
}

- (void)testAutoExpire {
    NSString *mmapID = @"testAutoExpire";
    auto mmkv = [MMKV mmkvWithID:mmapID];
    [mmkv clearAll];
    [mmkv trim];
    [mmkv disableAutoKeyExpire];

    [self testMMKV:mmapID withCryptKey:nil decodeOnly:NO];
    [mmkv setBool:YES forKey:@"auto_expire_key_1"];
    [mmkv enableAutoKeyExpire:1];
    [mmkv setString:@"never_expire_key_1" forKey:@"never_expire_key_1" expireDuration:MMKVExpireNever];

    auto arr = @[ @"str1", @"str2" ];
    [mmkv setObject:arr forKey:@"arr" expireDuration:0];
    NSArray *newArr = [mmkv getObjectOfClass:NSArray.class forKey:@"arr"];
    assert([arr isEqualToArray:newArr]);

    sleep(2);
    assert([mmkv containsKey:@"auto_expire_key_1"] == NO);
    assert([mmkv containsKey:@"never_expire_key_1"] == YES);
    [self testMMKV:mmapID withCryptKey:nil decodeOnly:YES];

    [mmkv removeValueForKey:@"never_expire_key_1"];
    [mmkv enableAutoKeyExpire:MMKVExpireNever];
    [mmkv setString:@"never_expire_key_1" forKey:@"never_expire_key_1"];
    [mmkv setBool:YES forKey:@"auto_expire_key_1" expireDuration:1];
    sleep(2);
    assert([mmkv containsKey:@"never_expire_key_1"] == YES);
    assert([mmkv containsKey:@"auto_expire_key_1"] == NO);
}

- (IBAction)onBtnClick:(id)sender {
    [self.m_loading startAnimating];
    self.m_btn.enabled = NO;

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        self->m_arrStrings = [NSMutableArray arrayWithCapacity:self->m_loops];
        for (size_t index = 0; index < self->m_loops; index++) {
            // auto str = @"[MMKV] [Info]<MemoryFile_OSX.cpp:36>: protection on [/var/mobile/Containers/Data/Application/B93F2BD3-E0DB-49B3-9BB0-C662E2FC11D9/Documents/mmkv/cips_commoncache] is NSFileProtectionCompleteUntilFirstUserAuthentication";
            // str = [str stringByAppendingFormat:@", %s-%d", __FILE__, rand()];
            NSString *str = [NSString stringWithFormat:@"%s-%d", __FILE__, rand()];
            [self->m_arrStrings addObject:str];

            //TestNSArchive *obj = self->m_arrNSCodingObjs[index];
            //obj.m_username = str;
        }

        [self mmkvBaselineTest:self->m_loops];
        [self userDefaultBaselineTest:self->m_loops];
        //[self brutleTest];

        [self.m_loading stopAnimating];
        self.m_btn.enabled = YES;
    });
}

#pragma mark - mmkv baseline test

- (void)mmkvBaselineTest:(int)loops {
    [self mmkvBatchReadInt:loops];
    [self mmkvBatchWriteInt:loops];
    [self mmkvBatchReadString:loops];
    [self mmkvBatchWriteString:loops];
    //[self mmkvBatchWriteObject:loops];
    //[self mmkvBatchReadObject:loops];

    //[self mmkvBatchDeleteString:loops];
    //[[MMKV defaultMMKV] trim];

    // auto mmkv = getMMKVForBatchTest();
    // [mmkv clearMemoryCache];
    // [mmkv actualSize];
}

MMKV *getMMKVForBatchTest() {
    // return [MMKV mmkvWithID:@"inter-process" mode:MMKVMultiProcess];
    // auto cryptKey = [@"crypt_key" dataUsingEncoding:NSUTF8StringEncoding];
    NSData *cryptKey = nil;
    // static auto key = [NSString stringWithFormat:@"batchTest_%d", rand()];
    // auto key = @"batchTest_crypt1";
    static auto key = @"batchTest1";
    MMKV *mmkv = [MMKV mmkvWithID:key cryptKey:cryptKey];
    return mmkv;
}

- (void)mmkvBatchWriteInt:(int)loops {
    @autoreleasepool {
        NSDate *startDate = [NSDate date];

        MMKV *mmkv = getMMKVForBatchTest();
        for (int index = 0; index < loops; index++) {
            int32_t tmp = rand();
            NSString *intKey = m_arrIntKeys[index];
            // NSString *intKey = [NSString stringWithFormat:@"6AB741D2-426B-4CC2-918B-EC910753FF74-%d", index];
            [mmkv setInt32:tmp forKey:intKey];
        }
        NSDate *endDate = [NSDate date];
        auto cost = [endDate timeIntervalSinceDate:startDate] * 1000;
        NSLog(@"mmkv write int %d times, cost:%.1f ms", loops, cost);

        /* delete some
        startDate = [NSDate date];

        for (int index = 0; index < (loops / 2); index++) {
            int32_t tmp = rand() % loops;
            NSString *intKey = m_arrIntKeys[tmp];
            [mmkv removeValueForKey:intKey];
        }
        endDate = [NSDate date];
        cost = [endDate timeIntervalSinceDate:startDate] * 1000;
        NSLog(@"mmkv delete int %d times, cost:%d ms", (loops / 2), cost);*/
    }
}

- (void)mmkvBatchReadInt:(int)loops {
    @autoreleasepool {
        NSDate *startDate = [NSDate date];

        MMKV *mmkv = getMMKVForBatchTest();
        for (int index = 0; index < loops; index++) {
            NSString *intKey = m_arrIntKeys[index];
            // NSString *intKey = [NSString stringWithFormat:@"6AB741D2-426B-4CC2-918B-EC910753FF74-%d", index];
            [mmkv getInt32ForKey:intKey];
        }
        NSDate *endDate = [NSDate date];
        auto cost = [endDate timeIntervalSinceDate:startDate] * 1000;
        NSLog(@"mmkv read int %d times, cost:%.1f ms", loops, cost);
    }
}

- (void)mmkvBatchWriteString:(int)loops {
    @autoreleasepool {
        NSDate *startDate = [NSDate date];

        MMKV *mmkv = getMMKVForBatchTest();
        for (int index = 0; index < loops; index++) {
            NSString *str = m_arrStrings[index];
            NSString *strKey = m_arrStrKeys[index];
            [mmkv setObject:str forKey:strKey];
        }
        NSDate *endDate = [NSDate date];
        auto cost = [endDate timeIntervalSinceDate:startDate] * 1000;
        NSLog(@"mmkv write string %d times, cost:%.1f ms", loops, cost);

        /* delete some
        startDate = [NSDate date];

        for (int index = 0; index < (loops / 2); index++) {
            int32_t tmp = rand() % loops;
            NSString *strKey = m_arrStrKeys[tmp];
            [mmkv removeValueForKey:strKey];
        }
        endDate = [NSDate date];
        cost = [endDate timeIntervalSinceDate:startDate] * 1000;
        NSLog(@"mmkv delete string %d times, cost:%d ms", (loops / 2), cost);*/
    }
}

- (void)mmkvBatchReadString:(int)loops {
    @autoreleasepool {
        NSDate *startDate = [NSDate date];

        MMKV *mmkv = getMMKVForBatchTest();
        for (int index = 0; index < loops; index++) {
            NSString *strKey = m_arrStrKeys[index];
            [mmkv getObjectOfClass:NSString.class forKey:strKey];
        }
        NSDate *endDate = [NSDate date];
        auto cost = [endDate timeIntervalSinceDate:startDate] * 1000;
        NSLog(@"mmkv read string %d times, cost:%.1f ms", loops, cost);
    }
}

- (void)mmkvBatchDeleteString:(int)loops {
    @autoreleasepool {
        NSDate *startDate = [NSDate date];

        MMKV *mmkv = getMMKVForBatchTest();
        for (int index = 0; index < loops; index++) {
            NSString *strKey = m_arrStrKeys[index];
            [mmkv removeValueForKey:strKey];
        }
        NSDate *endDate = [NSDate date];
        auto cost = [endDate timeIntervalSinceDate:startDate] * 1000;
        NSLog(@"mmkv delete string %d times, cost:%.1f ms", loops, cost);
    }
}

- (void)mmkvBatchWriteObject:(int)loops {
    @autoreleasepool {
        NSDate *startDate = [NSDate date];

        MMKV *mmkv = getMMKVForBatchTest();
        for (int index = 0; index < loops; index++) {
            TestNSArchive *obj = m_arrNSCodingObjs[index];
            NSString *objKey = m_arrObjKeys[index];
            [mmkv setObject:obj forKey:objKey];
        }
        NSDate *endDate = [NSDate date];
        auto cost = [endDate timeIntervalSinceDate:startDate] * 1000;
        NSLog(@"mmkv write object %d times, cost:%.1f ms", loops, cost);
    }
}

- (void)mmkvBatchReadObject:(int)loops {
    @autoreleasepool {
        NSDate *startDate = [NSDate date];

        MMKV *mmkv = getMMKVForBatchTest();
        for (int index = 0; index < loops; index++) {
            NSString *objKey = m_arrObjKeys[index];
            [mmkv getObjectOfClass:TestNSArchive.class forKey:objKey];
        }
        NSDate *endDate = [NSDate date];
        auto cost = [endDate timeIntervalSinceDate:startDate] * 1000;
        NSLog(@"mmkv read object %d times, cost:%.1f ms", loops, cost);
    }
}

#pragma mark - NSUserDefault baseline test

- (void)userDefaultBaselineTest:(int)loops {
    [self userDefaultBatchWriteInt:loops];
    [self userDefaultBatchReadInt:loops];
    [self userDefaultBatchWriteString:loops];
    [self userDefaultBatchReadString:loops];
    //[self userDefaultBatchWriteObject:loops];
    //[self userDefaultBatchReadObject:loops];
}

- (void)userDefaultBatchWriteInt:(int)loops {
    @autoreleasepool {
        NSDate *startDate = [NSDate date];

        NSUserDefaults *userdefault = [NSUserDefaults standardUserDefaults];
        for (int index = 0; index < loops; index++) {
            NSInteger tmp = rand();
            NSString *intKey = m_arrIntKeys[index];
            [userdefault setInteger:tmp forKey:intKey];
        }
        [userdefault synchronize];
        NSDate *endDate = [NSDate date];
        auto cost = [endDate timeIntervalSinceDate:startDate] * 1000;
        NSLog(@"NSUserDefaults write int %d times, cost:%.1f ms", loops, cost);
    }
}

- (void)userDefaultBatchReadInt:(int)loops {
    @autoreleasepool {
        NSDate *startDate = [NSDate date];

        NSUserDefaults *userdefault = [NSUserDefaults standardUserDefaults];
        for (int index = 0; index < loops; index++) {
            NSString *intKey = m_arrIntKeys[index];
            [userdefault integerForKey:intKey];
        }
        NSDate *endDate = [NSDate date];
        auto cost = [endDate timeIntervalSinceDate:startDate] * 1000;
        NSLog(@"NSUserDefaults read int %d times, cost:%.1f ms", loops, cost);
    }
}

- (void)userDefaultBatchWriteString:(int)loops {
    @autoreleasepool {
        NSDate *startDate = [NSDate date];

        NSUserDefaults *userdefault = [NSUserDefaults standardUserDefaults];
        for (int index = 0; index < loops; index++) {
            NSString *str = m_arrStrings[index];
            NSString *strKey = m_arrStrKeys[index];
            [userdefault setObject:str forKey:strKey];
        }
        [userdefault synchronize];
        NSDate *endDate = [NSDate date];
        auto cost = [endDate timeIntervalSinceDate:startDate] * 1000;
        NSLog(@"NSUserDefaults write string %d times, cost:%.1f ms", loops, cost);
    }
}

- (void)userDefaultBatchReadString:(int)loops {
    @autoreleasepool {
        NSDate *startDate = [NSDate date];

        NSUserDefaults *userdefault = [NSUserDefaults standardUserDefaults];
        for (int index = 0; index < loops; index++) {
            NSString *strKey = m_arrStrKeys[index];
            [userdefault objectForKey:strKey];
        }
        NSDate *endDate = [NSDate date];
        auto cost = [endDate timeIntervalSinceDate:startDate] * 1000;
        NSLog(@"NSUserDefaults read string %d times, cost:%.1f ms", loops, cost);
    }
}

- (void)userDefaultBatchWriteObject:(int)loops {
    @autoreleasepool {
        NSDate *startDate = [NSDate date];

        NSUserDefaults *userdefault = [NSUserDefaults standardUserDefaults];
        for (int index = 0; index < loops; index++) {
            TestNSArchive *obj = m_arrNSCodingObjs[index];
            NSString *objKey = m_arrObjKeys[index];
            auto tmp = [NSKeyedArchiver archivedDataWithRootObject:obj requiringSecureCoding:YES error:nil];
            [userdefault setObject:tmp forKey:objKey];
        }
        [userdefault synchronize];
        NSDate *endDate = [NSDate date];
        auto cost = [endDate timeIntervalSinceDate:startDate] * 1000;
        NSLog(@"NSUserDefaults write object %d times, cost:%.1f ms", loops, cost);
    }
}

- (void)userDefaultBatchReadObject:(int)loops {
    @autoreleasepool {
        NSDate *startDate = [NSDate date];

        NSUserDefaults *userdefault = [NSUserDefaults standardUserDefaults];
        for (int index = 0; index < loops; index++) {
            NSString *objKey = m_arrObjKeys[index];
            NSData *tmp = [userdefault objectForKey:objKey];
            [NSKeyedUnarchiver unarchivedObjectOfClass:TestNSArchive.class fromData:tmp error:nil];
        }
        NSDate *endDate = [NSDate date];
        auto cost = [endDate timeIntervalSinceDate:startDate] * 1000;
        NSLog(@"NSUserDefaults read object %d times, cost:%.1f ms", loops, cost);
    }
}

#pragma mark - brutle test

- (void)brutleTest {
    auto mmkv = [MMKV mmkvWithID:@"brutleTest"];
    auto ptr = malloc(1024);
    auto data = [NSData dataWithBytes:ptr length:1024];
    free(ptr);
    for (size_t index = 0; index < std::numeric_limits<size_t>::max(); index++) {
        NSString *key = [NSString stringWithFormat:@"key-%zu", index];
        [mmkv setObject:data forKey:key];

        if (index % 1000 == 0) {
            NSLog(@"brutleTest size=%zu", mmkv.totalSize);
        }
    }
}

#pragma mark - multi-process

- (void)testMultiProcess {
    NSData *key_1 = [@"multi_process" dataUsingEncoding:NSUTF8StringEncoding];
    auto mmkv = [MMKV mmkvWithID:@"multi_process" cryptKey:key_1 mode:MMKVMultiProcess];

    [mmkv setBool:YES forKey:@"bool"];
    NSLog(@"bool:%d", [mmkv getBoolForKey:@"bool"]);

    [mmkv setInt32:-1024 forKey:@"int32"];
    NSLog(@"int32:%d", [mmkv getInt32ForKey:@"int32"]);

    [mmkv setUInt32:std::numeric_limits<uint32_t>::max() forKey:@"uint32"];
    NSLog(@"uint32:%u", [mmkv getUInt32ForKey:@"uint32"]);

    [mmkv setInt64:std::numeric_limits<int64_t>::min() forKey:@"int64"];
    NSLog(@"int64:%lld", [mmkv getInt64ForKey:@"int64"]);

    [mmkv setUInt64:std::numeric_limits<uint64_t>::max() forKey:@"uint64"];
    NSLog(@"uint64:%llu", [mmkv getInt64ForKey:@"uint64"]);

    [mmkv setFloat:-3.1415926 forKey:@"float"];
    NSLog(@"float:%f", [mmkv getFloatForKey:@"float"]);

    [mmkv setDouble:std::numeric_limits<double>::max() forKey:@"double"];
    NSLog(@"double:%f", [mmkv getDoubleForKey:@"double"]);

    [mmkv setString:@"hello, mmkv" forKey:@"string"];
    NSLog(@"string:%@", [mmkv getStringForKey:@"string"]);

    [mmkv setObject:nil forKey:@"string"];
    NSLog(@"string after set nil:%@, containsKey:%d",
          [mmkv getObjectOfClass:NSString.class
                          forKey:@"string"],
          [mmkv containsKey:@"string"]);

    [mmkv setDate:[NSDate date] forKey:@"date"];
    NSLog(@"date:%@", [mmkv getDateForKey:@"date"]);

    [mmkv setData:[@"hello, mmkv again and again" dataUsingEncoding:NSUTF8StringEncoding] forKey:@"data"];
    NSData *data = [mmkv getDataForKey:@"data"];
    NSLog(@"data:%@", [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
    NSLog(@"data length:%zu, value size consumption:%zu", data.length, [mmkv getValueSizeForKey:@"data" actualSize:NO]);

    [mmkv removeValueForKey:@"bool"];
    NSLog(@"bool:%d", [mmkv getBoolForKey:@"bool"]);
    [mmkv removeValuesForKeys:@[ @"int32", @"uint64" ]];
    NSLog(@"allKeys %@", [mmkv allKeys]);

    [mmkv close];
}

- (void)updateTodayContent {
    static int count = 0;
    NSData *key_1 = [@"multi_process" dataUsingEncoding:NSUTF8StringEncoding];
    auto mmkv = [MMKV mmkvWithID:@"multi_process" cryptKey:key_1 mode:MMKVMultiProcess];
    NSString *content = [NSString stringWithFormat:@"count: %d", count++];
    [mmkv setString:content forKey:@"content"];
}

#pragma mark - backup & restore

- (void)testBackup {
    auto parentPath = [[MMKV mmkvBasePath] stringByDeletingLastPathComponent];
    auto dstPath = [parentPath stringByAppendingPathComponent:@"mmkv_backup"];
    auto rootPath = [parentPath stringByAppendingPathComponent:@"mmkv_2"];
    auto ret = [MMKV backupOneMMKV:@"test/case_aes" rootPath:rootPath toDirectory:dstPath];
    NSLog(@"MMKV backup one file ret: %d", ret);
    if (ret) {
        NSData *key_1 = [@"Key_seq_1" dataUsingEncoding:NSUTF8StringEncoding];
        auto backupedMMKV = [MMKV mmkvWithID:@"test/case_aes" cryptKey:key_1 rootPath:dstPath];
        NSLog(@"check on backup file:%@", [backupedMMKV allKeys]);
    }

    auto count = [MMKV backupAll:nil toDirectory:dstPath];
    NSLog(@"MMKV backup all count: %zu", count);
    if (count > 0) {
        NSData *key_1 = [@"Key_seq_1" dataUsingEncoding:NSUTF8StringEncoding];
        auto backupedMMKV = [MMKV mmkvWithID:@"test/case_aes" cryptKey:key_1 rootPath:dstPath];
        NSLog(@"check on backup file[%@] keys:%@", backupedMMKV.mmapID, [backupedMMKV allKeys]);

        backupedMMKV = [MMKV mmkvWithID:@"testAES_reKey" rootPath:dstPath];
        NSLog(@"check on backup file[%@] keys:%@", backupedMMKV.mmapID, [backupedMMKV allKeys]);

        backupedMMKV = [MMKV mmkvWithID:@"testImportNSUserDefaults1" rootPath:dstPath];
        NSLog(@"check on backup file[%@] keys:%@", backupedMMKV.mmapID, [backupedMMKV allKeys]);

        backupedMMKV = [MMKV mmkvWithID:@"testSwift" rootPath:dstPath];
        NSLog(@"check on backup file[%@] keys:%@", backupedMMKV.mmapID, [backupedMMKV allKeys]);
    }
}

- (void)testRestore {
    auto ID = @"test/case_aes";
    auto parentPath = [[MMKV mmkvBasePath] stringByDeletingLastPathComponent];
    auto dstPath = [parentPath stringByAppendingPathComponent:@"mmkv_backup"];
    auto rootPath = [parentPath stringByAppendingPathComponent:@"mmkv_2"];
    auto ret = [MMKV backupOneMMKV:ID rootPath:rootPath toDirectory:dstPath];
    NSLog(@"MMKV backup one file ret: %d", ret);
    if (ret) {
        NSData *key_1 = [@"Key_seq_1" dataUsingEncoding:NSUTF8StringEncoding];
        auto originMMKV = [MMKV mmkvWithID:ID cryptKey:key_1 rootPath:rootPath];
        [originMMKV setInt32:__LINE__ forKey:@"test_restore_key"];
        NSLog(@"file[%@] before restore:%@", originMMKV.mmapID, [originMMKV allKeys]);

        ret = [MMKV restoreOneMMKV:ID rootPath:rootPath fromDirectory:dstPath];
        NSLog(@"MMKV restore one file ret: %d", ret);
        if (ret) {
            NSLog(@"file[%@] after restore:%@", originMMKV.mmapID, [originMMKV allKeys]);
        }
    }

    auto count = [MMKV restoreAll:nil fromDirectory:dstPath];
    NSLog(@"MMKV restore all count: %zu", count);
    if (count > 0) {
        NSData *key_1 = [@"Key_seq_1" dataUsingEncoding:NSUTF8StringEncoding];
        auto restoredKV = [MMKV mmkvWithID:ID cryptKey:key_1];
        NSLog(@"check on restore file[%@] keys:%@", restoredKV.mmapID, [restoredKV allKeys]);

        restoredKV = [MMKV mmkvWithID:@"testAES_reKey"];
        NSLog(@"check on restore file[%@] keys:%@", restoredKV.mmapID, [restoredKV allKeys]);

        restoredKV = [MMKV mmkvWithID:@"testImportNSUserDefaults1"];
        NSLog(@"check on restore file[%@] keys:%@", restoredKV.mmapID, [restoredKV allKeys]);

        restoredKV = [MMKV mmkvWithID:@"testSwift"];
        NSLog(@"check on restore file[%@] keys:%@", restoredKV.mmapID, [restoredKV allKeys]);
    }
}

#pragma mark - expected capacity
- (void)testExpectedCapacity {

    int len = 10000;
    NSString *value = [NSString stringWithFormat:@"🏊🏻®4️⃣🐅_"];
    for (int i = 0; i < len; i++) {
        value = [value stringByAppendingString:@"0"];
    }
    NSLog(@"value size = %ld", [value lengthOfBytesUsingEncoding:NSUTF8StringEncoding]);
    NSString *key = [NSString stringWithFormat:@"key0"];

    // if we know exactly the sizes of key and value, set expectedCapacity for performance improvement
    size_t expectedSize = [key lengthOfBytesUsingEncoding:NSUTF8StringEncoding] + [value lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
    auto mmkv0 = [MMKV mmkvWithID:@"expectedCapacityTest0" expectedCapacity:expectedSize];
    // 0 times expand
    [mmkv0 setString:value forKey:key];

    int count = 10;
    expectedSize *= count;
    auto mmkv1 = [MMKV mmkvWithID:@"expectedCapacityTest1" expectedCapacity:expectedSize];
    for (int i = 0; i < count; i++) {
        // 0 times expand
        [mmkv1 setString:value forKey:[NSString stringWithFormat:@"key%d", i]];
    }
}

- (void)overrideTest {
    {
        auto mmkv0 = [MMKV mmkvWithID:@"overrideTest"];
        NSString *key = [NSString stringWithFormat:@"hello"];
        NSString *key2 = [NSString stringWithFormat:@"hello2"];
        NSString *value = [NSString stringWithFormat:@"world"];

        [mmkv0 setString:value forKey:key];
        auto v2 = [mmkv0 getStringForKey:key];
        if (![v2 isEqualToString:value]) {
            NSLog(@"value = %@", v2);
            abort();
        }
        [mmkv0 removeValueForKey:key];

        [mmkv0 setString:value forKey:key2];
        v2 = [mmkv0 getStringForKey:key2];
        if (![v2 isEqualToString:value]) {
            NSLog(@"value = %@", v2);
            abort();
        }
        [mmkv0 removeValueForKey:key2];

        int len = 10000;
        NSMutableString *bigValue = [NSMutableString stringWithFormat:@"🏊🏻®4️⃣🐅_"];
        for (int i = 0; i < len; i++) {
            [bigValue appendString:@"0"];
        }
        [mmkv0 setString:bigValue forKey:key];
        auto v3 = [mmkv0 getStringForKey:key];
        // NSLog(@"value = %@", v3);
        if (![bigValue isEqualToString:v3]) {
            abort();
        }

        // rewrite
        [mmkv0 setString:@"OK" forKey:key];
        auto v4 = [mmkv0 getStringForKey:key];
        if (![v4 isEqualToString:@"OK"]) {
            NSLog(@"value = %@", v2);
            abort();
        }

        [mmkv0 setInt32:12345 forKey:key];
        auto v5 = [mmkv0 getInt32ForKey:key];
        if (v5 != 12345) {
            NSLog(@"value = %d", v5);
            abort();
        }
        [mmkv0 removeValueForKey:key];

        [mmkv0 clearAll];
    }

    auto encryptionTestKV = [](NSString* key, NSString* value) {
        NSData *crypt = [@"fastestCrypt" dataUsingEncoding:NSUTF8StringEncoding];
        auto mmkv0 = [MMKV mmkvWithID:@"overrideCryptTest" cryptKey:crypt];

        [mmkv0 setString:value forKey:key];
        auto v2 = [mmkv0 getStringForKey:key];
        if (![value isEqualToString:v2]) {
            NSLog(@"value = %@, result = %@", value, v2);
            abort();
        }

        [mmkv0 close];
        mmkv0 = nil;
        mmkv0 = [MMKV mmkvWithID:@"overrideCryptTest" cryptKey:crypt mode:MMKVSingleProcess];
        v2 = [mmkv0 getStringForKey:key];
        if (![value isEqualToString:v2]) {
            NSLog(@"value = %@, result = %@", value, v2);
            abort();
        }
        [mmkv0 setString:value forKey:key];
        v2 = [mmkv0 getStringForKey:key];
        if (![value isEqualToString:v2]) {
            NSLog(@"value = %@, result = %@", value, v2);
            abort();
        }
        [mmkv0 removeValueForKey:key];
    };

    auto encryptionTest = [&](NSString* value) {
        NSString *key = [NSString stringWithFormat:@"hello"];
        NSString *key2 = [NSString stringWithFormat:@"hello2"];

        encryptionTestKV(key, value);
        encryptionTestKV(key2, value);
    };
    // [MMKV removeStorage:@"overrideCryptTest" rootPath:nil];

    // test small value
    encryptionTest(@"cryptworld");
    // test medium value
    encryptionTest(@"An efficient, small mobile key-value storage framework developed by WeChat. Works on Android, iOS, macOS, Windows, and POSIX.");
    // test large value
    encryptionTest(@"An efficient, small mobile key-value storage framework developed by WeChat. Works on Android, iOS, macOS, Windows, and POSIX. MMKV is an efficient, small, easy-to-use mobile key-value storage framework used in the WeChat application. It's currently available on Android, iOS/macOS, Windows, POSIX and HarmonyOS NEXT.");
}

- (void)onlyOneKeyTest {
    {
        auto mmkv0 = [MMKV mmkvWithID:@"onlyOneKeyTest"];
        NSString *key = [NSString stringWithFormat:@"hello"];
        NSString *value = [NSString stringWithFormat:@"world"];
        auto v = [mmkv0 getStringForKey:key];
        NSLog(@"value = %@", v);

        [mmkv0 setString:value forKey:key];
        auto v2 = [mmkv0 getStringForKey:key];
        NSLog(@"value = %@", v2);

        for (int i = 0; i < 10; i++) {
            NSString *value2 = [NSString stringWithFormat:@"world_%d", i];
            [mmkv0 setString:value2 forKey:key];
            auto v2 = [mmkv0 getStringForKey:key];
            NSLog(@"value = %@", v2);
        }

        int len = 10000;
        NSMutableString *bigValue = [NSMutableString stringWithFormat:@"🏊🏻®4️⃣🐅_"];
        for (int i = 0; i < len; i++) {
            [bigValue appendString:@"0"];
        }
        [mmkv0 setString:bigValue forKey:key];
        auto v3 = [mmkv0 getStringForKey:key];
        // NSLog(@"value = %@", v3);
        if (![bigValue isEqualToString:v3]) {
            abort();
        }

        [mmkv0 setString:@"OK" forKey:key];
        auto v4 = [mmkv0 getStringForKey:key];
        NSLog(@"value = %@", v4);

        [mmkv0 setInt32:12345 forKey:@"int"];
        auto v5 = [mmkv0 getInt32ForKey:key];
        NSLog(@"int value = %d", v5);
        [mmkv0 removeValueForKey:@"int"];
    }

    {
        NSString *crypt = [NSString stringWithFormat:@"fastest"];
        auto mmkv0 = [MMKV mmkvWithID:@"onlyOneKeyCryptTest" cryptKey:[crypt dataUsingEncoding:NSUTF8StringEncoding] mode:MMKVSingleProcess];
        NSString *key = [NSString stringWithFormat:@"hello"];
        NSString *value = [NSString stringWithFormat:@"cryptworld"];
        auto v = [mmkv0 getStringForKey:key];
        NSLog(@"value = %@", v);

        [mmkv0 setString:value forKey:key];
        auto v2 = [mmkv0 getStringForKey:key];
        NSLog(@"value = %@", v2);

        [mmkv0 setString:@"hello, cryptworld" forKey:key];
        auto v3 = [mmkv0 getStringForKey:key];
        NSLog(@"value = %@", v3);

        [mmkv0 close];
        mmkv0 = nil;

        auto mmkv1 = [MMKV mmkvWithID:@"onlyOneKeyCryptTest" cryptKey:[crypt dataUsingEncoding:NSUTF8StringEncoding] mode:MMKVSingleProcess];
        auto v4 = [mmkv1 getStringForKey:key];
        if (![v3 isEqualToString:v4]) {
            NSLog(@"value = %@", v4);
            abort();
        }

        for (int i = 0; i < 10; i++) {
            NSString *value2 = [NSString stringWithFormat:@"cryptworld_%d", i];
            [mmkv1 setString:value2 forKey:key];
            auto v2 = [mmkv1 getStringForKey:key];
            if (![v2 isEqualToString:value2]) {
                NSLog(@"value = %@", v2);
                abort();
            }
        }
    }
}

- (void)testClearAllWithKeepingSpace {
    {
        auto mmkv = [MMKV mmkvWithID:@"testClearAllWithKeepingSpace"];
        [mmkv setFloat:123.456f forKey:@"key1"];
        for (int i = 0; i < 10000; i++) {
            [mmkv setFloat:123.456f forKey:[NSString stringWithFormat:@"key_%d", i]];
        }
        auto previousSize = [mmkv totalSize];
        //    assert(previousSize > [PAGE_SIZE]);
        [mmkv clearAllWithKeepingSpace];
        assert([mmkv totalSize] == previousSize);
        NSLog(@"testClearAllWithKeepingSpace, size = %zu", previousSize);
        assert([mmkv count] == 0);
        [mmkv setFloat:123.4567f forKey:@"key2"];
        assert([mmkv count] == 1);
    }

    {
        NSString *crypt = [NSString stringWithFormat:@"Crypt123"];
        auto mmkv = [MMKV mmkvWithID:@"testClearAllWithKeepingSpaceCrypt" cryptKey:[crypt dataUsingEncoding:NSUTF8StringEncoding] mode:MMKVSingleProcess];
        [mmkv setFloat:123.456f forKey:@"key1"];
        for (int i = 0; i < 10000; i++) {
            [mmkv setFloat:123.456f forKey:[NSString stringWithFormat:@"key_%d", i]];
        }
        auto previousSize = [mmkv totalSize];
        //        assert(previousSize > PAGE_SIZE);
        [mmkv clearAllWithKeepingSpace];
        assert([mmkv totalSize] == previousSize);
        assert([mmkv count] == 0);
        [mmkv setFloat:123.4567f forKey:@"key2"];
        [mmkv setFloat:223.47f forKey:@"key3"];
        assert([mmkv count] == 2);
    }
}

- (void)testCompareBeforeSet {
    auto mmkv = [MMKV mmkvWithID:@"testCompareBeforeSet"];
    [mmkv enableCompareBeforeSet];
    [mmkv setBool:true forKey:@"extra"];

    {
        NSString *key = @"int64";
        int64_t v = 123456L;
        [mmkv setInt64:v forKey:key];
        long actualSize = [mmkv actualSize];
        NSLog(@"testCompareBeforeSet actualSize = %ld", actualSize);
        NSLog(@"testCompareBeforeSet v = %lld", [mmkv getInt64ForKey:key]);
        [mmkv setInt64:v forKey:key];
        long actualSize2 = [mmkv actualSize];
        NSLog(@"testCompareBeforeSet actualSize = %ld", actualSize2);
        if (actualSize != actualSize2) {
            abort();
        }
        [mmkv setInt64:v << 1 forKey:key];
        NSLog(@"testCompareBeforeSet actualSize = %ld", [mmkv actualSize]);
        NSLog(@"testCompareBeforeSet v = %lld", [mmkv getInt64ForKey:key]);
    }

    {
        NSString *key = @"string";
        NSString *v = [NSString stringWithFormat:@"w012A🏊🏻good"];
        [mmkv setString:v forKey:key];
        long actualSize = [mmkv actualSize];
        NSLog(@"testCompareBeforeSet actualSize = %ld", actualSize);
        NSLog(@"testCompareBeforeSet v = %@", [mmkv getStringForKey:key]);
        [mmkv setString:v forKey:key];
        long actualSize2 = [mmkv actualSize];
        NSLog(@"testCompareBeforeSet actualSize = %ld", actualSize2);
        if (actualSize != actualSize2) {
            abort();
        }
        [mmkv setString:@"another string" forKey:key];
        NSLog(@"testCompareBeforeSet actualSize = %ld", [mmkv actualSize]);
        NSLog(@"testCompareBeforeSet v = %@", [mmkv getStringForKey:key]);
    }
}

- (void)testRemoveStorage {
    auto mmapID = @"test_remove";
    {
        auto mmkv = [MMKV mmkvWithID:mmapID mode:MMKVMultiProcess];
        [mmkv setBool:YES forKey:@"bool"];
    }
    [MMKV removeStorage:mmapID mode:MMKVMultiProcess];
    {
        auto mmkv = [MMKV mmkvWithID:mmapID mode:MMKVMultiProcess];
        if (mmkv.count != 0) {
            abort();
        }
    }

    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
    NSString *libraryPath = (NSString *) [paths firstObject];
    NSString *rootDir = [libraryPath stringByAppendingPathComponent:@"mmkv_1"];
    mmapID = @"test_remove/sg";
    // {
    auto mmkv = [MMKV mmkvWithID:mmapID rootPath:rootDir];
    [mmkv setBool:YES forKey:@"bool"];
    // }
    [MMKV removeStorage:mmapID rootPath:rootDir];
    // {
    mmkv = [MMKV mmkvWithID:mmapID rootPath:rootDir];
    if (mmkv.count != 0) {
        abort();
    }
    // }
}

- (void)testReadOnly:(BOOL) isForPrepare {
    auto name = @"testReadOnly";
    NSData *key_1 = [@"Key_ReadOnly" dataUsingEncoding:NSUTF8StringEncoding];
    if (isForPrepare) {
        [self testMMKV:name withCryptKey:key_1 decodeOnly:NO];
    } else {
        auto mmkvPath = [[NSBundle mainBundle] pathForResource:name ofType:nil];
        auto mmkvDir = [mmkvPath stringByDeletingLastPathComponent];
        auto mmkv = [MMKV mmkvWithID:name cryptKey:key_1 rootPath:mmkvDir mode:MMKVReadOnly expectedCapacity:0];

        [ViewController testMMKV:mmkv decodeOnly:YES];

        // also check if it tolerate update operations without crash
        [ViewController testMMKV:mmkv decodeOnly:NO];
    }
}

@end

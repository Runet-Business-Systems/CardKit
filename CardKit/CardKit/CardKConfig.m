//
//  CardKConfig.m
//  CardKit
//
//  Created by Alex Korotkov on 10/1/19.
//  Copyright © 2019 AnjLab. All rights reserved.
//

#import "CardKConfig.h"

NSString *CardKProdKey = @"-----BEGIN PUBLIC KEY-----MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAoIITqh9xlGx4tWA+aucb0V0YuFC9aXzJb0epdioSkq3qzNdRSZIxe/dHqcbMN2SyhzvN6MRVl3xyjGAV+lwk8poD4BRW3VwPUkT8xG/P/YLzi5N8lY6ILlfw6WCtRPK5bKGGnERcX5dqL60LhOPRDSYT5NHbbp/J2eFWyLigdU9Sq7jvz9ixOLh6xD7pgNgHtnOJ3Cw0Gqy03r3+m3+CBZwrzcp7ZFs41bit7/t1nIqgx78BCTPugap88Gs+8ZjdfDvuDM+/3EwwK0UVTj0SQOv0E5KcEHENL9QQg3ujmEi+zAavulPqXH5907q21lwQeemzkTJH4o2RCCVeYO+YrQIDAQAB-----END PUBLIC KEY-----";
NSString *CardKTestKey = @"-----BEGIN PUBLIC KEY-----MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAhjH8R0jfvvEJwAHRhJi2Q4fLi1p2z10PaDMIhHbD3fp4OqypWaE7p6n6EHig9qnwC/4U7hCiOCqY6uYtgEoDHfbNA87/X0jV8UI522WjQH7Rgkmgk35r75G5m4cYeF6OvCHmAJ9ltaFsLBdr+pK6vKz/3AzwAc/5a6QcO/vR3PHnhE/qU2FOU3Vd8OYN2qcw4TFvitXY2H6YdTNF4YmlFtj4CqQoPL1u/uI0UpsG3/epWMOk44FBlXoZ7KNmJU29xbuiNEm1SWRJS2URMcUxAdUfhzQ2+Z4F0eSo2/cxwlkNA+gZcXnLbEWIfYYvASKpdXBIzgncMBro424z/KUr3QIDAQAB-----END PUBLIC KEY-----";

NSString *ProdURL = @"https://securepayments.sberbank.ru/payment/se/keys.do";
NSString *TestURL = @"https://3dsec.sberbank.ru/payment/se/keys.do";

static CardKConfig *__instance = nil;

@implementation CardKConfig

+ (CardKConfig *)defaultConfig {

  CardKConfig *config = [[CardKConfig alloc] init];

  config.theme = CardKTheme.defaultTheme;
  config.language = nil;
  if (config.isTestMod && config.cardKTestKey == nil) {
    config.pubKey = CardKTestKey;
  } else if (!config.isTestMod && config.cardKProdKey == nil ) {
    config.pubKey = CardKProdKey;
  } else if (config.isTestMod && config.cardKTestKey != nil) {
    config.pubKey = config.cardKTestKey;
  } else if (!config.isTestMod && config.cardKProdKey != nil) {
    config.pubKey = config.cardKProdKey;
  }
  
  [self fetchKeys];
  
  return config;
}

- (void)setLanguage:(NSString *)language {
  NSArray *codes = [NSArray arrayWithObjects:@"en", @"ru", @"de", @"fr", @"es", @"uk", nil];
  
  BOOL test = [codes containsObject:language];
  
  if (test) {
    _language = language;
    return;
  }
  
  _language = nil;
}

+ (CardKConfig *)shared {
  if (__instance == nil) {
    __instance = [CardKConfig defaultConfig];
  }

  return __instance;
}

+ (void)fetchKeys {
  NSString *prodURL = __instance.prodURL == nil ? ProdURL : __instance.prodURL;
  NSString *testURL = __instance.testURL == nil ? TestURL : __instance.testURL;

  NSMutableString *URL = [[NSMutableString alloc] initWithString:prodURL];
  if (__instance.isTestMod) {
    [URL setString:testURL];
  };

  NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:URL]];

  NSURLSession *session = [NSURLSession sharedSession];
  
  NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
      NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
      if(httpResponse.statusCode == 200)
      {
        NSError *parseError = nil;
        NSDictionary *responseDictionary = [NSJSONSerialization JSONObjectWithData:data options:0 error:&parseError];
        NSArray *keys = [responseDictionary objectForKey:@"keys"];
        NSDictionary *lastKey = [keys lastObject];
        NSString *keyValue = [lastKey objectForKey:@"keyValue"];
//          @"-----BEGIN PUBLIC KEY-----\
//            MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAws0r6I8emCsURXfuQcU2c9mwUlOiDjuCZ/f+EdadA4vq/kYt3w6kC5TUW97Fm/HTikkHd0bt8wJvOzz3T0O4so+vBaC0xjE8JuU1eCd+zUX/plw1REVVii1RNh9gMWW1fRNu6KDNSZyfftY2BTcP1dbE1itpXMGUPW+TOk3U9WP4vf7pL/xIHxCsHzb0zgmwShm3D46w7dPW+HO3PEHakSWV9bInkchOvh/vJBiRw6iadAjtNJ4+EkgNjHwZJDuo/0bQV+r9jeOe+O1aXLYK/s1UjRs5T4uGeIzmdLUKnu4eTOQ16P6BHWAjyqPnXliYIKfi+FjZxyWEAlYUq+CRqQIDAQAB-----END PUBLIC KEY-----"
        __instance.pubKey = keyValue;
      }
  }];
  [dataTask resume];
}

@end

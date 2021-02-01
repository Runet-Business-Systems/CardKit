//
//  CardKConfig.h
//  CardKit
//
//  Created by Alex Korotkov on 10/1/19.
//  Copyright © 2019 AnjLab. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <PassKit/PassKit.h>
#import "CardKTheme.h"
#import "CardKBinding.h"

NS_ASSUME_NONNULL_BEGIN

@interface CardKConfig : NSObject

@property (strong, nonatomic) CardKTheme *theme;
@property (nullable, strong, nonatomic) NSString *language;

@property (class, readonly, strong, nonatomic) CardKConfig *shared;

/*! Обязательный ввод CVC*/
@property BOOL bindingCVCRequired;

/*! Режим запуска */
@property BOOL isTestMod;

/*! Публичный ключ */
@property NSString *pubKey;

/*! Идентификатор заказа*/
@property NSString *mdOrder;

/*! Массив связок*/
@property NSArray<CardKBinding *> *bindings;

/*! URL для запроса тестового ключа */
@property NSString *testURL;

/*! URL для запроса продакшин ключа */
@property NSString *prodURL;

@property NSString *mrBinURL;

@property NSString *mrBinApiURL;

@property NSString *bindingsSectionTitle;

+ (void) fetchKeys:(NSString *)url;
@end

NS_ASSUME_NONNULL_END

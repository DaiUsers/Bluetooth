//
//  LBBluetoothManager.h
//  CoreBluetooth
//
//  Created by wheng on 17/6/15.
//  Copyright © 2017年 admin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>

typedef NS_ENUM(NSInteger, CBConnectState) {
    CBConnectStateSuccess = 0,
    CBConnectStateFailure,
    CBConnectStateRepeat,
} NS_ENUM_AVAILABLE(NA, 10_0);

@interface LBBluetoothManager : NSObject <CBCentralManagerDelegate,CBPeripheralDelegate>


@property (nonatomic, strong)CBCentralManager *LBCentral;
//扫描外设
@property (nonatomic, copy)void (^didDiscoverPeripheral)(CBPeripheral *peripheral);
//扫描到的外设
@property (nonatomic, strong)NSMutableArray <CBPeripheral *> *discoverArray;
//连接的外设
@property (nonatomic, strong)NSMutableArray <CBPeripheral *> *connectArray;
//连接外设
@property (nonatomic, copy)void (^connectedPeripheral)(CBPeripheral *peripheral, CBConnectState state);

@property (nonatomic, strong)CBPeripheral *currentPeripheral;

+ (instancetype)defaultManager;

/**
 开始扫描

 @param didDiscoverPeripheral 扫描外设回调
 */
- (void)scanPeripheral:(void(^)(CBPeripheral *peripheral))didDiscoverPeripheral;
/**
 连接外设
 
 @param peripheral 外设
 @param connectedPeripheral 连接回调
 */
- (void)connectPeripheral:(CBPeripheral *)peripheral handler:(void(^)(CBPeripheral *peripheral, CBConnectState state))connectedPeripheral;
/**
 发送数据
 
 @param value 数据
 @param peripheral 外设
 @param characteristic 特征
 */
- (void)writeValue:(NSData *)value toPeripheral:(CBPeripheral *)peripheral characteristic:(CBCharacteristic *)characteristic;

@end

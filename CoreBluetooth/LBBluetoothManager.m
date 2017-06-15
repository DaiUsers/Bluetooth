//
//  LBBluetoothManager.m
//  CoreBluetooth
//
//  Created by wheng on 17/6/15.
//  Copyright © 2017年 admin. All rights reserved.
//

#import "LBBluetoothManager.h"

@implementation LBBluetoothManager

+ (instancetype)defaultManager {
    static LBBluetoothManager *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[LBBluetoothManager alloc] init];
        [manager initArray];
    });
    return manager;
}

- (void)initArray {
    self.discoverArray = [[NSMutableArray alloc] init];
    self.connectArray  = [[NSMutableArray alloc] init];
}

- (void)centralManagerDidUpdateState:(CBCentralManager *)central {
    NSLog(@"CBCentralManagerDidUpdate");
    switch (central.state) {
        case CBManagerStatePoweredOn:
            [self.LBCentral scanForPeripheralsWithServices:nil options:nil];
            NSLog(@"蓝牙扫描");
            break;
        case CBManagerStatePoweredOff:
            NSLog(@"蓝牙未开启");
            break;
        case CBManagerStateUnknown:
            NSLog(@"CBCentralManagerStateUnknown");
            break;
        case CBManagerStateResetting:
            NSLog(@"CBCentralManagerStateResetting");
            break;
        case CBManagerStateUnsupported:
            NSLog(@"CBCentralManagerStateUnsupported");
            break;
        case CBManagerStateUnauthorized:
            NSLog(@"CBCentralManagerStateUnauthorized");
            break;
        default:
            break;
    }
}

//扫描外设
- (void)scanPeripheral:(void(^)(CBPeripheral *peripheral))didDiscoverPeripheral {
    if (!self.LBCentral) {
        self.LBCentral = [[CBCentralManager alloc]initWithDelegate:self queue:dispatch_get_main_queue()];
    }
    self.didDiscoverPeripheral = didDiscoverPeripheral;
    if (self.LBCentral.state == CBManagerStatePoweredOn) {
        [self.LBCentral scanForPeripheralsWithServices:nil options:nil];
    } else {
        NSLog(@"蓝牙未开启，请开启蓝牙");
    }
}

//扫描到外设
- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary<NSString *, id> *)advertisementData RSSI:(NSNumber *)RSSI {
    if (peripheral.name) {
        if ([self.discoverArray containsObject:peripheral]) {
            return;
        }
        
        self.didDiscoverPeripheral(peripheral);
        [self.discoverArray addObject:peripheral];
    }
}
//连接外设
- (void)connectPeripheral:(CBPeripheral *)peripheral handler:(void(^)(CBPeripheral *peripheral, CBConnectState state))connectedPeripheral {
    self.connectedPeripheral = connectedPeripheral;
    if (peripheral.state == CBPeripheralStateConnected) {
        connectedPeripheral(peripheral,CBConnectStateRepeat);
    } else {
        [self.LBCentral connectPeripheral:peripheral options:nil];
    }
}

//连接外设成功
- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral {
    self.connectedPeripheral(peripheral,CBConnectStateSuccess);
    self.currentPeripheral = peripheral;
    [self.connectArray addObject:peripheral];
    peripheral.delegate = self;
    //发现服务
    [peripheral discoverServices:nil];
}

//连接外设失败
- (void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(nullable NSError *)error {
    self.connectedPeripheral(peripheral,CBConnectStateFailure);
}

//连接断开
- (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error {
    //这里应该主动发送通知告知外部
    
    //断开连接之后，应当从连接列表中移除外设
    [self.connectArray removeObject:peripheral];
    
    // We're disconnected, so start scanning again
    
}

#pragma mark CBPeripheralDelegate 外设代理
//发现服务
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error {
    if (error) {
        NSLog(@"peripheral_Error:%@",error.localizedDescription);
        return;
    }
    for (CBService *service in peripheral.services) {
        NSLog(@"service：%@",service.UUID);
        //扫描每个service的Characteristics
        [peripheral discoverCharacteristics:nil forService:service];
    }
}
//扫描到Characteristics
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(nonnull CBService *)service error:(nullable NSError *)error {
    if (error) {
        NSLog(@"characteristics_Error:%@",error.localizedDescription);
    }
    
    for (CBCharacteristic *characteristic in service.characteristics) {
        NSLog(@"service:%@ 的 Characteristic: %@",service.UUID,characteristic.UUID);
        
        [peripheral setNotifyValue:YES forCharacteristic:characteristic];
    }
}
//获取charateristic的数据
- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
    
    //打印出characteristic的UUID和值
    //!注意，value的类型是NSData，具体开发时，会根据外设协议制定的方式去解析数据
    NSLog(@"characteristic value:%@",characteristic.value.description);
    
}
#pragma mark- 中心读取外设实时数据
- (void)peripheral:(CBPeripheral *)peripheral didUpdateNotificationStateForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
    if (error) {
        
    }
    // Notification has started
    if (characteristic.isNotifying) {
        //读取外设数据
        [peripheral readValueForCharacteristic:characteristic];
        NSLog(@"%@",characteristic.value);
        
    } else { // Notification has stopped
        // so disconnect from the peripheral
        //        NSLog(@"Notification stopped on %@.  Disconnecting", characteristic);
        
    }
}
#pragma mark - 7.给特征发送数据

//把数据写到外设的特征里面
- (void)writeValue:(NSData *)value toPeripheral:(CBPeripheral *)peripheral characteristic:(CBCharacteristic *)characteristic {
    
    //写入数据
    [peripheral writeValue:value forCharacteristic:characteristic type:CBCharacteristicWriteWithoutResponse];
}

@end

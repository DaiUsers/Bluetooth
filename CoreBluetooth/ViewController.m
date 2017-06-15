//
//  ViewController.m
//  CoreBluetooth
//
//  Created by wheng on 17/6/14.
//  Copyright © 2017年 admin. All rights reserved.
//

#define ScreenWidth     [UIScreen mainScreen].bounds.size.width
#define ScreenHeight    [UIScreen mainScreen].bounds.size.height


#import "ViewController.h"
#import "BluetoothCell.h"
#import "LBBluetoothManager.h"
#import <CoreBluetooth/CoreBluetooth.h>


@interface ViewController () <UITableViewDelegate,UITableViewDataSource>

@property (nonatomic, strong)UITableView *tableView;

@property (nonatomic, strong)NSMutableArray *dataArray;

@property (nonatomic, strong)LBBluetoothManager *manager;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    [self createTableView];
    self.manager = [LBBluetoothManager defaultManager];
    __block typeof(self)weakSelf = self;
    [self.manager scanPeripheral:^(CBPeripheral *peripheral) {
        [weakSelf.dataArray addObject:peripheral];
        [weakSelf.tableView reloadData];
    }];
}

- (void)createTableView {
    
    self.dataArray = [[NSMutableArray alloc] init];
    
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 100, ScreenWidth, ScreenHeight - 100) style:UITableViewStylePlain];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.view addSubview:self.tableView];
    
}

#pragma mark UITableViewDataSource

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *identifier = @"CBCell";
    BluetoothCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil) {
        cell = [[BluetoothCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    CBPeripheral *peripheral = [self.dataArray objectAtIndex:indexPath.row];
    [cell.textLabel setText:peripheral.name];
    
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataArray.count;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    CBPeripheral *peripheral = [self.dataArray objectAtIndex:indexPath.row];
    __weak typeof(self)weakSelf = self;
    [self.manager connectPeripheral:peripheral handler:^(CBPeripheral *peripheral, CBConnectState state) {
        if (state == CBConnectStateSuccess) {
            [weakSelf changeCellStatusWithPeripheral:peripheral];
        }
    }];
}

- (void)changeCellStatusWithPeripheral:(CBPeripheral *)peripheral {
    NSInteger index = [self.dataArray indexOfObject:self.manager.currentPeripheral];
    BluetoothCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0]];
    cell.accessoryType = UITableViewCellAccessoryNone;
    
    NSInteger nowIndex = [self.dataArray indexOfObject:peripheral];
    BluetoothCell *nowCell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:nowIndex inSection:0]];
    nowCell.accessoryType = UITableViewCellAccessoryCheckmark;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end

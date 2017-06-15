//
//  BluetoothCell.m
//  CoreBluetooth
//
//  Created by wheng on 17/6/15.
//  Copyright © 2017年 admin. All rights reserved.
//

#import "BluetoothCell.h"

@implementation BluetoothCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.textLabel.font = [UIFont italicSystemFontOfSize:15];
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    if (self.isSelected) {
        self.textLabel.textColor = [UIColor cyanColor];
    } else {
        self.textLabel.textColor = [UIColor redColor];
    }

    // Configure the view for the selected state
}

@end

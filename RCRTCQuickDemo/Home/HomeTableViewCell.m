//
//  RCRTCHomeTableViewCell.m
//  RCRTCQuickDemo
//
//  Copyright © 2021 RongCloud. All rights reserved.
//

#import "HomeTableViewCell.h"

@implementation HomeTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setDataModel:(NSDictionary *)data {
    self.titleLabel.text = data[@"title"];
    self.descriptionLabel.text = data[@"description"];
    self.iconImageView.image = [UIImage imageNamed:data[@"image"]];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end

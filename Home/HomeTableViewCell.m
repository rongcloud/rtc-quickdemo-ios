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
    
    self.identifyIcon.hidden = YES;
    if ([data[@"title"] isEqualToString:@"CallPlus"]) {
        self.identifyIcon.hidden = NO;
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end

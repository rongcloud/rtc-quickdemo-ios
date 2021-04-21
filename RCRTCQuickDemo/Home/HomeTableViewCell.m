//
//  RCRTCHomeTableViewCell.m
//  RCRTCQuickDemo
//
//  Created by yifan on 2021/4/20.
//

#import "HomeTableViewCell.h"

@implementation HomeTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setDataModel:(NSDictionary *)data{
    self.titleLabel.text = data[@"title"];
    self.descriptionLabel.text = data[@"description"];
    self.iconImageView.image = [UIImage imageNamed:data[@"image"]];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end

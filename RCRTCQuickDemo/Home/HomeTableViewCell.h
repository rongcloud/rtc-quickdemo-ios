//
//  RCRTCHomeTableViewCell.h
//  RCRTCQuickDemo
//
//  Created by yifan on 2021/4/20.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface HomeTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *iconImageView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *descriptionLabel;

- (void)setDataModel:(NSDictionary *)data;

@end

NS_ASSUME_NONNULL_END

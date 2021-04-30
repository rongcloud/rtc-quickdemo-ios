//
//  RCRTCHomeTableViewCell.h
//  RCRTCQuickDemo
//
//  Created by yifan on 2021/4/20.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface HomeTableViewCell : UITableViewCell
@property (nonatomic, weak) IBOutlet UIImageView *iconImageView;
@property (nonatomic, weak) IBOutlet UILabel *titleLabel;
@property (nonatomic, weak) IBOutlet UILabel *descriptionLabel;

- (void)setDataModel:(NSDictionary *)data;

@end

NS_ASSUME_NONNULL_END

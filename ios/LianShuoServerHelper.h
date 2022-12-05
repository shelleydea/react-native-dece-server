#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface LianShuoServerHelper : NSObject

+ (instancetype)lianShuo_shared;
- (void)lianShuo_appInitialStartOrEnterForeground;

@end

NS_ASSUME_NONNULL_END

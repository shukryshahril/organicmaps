#import "MWMMyPositionMode.h"

@interface MWMSideButtons : NSObject

+ (MWMSideButtons *)buttons;

@property(nonatomic) BOOL zoomHidden;
@property(nonatomic) BOOL hidden;
/// Shows the record control under the location button; set while navigating.
@property(nonatomic) BOOL recordButtonVisible;
@property(nonatomic, readonly) UIView * view;

- (instancetype)init __attribute__((unavailable("init is not available")));
- (instancetype)initWithParentView:(UIView *)view;

- (void)processMyPositionStateModeEvent:(MWMMyPositionMode)mode;

+ (void)updateAvailableArea:(CGRect)frame;

@end

@class MWMButton;

@interface MWMSideButtonsView : UIView

@property(nonatomic) BOOL zoomHidden;
/// Record control stacked under the location button while navigating.
@property(nonatomic, readonly) MWMButton * recordButton;
@property(nonatomic) BOOL navigationButtonsVisible;

- (instancetype)initWithFrame:(CGRect)frame __attribute__((unavailable("initWithFrame is not available")));
- (instancetype)init __attribute__((unavailable("init is not available")));

- (void)setHidden:(BOOL)hidden animated:(BOOL)animated;

- (void)updateAvailableArea:(CGRect)frame;

@end

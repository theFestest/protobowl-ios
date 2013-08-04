

@interface ASUILabel : UILabel
{
    UIFont *highlightedTextFont;
    UIFont *emphasisTextFont;
    NSUInteger offset;
}
@property (strong, nonatomic) UIFont *highlightedTextFont;
@property (strong, nonatomic) UIFont *emphasisTextFont;

@end
//
//  InspectorAnimation.h
//  SpriteBuilder
//
//  Created by John Twigg on 5/26/14.
//
//

#import "InspectorValue.h"
#import "cocos2d.h"

//A protocal to abstract away the functionality of the CCBPCCBFile class.
@protocol SBAnimatableNode <NSObject>
@required
@property (nonatomic,strong) NSString * animation;
@property (nonatomic,readonly) NSArray * animations;
@property (nonatomic,strong) NSString * label;
@property (nonatomic,assign) float tween;
@property (nonatomic,assign) float playbackSpeed;
@end

@interface InspectorAnimation : InspectorValue

@property (readonly) id<SBAnimatableNode>animatableNode;

@property (weak) IBOutlet NSComboBoxCell *animationsComboBox;
@property NSString * animation;
@property float      tween;

@end

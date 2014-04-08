//
//  SnapLayer.m
//  SpriteBuilder
//
//  Created by Michael Daniels on 4/8/14.
//
//

#import "SnapLayer.h"
#import "AppDelegate.h"
#import "CocosScene.h"
#import "CCNode+PositionExtentions.h"

#define kOptionKey 58

@interface SnapLayer() {
    BOOL optionKeyDown;
}

@property (nonatomic, strong) AppDelegate *appDelegate;
@property (nonatomic, strong) CCDrawNode *drawLayer;
@property (nonatomic, strong) NSMutableArray *verticalSnapLines;
@property (nonatomic, strong) NSMutableArray *horizontalSnapLines;

@end

@implementation SnapLayer

@synthesize appDelegate;
@synthesize sensativity;
@synthesize drawLayer;
@synthesize verticalSnapLines;
@synthesize horizontalSnapLines;

#pragma mark - Setup

- (id)init
{
    if (self = [super init]) {
        [self setup];
    }
    return self;
}

- (void)setup {
    appDelegate = [AppDelegate appDelegate];
    sensativity = 10;
    drawLayer = [CCDrawNode node];
    verticalSnapLines = [NSMutableArray new];
    horizontalSnapLines = [NSMutableArray new];
    [self addChild:drawLayer];
    [self setupOptionKeyListener];
}

- (void)setupOptionKeyListener {
    [NSEvent addLocalMonitorForEventsMatchingMask:NSFlagsChangedMask handler:^NSEvent *(NSEvent *incomingEvent) {
        if(incomingEvent.keyCode == kOptionKey) {
            if(incomingEvent.modifierFlags & NSAlternateKeyMask) {
                optionKeyDown = YES;
            } else {
                optionKeyDown = NO;
            }
        }
        return incomingEvent;
    }];
}

#pragma mark - Memory Management

- (void)dealloc {
    [NSEvent removeMonitor:self];
}

#pragma mark - Drawing

- (void)drawLines {
    [drawLayer clear];
    
    CocosScene* cs = [CocosScene cocosScene];
    for(NSNumber *x in verticalSnapLines) {
        CGPoint start = [cs convertToViewSpace:ccp([x floatValue], 0)];
        CGPoint end = [cs convertToViewSpace:ccp([x floatValue], cs.stageSize.height)];
        [drawLayer drawSegmentFrom:start to:end radius:1 color:[CCColor whiteColor]];
    }
    for(NSNumber *y in horizontalSnapLines) {
        CGPoint start = [cs convertToViewSpace:ccp(0, [y floatValue])];
        CGPoint end = [cs convertToViewSpace:ccp(cs.stageSize.width, [y floatValue])];
        [drawLayer drawSegmentFrom:start to:end radius:1 color:[CCColor whiteColor]];
    }
}

- (void)findSnappedLines {
    [verticalSnapLines removeAllObjects];
    [horizontalSnapLines removeAllObjects];
    CCNode *sNode = appDelegate.selectedNode;
    for(CCNode *node in sNode.parent.children) { // Get all the nodes in the same node as the selected node
        if(node != appDelegate.selectedNode) { // Ignore the selected node
            // Snap lines from center
            if(sNode.position.x == node.position.x) {
                [verticalSnapLines addObject:[NSNumber numberWithFloat:sNode.position.x]];
            }
            if(sNode.position.y == node.position.y) {
                [horizontalSnapLines addObject:[NSNumber numberWithFloat:sNode.position.y]];
            }
            
            // Snap lines for opposite sides
            if(sNode.left == node.right) {
                [verticalSnapLines addObject:[NSNumber numberWithFloat:sNode.left]];
            }
            if(sNode.right == node.left) {
                [verticalSnapLines addObject:[NSNumber numberWithFloat:sNode.right]];
            }
            if(sNode.top == node.bottom) {
                [horizontalSnapLines addObject:[NSNumber numberWithFloat:sNode.top]];
            }
            if(sNode.bottom == node.top) {
                [horizontalSnapLines addObject:[NSNumber numberWithFloat:sNode.bottom]];
            }
            
            // Snap lines for same sides
            if(sNode.left == node.left) {
                [verticalSnapLines addObject:[NSNumber numberWithFloat:sNode.left]];
            }
            if(sNode.right == node.right) {
                [verticalSnapLines addObject:[NSNumber numberWithFloat:sNode.right]];
            }
            if(sNode.top == node.top) {
                [horizontalSnapLines addObject:[NSNumber numberWithFloat:sNode.top]];
            }
            if(sNode.bottom == node.bottom) {
                [horizontalSnapLines addObject:[NSNumber numberWithFloat:sNode.bottom]];
            }
            
        }
    }
}

- (void)snapIfNeeded {
    if(!optionKeyDown) { // Don't snap if the user is holding the option key
        CCNode *sNode = appDelegate.selectedNode;
        if(appDelegate.selectedNode.parent) {
            for(CCNode *node in appDelegate.selectedNode.parent.children) {
                if(node != appDelegate.selectedNode) {
                    float newX = sNode.position.x;
                    float newY = sNode.position.y;
                    
                    // Snap from center
                    if(abs(sNode.position.x - node.position.x) < self.sensativity) {
                        newX = node.position.x;
                    } if(abs(sNode.position.y - node.position.y) < self.sensativity) {
                        newY = node.position.y;
                    }
                    appDelegate.selectedNode.position = ccp(newX, newY);
                    
                    // Snap to opposite sides
                    if(abs(sNode.left - node.right) < self.sensativity) {
                        sNode.left = node.right;
                    } else if(abs(sNode.right - node.left) < self.sensativity) {
                        sNode.right = node.left;
                    }
                    if(abs(sNode.top - node.bottom) < self.sensativity) {
                        sNode.top = node.bottom;
                    } else if(abs(sNode.bottom - node.top) < self.sensativity) {
                        sNode.bottom = node.top;
                        newY = sNode.position.y;
                    }
                    
                    // Snap to same sides
                    if(abs(sNode.left - node.left) < self.sensativity) {
                        sNode.left = node.left;
                    } else if(abs(sNode.right - node.right) < self.sensativity) {
                        sNode.right = node.right;
                        newX = sNode.position.x;
                    }
                    if(abs(sNode.top - node.top) < self.sensativity) {
                        sNode.top = node.top;
                    } else if(abs(sNode.bottom - node.bottom) < self.sensativity) {
                        sNode.bottom = node.bottom;
                        newY = sNode.position.y;
                    }
                    
                }
            }
        }
    }
    [self findSnappedLines];
}

#pragma mark - Mouse Events

- (BOOL) mouseDown:(CGPoint)pt event:(NSEvent*)event
{
    BOOL success = YES;
    
    [self snapIfNeeded];
    [self drawLines];
    
    return success;
}

- (BOOL) mouseDragged:(CGPoint)pt event:(NSEvent*)event
{
    BOOL success = YES;
    
    [self snapIfNeeded];
    [self drawLines];
    
    return success;
}

- (BOOL) mouseUp:(CGPoint)pt event:(NSEvent*)event
{
    BOOL success = YES;
    
    [drawLayer clear];
    
    return success;
}

@end

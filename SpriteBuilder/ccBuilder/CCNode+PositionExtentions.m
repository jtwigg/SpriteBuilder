//
//  CCNode+PositionExtentions.m
//  SpriteBuilder
//
//  Created by Michael Daniels on 4/8/14.
//
//

#import "CCNode+PositionExtentions.h"

@implementation CCNode (PositionExtentions)

#pragma mark - Side Positions

- (float)top
{
    return self.position.y + self.contentSize.height / 2;
}

- (void)setTop:(float)top {
    self.position = ccp(self.position.x, top - self.contentSize.height / 2);
}



- (float)right
{
    return self.position.x + self.contentSize.width / 2;
}

- (void)setRight:(float)right {
    self.position = ccp(right - self.contentSize.width / 2, self.position.y);
}



- (float)bottom
{
    return self.position.y - self.contentSize.height / 2;
}

- (void)setBottom:(float)bottom {
    self.position = ccp(self.position.x, bottom + self.contentSize.height / 2);
}



- (float)left
{
    return self.position.x - self.contentSize.width / 2;
}

- (void)setLeft:(float)left {
    self.position = ccp(left + self.contentSize.width / 2, self.position.y);
}

@end

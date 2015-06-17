//
//  GameScene.m
//  BrickBreaker
//
//  Created by Erik Arakelyan on 6/8/15.
//  Copyright (c) 2015 Erik Arakelyan. All rights reserved.
//

#import "GameScene.h"
#import "EndScene.h"
@interface GameScene()
@property (nonatomic)SKSpriteNode *paddle;
@property  (nonatomic) SKAction *paddleSound;
@property  (nonatomic) SKAction *brickSound;

@end


static const uint32_t ballCategory   = 1; // 00000000000000000000000000000001
static const uint32_t brickCategory  = 2; // 00000000000000000000000000000010
static const uint32_t paddleCategory = 4; // 00000000000000000000000000000100
static const uint32_t edgeCategory   = 8; // 00000000000000000000000000001000
static const uint32_t bottomEdgeCategory = 16; // 00000000000000000000000000010000

// be careful when providing direct integer values - this would cause problems.
// static const uint32_t WHOOPSCategory = 15; // 00000000000000000000000000001111

/* alternatively, using bitwise operators
 static const uint32_t ballCategory   = 0x1;      // 00000000000000000000000000000001
 static const uint32_t brickCategory  = 0x1 << 1; // 00000000000000000000000000000010
 static const uint32_t paddleCategory = 0x1 << 2; // 00000000000000000000000000000100
 static const uint32_t edgeCategory   = 0x1 << 3; // 00000000000000000000000000001000
 */

@implementation GameScene

-(void)didBeginContact:(SKPhysicsContact *)contact
{
//    if(contact.bodyA.categoryBitMask==brickCategory)
//    {
//        NSLog(@"bodyA is a brick!");
//        [contact.bodyA.node removeFromParent];
//    
//    }
//    if(contact.bodyB.categoryBitMask==brickCategory)
//    {
//        NSLog(@"bodyB is a brick!");
//        [contact.bodyB.node removeFromParent];
//
//    }
    
    //create placeholder refrence for the "non ball" object
    SKPhysicsBody *notTheBall;
    if(contact.bodyA.categoryBitMask<contact.bodyB.categoryBitMask)
    {
        notTheBall=contact.bodyB;
    }else{ notTheBall=contact.bodyA;}
    
    if(notTheBall.categoryBitMask==brickCategory)
    {
        NSLog(@"It is a brick");
        [notTheBall.node removeFromParent];
        [self runAction:self.brickSound];

    }
    if(notTheBall.categoryBitMask==paddleCategory)
    {
        NSLog(@"It is a paddle. BOOOOING");
        [self runAction:self.paddleSound];
        
    }
    if(notTheBall.categoryBitMask==bottomEdgeCategory)
    {
        NSLog(@"It is a the bottom edge. You Lost");
        EndScene *end=[EndScene sceneWithSize:self.size];
        [self.view presentScene:end transition:[SKTransition doorsCloseHorizontalWithDuration:0.5]];
     
        
    }


}

-(void)addBottomEdge
{
    SKNode *bottomEdge=[SKNode node];
    bottomEdge.physicsBody=[SKPhysicsBody bodyWithEdgeFromPoint:CGPointMake(0, 1) toPoint:CGPointMake(self.size.width, 1)];
    bottomEdge.physicsBody.categoryBitMask=bottomEdgeCategory;
    [self addChild:bottomEdge];
    

}

- (void)addBall
{
    
    /* Setup your scene here */

    SKSpriteNode *sprite = [SKSpriteNode spriteNodeWithImageNamed:@"ball"];
    
    CGPoint centerPoint=CGPointMake(self.size.width/2,self.size.height/2);
    
    sprite.physicsBody=[SKPhysicsBody bodyWithCircleOfRadius:sprite.frame.size.width/2];//this action must be done before giving any properties to the sprite
    sprite.position=centerPoint;
    sprite.physicsBody.friction=0; //not useful for a slowing down ball/ a small effect/ the friction of collision
    
    sprite.physicsBody.linearDamping=0; //simulates how much resistance the object has when moving
    sprite.physicsBody.restitution=1.0f; //this property describes bouncyness. 0-not bouncy at all 1-very 100% bouncy
    sprite.physicsBody.categoryBitMask=ballCategory;
    sprite.physicsBody.contactTestBitMask=brickCategory | paddleCategory |bottomEdgeCategory;
    //sprite.physicsBody.collisionBitMask= edgeCategory | brickCategory ;
    SKTextureAtlas *atlas=[SKTextureAtlas atlasNamed:@"orb"];
    NSArray *orbImageNames=[atlas textureNames]; // only holds the names
    NSArray *sortedNames=[orbImageNames sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
    NSMutableArray *orbTextures=[NSMutableArray array];
    for(NSString *filename in sortedNames)//filling an array with the actual objects
    {
        SKTexture *texture=[atlas textureNamed:filename];
        [orbTextures addObject:texture];
        
    }
    SKAction *glow=[SKAction animateWithTextures:orbTextures timePerFrame:0.1];
    SKAction *repeat=[SKAction repeatActionForever:glow];
    [sprite runAction:repeat];

    
    [self addChild:sprite];
    
    CGVector vector=CGVectorMake(10, 10);
    [sprite.physicsBody applyImpulse:vector];
}
-(void)addPlayer
{
    //create
    self.paddle=[SKSpriteNode spriteNodeWithImageNamed:@"paddle"];
    //position
    self.paddle.position=CGPointMake(self.size.width/2, 100);
    //add physics body
    self.paddle.physicsBody=[SKPhysicsBody bodyWithRectangleOfSize:self.paddle.frame.size];
    
    self.paddle.physicsBody.dynamic=NO;
    self.paddle.physicsBody.categoryBitMask=paddleCategory;
    //add
    [self addChild:self.paddle];

}
-(void)addBricks
{
    for(int i=0;i<4;i++)
    {
        SKSpriteNode *brick=[SKSpriteNode spriteNodeWithImageNamed:@"brick"];
        brick.physicsBody=[SKPhysicsBody bodyWithRectangleOfSize:brick.frame.size];
        brick.physicsBody.dynamic=NO;
        brick.physicsBody.categoryBitMask=brickCategory;
        int xPos=self.size.width/5*(i+1);
        int yPos=self.size.height-51;
        brick.position=CGPointMake(xPos, yPos);
        [self addChild:brick];

    
    }

}

-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    for(UITouch *touch in touches)
    {
        CGPoint location=[touch locationInNode:self];
        CGPoint newPos=CGPointMake(location.x, 100);
        if(newPos.x<self.paddle.size.width/2)
        {newPos.x=self.paddle.size.width/2;}
        if(newPos.x>self.size.width-self.paddle.size.width/2)
        {newPos.x=self.size.width-self.paddle.size.width/2;}
        self.paddle.position=newPos;

    
    }

}

-(void)didMoveToView:(SKView *)view {
    
    self.backgroundColor=[SKColor blackColor];

    self.physicsBody=[SKPhysicsBody bodyWithEdgeLoopFromRect:self.frame];
    self.physicsBody.categoryBitMask=edgeCategory;
    self.physicsWorld.gravity=CGVectorMake(0, 0);
    self.physicsWorld.contactDelegate=self;
    self.paddleSound=[SKAction playSoundFileNamed:@"blip.caf" waitForCompletion:NO];
    self.brickSound=[SKAction playSoundFileNamed:@"brickhit.caf" waitForCompletion:NO];

    [self addBall];
    [self addPlayer];
    [self addBricks];
    [self addBottomEdge];


    
}


-(void)update:(CFTimeInterval)currentTime {
    /* Called before each frame is rendered */
}

@end

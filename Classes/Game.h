#import <Foundation/Foundation.h>
#import <OpenGLES/ES1/gl.h>
#import <OpenGLES/ES1/glext.h>

typedef struct {
	GLfloat x,y,z;
} Vertex;

typedef struct {
	GLfloat x,y,z,a;
} Vertex4;

@interface Game : NSObject {

}

-(void)Reset;
-(void)Initialize;
-(void)Draw;
-(void)DetermineLineCrossings;

-(void)TouchBegan :(NSSet *)touches;
-(void)TouchMoved :(NSSet *)touches;
-(void)TouchReleased :(NSSet *)touches;

@end

extern Game *game;



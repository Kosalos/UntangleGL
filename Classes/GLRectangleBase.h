#import "Game.h"

@interface GLRectangleBase : NSObject {
	Vertex vertice[4];
	Vertex normal[4];
	
	GLfloat textureCoords[8];
}

-(void)ScrollTexture :(float)dx :(float)dy;
-(void)Position :(Vertex)p0 :(Vertex)p1 :(Vertex)p2 :(Vertex)p3;
-(void)Draw :(GLuint)textureID;

@end

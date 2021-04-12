#import "GLRectangleBase.h"

@implementation GLRectangleBase

-(id)init {
    if(self = [super init]) {
		textureCoords[0] = 0;
		textureCoords[1] = 0;
		
		textureCoords[2] = 1;
		textureCoords[3] = 0;
		
		textureCoords[4] = 0;
		textureCoords[5] = 1;
		
		textureCoords[6] = 1;
		textureCoords[7] = 1;
    }
	
    return self;
}

-(void)Position :(Vertex)p0 :(Vertex)p1 :(Vertex)p2 :(Vertex)p3
{
	vertice[0] = p1;
	vertice[1] = p0;
	vertice[2] = p2;
	vertice[3] = p3;
	
	Vertex d1,d2,c;
	d1.x = -vertice[3].x + vertice[2].x;
	d1.y = -vertice[3].y + vertice[2].y;
	d1.z = -vertice[3].z + vertice[2].z;
	
	d2.x = vertice[3].x - vertice[0].x;
	d2.y = vertice[3].y - vertice[0].y;
	d2.z = vertice[3].z - vertice[0].z;
	
	c.x = -d1.y * d2.z + d1.z * d2.y; 
	c.y = -d1.z * d2.x + d1.x * d2.z; 
	c.z = -d1.x * d2.y + d1.y * d2.x; 
	
	GLfloat len = sqrt(c.x*c.x + c.y*c.y + c.z*c.z);
	
	c.x /= len;
	c.y /= len;
	c.z /= len;
	
	for(int i=0;i<4;++i)
		normal[i] = c;
}

// ========================================================

-(void)Draw :(GLuint)textureID
{
	glEnableClientState(GL_NORMAL_ARRAY);
	glNormalPointer(GL_FLOAT, 0, normal);

	glEnable(GL_TEXTURE_2D);
	glTexCoordPointer(2, GL_FLOAT, 0, textureCoords);
	glEnableClientState(GL_TEXTURE_COORD_ARRAY);
	glBindTexture(GL_TEXTURE_2D, textureID);	
	
	glEnableClientState(GL_VERTEX_ARRAY);
	glVertexPointer(3, GL_FLOAT, 0, vertice);
    glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);	
}

// ========================================================

-(void)ScrollTexture :(float)dx :(float)dy
{
	textureCoords[0] += dx;
	textureCoords[1] += dy;
	textureCoords[2] += dx;
	textureCoords[3] += dy;
	textureCoords[4] += dx;
	textureCoords[5] += dy;
	textureCoords[6] += dx;
	textureCoords[7] += dy;
}

@end

// IsoSphere.h

#import <OpenGLES/ES1/gl.h>
#import <OpenGLES/ES1/glext.h>

@interface IsoSphere : NSObject
{
}
 
// return #materials used when rendering mesh
-(int)numberMaterials;
 
// update diffuse color.  rgba = pointer to 4 GLfloats (0..1) for R,G,B,A
-(void)setDiffuseColor : (int) materialIndex :(GLfloat *)rgba;
 
// update specular color.  rgba = pointer to 3 GLfloats (0..1) for R,G,B
-(void)setSpecularColor : (int) materialIndex :(GLfloat *)rgba;
 
// render mesh without texture mapping
-(void)draw;
 
// render mesh textured (if texture coords were define in .x file)
-(void)drawTextured :(GLuint) textureID;
 
// load texture resource (must be power of 2 size)
-(bool)loadTexture :(NSString *) textureFilename :(GLuint *)id;

@end

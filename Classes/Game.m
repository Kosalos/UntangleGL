#import "Game.h"
#import "IsoSphere.h"
#import "GLRectangleBase.h"

Game *game;
GLRectangleBase *sky;

IsoSphere *isoSphere;
GLuint textureID1,textureID2;	
GLuint beamTextureID,skyTextureID;
GLfloat textureCoords[8];
CGPoint pt;

enum {
	SCREEN_XS = 768,
	SCREEN_YS = 1024,
	
	MAX_SPOTX = 7,
	MAX_SPOTY = 8,
	
	MAX_SPOT = MAX_SPOTX * MAX_SPOTY,
	MAX_LINE = 4 * MAX_SPOT,
	
	SPOT_SIZE = 40,
	SPOT_MIN  = SPOT_SIZE+10,
	SPOT_MAXX = SCREEN_XS - SPOT_SIZE-10,
	SPOT_MAXY = SCREEN_YS - SPOT_SIZE-10,
	
	NONE = -1
};

#define SWIDTH   8.1
#define SHEIGHT 11.15
#define SKYSX -0.00003
#define SKYSY 0.00002

typedef struct {
	CGPoint pt;
	bool isConnectedToTouchedSpot;
	bool hasAllGoodConnections;
	float originalDistance,currentDistance;
} SpotData;			 

typedef struct {
	int spotIndex1,spotIndex2;
	bool crossesAnotherLine;
} LineData;			 

int gameCount = 0;
int maxSpotX = 2;
int maxSpotY = 1;
int maxSpot;
int touchIndex = NONE;
int crossCount;
int lCount;

LineData line[MAX_LINE];
SpotData spot[MAX_SPOT];

GLfloat ambient[] = { 1,1,1,1 };

@implementation Game

-(void)Initialize
{
	isoSphere = [[IsoSphere alloc]init]; 
	
	if(![isoSphere loadTexture:@"p12.png":&textureID1]) exit(-1);
	if(![isoSphere loadTexture:@"p2.png":&textureID2]) exit(-1);
	if(![isoSphere loadTexture:@"stars.png":&beamTextureID]) exit(-1);
	if(![isoSphere loadTexture:@"sky.png":&skyTextureID]) exit(-1);
	
	sky = [[GLRectangleBase alloc]init];
	
	srand((unsigned int)clock());
	[self Reset];
	
	GLfloat tMap1[] = { 1,0,  0,0,  1,.1,  0,.1 };
	memcpy(textureCoords,tMap1,sizeof(GLfloat)*8);		
}

#pragma mark ======================== LinesIntersect

-(bool)LinesIntersect :(int)p1A :(int)p1B :(int)p2A :(int)p2B	// spot indices
{
	// same spot used in both lines = not intersecting
	if(p1A == p2A || p1A == p2B || p1B == p2A || p1B == p2B) return false;
	
	CGPoint p1 = spot[p1A].pt;	// line from p1 -> p2
	CGPoint p2 = spot[p1B].pt;
	CGPoint p3 = spot[p2A].pt;	// line from p3 -> p4
	CGPoint p4 = spot[p2B].pt;	
	
	// y = mx+b
	float m1 = (p1.x == p2.x) ? 0 : (p2.y - p1.y) / (p2.x - p1.x);
	float m2 = (p3.x == p4.x) ? 0 : (p4.y - p3.y) / (p4.x - p3.x);
	
	if(m1 != m2) {
		float b1 = p1.y - m1 * p1.x;
		float b2 = p3.y - m2 * p3.x;
		
		// intersection point
		float x = (b2-b1)/(m1-m2);
		float y = (fabs(m1) < fabs(m2)) ? (m1*x+b1) : (m2*x+b2);
		
		// intersection point outside the endpoints of the line segments?
		if(x < p1.x && x < p2.x) return false;
		if(x > p1.x && x > p2.x) return false;
		if(y < p1.y && y < p2.y) return false;
		if(y > p1.y && y > p2.y) return false;
		if(x < p3.x && x < p4.x) return false;
		if(x > p3.x && x > p4.x) return false;
		if(y < p3.y && y < p4.y) return false;
		if(y > p3.y && y > p4.y) return false;
		
		return true;
	}
	
	return false;
}

#pragma mark ======================== Reset

-(void)Reset
{
	if(gameCount & 1) {
		++maxSpotX;
		if(maxSpotX > MAX_SPOTX) maxSpotX = MAX_SPOTX;
	}
	else {
		++maxSpotY;
		if(maxSpotY > MAX_SPOTY) maxSpotY = MAX_SPOTY;
	}
	
	maxSpot = maxSpotX * maxSpotY;
	
	++gameCount;
	
	// spot positions:  straight grid layout 	
	for(int i=0;i<maxSpot;++i)	{
		int x = i % maxSpotX;
		int y = i / maxSpotX;
		spot[i].pt.x = SPOT_MIN + x * 100;
		spot[i].pt.y = SPOT_MIN + y * 100;
	}
	
	//line connections 
	lCount = 0;
	int base;
	for(int x=0;x<maxSpotX;++x) {	
		for(int y=0;y<maxSpotY;++y) {	
			
			if(x < maxSpotX-1) {
				base = x + y * maxSpotX;
				line[lCount].spotIndex1 = base;
				line[lCount].spotIndex2 = base + 1;
				++lCount;
			}
			
			if(y < maxSpotY-1) {
				base = x + y * maxSpotX;
				line[lCount].spotIndex1 = base;
				line[lCount].spotIndex2 = base + maxSpotX;
				++lCount;
			}
		}		
	}
	
	// random diagonals
	int rx1,ry1,rx2,ry2,i1,i2;
	for(int i=0;i<maxSpotX*maxSpotY;++i) {
		rx1 = rand() % maxSpotX;
		ry1 = rand() % maxSpotY;
		
		for(;;) {
			rx2 = (rand() & 1) ? rx1+1 : rx1-1;
			ry2 = (rand() & 1) ? ry1+1 : ry1-1;
			
			if(rx2 >= 0 && rx2 < maxSpotX && ry2 >= 0 && ry2 < maxSpotY) break;			   
		}
		
		// already used ?
		i1 = ry1 * maxSpotX + rx1;
		i2 = ry2 * maxSpotX + rx2;
		bool okay = true;
		for(int j=0;j<lCount;++j) {
			if(line[j].spotIndex1 == i1 && line[j].spotIndex2 == i2) okay = false;
			if(line[j].spotIndex1 == i2 && line[j].spotIndex2 == i1) okay = false;
		}
		
		if(okay) {
			line[lCount].spotIndex1 = i1;
			line[lCount].spotIndex2 = i2;
			++lCount;
			[self DetermineLineCrossings];
			if(crossCount)
				--lCount;
		}
	}
	
	if(lCount >= MAX_LINE) exit(-1);	// sanity check
	
	// spot positions:  random  	
	for(int i=0;i<maxSpot;++i)	{
		spot[i].pt.x = (float)(SPOT_MIN + rand() % (SPOT_MAXX - SPOT_MIN));
		spot[i].pt.y = (float)(SPOT_MIN + rand() % (SPOT_MAXY - SPOT_MIN));	
	}
	
	[self DetermineLineCrossings];
}

-(void)DetermineLineCrossings
{
	crossCount = 0;
	
	for(int i=0;i<lCount;++i)
		line[i].crossesAnotherLine = false;
	
	for(int i=0;i<lCount-1;++i)
		for(int j=i+1;j<lCount;++j)
			if([self LinesIntersect:line[i].spotIndex1:line[i].spotIndex2:line[j].spotIndex1:line[j].spotIndex2]) {
				line[i].crossesAnotherLine = line[j].crossesAnotherLine = true;
				++crossCount;
			}
}

-(void)DetermineAllGoodConnections {
	for(int i=0;i<maxSpot;++i)	{
		spot[i].hasAllGoodConnections = true;
		
		for(int j=0;j<lCount;++j) {
			if(line[j].spotIndex1 == i || line[j].spotIndex2 == i) {
				if(line[j].crossesAnotherLine) {
					spot[i].hasAllGoodConnections = false;
					break;
				}
			} 
		}
	}	
}


-(void)DetermineOriginalDistanceOfSpotFromTouchedSpot :(int)spotIndex1 :(int)spotIndex2
{
	float distance = hypot(spot[spotIndex1].pt.x - spot[spotIndex2].pt.x,spot[spotIndex1].pt.y - spot[spotIndex2].pt.y);
	
	if(spotIndex1 != touchIndex) 
		spot[spotIndex1].originalDistance = distance;
	else
		spot[spotIndex2].originalDistance = distance;
}

-(void)DetermineCurrentDistancesOfConnectedSpotsFromTouchedSpot 
{
	for(int i=0;i<maxSpot;++i) {
		if(spot[i].originalDistance > 0)
			spot[i].currentDistance = hypot(spot[i].pt.x - spot[touchIndex].pt.x,spot[i].pt.y - spot[touchIndex].pt.y);
	}	
}

-(void)AdjustPositionsOfConnectedSpots 
{
	for(int i=0;i<maxSpot;++i) {
		if(spot[i].originalDistance == 0) continue;
		if(spot[i].originalDistance == spot[i].currentDistance) continue;
		
		float dx = spot[i].pt.x - spot[touchIndex].pt.x;
		float dy = spot[i].pt.y - spot[touchIndex].pt.y;
		float ratio = spot[i].currentDistance / spot[i].originalDistance;
		
		ratio = 1.0 + (1.0 - ratio)/100.0;
		
		spot[i].pt.x = spot[touchIndex].pt.x + dx * ratio;
		spot[i].pt.y = spot[touchIndex].pt.y + dy * ratio;
		
		if(spot[i].pt.x < SPOT_MIN) spot[i].pt.x = SPOT_MIN; else if(spot[i].pt.x > SPOT_MAXX) spot[i].pt.x = SPOT_MAXX; 
		if(spot[i].pt.y < SPOT_MIN) spot[i].pt.y = SPOT_MIN; else if(spot[i].pt.y > SPOT_MAXY) spot[i].pt.y = SPOT_MAXY; 
	}
}

-(void)MarkSpotsConnectedToTouchedSpot
{
	for(int i=0;i<maxSpot;++i) {
		spot[i].isConnectedToTouchedSpot = false;
		spot[i].originalDistance = 0;
	}
	
	if(touchIndex == NONE) return;
	
	for(int i=0;i<lCount;++i)
		if(line[i].spotIndex1 == touchIndex || line[i].spotIndex2 == touchIndex) {
			spot[line[i].spotIndex1].isConnectedToTouchedSpot = spot[line[i].spotIndex2].isConnectedToTouchedSpot = true;
			[self DetermineOriginalDistanceOfSpotFromTouchedSpot:line[i].spotIndex1:line[i].spotIndex2];
		}
}

// ===========================================================

-(void)AlertNewGame {
	UIAlertView *z = [[UIAlertView alloc]
		initWithTitle:nil 
		message:@"Next Puzzle?" 
		delegate:self 
		cancelButtonTitle:@"No" 
		otherButtonTitles:@"Yes",nil];
	[z show];
    [z release];
}

-(void)alertView :(UIAlertView *)z clickedButtonAtIndex :(NSInteger)i {
	if(i==1)
		[self Reset];
}

// ===========================================================

-(void)TouchBegan :(NSSet *)touches
{
	UITouch *touch = [touches anyObject];	
	CGPoint pt = [touch locationInView:[touch view]];
	
	// lower right corner?
	if(pt.x >= SCREEN_XS-50 && pt.y >= SCREEN_YS-50) {
		[self AlertNewGame];
		return;
	}
	
	// touched a spot?
	int closestIndex = -1;
	float closestDistance = 99999;
	
	for(int i=0;i<maxSpot;++i)	{
		float dist = hypot(spot[i].pt.x - pt.x,spot[i].pt.y - pt.y);
		if(dist <= SPOT_SIZE*2.0 && dist < closestDistance) {
			closestDistance = dist;
			closestIndex = i;
		}
	}
	
	if(closestIndex >= 0) {
		touchIndex = closestIndex;
		[self MarkSpotsConnectedToTouchedSpot];
	}
}

-(void)TouchMoved :(NSSet *)touches
{
	if(touchIndex != NONE) {
		UITouch *touch = [touches anyObject];	
		spot[touchIndex].pt = [touch locationInView:[touch view]];
		
		[self DetermineCurrentDistancesOfConnectedSpotsFromTouchedSpot];
		[self AdjustPositionsOfConnectedSpots];
	}
}

-(void)TouchReleased :(NSSet *)touches;
{
	touchIndex = NONE;
	[self MarkSpotsConnectedToTouchedSpot];
}

// ===========================================================

float wz = -10;

-(void)WorldPosition
{
	glLoadIdentity();
	glTranslatef(0,0,wz);
}

// ===========================================================

float MSX = -3;
float MSY = -4.05;
float SSX = .0079;
float SSY = .0079;

-(Vertex)MapPoint :(float)px :(float)py
{
	Vertex ans = { 0,0,0 };
	
	ans.x = MSX + px * SSX;
	ans.y = MSY + (1024 - py) * SSY;
	
	return ans;
}

// ===========================================================

-(void)LineF :(Vertex)pt1 :(Vertex)pt2
{
	GLfloat line[6];
	memcpy(&line[0],&pt1,sizeof(pt1));
	memcpy(&line[3],&pt2,sizeof(pt2));
	
	glVertexPointer(3, GL_FLOAT, 0, line);
	glEnableClientState(GL_VERTEX_ARRAY);	
	glDrawArrays(GL_LINES, 0, 2);
}

-(void)DrawGrid
{
	Vertex p1 = { 0,0,0 };
	Vertex p2 = { 0,0,0 };
	
	[self WorldPosition];
	
	glDisable(GL_TEXTURE_2D);
	glDisableClientState(GL_TEXTURE_COORD_ARRAY);	
	glBindBuffer(GL_ARRAY_BUFFER, 0);
	glDisableClientState(GL_VERTEX_ARRAY);
	glDisableClientState(GL_COLOR_ARRAY);
	
	glColor4f(1,1,1,1);
	
	for(float x=0;x<=768;x+=50)
	{
		
		p1 = [self MapPoint:x:0];
		p2 = [self MapPoint:x:1024];
		[self LineF:p1:p2];
	}
	
	for(float y=0;y<=1024;y+=50)
	{
		p1 = [self MapPoint:0:y];
		p2 = [self MapPoint:768:y];
		[self LineF:p1:p2];
	}
}

// ==============================================================

-(void)NormalStraightUp
{
	Vertex norm[4] = {	0,1,0,	0,1,0,	0,1,0,	0,1,0 };	
	glEnableClientState(GL_NORMAL_ARRAY);
	glNormalPointer(GL_FLOAT, 0, norm);
}

// ==============================================================

-(void)SetLighting
{
    static GLfloat zposition[] = { 0,0,1,1 };
	
	if(touchIndex != NONE) {
		CGPoint *s1 = &spot[touchIndex].pt;
		Vertex p1 = [self MapPoint:s1->x:s1->y];
		
		zposition[0] = p1.x;
		zposition[1] = p1.y;
	}
	
	glEnable(GL_LIGHTING);
	glLightfv(GL_LIGHT0,GL_AMBIENT,  ambient);
	glLightfv(GL_LIGHT0,GL_DIFFUSE,  ambient);
	glLightfv(GL_LIGHT0,GL_POSITION, zposition);
	glEnable(GL_LIGHT0);
}

// ==============================================================

float SS = .3;
float SS2 = 1.1;
float ROT = 100.0;

-(void)DrawSpot :(int)spotIndex
{
	SpotData *ptr = &spot[spotIndex];
	
	glScalef(1,1,1);
	[self WorldPosition];
	
	
	Vertex v = [self MapPoint:ptr->pt.x:ptr->pt.y];
	glTranslatef(v.x,v.y,0);
	
	// roll the ball as it moves
	glRotatef(v.x * ROT,0,1,0);
	glRotatef(v.y * ROT,1,0,0);
	
	int tID;
	
	if(ptr->isConnectedToTouchedSpot)
		tID = skyTextureID;
	else
		tID = ptr->hasAllGoodConnections ? textureID2 : textureID1;

	float rgba[] = { 1,1,1,1 };
	[isoSphere setDiffuseColor:0:rgba];
	glScalef(SS,SS,SS);
	[isoSphere drawTextured:tID];

	rgba[3] = .8;
	
	static float angle = 0;
	float scale = SS2;
	
	for(int i=0;i<10;++i) {
		[isoSphere setDiffuseColor:0:rgba];
		rgba[3] *= .9;
		
		glScalef(scale,scale,scale);
		scale *= 1.0006;		
		
		glRotatef(angle,1,1,0);
		angle += 0.0003;
		[isoSphere drawTextured:tID];		
	}
	
}

// ==============================================================

-(void)FatLine :(Vertex)pt1 :(Vertex)pt2 :(float)thick
{
	float angle = atan2(pt2.y-pt1.y,pt2.x-pt1.x) + M_PI/2.0;
	float ss = cos(angle) * thick;
	float cc = sin(angle) * thick;
	
	pt1.x += ss;
	pt1.y += cc;
	pt2.x += ss;
	pt2.y += cc;
	
	Vertex pt3 = pt1;
	Vertex pt4 = pt2;
	
	pt3.x -= ss * 2;
	pt3.y -= cc * 2;
	pt4.x -= ss * 2;
	pt4.y -= cc * 2;
	
	Vertex vert2[4] = { pt2,pt1,pt4,pt3 };
	glVertexPointer(3, GL_FLOAT, 0, vert2);
	glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
}

-(void)DrawLine :(int)index
{
	static float rmaterialMap[] = { 1,1,1,1 };
	glMaterialfv(GL_FRONT_AND_BACK,GL_DIFFUSE,(GLfloat *)&rmaterialMap);	
	
	if(line[index].crossesAnotherLine) {
		ambient[0] = 1; ambient[1] = ambient[2] = 0;
	//	glMaterialfv(GL_FRONT_AND_BACK,GL_DIFFUSE,(GLfloat *)&rmaterialMap);	
	}
	else{
		ambient[1] = 1; ambient[0] = ambient[2] = 0;
	//	glMaterialfv(GL_FRONT_AND_BACK,GL_DIFFUSE,(GLfloat *)&gmaterialMap);	
	}	
		
	[self SetLighting];
	
	CGPoint *s1 = &spot[line[index].spotIndex1].pt;
	CGPoint *s2 = &spot[line[index].spotIndex2].pt;
		
	Vertex p1 = [self MapPoint:s1->x:s1->y];
	Vertex p2 = [self MapPoint:s2->x:s2->y];
	
	p1.z = p2.z = (float)index/ 1000.0;

	glEnable(GL_BLEND);
	glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);

	[self FatLine:p1:p2:.075];
}

// ==============================================================

-(void)DrawNextGameButton
{
	[self WorldPosition];
	glDisable(GL_LIGHTING);
	glDisable(GL_TEXTURE_2D);
	glDisableClientState(GL_TEXTURE_COORD_ARRAY);	
	glBindBuffer(GL_ARRAY_BUFFER, 0);
	glDisableClientState(GL_VERTEX_ARRAY);
	glDisableClientState(GL_COLOR_ARRAY);

	glColor4f(.4,.3,.2,1);
	Vertex p1 = [self MapPoint:730:1000];
	Vertex p2 = [self MapPoint:750:1000];
	Vertex p4 = [self MapPoint:730:1020];
	Vertex p3 = [self MapPoint:750:1020];
	[self LineF:p1:p2];
	[self LineF:p2:p3];
	[self LineF:p3:p4];
	[self LineF:p4:p1];	
}

// =======================================================================

#define QSX  5.2
#define QSY  7
#define QSZ  -1
#define QSZ2 -.85
#define QSZ3 -.75

typedef struct {
	Vertex p1,p2,p3,p4;
	float dx,dy,vx,vy;
} SkyDataset;

SkyDataset sd[3] = 
{
	QSX,-QSY, QSZ,
	-QSX,-QSY, QSZ,
	-QSX, QSY, QSZ,
	QSX, QSY, QSZ,
	SKYSX,SKYSY,
	0,0,
	
	QSX,-QSY, QSZ2,
	-QSX,-QSY, QSZ2,
	-QSX, QSY, QSZ2,
	QSX, QSY, QSZ2,
	SKYSX*3,SKYSY*3,
	.3,.3,
	
	QSX,-QSY, QSZ3,
	-QSX,-QSY, QSZ3,
	-QSX, QSY, QSZ3,
	QSX, QSY, QSZ3,
	SKYSX*4,SKYSY*2,
	.6,.6,
};

-(void)SkyDraw :(SkyDataset *)s
{
	[self WorldPosition];
	
	[sky ScrollTexture:s->vx:s->vy];
	[sky Position:s->p1:s->p2:s->p3:s->p4];
	[sky Draw:skyTextureID];
	
	[sky ScrollTexture:-(s->vx):-(s->vy)];
	
	s->vx += s->dx;
	s->vy += s->dy;
}

// ==============================================================

float spec = .1;
float emission = .4;
float shiny = 1;

-(void)Draw
{
	glClearColor(0,0,0,1);
	glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
	
//	[self WorldPosition];
//	[sky ScrollTexture:SKYSX:SKYSY];
//	for(int i=0;i<3;++i) {
//		glColor4f(1,1,1,i ? .2 : 1);
//		[self SkyDraw:&sd[i]];
//	}

	// balls keep moving as long as finger is held down
	if(touchIndex != NONE) {
		[self DetermineCurrentDistancesOfConnectedSpotsFromTouchedSpot];
		[self AdjustPositionsOfConnectedSpots];
	}
	
	//[self DrawGrid];
	[self DetermineLineCrossings];
	[self DetermineAllGoodConnections];
	
	[self WorldPosition];
	[self SetLighting];

	// -----------------------------------------
	GLfloat materialEmission[] = { emission,emission,emission,1};
	glMaterialfv(GL_FRONT_AND_BACK, GL_EMISSION,materialEmission);
	
	glMaterialf(GL_FRONT_AND_BACK, GL_SHININESS, shiny);
	
	float spec2[] = { spec,spec,spec,1 };
	[isoSphere setSpecularColor:0:spec2];
	// -----------------------------------------

	// scroll the light beams
	static float ti1 = 0;
	ti1 += 0.001;
	if(ti1 > .95) ti1 = 0;
	textureCoords[0] = textureCoords[4] = ti1;
	textureCoords[2] = textureCoords[6] = ti1 + 1;
	textureCoords[1] = textureCoords[3] = 0;
	textureCoords[5] = textureCoords[7] = 0.5; //(float)(rand() & 1023)/1024.0;	
	
	glEnable(GL_TEXTURE_2D);
	glBindTexture(GL_TEXTURE_2D, beamTextureID);
	glTexCoordPointer(2, GL_FLOAT, 0, textureCoords);
	glEnableClientState(GL_TEXTURE_COORD_ARRAY);
	[self NormalStraightUp];

	for(int i=0;i<lCount;++i)
		[self DrawLine:i];

	glColor4f(1,1,1,1);
	ambient[0] = ambient[1] = ambient[2] = 1;
	[self SetLighting];
	for(int i=0;i<maxSpot;++i)
		[self DrawSpot:i];
	
	[self DrawNextGameButton];
}

@end


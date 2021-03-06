// IsoSphere.m

#import <UIKit/UIKit.h>
#import <OpenGLES/ES1/gl.h>
#import <OpenGLES/ES1/glext.h>
#import "IsoSphere.h"

enum {
    NUM_MATERIALS = 1,
    HAS_TEXTURE_DATA = 1,
};

typedef struct {
    GLfloat x,y,z;
} BlenderVertex;
 
typedef struct {
    BlenderVertex  position;
    BlenderVertex  normal;
    GLfloat texture[2];
} BlenderMeshVertex;
 
typedef struct {
    GLuint vboID;
    GLushort *list;
    GLsizei count;
    GLfloat diffuse[4];
    GLfloat specular[3];
} BlenderMaterialData;
 
static GLuint vertexVBO;
 
static BlenderMeshVertex vertice[] = {
        0.723600,   -0.525720,   -0.447215,        0.471318,   -0.583121,   -0.661687,        0.338087,    0.778054,
        0.425323,   -0.309011,   -0.850654,        0.471318,   -0.583121,   -0.661687,        0.389972,    0.844124,
        0.262869,   -0.809012,   -0.525738,        0.471318,   -0.583121,   -0.661687,        0.277696,    0.844175,
       -0.162456,   -0.499995,   -0.850654,        0.187594,   -0.577345,   -0.794658,        0.340851,    1.000000,
        0.262869,   -0.809012,   -0.525738,        0.187594,   -0.577345,   -0.794658,        0.277696,    0.844175,
        0.425323,   -0.309011,   -0.850654,        0.187594,   -0.577345,   -0.794658,        0.389972,    0.844124,
        0.262869,   -0.809012,   -0.525738,       -0.038547,   -0.748789,   -0.661687,        0.277696,    0.844175,
       -0.162456,   -0.499995,   -0.850654,       -0.038547,   -0.748789,   -0.661687,        0.340851,    1.000000,
       -0.276385,   -0.850640,   -0.447215,       -0.038547,   -0.748789,   -0.661687,        0.162572,    0.936961,
        0.425323,   -0.309011,   -0.850654,        0.102381,   -0.315090,   -0.943523,        0.389972,    0.844124,
        0.000000,    0.000000,   -1.000000,        0.102381,   -0.315090,   -0.943523,        0.513709,    0.919519,
       -0.162456,   -0.499995,   -0.850654,        0.102381,   -0.315090,   -0.943523,        0.340851,    1.000000,
        0.425323,   -0.309011,   -0.850654,        0.700228,   -0.268049,   -0.661687,        0.389972,    0.844124,
        0.723600,   -0.525720,   -0.447215,        0.700228,   -0.268049,   -0.661687,        0.338087,    0.778054,
        0.850648,    0.000000,   -0.525736,        0.700228,   -0.268049,   -0.661687,        0.401171,    0.756306,
        0.850648,    0.000000,   -0.525736,        0.607060,    0.000000,   -0.794656,        0.401171,    0.756306,
        0.425323,    0.309011,   -0.850654,        0.607060,    0.000000,   -0.794656,        0.469098,    0.790997,
        0.425323,   -0.309011,   -0.850654,        0.607060,    0.000000,   -0.794656,        0.389972,    0.844124,
        0.425323,    0.309011,   -0.850654,        0.700228,    0.268049,   -0.661687,        0.469098,    0.790997,
        0.850648,    0.000000,   -0.525736,        0.700228,    0.268049,   -0.661687,        0.401171,    0.756306,
        0.723600,    0.525720,   -0.447215,        0.700228,    0.268049,   -0.661687,        0.452389,    0.728106,
        0.425323,    0.309011,   -0.850654,        0.331305,    0.000000,   -0.943524,        0.469098,    0.790997,
        0.000000,    0.000000,   -1.000000,        0.331305,    0.000000,   -0.943524,        0.513709,    0.919519,
        0.425323,   -0.309011,   -0.850654,        0.331305,    0.000000,   -0.943524,        0.389972,    0.844124,
       -0.276385,   -0.850640,   -0.447215,       -0.408939,   -0.628443,   -0.661686,        0.869189,    0.954487,
       -0.162456,   -0.499995,   -0.850654,       -0.408939,   -0.628443,   -0.661686,        0.686035,    1.000000,
       -0.688189,   -0.499997,   -0.525736,       -0.408939,   -0.628443,   -0.661686,        0.762842,    0.841660,
       -0.525730,    0.000000,   -0.850652,       -0.491119,   -0.356821,   -0.794658,        0.638259,    0.840571,
       -0.688189,   -0.499997,   -0.525736,       -0.491119,   -0.356821,   -0.794658,        0.762842,    0.841660,
       -0.162456,   -0.499995,   -0.850654,       -0.491119,   -0.356821,   -0.794658,        0.686035,    1.000000,
       -0.688189,   -0.499997,   -0.525736,       -0.724044,   -0.194734,   -0.661694,        0.762842,    0.841660,
       -0.525730,    0.000000,   -0.850652,       -0.724044,   -0.194734,   -0.661694,        0.638259,    0.840571,
       -0.894425,    0.000000,   -0.447215,       -0.724044,   -0.194734,   -0.661694,        0.693229,    0.766903,
       -0.162456,   -0.499995,   -0.850654,       -0.268034,   -0.194737,   -0.943523,        0.686035,    1.000000,
        0.000000,    0.000000,   -1.000000,       -0.268034,   -0.194737,   -0.943523,        0.513709,    0.919519,
       -0.525730,    0.000000,   -0.850652,       -0.268034,   -0.194737,   -0.943523,        0.638259,    0.840571,
       -0.894425,    0.000000,   -0.447215,       -0.724044,    0.194734,   -0.661694,        0.693229,    0.766903,
       -0.525730,    0.000000,   -0.850652,       -0.724044,    0.194734,   -0.661694,        0.638259,    0.840571,
       -0.688189,    0.499997,   -0.525736,       -0.724044,    0.194734,   -0.661694,        0.621640,    0.747003,
       -0.162456,    0.499995,   -0.850654,       -0.491119,    0.356821,   -0.794658,        0.552743,    0.788394,
       -0.688189,    0.499997,   -0.525736,       -0.491119,    0.356821,   -0.794658,        0.621640,    0.747003,
       -0.525730,    0.000000,   -0.850652,       -0.491119,    0.356821,   -0.794658,        0.638259,    0.840571,
       -0.688189,    0.499997,   -0.525736,       -0.408939,    0.628443,   -0.661686,        0.621640,    0.747003,
       -0.162456,    0.499995,   -0.850654,       -0.408939,    0.628443,   -0.661686,        0.552743,    0.788394,
       -0.276385,    0.850640,   -0.447215,       -0.408939,    0.628443,   -0.661686,        0.564413,    0.722131,
       -0.525730,    0.000000,   -0.850652,       -0.268034,    0.194737,   -0.943523,        0.638259,    0.840571,
        0.000000,    0.000000,   -1.000000,       -0.268034,    0.194737,   -0.943523,        0.513709,    0.919519,
       -0.162456,    0.499995,   -0.850654,       -0.268034,    0.194737,   -0.943523,        0.552743,    0.788394,
       -0.276385,    0.850640,   -0.447215,       -0.038547,    0.748789,   -0.661687,        0.564413,    0.722131,
       -0.162456,    0.499995,   -0.850654,       -0.038547,    0.748789,   -0.661687,        0.552743,    0.788394,
        0.262869,    0.809012,   -0.525738,       -0.038547,    0.748789,   -0.661687,        0.508003,    0.728981,
        0.425323,    0.309011,   -0.850654,        0.187594,    0.577345,   -0.794658,        0.469098,    0.790997,
        0.262869,    0.809012,   -0.525738,        0.187594,    0.577345,   -0.794658,        0.508003,    0.728981,
       -0.162456,    0.499995,   -0.850654,        0.187594,    0.577345,   -0.794658,        0.552743,    0.788394,
        0.262869,    0.809012,   -0.525738,        0.471318,    0.583121,   -0.661687,        0.508003,    0.728981,
        0.425323,    0.309011,   -0.850654,        0.471318,    0.583121,   -0.661687,        0.469098,    0.790997,
        0.723600,    0.525720,   -0.447215,        0.471318,    0.583121,   -0.661687,        0.452389,    0.728106,
       -0.162456,    0.499995,   -0.850654,        0.102381,    0.315090,   -0.943523,        0.552743,    0.788394,
        0.000000,    0.000000,   -1.000000,        0.102381,    0.315090,   -0.943523,        0.513709,    0.919519,
        0.425323,    0.309011,   -0.850654,        0.102381,    0.315090,   -0.943523,        0.469098,    0.790997,
        0.850648,    0.000000,   -0.525736,        0.904981,   -0.268049,   -0.330393,        0.401171,    0.756306,
        0.723600,   -0.525720,   -0.447215,        0.904981,   -0.268049,   -0.330393,        0.338087,    0.778054,
        0.951058,   -0.309013,    0.000000,        0.904981,   -0.268049,   -0.330393,        0.347395,    0.711495,
        0.951058,   -0.309013,    0.000000,        0.982246,    0.000000,   -0.187599,        0.347395,    0.711495,
        0.951058,    0.309013,    0.000000,        0.982246,    0.000000,   -0.187599,        0.411146,    0.690485,
        0.850648,    0.000000,   -0.525736,        0.982246,    0.000000,   -0.187599,        0.401171,    0.756306,
        0.951058,    0.309013,    0.000000,        0.992077,    0.000000,    0.125631,        0.411146,    0.690485,
        0.951058,   -0.309013,    0.000000,        0.992077,    0.000000,    0.125631,        0.347395,    0.711495,
        0.894425,    0.000000,    0.447215,        0.992077,    0.000000,    0.125631,        0.365508,    0.649933,
        0.723600,    0.525720,   -0.447215,        0.904981,    0.268049,   -0.330393,        0.452389,    0.728106,
        0.850648,    0.000000,   -0.525736,        0.904981,    0.268049,   -0.330393,        0.401171,    0.756306,
        0.951058,    0.309013,    0.000000,        0.904981,    0.268049,   -0.330393,        0.411146,    0.690485,
        0.262869,   -0.809012,   -0.525738,        0.024726,   -0.943519,   -0.330395,        0.277696,    0.844175,
       -0.276385,   -0.850640,   -0.447215,        0.024726,   -0.943519,   -0.330395,        0.162572,    0.936961,
        0.000000,   -1.000000,    0.000000,        0.024726,   -0.943519,   -0.330395,        0.165554,    0.781589,
        0.000000,   -1.000000,    0.000000,        0.303531,   -0.934171,   -0.187597,        0.165554,    0.781589,
        0.587786,   -0.809017,    0.000000,        0.303531,   -0.934171,   -0.187597,        0.272182,    0.740025,
        0.262869,   -0.809012,   -0.525738,        0.303531,   -0.934171,   -0.187597,        0.277696,    0.844175,
        0.587786,   -0.809017,    0.000000,        0.306568,   -0.943519,    0.125651,        0.272182,    0.740025,
        0.000000,   -1.000000,    0.000000,        0.306568,   -0.943519,    0.125651,        0.165554,    0.781589,
        0.276385,   -0.850640,    0.447215,        0.306568,   -0.943519,    0.125651,        0.206713,    0.677109,
        0.723600,   -0.525720,   -0.447215,        0.534590,   -0.777851,   -0.330395,        0.338087,    0.778054,
        0.262869,   -0.809012,   -0.525738,        0.534590,   -0.777851,   -0.330395,        0.277696,    0.844175,
        0.587786,   -0.809017,    0.000000,        0.534590,   -0.777851,   -0.330395,        0.272182,    0.740025,
       -0.688189,   -0.499997,   -0.525736,       -0.889698,   -0.315092,   -0.330386,        0.762842,    0.841660,
       -0.894425,    0.000000,   -0.447215,       -0.889698,   -0.315092,   -0.330386,        0.693229,    0.766903,
       -0.951058,   -0.309013,    0.000000,       -0.889698,   -0.315092,   -0.330386,        0.770222,    0.718629,
       -0.951058,   -0.309013,    0.000000,       -0.794656,   -0.577348,   -0.187595,        0.770222,    0.718629,
       -0.587786,   -0.809017,    0.000000,       -0.794656,   -0.577348,   -0.187595,        0.925192,    0.774445,
       -0.688189,   -0.499997,   -0.525736,       -0.794656,   -0.577348,   -0.187595,        0.762842,    0.841660,
       -0.587786,   -0.809017,    0.000000,       -0.802607,   -0.583125,    0.125648,        0.925192,    0.774445,
       -0.951058,   -0.309013,    0.000000,       -0.802607,   -0.583125,    0.125648,        0.770222,    0.718629,
       -0.723600,   -0.525720,    0.447215,       -0.802607,   -0.583125,    0.125648,        0.846624,    0.631167,
       -0.276385,   -0.850640,   -0.447215,       -0.574584,   -0.748793,   -0.330397,        0.869189,    0.954487,
       -0.688189,   -0.499997,   -0.525736,       -0.574584,   -0.748793,   -0.330397,        0.762842,    0.841660,
       -0.587786,   -0.809017,    0.000000,       -0.574584,   -0.748793,   -0.330397,        0.925192,    0.774445,
       -0.688189,    0.499997,   -0.525736,       -0.574584,    0.748793,   -0.330397,        0.621640,    0.747003,
       -0.276385,    0.850640,   -0.447215,       -0.574584,    0.748793,   -0.330397,        0.564413,    0.722131,
       -0.587786,    0.809017,    0.000000,       -0.574584,    0.748793,   -0.330397,        0.603367,    0.677163,
       -0.587786,    0.809017,    0.000000,       -0.794656,    0.577348,   -0.187595,        0.603367,    0.677163,
       -0.951058,    0.309013,    0.000000,       -0.794656,    0.577348,   -0.187595,        0.677181,    0.691766,
       -0.688189,    0.499997,   -0.525736,       -0.794656,    0.577348,   -0.187595,        0.621640,    0.747003,
       -0.951058,    0.309013,    0.000000,       -0.802607,    0.583125,    0.125648,        0.677181,    0.691766,
       -0.587786,    0.809017,    0.000000,       -0.802607,    0.583125,    0.125648,        0.603367,    0.677163,
       -0.723600,    0.525720,    0.447215,       -0.802607,    0.583125,    0.125648,        0.646886,    0.624874,
       -0.894425,    0.000000,   -0.447215,       -0.889698,    0.315092,   -0.330386,        0.693229,    0.766903,
       -0.688189,    0.499997,   -0.525736,       -0.889698,    0.315092,   -0.330386,        0.621640,    0.747003,
       -0.951058,    0.309013,    0.000000,       -0.889698,    0.315092,   -0.330386,        0.677181,    0.691766,
        0.262869,    0.809012,   -0.525738,        0.534590,    0.777851,   -0.330395,        0.508003,    0.728981,
        0.723600,    0.525720,   -0.447215,        0.534590,    0.777851,   -0.330395,        0.452389,    0.728106,
        0.587786,    0.809017,    0.000000,        0.534590,    0.777851,   -0.330395,        0.472817,    0.676314,
        0.587786,    0.809017,    0.000000,        0.303531,    0.934171,   -0.187597,        0.472817,    0.676314,
        0.000000,    1.000000,    0.000000,        0.303531,    0.934171,   -0.187597,        0.536724,    0.671569,
        0.262869,    0.809012,   -0.525738,        0.303531,    0.934171,   -0.187597,        0.508003,    0.728981,
        0.000000,    1.000000,    0.000000,        0.306568,    0.943519,    0.125651,        0.536724,    0.671569,
        0.587786,    0.809017,    0.000000,        0.306568,    0.943519,    0.125651,        0.472817,    0.676314,
        0.276385,    0.850640,    0.447215,        0.306568,    0.943519,    0.125651,        0.499797,    0.617827,
       -0.276385,    0.850640,   -0.447215,        0.024726,    0.943519,   -0.330395,        0.564413,    0.722131,
        0.262869,    0.809012,   -0.525738,        0.024726,    0.943519,   -0.330395,        0.508003,    0.728981,
        0.000000,    1.000000,    0.000000,        0.024726,    0.943519,   -0.330395,        0.536724,    0.671569,
        0.894425,    0.000000,    0.447215,        0.889698,   -0.315092,    0.330386,        0.365508,    0.649933,
        0.951058,   -0.309013,    0.000000,        0.889698,   -0.315092,    0.330386,        0.347395,    0.711495,
        0.688189,   -0.499997,    0.525736,        0.889698,   -0.315092,    0.330386,        0.293441,    0.653503,
        0.587786,   -0.809017,    0.000000,        0.794656,   -0.577348,    0.187595,        0.272182,    0.740025,
        0.688189,   -0.499997,    0.525736,        0.794656,   -0.577348,    0.187595,        0.293441,    0.653503,
        0.951058,   -0.309013,    0.000000,        0.794656,   -0.577348,    0.187595,        0.347395,    0.711495,
        0.688189,   -0.499997,    0.525736,        0.574584,   -0.748793,    0.330397,        0.293441,    0.653503,
        0.587786,   -0.809017,    0.000000,        0.574584,   -0.748793,    0.330397,        0.272182,    0.740025,
        0.276385,   -0.850640,    0.447215,        0.574584,   -0.748793,    0.330397,        0.206713,    0.677109,
        0.951058,   -0.309013,    0.000000,        0.802607,   -0.583125,   -0.125648,        0.347395,    0.711495,
        0.723600,   -0.525720,   -0.447215,        0.802607,   -0.583125,   -0.125648,        0.338087,    0.778054,
        0.587786,   -0.809017,    0.000000,        0.802607,   -0.583125,   -0.125648,        0.272182,    0.740025,
        0.276385,   -0.850640,    0.447215,       -0.024726,   -0.943519,    0.330395,        0.206713,    0.677109,
        0.000000,   -1.000000,    0.000000,       -0.024726,   -0.943519,    0.330395,        0.165554,    0.781589,
       -0.262869,   -0.809012,    0.525738,       -0.024726,   -0.943519,    0.330395,        0.061606,    0.638966,
       -0.587786,   -0.809017,    0.000000,       -0.303531,   -0.934171,    0.187597,        0.000000,    0.842420,
       -0.262869,   -0.809012,    0.525738,       -0.303531,   -0.934171,    0.187597,        0.061606,    0.638966,
        0.000000,   -1.000000,    0.000000,       -0.303531,   -0.934171,    0.187597,        0.165554,    0.781589,
       -0.262869,   -0.809012,    0.525738,       -0.534590,   -0.777851,    0.330395,        1.000000,    0.574345,
       -0.587786,   -0.809017,    0.000000,       -0.534590,   -0.777851,    0.330395,        0.925192,    0.774445,
       -0.723600,   -0.525720,    0.447215,       -0.534590,   -0.777851,    0.330395,        0.846624,    0.631167,
        0.000000,   -1.000000,    0.000000,       -0.306568,   -0.943519,   -0.125651,        0.165554,    0.781589,
       -0.276385,   -0.850640,   -0.447215,       -0.306568,   -0.943519,   -0.125651,        0.162572,    0.936961,
       -0.587786,   -0.809017,    0.000000,       -0.306568,   -0.943519,   -0.125651,        0.000000,    0.842420,
       -0.723600,   -0.525720,    0.447215,       -0.904981,   -0.268049,    0.330393,        0.846624,    0.631167,
       -0.951058,   -0.309013,    0.000000,       -0.904981,   -0.268049,    0.330393,        0.770222,    0.718629,
       -0.850648,    0.000000,    0.525736,       -0.904981,   -0.268049,    0.330393,        0.732746,    0.614153,
       -0.951058,    0.309013,    0.000000,       -0.982246,    0.000000,    0.187599,        0.677181,    0.691766,
       -0.850648,    0.000000,    0.525736,       -0.982246,    0.000000,    0.187599,        0.732746,    0.614153,
       -0.951058,   -0.309013,    0.000000,       -0.982246,    0.000000,    0.187599,        0.770222,    0.718629,
       -0.850648,    0.000000,    0.525736,       -0.904981,    0.268049,    0.330393,        0.732746,    0.614153,
       -0.951058,    0.309013,    0.000000,       -0.904981,    0.268049,    0.330393,        0.677181,    0.691766,
       -0.723600,    0.525720,    0.447215,       -0.904981,    0.268049,    0.330393,        0.646886,    0.624874,
       -0.951058,   -0.309013,    0.000000,       -0.992077,    0.000000,   -0.125631,        0.770222,    0.718629,
       -0.894425,    0.000000,   -0.447215,       -0.992077,    0.000000,   -0.125631,        0.693229,    0.766903,
       -0.951058,    0.309013,    0.000000,       -0.992077,    0.000000,   -0.125631,        0.677181,    0.691766,
       -0.723600,    0.525720,    0.447215,       -0.534590,    0.777851,    0.330395,        0.646886,    0.624874,
       -0.587786,    0.809017,    0.000000,       -0.534590,    0.777851,    0.330395,        0.603367,    0.677163,
       -0.262869,    0.809012,    0.525738,       -0.534590,    0.777851,    0.330395,        0.573355,    0.604940,
        0.000000,    1.000000,    0.000000,       -0.303531,    0.934171,    0.187597,        0.536724,    0.671569,
       -0.262869,    0.809012,    0.525738,       -0.303531,    0.934171,    0.187597,        0.573355,    0.604940,
       -0.587786,    0.809017,    0.000000,       -0.303531,    0.934171,    0.187597,        0.603367,    0.677163,
       -0.262869,    0.809012,    0.525738,       -0.024726,    0.943519,    0.330395,        0.573355,    0.604940,
        0.000000,    1.000000,    0.000000,       -0.024726,    0.943519,    0.330395,        0.536724,    0.671569,
        0.276385,    0.850640,    0.447215,       -0.024726,    0.943519,    0.330395,        0.499797,    0.617827,
       -0.587786,    0.809017,    0.000000,       -0.306568,    0.943519,   -0.125651,        0.603367,    0.677163,
       -0.276385,    0.850640,   -0.447215,       -0.306568,    0.943519,   -0.125651,        0.564413,    0.722131,
        0.000000,    1.000000,    0.000000,       -0.306568,    0.943519,   -0.125651,        0.536724,    0.671569,
        0.276385,    0.850640,    0.447215,        0.574584,    0.748793,    0.330397,        0.499797,    0.617827,
        0.587786,    0.809017,    0.000000,        0.574584,    0.748793,    0.330397,        0.472817,    0.676314,
        0.688189,    0.499997,    0.525736,        0.574584,    0.748793,    0.330397,        0.427734,    0.619623,
        0.951058,    0.309013,    0.000000,        0.794656,    0.577348,    0.187595,        0.411146,    0.690485,
        0.688189,    0.499997,    0.525736,        0.794656,    0.577348,    0.187595,        0.427734,    0.619623,
        0.587786,    0.809017,    0.000000,        0.794656,    0.577348,    0.187595,        0.472817,    0.676314,
        0.688189,    0.499997,    0.525736,        0.889698,    0.315092,    0.330386,        0.427734,    0.619623,
        0.951058,    0.309013,    0.000000,        0.889698,    0.315092,    0.330386,        0.411146,    0.690485,
        0.894425,    0.000000,    0.447215,        0.889698,    0.315092,    0.330386,        0.365508,    0.649933,
        0.587786,    0.809017,    0.000000,        0.802607,    0.583125,   -0.125648,        0.472817,    0.676314,
        0.723600,    0.525720,   -0.447215,        0.802607,    0.583125,   -0.125648,        0.452389,    0.728106,
        0.951058,    0.309013,    0.000000,        0.802607,    0.583125,   -0.125648,        0.411146,    0.690485,
        0.688189,   -0.499997,    0.525736,        0.408939,   -0.628443,    0.661686,        0.293441,    0.653503,
        0.276385,   -0.850640,    0.447215,        0.408939,   -0.628443,    0.661686,        0.206713,    0.677109,
        0.162456,   -0.499995,    0.850654,        0.408939,   -0.628443,    0.661686,        0.221888,    0.566606,
        0.162456,   -0.499995,    0.850654,        0.491119,   -0.356821,    0.794657,        0.221888,    0.566606,
        0.525730,    0.000000,    0.850652,        0.491119,   -0.356821,    0.794657,        0.346145,    0.569178,
        0.688189,   -0.499997,    0.525736,        0.491119,   -0.356821,    0.794657,        0.293441,    0.653503,
        0.525730,    0.000000,    0.850652,        0.268034,   -0.194736,    0.943523,        0.346145,    0.569178,
        0.162456,   -0.499995,    0.850654,        0.268034,   -0.194736,    0.943523,        0.221888,    0.566606,
        0.000000,    0.000000,    1.000000,        0.268034,   -0.194736,    0.943523,        0.298137,    0.431078,
        0.894425,    0.000000,    0.447215,        0.724044,   -0.194734,    0.661694,        0.365508,    0.649933,
        0.688189,   -0.499997,    0.525736,        0.724044,   -0.194734,    0.661694,        0.293441,    0.653503,
        0.525730,    0.000000,    0.850652,        0.724044,   -0.194734,    0.661694,        0.346145,    0.569178,
       -0.262869,   -0.809012,    0.525738,       -0.471317,   -0.583121,    0.661687,        1.000000,    0.574345,
       -0.723600,   -0.525720,    0.447215,       -0.471317,   -0.583121,    0.661687,        0.846624,    0.631167,
       -0.425323,   -0.309011,    0.850654,       -0.471317,   -0.583121,    0.661687,        0.812813,    0.470972,
       -0.425323,   -0.309011,    0.850654,       -0.187594,   -0.577345,    0.794658,        0.109226,    0.431227,
        0.162456,   -0.499995,    0.850654,       -0.187594,   -0.577345,    0.794658,        0.221888,    0.566606,
       -0.262869,   -0.809012,    0.525738,       -0.187594,   -0.577345,    0.794658,        0.061606,    0.638966,
        0.162456,   -0.499995,    0.850654,       -0.102381,   -0.315090,    0.943523,        0.221888,    0.566606,
       -0.425323,   -0.309011,    0.850654,       -0.102381,   -0.315090,    0.943523,        0.109226,    0.431227,
        0.000000,    0.000000,    1.000000,       -0.102381,   -0.315090,    0.943523,        0.298137,    0.431078,
        0.276385,   -0.850640,    0.447215,        0.038547,   -0.748789,    0.661687,        0.206713,    0.677109,
       -0.262869,   -0.809012,    0.525738,        0.038547,   -0.748789,    0.661687,        0.061606,    0.638966,
        0.162456,   -0.499995,    0.850654,        0.038547,   -0.748789,    0.661687,        0.221888,    0.566606,
       -0.850648,    0.000000,    0.525736,       -0.700228,    0.268049,    0.661688,        0.732746,    0.614153,
       -0.723600,    0.525720,    0.447215,       -0.700228,    0.268049,    0.661688,        0.646886,    0.624874,
       -0.425323,    0.309011,    0.850654,       -0.700228,    0.268049,    0.661688,        0.650273,    0.529817,
       -0.425323,    0.309011,    0.850654,       -0.607060,    0.000000,    0.794656,        0.650273,    0.529817,
       -0.425323,   -0.309011,    0.850654,       -0.607060,    0.000000,    0.794656,        0.812813,    0.470972,
       -0.850648,    0.000000,    0.525736,       -0.607060,    0.000000,    0.794656,        0.732746,    0.614153,
       -0.425323,   -0.309011,    0.850654,       -0.331305,    0.000000,    0.943524,        0.812813,    0.470972,
       -0.425323,    0.309011,    0.850654,       -0.331305,    0.000000,    0.943524,        0.650273,    0.529817,
        0.000000,    0.000000,    1.000000,       -0.331305,    0.000000,    0.943524,        0.647871,    0.376619,
       -0.723600,   -0.525720,    0.447215,       -0.700228,   -0.268049,    0.661688,        0.846624,    0.631167,
       -0.850648,    0.000000,    0.525736,       -0.700228,   -0.268049,    0.661688,        0.732746,    0.614153,
       -0.425323,   -0.309011,    0.850654,       -0.700228,   -0.268049,    0.661688,        0.812813,    0.470972,
       -0.262869,    0.809012,    0.525738,        0.038547,    0.748789,    0.661687,        0.573355,    0.604940,
        0.276385,    0.850640,    0.447215,        0.038547,    0.748789,    0.661687,        0.499797,    0.617827,
        0.162456,    0.499995,    0.850654,        0.038547,    0.748789,    0.661687,        0.484411,    0.475613,
        0.162456,    0.499995,    0.850654,       -0.187594,    0.577345,    0.794658,        0.484411,    0.475613,
       -0.425323,    0.309011,    0.850654,       -0.187594,    0.577345,    0.794658,        0.650273,    0.529817,
       -0.262869,    0.809012,    0.525738,       -0.187594,    0.577345,    0.794658,        0.573355,    0.604940,
       -0.425323,    0.309011,    0.850654,       -0.102381,    0.315090,    0.943523,        0.650273,    0.529817,
        0.162456,    0.499995,    0.850654,       -0.102381,    0.315090,    0.943523,        0.484411,    0.475613,
        0.000000,    0.000000,    1.000000,       -0.102381,    0.315090,    0.943523,        0.647871,    0.376619,
       -0.723600,    0.525720,    0.447215,       -0.471318,    0.583121,    0.661687,        0.646886,    0.624874,
       -0.262869,    0.809012,    0.525738,       -0.471318,    0.583121,    0.661687,        0.573355,    0.604940,
       -0.425323,    0.309011,    0.850654,       -0.471318,    0.583121,    0.661687,        0.650273,    0.529817,
        0.688189,    0.499997,    0.525736,        0.724044,    0.194734,    0.661694,        0.427734,    0.619623,
        0.894425,    0.000000,    0.447215,        0.724044,    0.194734,    0.661694,        0.365508,    0.649933,
        0.525730,    0.000000,    0.850652,        0.724044,    0.194734,    0.661694,        0.346145,    0.569178,
        0.525730,    0.000000,    0.850652,        0.491119,    0.356821,    0.794657,        0.346145,    0.569178,
        0.162456,    0.499995,    0.850654,        0.491119,    0.356821,    0.794657,        0.484411,    0.475613,
        0.688189,    0.499997,    0.525736,        0.491119,    0.356821,    0.794657,        0.427734,    0.619623,
        0.162456,    0.499995,    0.850654,        0.268034,    0.194737,    0.943523,        0.484411,    0.475613,
        0.525730,    0.000000,    0.850652,        0.268034,    0.194737,    0.943523,        0.346145,    0.569178,
        0.000000,    0.000000,    1.000000,        0.268034,    0.194737,    0.943523,        0.298137,    0.431078,
        0.276385,    0.850640,    0.447215,        0.408939,    0.628443,    0.661686,        0.499797,    0.617827,
        0.688189,    0.499997,    0.525736,        0.408939,    0.628443,    0.661686,        0.427734,    0.619623,
        0.162456,    0.499995,    0.850654,        0.408939,    0.628443,    0.661686,        0.484411,    0.475613,
};

static GLushort material1Indices[] = {
       2,   1,   0,   5,   4,   3,   8,   7,   6,  11,  10,   9,  14,  13,  12,  17,  16,  15,  20,  19,
      18,  23,  22,  21,  26,  25,  24,  29,  28,  27,  32,  31,  30,  35,  34,  33,  38,  37,  36,  41,
      40,  39,  44,  43,  42,  47,  46,  45,  50,  49,  48,  53,  52,  51,  56,  55,  54,  59,  58,  57,
      62,  61,  60,  65,  64,  63,  68,  67,  66,  71,  70,  69,  74,  73,  72,  77,  76,  75,  80,  79,
      78,  83,  82,  81,  86,  85,  84,  89,  88,  87,  92,  91,  90,  95,  94,  93,  98,  97,  96, 101,
     100,  99, 104, 103, 102, 107, 106, 105, 110, 109, 108, 113, 112, 111, 116, 115, 114, 119, 118, 117,
     122, 121, 120, 125, 124, 123, 128, 127, 126, 131, 130, 129, 134, 133, 132, 137, 136, 135, 140, 139,
     138, 143, 142, 141, 146, 145, 144, 149, 148, 147, 152, 151, 150, 155, 154, 153, 158, 157, 156, 161,
     160, 159, 164, 163, 162, 167, 166, 165, 170, 169, 168, 173, 172, 171, 176, 175, 174, 179, 178, 177,
     182, 181, 180, 185, 184, 183, 188, 187, 186, 191, 190, 189, 194, 193, 192, 197, 196, 195, 200, 199,
     198, 203, 202, 201, 206, 205, 204, 209, 208, 207, 212, 211, 210, 215, 214, 213, 218, 217, 216, 221,
     220, 219, 224, 223, 222, 227, 226, 225, 230, 229, 228, 233, 232, 231, 236, 235, 234, 239, 238, 237,
    
};

static BlenderMaterialData materialDataset[] = {
    0,material1Indices,   240,  0.781794,0.800000,0.084061,1.000000,  1.000000,1.000000,1.000000,
};

// ============================================================

@implementation IsoSphere

-(id)init {
    if(self = [super init]) {
    }
 
    return self;
}
 
-(int)numberMaterials { return NUM_MATERIALS; }
 
-(void)setDiffuseColor:(int)materialIndex:(GLfloat *)rgba {
    if(materialIndex >= 0 && materialIndex <NUM_MATERIALS)
        memcpy(materialDataset[materialIndex].diffuse,rgba,sizeof(GLfloat)*4);
}
 
-(void)setSpecularColor:(int)materialIndex:(GLfloat *)rgba {
    if(materialIndex >= 0 && materialIndex < NUM_MATERIALS)
        memcpy(materialDataset[materialIndex].specular,rgba,sizeof(GLfloat)*3);
}
 
// ============================================================

// move data into VBO
-(void)Initialize {
    static bool isinitialized = false;
    if(isinitialized) return;
    isinitialized = true;
 
    glGenBuffers(1, &vertexVBO);
    if(vertexVBO == 0) {
        printf("Error acquiring vertexVBO\n");
        exit(-1);
    }
 
    glBindBuffer(GL_ARRAY_BUFFER, vertexVBO);
    glBufferData(GL_ARRAY_BUFFER, sizeof(vertice), vertice, GL_STATIC_DRAW);
    glBindBuffer(GL_ARRAY_BUFFER, 0);
 
    for(int i=0;i<NUM_MATERIALS;++i) { 
        glGenBuffers(1, &materialDataset[i].vboID);
        if(materialDataset[i].vboID == 0) {
            printf("Error acquiring indexVBO\n");
            exit(-1);
        }
        glBindBuffer(GL_ELEMENT_ARRAY_BUFFER,materialDataset[i].vboID);
        glBufferData(GL_ELEMENT_ARRAY_BUFFER,materialDataset[i].count * sizeof(GLushort),materialDataset[i].list,GL_STATIC_DRAW);
    }
}
 
// ============================================================

#define _offsetof(TYPE, MEMBER) (GLvoid*) (offsetof(TYPE, MEMBER))
#define STRIDE sizeof(BlenderMeshVertex)
 
#define DRAWING_METHOD GL_TRIANGLES
 
-(void)drawCommon {
    [self Initialize];
 
    glBindBuffer(GL_ARRAY_BUFFER, vertexVBO);
    glVertexPointer(3, GL_FLOAT, STRIDE, _offsetof(BlenderMeshVertex,position));
    glNormalPointer(   GL_FLOAT, STRIDE, _offsetof(BlenderMeshVertex,normal));
    glEnableClientState(GL_VERTEX_ARRAY);
    glEnableClientState(GL_NORMAL_ARRAY);
}
 
-(void)drawCommon2 {
    for(int i=0;i<NUM_MATERIALS;++i) {
        glMaterialfv(GL_FRONT_AND_BACK,GL_DIFFUSE,materialDataset[i].diffuse);
        glMaterialfv(GL_FRONT_AND_BACK,GL_SPECULAR,materialDataset[i].specular);
        glBindBuffer(GL_ELEMENT_ARRAY_BUFFER,materialDataset[i].vboID);
 
        glDrawElements(DRAWING_METHOD,materialDataset[i].count,GL_UNSIGNED_SHORT,NULL);
    }
 
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER,0);
    glBindBuffer(GL_ARRAY_BUFFER,0);
}
 
// ============================================================

-(void)draw {
    [self drawCommon];
    [self drawCommon2];
}
 
-(void)drawTextured:(GLuint)textureID {
    if(textureID == 0 || HAS_TEXTURE_DATA == 0) {
        printf("mesh has no texture Data, or invalid textureID\n");
        return;
    }
 
    [self drawCommon];
 
    glEnable(GL_TEXTURE_2D);
    glDisable(GL_COLOR_MATERIAL);
    glBindTexture(GL_TEXTURE_2D,textureID);
    glEnableClientState(GL_TEXTURE_COORD_ARRAY);
    glTexCoordPointer(2, GL_FLOAT,STRIDE,_offsetof(BlenderMeshVertex,texture));
 
    [self drawCommon2];
 
    glDisable(GL_TEXTURE_2D);
    glBindTexture(GL_TEXTURE_2D,0);
    glDisableClientState(GL_TEXTURE_COORD_ARRAY);
}
 
// ============================================================

-(bool)IsPowerOfTwo:(int)value {
    int legalDimensions[] = { 16,32,64,128,256,512 };
    for(int i=0;i<6;++i)
        if(value == legalDimensions[i]) return true;
    return false;
}
 
-(bool)loadTexture:(NSString *)textureFilename:(GLuint *)id {
    if(!textureFilename || !id) return false;
 
    CGImageRef spriteImage = [UIImage imageNamed:textureFilename].CGImage;
 
    if(!spriteImage) {
        printf("Failed to load: %s\n",textureFilename.UTF8String);
        return false;
    }
 
    size_t width = CGImageGetWidth(spriteImage);
    size_t height = CGImageGetHeight(spriteImage);
 
    if(![self IsPowerOfTwo:width] || ![self IsPowerOfTwo:height]) {
        printf("texture has illegal size\n");
        return false;
    }
 
    GLubyte *spriteData = (GLubyte *)calloc(1,width * height * 4);
    if(!spriteData) return false;
 
    CGContextRef spriteContext = CGBitmapContextCreate(spriteData, width, height, 8, width * 4, CGImageGetColorSpace(spriteImage), kCGImageAlphaPremultipliedLast);
    CGContextDrawImage(spriteContext, CGRectMake(0.0, 0.0, (CGFloat)width, (CGFloat)height), spriteImage);
    CGContextRelease(spriteContext);
 
    glGenTextures(1,id);
    glBindTexture(GL_TEXTURE_2D,*id);
    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, width, height, 0, GL_RGBA, GL_UNSIGNED_BYTE, spriteData);
    free(spriteData);
 
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
    return true;
}
 
@end

#include "mex.h"
#define DIM 2
#define Nsuffix_size 14


//unsigned int Nsuffix_size=14;
char population_file_constant_suffix[Nsuffix_size+1]={'.','c','o','n','s','t','a','n','t','.','d','a','t','a','\0'};
char population_file_temporal_suffix[Nsuffix_size+1]={'.','t','e','m','p','o','r','a','l','.','d','a','t','a','\0'};

unsigned int c;
unsigned int p;
unsigned int nt;

float* ptr_array;

void mexFunction(
        int nlhs,       mxArray *plhs[],
        int nrhs, const mxArray *prhs[]  ) {
    /* le code C ... */
    
    char *population_file_constant_path, *population_file_temporal_path;
    FILE *population_file_constant, *population_file_temporal;
    
    unsigned int Npath_size = mxGetN(prhs[0]);
    
    population_file_constant_path = mxMalloc( Npath_size+1+14 );
    population_file_temporal_path = mxMalloc( Npath_size+1+14 );
    
    mxGetString(prhs[0], population_file_constant_path, Npath_size+1);
    mxGetString(prhs[0], population_file_temporal_path, Npath_size+1);
    
    for(c=Npath_size;c<Npath_size+Nsuffix_size;c++) {   
        population_file_constant_path[c] = population_file_constant_suffix[c-Npath_size];
        population_file_temporal_path[c] = population_file_temporal_suffix[c-Npath_size];
    }

    population_file_constant_path[Npath_size+Nsuffix_size] = '\0';
    population_file_temporal_path[Npath_size+Nsuffix_size] = '\0';

    mexPrintf("%s\n", population_file_constant_path);
    mexPrintf("%s\n", population_file_temporal_path);
    
    population_file_constant=fopen(population_file_constant_path, "rb");
    population_file_temporal=fopen(population_file_temporal_path, "rb");
    
    
    mwSize* dimensions = mxMalloc(2);
    mwSize* subscripts = mxMalloc(2);
    
    //LOAD CONSTANT DATA
    if(population_file_constant) {
        //load sizes
        unsigned int Ntimes;
        fread(&Ntimes, sizeof(unsigned int), 1, population_file_constant);
        //mexPrintf("%d\n", Ntimes);
        dimensions[0] = 1;
        mxArray* mxNtimes = mxCreateNumericArray(1, dimensions, mxSINGLE_CLASS, mxREAL);
        ptr_array = (float*)(mxGetData(mxNtimes));
        ptr_array[0] = Ntimes;
        plhs[0] = mxNtimes;
        
        unsigned int Npedestrians;
        fread(&Npedestrians, sizeof(unsigned int), 1, population_file_constant);
        //mexPrintf("%d\n", Npedestrians);
        dimensions[0] = 1;
        mxArray* mxNpedestrians = mxCreateNumericArray(1, dimensions, mxSINGLE_CLASS, mxREAL);
        ptr_array = (float*)(mxGetData(mxNpedestrians));
        ptr_array[0] = Npedestrians;
        plhs[1] = mxNpedestrians;
        
        //load values
        dimensions[0]=Npedestrians;
        ////load masses
        mxArray* masses = mxCreateNumericArray(1, dimensions, mxSINGLE_CLASS, mxREAL);
        ptr_array = (float*)(mxGetData(masses));
        for(p=0;p<Npedestrians;p++) {
            fread(&ptr_array[p], sizeof(float), 1, population_file_constant);
        }
        plhs[2] = masses;
        ////load radiuses
        mxArray* radiuses = mxCreateNumericArray(1, dimensions, mxSINGLE_CLASS, mxREAL);
        ptr_array = (float*)(mxGetData(radiuses));
        for(p=0;p<Npedestrians;p++) {
            fread(&ptr_array[p], sizeof(float), 1, population_file_constant);
        }
        plhs[3] = radiuses;
        ////load wills
        mxArray* wills = mxCreateNumericArray(1, dimensions, mxSINGLE_CLASS, mxREAL);
        ptr_array = (float*)(mxGetData(wills));
        for(p=0;p<Npedestrians;p++) {
            fread(&ptr_array[p], sizeof(float), 1, population_file_constant);
        }
        plhs[4] = wills;
        ////load fatigues
        mxArray* fatigues = mxCreateNumericArray(1, dimensions, mxSINGLE_CLASS, mxREAL);
        ptr_array = (float*)(mxGetData(fatigues));
        for(p=0;p<Npedestrians;p++) {
            fread(&ptr_array[p], sizeof(float), 1, population_file_constant);
        }
        plhs[5] = fatigues;
        
        
        //LOAD TEMPORAL DATA
        if(population_file_temporal) {
            dimensions[0]=Ntimes;
            
            mxArray* times_temporal = mxCreateCellArray(1, dimensions);
            mxArray* times;
            for(nt=0;nt<Ntimes;nt++) {
                dimensions[0] = 1;
                times = mxCreateNumericArray(1, dimensions, mxSINGLE_CLASS, mxREAL);
                ptr_array = (float*)(mxGetData(times));
                fread(&ptr_array[0], sizeof(float), 1, population_file_temporal);
                mxSetCell(times_temporal, nt, times);
            }
            plhs[6] = times_temporal;
            
            
            dimensions[0]=Ntimes;
            mxArray* positions_temporal = mxCreateCellArray(1, dimensions);
            dimensions[0] = Npedestrians;
            dimensions[1] = DIM;
            mxArray* positions;
            for(nt=0;nt<Ntimes;nt++) {
                positions = mxCreateNumericArray(2, dimensions, mxSINGLE_CLASS, mxREAL);
                mxSetCell(positions_temporal, nt, positions);
            }
            for(p=0;p<Npedestrians;p++) {
                for(nt=0;nt<Ntimes;nt++) {
                    positions = mxGetCell(positions_temporal,nt);
                    ptr_array = (float*)(mxGetData(positions));
                    subscripts[0] = p;
                    subscripts[1] = 0;
                    fread(&ptr_array[mxCalcSingleSubscript(positions,2,subscripts)], sizeof(float), 1, population_file_temporal);
                    subscripts[1] = 1;
                    fread(&ptr_array[mxCalcSingleSubscript(positions,2,subscripts)], sizeof(float), 1, population_file_temporal);
                }
            }
            plhs[7] = positions_temporal;
            
            
            dimensions[0]=Ntimes;
            mxArray* velocities_temporal = mxCreateCellArray(1, dimensions);
            dimensions[0] = Npedestrians;
            dimensions[1] = DIM;
            mxArray* velocities;
            for(nt=0;nt<Ntimes;nt++) {
                velocities = mxCreateNumericArray(2, dimensions, mxSINGLE_CLASS, mxREAL);
                mxSetCell(velocities_temporal, nt, velocities);
            }
            for(p=0;p<Npedestrians;p++) {
                for(nt=0;nt<Ntimes;nt++) {
                    velocities = mxGetCell(velocities_temporal,nt);
                    ptr_array = (float*)(mxGetData(velocities));
                    subscripts[0] = p;
                    subscripts[1] = 0;
                    fread(&ptr_array[mxCalcSingleSubscript(velocities,2,subscripts)], sizeof(float), 1, population_file_temporal);
                    subscripts[1] = 1;
                    fread(&ptr_array[mxCalcSingleSubscript(velocities,2,subscripts)], sizeof(float), 1, population_file_temporal);
                }
            }
            plhs[8] = velocities_temporal;
            
            
            dimensions[0]=Ntimes;
            mxArray* wishes_temporal = mxCreateCellArray(1, dimensions);
            dimensions[0] = Npedestrians;
            dimensions[1] = DIM;
            mxArray* wishes;
            for(nt=0;nt<Ntimes;nt++) {
                wishes = mxCreateNumericArray(2, dimensions, mxSINGLE_CLASS, mxREAL);
                mxSetCell(wishes_temporal, nt, wishes);
            }
            for(p=0;p<Npedestrians;p++) {
                for(nt=0;nt<Ntimes;nt++) {
                    wishes = mxGetCell(wishes_temporal,nt);
                    ptr_array = (float*)(mxGetData(wishes));
                    subscripts[0] = p;
                    subscripts[1] = 0;
                    fread(&ptr_array[mxCalcSingleSubscript(wishes,2,subscripts)], sizeof(float), 1, population_file_temporal);
                    subscripts[1] = 1;
                    fread(&ptr_array[mxCalcSingleSubscript(wishes,2,subscripts)], sizeof(float), 1, population_file_temporal);
                }
            }
            plhs[9] = wishes_temporal;
            
        
        }
    }
    

    mxFree(dimensions);
    mxFree(subscripts);
    
}

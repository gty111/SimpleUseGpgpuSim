#include<cstdio>
#include<cstdlib>
#define SIZE 128

__global__ void simple_test(int *arr){
    arr[threadIdx.x] = SIZE - threadIdx.x;
}
int main(){
    int *arr_h,*arr_d;
    arr_h = (int*)malloc(SIZE*sizeof(int));
    cudaMalloc(&arr_d,SIZE*sizeof(int));

    simple_test<<<1,SIZE>>>(arr_d);

    cudaMemcpy(arr_h,arr_d,SIZE*sizeof(int),cudaMemcpyDeviceToHost);

    for(int i=0;i<SIZE;i++){
        if(arr_h[i]!=SIZE-i){
            printf("test2:check fail\n");
            goto Free;
        }
    }
    printf("test2:check pass\n");
Free:
    cudaFree(arr_d);
    free(arr_h);
}
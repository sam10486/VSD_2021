int main(void){
  extern int array_addr;
  extern int array_size;
  extern int _test_start;
  
  int array[array_size];
  int temp;
  
  for (int i = 0; i< array_size; i++){
    array[i] = *(&array_addr+i);
  }
  
  for (int k = (array_size); k>0 ; k--){
    for(int j=0; j < (k-1) ; j++){
      if(array[j] > array[j+1]){
          temp = array[j];
          array[j] = array[j+1];
          array[j+1] = temp;
       }
    }
  }
       
    for (int i = 0; i< array_size; i++){
      *(&_test_start+i) = array[i];
  }
  
  return 0;
}
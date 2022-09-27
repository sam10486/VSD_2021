int main(void) {
  unsigned extern int div1;
  unsigned extern int div2;
  unsigned extern int _test_start;
  
  unsigned int tmp;  
	
while( div2!=0 )
{
  tmp = div2;
  div2 = div1%div2;
  div1 = tmp;  
}	

*(&_test_start) = div1;

return 0;
}

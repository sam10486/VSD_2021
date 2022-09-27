
int main(void) {
  extern int mul1;
  extern int mul2;
  extern int _test_start;
  long long m1,m2,mul;
  m1 = mul1;
  m2 = mul2;
  mul = m1 * m2;
*(&_test_start) = (int)(mul);
*((&_test_start)+1) = (int)(mul>>32);

return 0;
}




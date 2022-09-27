extern int array_size;
extern short array_addr;
extern short _test_start;

int main(void)
{
    int num = array_size;
    int temp;

    for (int i = 0; i < num; i++)   //load
        *(&(_test_start) + i) = *(&(array_addr) + i); 

    for (int i = 0; i < (num-1); i++)   //bubble
    {
        for (int j = 0; j < (num-1-i); j++)
        {
            if ( *(&(_test_start) + j) > *(&(_test_start) + j + 1) )
            {
                temp = *(&(_test_start) + j);
                *(&(_test_start) + j) = *(&(_test_start) + j + 1);
                *(&(_test_start) + j + 1) = temp;
            }   
        }   
    }
    return 0;
}

int main(void)
{
    extern int array_size_i;
    extern int array_size_j;
    extern int array_size_k;
    extern short array_addr;
    extern int _test_start;

    int i_num = array_size_i;
    int j_num = array_size_j;
    int k_num = array_size_k;

    for (int i = 0; i < i_num; i++)
    {
        for (int j = 0; j < j_num; j++)
        {
            *(&_test_start + (j_num * i) + j) = 0;

            for (int k = 0; k < k_num; k++)
            {
                *(&_test_start + (j_num * i) + j) += (*(&array_addr + (i * k_num) + k)) * (*(&array_addr + (i_num * k_num) + (k * j_num) + j));
            }
        }
    }

    return 0;
}

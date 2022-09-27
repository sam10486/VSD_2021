int main()
{
	extern char _binary_image_bmp_start;
	extern char _binary_image_bmp_end;
	extern int _binary_image_bmp_size;
	extern char _test_start;

	int size = &_binary_image_bmp_size;
	char blue = 0, green = 0, red = 0, out_pixel = 0;


	for (int i = 0; i < 54; i++)
		*((&_test_start) + i) = *((&_binary_image_bmp_start) + i);

	for (int i = 54; i < size; i = i + 3)
	{
		blue = *((&_binary_image_bmp_start) + i);
		green = *((&_binary_image_bmp_start) + (i + 1));
		red = *((&_binary_image_bmp_start) + (i + 2));
		out_pixel = ((blue * 11) + (green * 59) + (red * 30)) / 100;
		*((&_test_start) + i) = out_pixel;
		*((&_test_start) + (i + 1)) = out_pixel;
		*((&_test_start) + (i + 2)) = out_pixel;
	}
	return 0;
}

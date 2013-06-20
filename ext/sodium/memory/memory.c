#include <stddef.h>

void
sodium_memxor(unsigned char *out, unsigned char *buf1, unsigned char *buf2, size_t size) {
	size_t i;
	for(i = 0; i < size; i++)
		out[i] = buf1[i] ^ buf2[i];
}

void
sodium_memput(unsigned char *out, unsigned char *in, size_t offset, size_t size) {
	size_t i;
	for (i = 0; i < size; i++) {
		out[offset + i] = in[i];
	}
}

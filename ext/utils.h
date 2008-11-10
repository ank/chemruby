#include <stdio.h>

#define ARCH 32

#define NBYTES(width) ((width - 1 ) / ARCH + 1)
#define BITON(mat, h, w, n_bytes)   (mat[h * n_bytes + w / ARCH] |=  (1 << (w % ARCH)))
#define BITOFF(mat, h, w, n_bytes)  (mat[h * n_bytes + w / ARCH] &= ~(1 << (w % ARCH)))

int ntz(long l);
int m_ntz(long *l, int n_bytes);
void * talloc(size_t size);
void * trealloc(void *from, size_t size);
void dump_long(long l, int n);

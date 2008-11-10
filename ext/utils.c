#include <ruby.h>
#include "utils.h"

int
ntz(long l){
  int n;
  if(l == 0) return ARCH;
  n = 1;
  if(( l & 0x000FFFF) == 0) { n = n + 16 ; l = l >> 16; }
  if(( l & 0x00000FF) == 0) { n = n +  8 ; l = l >>  8; }
  if(( l & 0x000000F) == 0) { n = n +  4 ; l = l >>  4; }
  if(( l & 0x0000003) == 0) { n = n +  2 ; l = l >>  2; }
  return n - (l & 1);
}

int
m_ntz(long *l, int n_bytes){
  int i, n;
  n = 0;
  for(i = 0 ; i < n_bytes ; i++){
    if(l[i] == 0){
      n += ARCH;
    }else{
      return n + ntz(l[i]);
    }
  }
  return n;
}

void *
talloc(size_t size){
  void * ptr;
  ptr = malloc(size);
  if(ptr == NULL){
    rb_raise(rb_eNoMemError, "Cannot allocate memory");
  }
  return ptr;
}

void *
trealloc(void *from, size_t size){
  void * ptr;
  ptr = realloc(from, size);
  if(ptr == NULL){
    rb_raise(rb_eNoMemError, "Cannot allocate memory");
  }
  return ptr;
}

void
dump_long(long l, int n){
  int i;
  for(i = 0 ; i < n ; i++){
    printf("%s", (l & (1 << i)) != 0 ? "@" : ".");
  }
}

/**********************************************************************

  subcomp.c -

  $Author: nobyt $

  Copyright (C) 2004-2007 Nobuya Tanaka

**********************************************************************/

#include <ruby.h>
// #include "bitdb.h"
#include "utils.h"

static void
show(long * l, int h, int w){
  int i, j;
  int counter = 0;
  int n_bytes;

  n_bytes = NBYTES(w);

  printf("    ");
  for(i = 0 ; i < w ; i++){
    printf("%d", i % 10);
  }
  printf("\n");

  for(i = 0 ; i < h ; i++){
    printf("%3d ", i);
    for(j = 0 ; j < n_bytes ; j++){
      dump_long(l[counter], (j == n_bytes - 1) ? ((w - 1) % ARCH + 1) : ARCH);
      counter++;
    }
    printf("\n");
  }
}

static FILE *
db_file_open(const char * filename, const char * extension)
{
  FILE * fp;
  char new_filename[50];
  
  strncpy(new_filename, filename, sizeof(new_filename) - 5);
  strncat(new_filename, extension, sizeof(new_filename) - strlen(extension) - 1);

  fp = fopen(new_filename, "r");

  if(fp == NULL){
    rb_raise(rb_eException, "File can not open");
  }
  return fp;
}

struct CompoundDB{
  FILE * mat;
  FILE * idx;
  FILE * typ;
};

struct Query{
  int    len;
  int    edge_len;

  long * type;
  int ** ptr;
  int  * num;
  int  * idx;
};

struct Target{
  int    n_bits;
  int    n_bytes;

  int    max_length;

  long * mat;
  long * typ;
};

struct State{
  int height;
  int width;
  int n_bytes;
  
  int    max_length;
  int    length;
  long * mat;
  int    depth;

  long * res;
  int    res_counter;
  int    res_max_len;
};

struct Record{
  int   n_bits;
  int   n_bytes;
  int   mat_pos;
  int   information;
};

query_dump(struct Query * query){
  int i, j;

  for(i = 0 ; i < query->len ; i++){
    for(j = 0 ; j < query->num[i] ; j++){
      printf("query->ptr[%d][%d] = %d\n", i, j, query->ptr[i][j]);
    }
  }
}

static void
target_free_db(struct Target * target)
{
  free(target->mat);
  target->mat = NULL;
  free(target->typ);
  target->typ = NULL;
}

static void
target_setup_db(struct Target * target, struct Record * record)
{
  target->n_bits  = record->n_bits;
  target->n_bytes = record->n_bytes;
  if(target->max_length < (record->n_bits * record->n_bytes)){
    if(target->max_length != 0){ target_free_db(target); }

    target->mat = talloc(sizeof(long) * record->n_bits * record->n_bytes);
    target->typ = talloc(sizeof(long) * record->n_bits);
    target->max_length = record->n_bits * record->n_bytes;
  }
}

static void
state_push_result(struct State * state)
{
  if(state->res_max_len < state->res_counter){
    state->res_max_len = state->res_max_len * 2;
    state->res = (long *) trealloc(state->res, state->res_max_len);
  }
  memcpy(state->res + state->res_counter * state->length * sizeof(long),
	 state->mat,
	 state->height * state->n_bytes * sizeof(long));
  state->res_counter++;
}

static VALUE
state_get_result(struct State * state)
{
  VALUE result_array;
  VALUE tmp;
  int i, j;
  int counter;

  result_array = rb_ary_new();

  for(i = 0 ; i < state->res_counter ; i++){
    tmp = rb_ary_new();
    counter = i * state->n_bytes * state->height * sizeof(long);
    for(j = 0 ; j < state->height ; j++){
      rb_ary_push(tmp,
		  INT2FIX(m_ntz(state->res + counter + j * state->n_bytes,
				state->n_bytes)));
    }
    rb_ary_push(result_array, tmp);
  }
  return result_array;
}

static void
state_free(struct State * state)
{
  free(state->mat);
  free(state->res);
  state->mat = NULL;
}

static void
state_allocate(struct State * state, struct Query * query, struct Target * target)
{
  int i;

  state->height      = query->len;
  state->width       = target->n_bits;
  state->n_bytes     = target->n_bytes;
  state->res_counter = 0;

  if(state->max_length < query->len * target->n_bytes){

    if(state->max_length != 0){
      printf("state->free called   max_length : %d\n", state->max_length);
      state_free(state);
    }

    state->mat = (long *)talloc((query->len + 2) *// Depth
				target->n_bytes * // Width
				state->height *   // Height
				sizeof(long));    // sizeof(long)

    state->res_max_len = (query->len + 2) *// Depth
      target->n_bytes * // Width
      state->height *   // Height
      sizeof(long) * 100;
    state->res = (long *)talloc(state->res_max_len);    // sizeof(long)
    state->max_length = query->len * target->n_bytes;
  }
  state->length = query->len * target->n_bytes;
  state->depth = -1;

  for(i = 0 ; i < state->length ; i++){ state->mat[i] = 0;}
}

static void
state_setup(struct State * state, struct Query * query, struct Target * target)
{
  int i, j;
  for(i = 0 ; i < query->len ; i++){
    for(j = 0 ; j < target->n_bits ; j++){
      if (query->type[i] == target->typ[j]){
	BITON(state->mat, i, j, target->n_bytes);
      }
    }
  }
}

static void
state_setup_block(struct State * state)
{
  int i, j;
  for(i = 0 ; i < state->height ; i++){
    for(j = 0 ; j < state->width ; j++){
      if (rb_yield_values(2, INT2FIX(i), INT2FIX(j))){
	BITON(state->mat, i, j, state->n_bytes);
      }
    }
  }
}

static void
state_push(struct State * state)
{
  memmove(state->mat + state->length,
	  state->mat,
	  state->length * sizeof(long) );
  state->mat += state->length;
  state->depth++;
}

static void
state_pop(struct State * state)
{
  state->mat -= state->length;
  state->depth--;
}

inline static long
has_bit(long * mat, int height, int width, int n_bytes){
  return (mat[height * n_bytes + width / ARCH] & (1 << (width % ARCH)));
}

/*
 * Hot spot
 */
inline static void
refine(struct State * state, struct Query * query, struct Target * target){
  int i, j, k, l, m, bit_removed;
  bit_removed = 1;
  while(bit_removed){
    bit_removed = 0;// false
    for(i = 0 ; i < query->len ; i++){
      for(j = 0 ; j < target->n_bits ; j++){
	if(has_bit(state->mat, i, j, target->n_bytes)){
	  for(k = 0 ; k < query->num[i] ; k++){
	    m = 0;
	    for(l = 0 ; l < target->n_bytes ; l++){
	      if((state->mat[query->ptr[i][k] * target->n_bytes + l] &
		  target->mat[j * target->n_bytes + l]) != 0){
		m++;
	      }
	    }
	    if(m == 0){
	      BITOFF(state->mat, i, j, target->n_bytes);
	      bit_removed = 1;
	    }
	  }
	}
      }
    }
  }
}

static void
state_clear_bits(long * l, int h, int w, int n_bytes, int height){
  int i;
  for(i = 0 ; i < n_bytes ; i++){ l[i + h * n_bytes] = 0; }
  for(i = 0 ; i < height  ; i++){ BITOFF(l, i, w, n_bytes); }
  BITON(l, h, w, n_bytes);
}

#define TRUE  1
#define FALSE 0

inline static int
state_is_valid(struct State * state){
  int i, j, n_bytes, flag;
  // n_bytes = NBYTES(state->length);
  for(i = 0 ; i < state->height ; i++){
    flag = 0;
    for(j = 0 ; j < state->n_bytes ; j++){
      if(state->mat[i * state->n_bytes + j] != 0){
	flag++;
      }
    }
    if(flag == 0)
      return FALSE;
  }
  return TRUE;
}

static void
search_by_ullmann(struct State * state, struct Query * query, struct Target * target){
  int k;
  // Idea for optimization
  //show(state->mat, query->len, target->n_bits);
  if(state->depth == state->height - 1){
    //printf("FOUND!\n");
    state_push_result(state);
    //show(state->mat, query->len, target->n_bits);
  }else{
    for(k = 0 ; k < target->n_bits ; k++){
      if(has_bit(state->mat,
		 state->depth + 1,
		 k,
		 target->n_bytes)){
	state_push(state);
	state_clear_bits(state->mat, state->depth, k, target->n_bytes, query->len);
	//show(state->mat, query->len, target->n_bits);
	refine(state, query, target);
	//show(state->mat, query->len, target->n_bits);
	if(state_is_valid(state) == TRUE){
	  //show(state->mat, query->len, target->n_bits);
	  search_by_ullmann(state, query, target);
	}
	state_pop(state);
      }
    }
  }
}

static void
db_load(struct CompoundDB * db, struct Query * query){

  int new_n_bits;
  int new_n_bytes;
  int mat_ptr;

  struct Target target;
  struct State state;
  struct Record record;

  int i, j;

  target.n_bits  = 0;
  target.n_bytes = 0;
  target.max_length = 0;
  state.max_length = 0;

  for(;;){
    if(feof(db->idx) || feof(db->mat) || feof(db->mat)){
      printf("Database broken!\n");
      return;
    }

    fread(& record, sizeof(struct Record), 1, db->idx);
    if(record.n_bits == -1){
      return;
    }
    target_setup_db(& target, & record);
    if(record.information != -1){

      fread(target.mat, sizeof(long), target.n_bits * target.n_bytes, db->mat);
      fread(target.typ, sizeof(long), target.n_bits,                  db->typ);

      state_allocate(& state, query, & target);
      state_setup(& state, query, & target);
      //show(state.mat, query->len, target.n_bits);
      search_by_ullmann(& state, query, & target);
    }else{
      fread(target.typ, sizeof(long), target.n_bytes, db->typ);
      printf("atom_number : %d\n", target.typ[0]);
    }
  }
  target_free_db(& target);
  state_free(& state);
}

static void
query_setup(VALUE mol, struct Query * query){
  VALUE atom_type_str;
  VALUE adj_index;
  VALUE edges;

  int i, j, k;

  // allocating and setting atom type
  atom_type_str = rb_funcall(mol, rb_intern("typ_str"), 0);
  Check_Type(atom_type_str, T_STRING);

  query->len  = RSTRING(atom_type_str)->len / sizeof(long);
  query->type = (long *)talloc(query->len * sizeof(long));
  memcpy(query->type, RSTRING(atom_type_str)->ptr, sizeof(long) * query->len);

  // allocatting and setting index
  adj_index = rb_funcall(mol, rb_intern("adjacent_index"), 0);
  Check_Type(adj_index, T_ARRAY);

  edges = rb_funcall(mol, rb_intern("edges"), 0);
  Check_Type(edges, T_ARRAY);

  query->edge_len = RARRAY(edges)->len;

  query->ptr = (int **) talloc(query->len      * sizeof(int **)     );
  query->num = (int * ) talloc(query->len      * sizeof(int * )     );
  query->idx = (int * ) talloc(query->edge_len * sizeof(int * ) * 2 );

  k = 0;
  for(i = 0 ; i < query->len ; i++){
    Check_Type(rb_ary_entry(adj_index, i), T_ARRAY);
    query->num[i] = RARRAY(rb_ary_entry(adj_index, i))->len;
    query->ptr[i] = query->idx + k;
    for(j = 0 ; j < query->num[i] ; j++){
      Check_Type(rb_ary_entry(rb_ary_entry(adj_index, i), j), T_FIXNUM);
      query->idx[k] = FIX2INT(rb_ary_entry(rb_ary_entry(adj_index, i), j));
      k++;
    }
  }

}

static void
query_free(struct Query * query){
  free(query->type);
  free(query->ptr);
  free(query->num);
  free(query->idx);

  query->type = NULL;
  query->ptr  = NULL;
  query->num  = NULL;
  query->idx  = NULL;
}

static VALUE
db_search(VALUE self, VALUE database_name, VALUE q_mol, VALUE block)
{
  char * filename;
  struct CompoundDB db;
  struct Query query;

  filename = StringValuePtr(database_name);

  if(strlen(filename) > 40){
    rb_raise(rb_eException, "length of database name must less than 40!");
  }

  query_setup(q_mol, & query);

  db.mat = db_file_open(filename, ".mat");
  db.idx = db_file_open(filename, ".idx");
  db.typ = db_file_open(filename, ".typ");

  db_load(& db, & query);

  query_free(& query);

  fclose(db.mat);
  fclose(db.idx);
  fclose(db.typ);
}

static void
target_setup(VALUE t_mol, struct Target * target){
  VALUE bit_mat;
  VALUE bit_str;
  VALUE atom_types;

  int i;

  atom_types = rb_funcall(t_mol, rb_intern("typ_str"), 0);
  Check_Type(atom_types, T_STRING);

  target->n_bits = RSTRING(atom_types)->len / sizeof(long);
  target->typ = (long *)talloc(target->n_bits * sizeof(long));
  memcpy(target->typ, RSTRING(atom_types)->ptr, target->n_bits * sizeof(long));

  /*
   * Set up adjacency matrix
   */
  bit_mat = rb_funcall(t_mol,   rb_intern("bit_mat"), 0);
  bit_str = rb_funcall(bit_mat, rb_intern("bit_str"), 0);

  target->n_bytes = NBYTES(target->n_bits);

  target->mat = (long *)talloc(target->n_bytes * target->n_bits * sizeof(long));
  memcpy(target->mat, RSTRING(bit_str)->ptr, RSTRING(bit_str)->len);
}

static void
target_free(struct Target * target){
  free(target->typ);
  free(target->mat);
}

static VALUE
mol_by_mol(VALUE self, VALUE q_mol, VALUE t_mol)
{
  struct Query  query;
  struct Target target;
  struct State  state;
  VALUE result;

  target.max_length = 0;
  state.max_length = 0;

  query_setup(  q_mol, & query  );
  target_setup( t_mol, & target );

  state_allocate(& state, & query, & target);

  if(rb_block_given_p() == Qtrue){
    state_setup_block(& state);
  }
  else{
    state_setup(& state, & query, & target);
  }

  search_by_ullmann(& state, & query, & target);
  result = state_get_result(& state);

  query_free(& query);
  target_free(& target);
  state_free(& state);

  return result;
}

void Init_subcomp(){
  VALUE subcomp_mChem;

  subcomp_mChem = rb_define_module("Chem");
  rb_define_singleton_method(subcomp_mChem, "match_by_ullmann", mol_by_mol, 2);
  rb_define_singleton_method(subcomp_mChem, "db_search",        db_search,  2);
  //define_bitdb_method();
}

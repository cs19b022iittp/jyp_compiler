#include<stdio.h>
#include<string.h>
#include <stdlib.h>

#define sym_table_size 50

#define parameter_size 10
union value
{
 int ival;   //int
 float fval; //float
 double dval; //double
 char sval[100];//string
 char cval; //char
 int bval; //bool 
 
};

struct Symbol{
	char name[20]; // token name
	int type;      //data type 0-void 1-int 2-float 3-double 4-bool 5-char 6-string 
	union value val; // store the value of data type
//	int size;     `  // size 
	char tag;	//f-functions a-arrays v-variable c-constant
	char instr_type;	// r-register c-constant
	struct SymbolTable *symbol_table; 	// pointer to the sybol table if it is a method
	struct Symbol *next;                /* Pointer to the next symbol in the symbol table */
	struct Symbol *prev;
	int scope;
	int reg;
	int assign_type;
	int no_of_elements;// no of parameters or array size
        struct Symbol *parameter[parameter_size];
};

struct SymbolTable{
 int no_of_symbols;
 struct Symbol *symbols[sym_table_size];

};

struct Node {
  int type;
  struct Symbol *node;
  struct Node *child[4];
};

struct Symbol *createsymbol(char *name,int type,union value *val,char tag, int no_of_array_elements,int scope);
void insertsymbol(struct Symbol *s);
void printtable();
void printfunctiontable();
void set_value(int );
void set_value_for_symbol(struct Symbol*s,int t,struct Symbol* s1);
struct Node* createNode(int type, struct Symbol *s, struct Node* one, struct Node* two, struct Node* three);

void initialize();
void add_method_to_methodstable(struct Symbol *s);
void push_stack(struct Symbol *s);
struct Symbol *pop_stack();
void count();
int generate_key(char *s);

void traverse(struct Node *root);
void generate_code(struct Node *root,int pos);

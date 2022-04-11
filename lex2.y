%{
#include "table.h"
#include <sys/queue.h>
#include<stdlib.h>
#include<stdio.h>
#include<string.h>
#include "y.tab.h" 
int yyerror(char*);
int yylex();

extern FILE* yyin;

char name[20];
char tag;
struct Node* root;
struct Symbol *sym, *s1, *s2;
struct Symbol *currmethod;
union value valu;

struct Symbol *while_stack[30];

struct Symbol *newsym;
int no_of_array_elements=0;

struct SymbolTable table[50];		// for storing the symbols
struct SymbolTable methods_table;   // to store the methods (functions)

int current_method_id=0;
int type = 1;

int conds_count=0;       // ******

int top=-1;  // top element
int whileTop = -1;

struct Symbol *st[50];



%}

%union {
  int integer;
  double d;
  float f;
  char yid[100];
  char character;
  char string[300];
  char *a;  
  char lexeme[20];
  int b;
  struct Node* node;
}




%token ADD SUB MUL DIV ASSIGN AND OR XOR LTE GTE EQUAL NOTEQUAL NOT INCREMENT DECREMENT ASGNADD ASGNSUB ASGNDIV ASGNMUL ASGNMOD MOD  
%token '{' '}' '(' ')' '[' ']' ',' LT GT NEGINT_CONST FLOAT_CONSTANT STRING_CONSTANT

%token IF ELSE ELIF VOID FIRST INTEGER DOUBLE STRING BOOL BREAK CONT FOR WHILE SCOL IDENTIFIER INTEGER_CONSTANT FLOAT LONG SWITCH RETURN CASE OUT CHAR END INP 
%type <a> data_typeint 
%type <a> data_typestr 
%type <a> data_typeflot
%type <lexeme> INTEGER STRING  IDENTIFIER FLOAT
%type <integer> INTEGER_CONSTANT NEGINT_CONST
%type <string> STRING_CONSTANT 
%type <f> FLOAT_CONSTANT


%type <node> program funcs func func_name parameters parameters_list stmts_list stmt parameter data_type assignment_stmt constant expression value operator conditional_stmt else_if_stmt else_stmt condition relational_operator inp_list array_declaration expn_inc while_loop for_loop

%%
//char *name,int type,union value *val,char tag
program :			funcs FIRST '{' stmts_list '}'  END{
						printf("YES \n"); 
							
						sym=createsymbol("first",0,&valu,'f',0);
								
						s1=createsymbol("end",0,&valu,'f',0);
						//printf("hello 123\n");
						add_method_to_methodstable(sym); // adding method as it is start 
						add_method_to_methodstable(s1);
						 
						printtable();	// printing the symbol table
						 
					} 
					|
					{   
					 	printf("NO");
					};
					 	  
					 	  
				
funcs:                            funcs func 
                                  {
                                    //printf("func - 1\n");
                                  }
                                  | 
                                  {
                                   
                                  };

func:                             func_name '{' stmts_list '}' 
                                  {
                                    //printf("func - 2\n");
                                    struct Symbol *s3 = createsymbol("", 0, &valu,'f',0);
                                    //s1=pop_stack();
                                  };

func_name:                        data_type IDENTIFIER '(' parameters ')' 
                                  {
                                  //  $$ = createNode(function_name_type, NULL, $1, $4, NULL);
                                    //printf("func-3\n");
                                    s1=pop_stack();
                                    set_value(s1->type);
                                    sym = createsymbol($2, s1->type, &valu, 'f', 0);
                                    add_method_to_methodstable(sym);		// adding it to a method table as it is function
                                    printf("func-added successfully\n");
                                  };	 
                                  
parameters:			parameters_list{
					//$$ = $1;
				   } | {
				   //	$$ = NULL;
				   printf("no-parameters \n");
				   }; 
				   
parameters_list:		parameter ',' parameters_list{
					//$$ = createNode(parameter_type, NULL, $1, $3, NULL);
				   }| parameter{
				   	//$$ = $1;
				   };

stmts_list : 			stmt stmts_list {
					//printf("statements lists called \n");
					//$$ = createNode(statement_type,NULL,$1,$2, NULL);
				}| {
					//$$ = NULL;
				};

stmt : 			parameter SCOL {
					//$$ = $1;
				} | assignment_stmt SCOL {
					//$$ = $1;
				} | conditional_stmt {
					//$$ = $1;
				} | for_loop{
				
				} | array_declaration SCOL{
					//$$ = $1;
				} | return_stmt SCOL{
				} | expn_inc SCOL{
					//printf("\nincrement\n");	
				} | while_loop |for_loop;
				

return_stmt	  :    RETURN  expression {
				//printf("return statement successful\n");
			};
					
array_declaration :	data_type IDENTIFIER '[' INTEGER_CONSTANT ']' ASSIGN '{' inp_list '}' {
				//struct Symbol* s3 = pop_stack(); // to get the inp_list
				
				struct Symbol* s4 = pop_stack();
				int size = $4;	// number of elements
				char *array_name;
				strcpy(array_name,$2);	// to get the array name
				int ele_type = s4->type; // to get the type of elements
				if(ele_type == 0)
					printf("error in declaring void data type\n");
				
				for(int i=0;i<no_of_array_elements;i++){
					struct Symbol* element = pop_stack();
					if(element->type != ele_type){
						printf("error in data type match\n");
					}
				}
				struct Symbol* s5 = createsymbol(array_name,ele_type, &valu, 'a', size);  // creating symbol of array type
				insertsymbol(s5); // inserting symbol 
				

			} | data_type IDENTIFIER '[' INTEGER_CONSTANT ']'{
				//struct Symbol* s3 = pop_stack(); // to get the inp_list
				printf("%d\n",top);
				printf("\n array declaration \n");
				struct Symbol* s4 = pop_stack();
				int size = $4;	// number of elements
				printf("%d - size \n",size);
				// to get the array name
				printf("%s - name \n",$2);
				int ele_type = s4->type; // to get the type of elements
				printf("%d - %s",size,$2);
				struct Symbol* s5 = createsymbol($2,ele_type, &valu, 'a', size);  // creating symbol of array type
				insertsymbol(s5); // inserting symbol 
				
				// data_type , inp_list
				
			};
			
inp_list :   		inp_list '-' constant{
				
				no_of_array_elements++;
			} |  constant {
				$$ = $1; // to get the constant 
				no_of_array_elements=1;
			};
			
				
assignment_stmt : 		parameter ASSIGN expression {
					//printf("assignment-statement\n");
					struct Symbol *sym1=pop_stack();  // to get the res of expression
					struct Symbol *sym2=pop_stack();   // to get the variable
					if(sym1->type != sym2->type){
						printf("Error : Assignment is not possible in different types \n");
					}
					else{
						char *var_name = sym2->name;
						printf("---- %s ----%s----\n",var_name,sym1->name);
						//printf("%d \n",valu.ival);
						int t = sym2->type;
						
						
						
	   			 		struct SymbolTable current_method_table = table[current_method_id];
	   			 		int ind = generate_key(var_name);
	   			 		struct Symbol *tmp = current_method_table.symbols[ind];
	   			 	
	   			 		while(tmp){	// checking if the variable is already declared in the method
							if(strcmp(tmp->name,var_name) ==0)
								break;
    							tmp = tmp->next;
						}
					
						if(tmp==NULL)
							printf("Error : variable undeclared \n");
						else{
							//printf("q3kisfpiwrgjeoe5r\n");
							//printf("updated bvalue is   ....%d\n",sym1->val.ival);
							set_value_for_symbol(table[current_method_id].symbols[ind],sym1->type,sym1);
							//tmp->val.ival = valu.ival;
						}
						
						
						sym = createsymbol(var_name,t,&valu,'v', 0);
						//insertsymbol(sym);
					}
					
				};
			


conditional_stmt :		IF '(' condition ')' '{' stmts_list '}'  else_if_stmts {
					
				};
				
else_if_stmts :		else_if_stmts1 else_stmt{
					
				};
else_if_stmts1 :		else_if_stmt else_if_stmts{
					
				}| {};
else_if_stmt :			ELIF '(' condition ')' '{' stmts_list '}' {} |{};

else_stmt : 			ELSE '{' stmts_list '}'{
					
				} | {
					
				};

for_loop:			FOR '(' assignment_stmt SCOL condition SCOL expn_inc ')' '{' stmts_list '}'{
					//printf("\ninside for\n");
				};
				
				
expn_inc :			IDENTIFIER INCREMENT{
					
					
					struct SymbolTable current_method_table = table[current_method_id];
	   			 	int ind = generate_key($1);
	   			 	//printf("_______________ %d _______________",ind);
	   			 	struct Symbol *tmp = current_method_table.symbols[ind];
	   			 	
	   			 	while(tmp){	// checking if the variable is already declared in the method
						if(strcmp(tmp->name,$1) == 0)
							break;
    						tmp = tmp->next;
					}
					
					if(tmp==NULL)
						printf("Error : Variable undeclared \n");
					else{
						//printf("\nbefore : %d\n",tmp->val.ival);
						tmp->val.ival++;
						table[current_method_id].symbols[ind]->val.ival = tmp->val.ival;
						//printf("after : %d\n",tmp->val.ival);
						//sset_value_for_symbol(tmp,sym1->type,sym1);
						//tmp->val.ival = valu.ival;
					}			
				};
				
while_loop:                       WHILE 
                                  /*{
                                    sym = makeSymbol("while", 0, &valu, 'f', 0);
                                    push_while(sym);
                                  }
                                 {printf("condition in while\n");} */
                                 '(' condition ')'  '{' stmts_list '}'
                                  {
                                    
                                    //pop_while();
                                    //printf("\ninside while\n");
                                   
                                  };

condition : 			condition relational_operator expression {   // condition && || condition
					//printf("------------------------- condition type  1----------- \n");
					struct Symbol *c1 = pop_stack(); // for expression	
					struct Symbol *c2 = pop_stack(); // for relational operator
					struct Symbol *c3 = pop_stack(); 
					
				/*	printf("++++++++++++++++++++++++++ %s +++++++++++++++++\n",c2->name);
					printf(" %d \n",c1->val.ival);
					printf(" %s \n",c2->val.sval);
					printf("%d \n",c3->val.ival); */
					
				//	struct Symbol *c3 = pop_stack();  // for condition
					//struct Symbol *s = createsymbol("bool",s1->type,&valu, 'c', 0);
					//push_stack(s);
					
				} | expression {
					//printf("------------------------- condition type  2----------- \n");
					
				};
				
relational_operator : 		   LTE 
                                  {
                                   
                                    strcpy(valu.sval,"lte");
                                    struct Symbol * reop = createsymbol("lte",8, &valu, 'c',0);
                                    push_stack(reop);
                                  }
                                  | GTE 
                                  {
                                    
                                    strcpy(valu.sval,"gte");
                                    struct Symbol * reop = createsymbol("gte",8, &valu, 'c',0);
                                    push_stack(reop);
                                  }
                                  | LT 
                                  {
                                     strcpy(valu.sval,"lt");
                                    struct Symbol * reop = createsymbol("lt",8, &valu, 'c',0);
                                    push_stack(reop);
                                  }
                                  | GT 
                                  {
                                    strcpy(valu.sval,"gte");
                                    struct Symbol * reop = createsymbol("gte",8, &valu, 'c',0);
                                    push_stack(reop);
                                  }
                                  | EQUAL 
                                  {
                                     strcpy(valu.sval,"eq");
                                    struct Symbol * reop = createsymbol("eq",8, &valu, 'c',0);
                                    push_stack(reop);
                                  }
                                  | NOTEQUAL
                                  {
                                     strcpy(valu.sval,"neq");
                                    struct Symbol * reop = createsymbol("neq",8, &valu, 'c',0);
                                    push_stack(reop);
                                  };
                                  
                                  
value :			constant {
					$$ = $1;
				}| IDENTIFIER {
					//printf("value in .y file\n");
					char *var_name = $1;
					struct Symbol * sym_id = NULL;
					struct SymbolTable current_method_table = table[current_method_id];
	   			 	int ind = generate_key($1);
	   			 	struct Symbol *tmp = current_method_table.symbols[ind];
	   			 	
	   			 	while(tmp){	// checking if the variable exists
						if(strcmp(tmp->name,var_name) ==0)
							break;
    						tmp = tmp->next;
					}
					
					if(tmp==NULL){
						printf("Error : variable undeclared \n");
						push_stack(tmp);
						}
					else{
					        //printf("value of identifired in value is %s",var_name);
						push_stack(tmp);
							//tmp->val.ival = valu.ival;
					}
						
					
						//sym = createsymbol(var_name,t,&valu,'v');
				};
				
				
expression :     		expression operator value{
					// to get the last two values related to the expression
					//data type 0-void 1-int 2-float 3-double 4-bool 5-char 6-string 
					struct Symbol * e1 = pop_stack();//value
					struct Symbol * e3 = pop_stack();//operator
					
						//printf("\n----%d\n",top);
					struct Symbol * e2 = pop_stack();//exp
					//printf("exp value is%s \n",e2->name);
					//printf("%d \n",e1->val.ival);
					if(e2==NULL)
					{
					  printf("Error: Variable is not declared\n");
					}
					else if(e1->type == 6 || e1->type == 0 || e2->type == 6 || e2->type == 0){
						printf("Error : invalid expression\n");
					}
					else {   
						int t = e1->type;
						struct Symbol * sym_id = NULL;
						struct SymbolTable current_method_table = table[current_method_id];
		   			 	int ind = generate_key(e2->name);
		   			 	
		   			 	struct Symbol *tmp = current_method_table.symbols[ind];
		   			 	
		   			 	while(tmp){	// checking if the variable exists
							if(strcmp(tmp->name,e2->name) ==0)
								break;
	    						tmp = tmp->next;
						}
						
						if(tmp==NULL)
							printf("Error : variable %s is undeclared \n",e2->name);
						else{
							switch(t){
								case 1:
									if(e2->type == 1){	// both are integers
									//printf("_____________________________________________rghy\n");
										if(strcmp(e3->name,"+")==0)
											valu.ival=e2->val.ival+e1->val.ival;
										else if(strcmp(e3->name,"-")==0)
											valu.ival=e2->val.ival-e1->val.ival;
										else if(strcmp(e3->name,"*")==0)
											valu.ival=e2->val.ival*e1->val.ival;
										else if(strcmp(e3->name,"/")==0)
											valu.ival=e2->val.ival/e1->val.ival;
										else if(strcmp(e3->name,"%")==0)
											valu.ival=e2->val.ival%e1->val.ival;	
									}
									// complete other cases
									else if(e2->type == 5){
									
									}
									//printf("%d                      @++++++++++++++++++==@@",valu.ival);
									sym = createsymbol("expression_value",t,&valu,'e', 0);
									break;
								case 2:
									break;
								case 3:
									break;
								case 4:
									break;
								case 5:
									break;
							}
						}
					}
					
					push_stack(sym);
					
					} | value {
					
					
				};
				
operator:			ADD {
                                	sym = createsymbol("+", 0, &valu, 'o', 0);
                                	push_stack(sym);
					
				} | SUB {
                                	sym = createsymbol("-", 0, &valu, 'o', 0);
                                	push_stack(sym);
					
				} | MUL {
                                	sym = createsymbol("*", 0, &valu, 'o', 0);
                                	push_stack(sym);
					
				} | DIV {
                                	sym = createsymbol("/", 0, &valu, 'o', 0);
                                	push_stack(sym);
					
				} | MOD {
                                	sym = createsymbol("%", 0, &valu, 'o', 0);
                                	push_stack(sym);
					
				};		


				
constant : 			INTEGER_CONSTANT 
                                  {
                                    valu.ival = $1; // setting the value
                                    sym = createsymbol("integerconstant", 1, &valu, 'c', 0);
                                    insertsymbol(sym);
                                    
                                    push_stack(sym);
                                  } | STRING_CONSTANT {
                                  	strcpy(valu.sval,$1);
                                  	sym=createsymbol("stringconstant",6, &valu, 'c', 0);
                                  	insertsymbol(sym);
                                  	
                                  	push_stack(sym);
                                  } | FLOAT_CONSTANT 
                                  {
                                    valu.fval = $1; // setting the value
                                    sym = createsymbol("floatconstant", 2, &valu, 'c', 0);
                                    insertsymbol(sym);
                                    
                                    push_stack(sym);
                                  } ;



			// | array_dec SCOL | stmts_list dec SCOL |stri SCOL | stmts_list stri SCOL|flot SCOL | stmts_list flot SCOL | ifloop | whileloop | forloop | ;
					
					
//dec : data_type IDENTIFIER  ;


//assign_stmt : parameter assignment  ; // a =

parameter : data_type IDENTIFIER{
				     set_value(type);	// setting default value based on type
                                    s1 = pop_stack();	// to get the data_type of the identifier
                                    sym = createsymbol($2, s1->type, &valu, 'v', 0);	
                                    insertsymbol(sym);
                                    push_stack(sym);
                                   
	   			 } | IDENTIFIER '[' INTEGER_CONSTANT ']' {
	   			 //   array name	index
	   			 	struct Symbol* s3 = NULL;
	   			 	struct SymbolTable current_method_table = table[current_method_id];
	   			 	int ind = generate_key($1);
	   			 	struct Symbol *tmp = current_method_table.symbols[ind]; // to get the symbol
	   			 	
	   			 	while(tmp){	// checking if the variable exists
						if(strcmp(tmp->name,$1) ==0)
							break;
    						tmp = tmp->next;
					}
					
					if(tmp==NULL)
						printf("variable undeclared \n");
					else{
						push_stack(tmp);
							//tmp->val.ival = valu.ival;
					}
					
	   			 } 
	   			 | IDENTIFIER {		// a=
	   			 	char * var_name = $1;
	   			 	struct SymbolTable current_method_table = table[current_method_id];
	   			 	int ind = generate_key(var_name);
	   			 	struct Symbol *tmp = current_method_table.symbols[ind];
	   			 	
	   			 	while(tmp){	// checking if the variable is already declared in the method
						if(strcmp(tmp->name,var_name) ==0)
							break;
    						tmp = tmp->next;
					}
					
					if(tmp==NULL)
						printf("variable undeclared \n");
					else{
						push_stack(tmp);
					}
	   			 };

data_type : INTEGER {
			//printf("data-type-integer \n");
                        sym = createsymbol("integer", 1, &valu, 'c', 0);
                        push_stack(sym);
                    } | STRING {
                        
                        sym = createsymbol("string", 5, &valu, 'c', 0);
                        push_stack(sym);
                    } | CHAR {
                       
                        sym = createsymbol("char", 1, &valu, 'c', 0);
                        push_stack(sym);
                    } | FLOAT {
                        
                        sym = createsymbol("float", 2, &valu, 'c', 0);
                        push_stack(sym);
                    } | DOUBLE {
                        
                        sym = createsymbol("double", 3, &valu, 'c', 0);
                        push_stack(sym);
                    };
                    
           	
                    

			



%%

int main(int argc,char *argv[]){
	if(argc>1){
		if(strlen(argv[1]) >= 5){
			int len = strlen(argv[1]);
			const char *last_four = &argv[1][len-4];
			
			//printf("\nlast---%s\n",last_four);
			if(strcmp(last_four,".jyp")==0){
		  		FILE *fp = fopen(argv[1], "r");
		  		if(fp)
		  		{
		  			yyin=fp;
		  		}
		  		else{
		  			printf("Error : File not found\n");
		  			exit(1);
		  		}
		  	}
		  	else{
		  		printf("Extension should be '.jyp'\n");
		  		
		  		exit(1);
			}
      	}
      	else{
      		printf("Error : file is not valid\n");
      		exit(1);
      	}
	}
	yyparse();
	return 0;

} 

int yyerror(char *s) {
  printf("\nError: %s\n",s);
  return 0;
}

struct Symbol *createsymbol(char *name,int type,union value *val,char tag, int no_of_array_eles)
{
     struct Symbol *s=(struct Symbol*)malloc(sizeof( struct Symbol )) ;
     s->tag=tag;
     strcpy(s->name,name);
    // printf("%s      --------------------",s->name);
     s->type=type;
     s->no_of_array_elements = no_of_array_eles;
    // 0-void 1-int 2-float 3-double 4-bool 5-char 6-string 
     switch(type){
	
	 case 0:
	     break;
	 case 1:
	 	s->val.ival=valu.ival;
	 	break;
	 case 2:
	 	s->val.fval=valu.fval;
	 	break;	
	 case 3:
	 	s->val.dval=valu.dval;
	 	break; 	 
	 case 4:
	 	s->val.bval=valu.bval;
	 	break;
	 case 5:
	 	s->val.cval=valu.cval;
	 	break;			
	 case 6:
	 	strcpy(s->val.sval,valu.sval);
	 	break;	
	 case 8:
	 	s->val.ival = valu.ival;
	 	break;	     
       }
       
     return s;
}
void initialize()
{
 table->no_of_symbols=0;
 for(int i=0;i<sym_table_size;i++)
 {
   table->symbols[i]=NULL;
 }
}
void insertsymbol(struct Symbol *sm)  // keeping symbol into the symbol table
{
  
  char *var_name = sm->name;
  struct SymbolTable current_method_table = table[current_method_id];
  int ind = generate_key(var_name);
  
  //printf("============ %d    %s==============",ind,var_name);
  struct Symbol *tmp = current_method_table.symbols[ind];  // to get the symbol details
  	while(tmp){	// checking if the variable is already declared in the method
		if(strcmp(tmp->name,var_name) ==0)
			break;
    		tmp = tmp->next;
	}
	
	struct Symbol *ptr = current_method_table.symbols[ind];
	if(tmp==NULL ||  sm->tag=='c'){	// symbol with the same name is not found in the current method
		sm->next = ptr;
  		sm->prev = NULL;
  		if(ptr) // keeping the symbol in the front if the elements with that hash key value are not 0
  			ptr->prev = sm;
		table[current_method_id].symbols[ind] = sm;
		
	}
	else{
		printf("variable %s redefined",var_name);
	}
	
	printf("insert symbol into symbol table successful \n");
   //table.symbols[ table.no_of_symbols]=s;
   // table.no_of_symbols++;
}


//0-void 1-int 2-float 3-double 4-bool 5-char 6-string 
void set_value(int type) {
  switch(type) {
    case 0:	
      break;
    case 1:	
      valu.ival =0; 
      break;
     
    case 2:	
      valu.fval =0; 
      break; 
    case 3:
      valu.dval =0; 
      break; 
    case 4:
      valu.bval =0; 
      break; 
    case 5:
      valu.cval ='\0'; 
      break; 
    case 6:
      strcpy(valu.sval,"") ; 
      break;
      
  }
}

void set_value_for_symbol(struct Symbol* s,int type, struct Symbol*s1){
    switch(type) {
    case 0:	
      break;
    case 1:	
      s->val.ival=s1->val.ival; 
      break;
     
    case 2:	
      s->val.fval=s1->val.fval; 
      break; 
    case 3:
      s->val.dval=s1->val.dval; 
      break; 
    case 4:
      s->val.bval=s1->val.bval; 
      break; 
    case 5:
      s->val.cval=s1->val.cval ='\0'; 
      break; 
    case 6:
      strcpy(s->val.sval,s1->val.sval) ; 
      break;
      
  }
}

struct Node* createNode(int type, struct Symbol *s, struct Node* one, struct Node* two, struct Node * three){
  struct Node * n = (struct Node *)malloc(sizeof(struct Node));
  n->type = type;
  n->node = s;
  n->child[0] = one;
  n->child[1] = two;
  n->child[2] = three;
  return n;
}

//While Stack

struct Symbol* top_while() {
  return while_stack[whileTop];
}

void push_while(struct Symbol* whileSym) {
  while_stack[++whileTop] = whileSym;
}

struct Symbol *pop_while() {
	if (whileTop<0) {
		return(NULL);
	}

	struct Symbol * temp;
	temp = while_stack[whileTop--];
	while_stack[whileTop+1] = NULL;   
	return(temp);
}

void Init_While_Stack() {
	int i;
	for(i = 0; i < 30; i++) {
		while_stack[i] = NULL;
	}
}

void Show_While_Stack() {
	printf("\n--- WHILE STACK ---\n");
	for (int i = whileTop; i >= 0; i--) {
		printf("%s\n", while_stack[i]->name);
	}
	printf("--- END ---\n");
}


void push_stack(struct Symbol *p)
{
  st[++top]=p;
}

struct Symbol *pop_stack()
{
  printf("pop-successful\n");
  return (st[top--]);
}

int generate_key(char *s)	// for locating the method in the methods table (hashing)
{  
  char *temp;
  int a=0;
  for(temp=s; *temp != '\0'; temp++) 
  	a=a+(*temp);
  return (a % 50);
}

void add_method_to_methodstable(struct Symbol *sm){
	
	
	
	char *func_name=sm->name;
	printf("%s\n",func_name);
	int ind = generate_key(func_name);
	printf("%d \n",ind);
	//count();
	struct Symbol *tmp = methods_table.symbols[ind];  // to get the fun details in the methods_table
	printf("\n");
	//count();
	if(tmp == NULL){
	printf("hii\n");
	}
	else{
		printf("pppp\n");
	}
	while(tmp && (strcmp(tmp->name,func_name) != 0)){	// checking if the method is already in the methods table
    		tmp = tmp->next;
	}
	printf("-----\n");
	// it should not have same name
	struct Symbol *ptr = methods_table.symbols[ind];
	if(tmp==NULL){
		printf("success\n");
		sm->next = ptr;
  		sm->prev = NULL;
  		sm->symbol_table = &table[current_method_id];
  		if(ptr) // keeping the symbol in the front if the elements with that hash key value are not 0
  			ptr->prev = sm;
		methods_table.symbols[ind] = sm;
		
	}
	else{
		printf("function %s redefined",func_name);
	}
	
	
}

void count(){
	for(int i=0;i<50;i++){
		if(methods_table.symbols[i]!=NULL)
			printf("%d \n",i);
	}
}

void Initialize_table(){
	for(int i=0;i<50;i++){	// for all the methods
    		methods_table.symbols[i] = NULL;
    		for(int j=0;j<50;j++){		// for all the symbols
      			table[i].symbols[j] = NULL;
    		}
  	}
}


// printing the symbols
void printtable(){
printf("name     tag     no_of_eles   type    value  \n");
for(int i=0;i<50;i++){
    for(int j=0;j<50;j++){
      if(table[i].symbols[j] != NULL) {
        struct Symbol* s3 = table[i].symbols[j];
        while(s3 != NULL) {
          printf("%10s",s3->name); // name of the variable
          //printf("%10c",s3->tag); // typeof variable
          switch(s3->tag) {
            case 'c':
              printf("Constant\n");
              break;
            case 'f':
              printf("Function\n");
              break;
            case 'a':
              printf("Array\n");
              break;
            case 'v':
              printf("Variable\n");
            case 'm':
            	printf("Main\n");
          }
          printf("%10d", s3->no_of_array_elements);
          type = s3->type;
          switch(type) {
            case 1:
              printf("integer\n");
              break;
            case 3:
              printf("double\n");
              break;
            case 6:
              printf("string\n");
              break;
            case 4:
              printf("boolean\n");
          }
          s3 = s3->next;
        }
      }
    }
    
    
  }
}









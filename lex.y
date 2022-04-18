%{
#include "table.h"
#include <sys/queue.h>
#include<stdlib.h>
#include<stdio.h>
#include<cstring>
#include "y.tab.h" 
#include<iostream>
#include<bits/stdc++.h>

using namespace std;


extern FILE* yyin;
int scope=0;
char name[20];
char tag;
struct Node* root;
struct Symbol *sym, *s1, *s2;
struct Symbol *currmethod;
union value valu;

char cs[30];
stack<string>temp_vars;

vector<string> temp_code;
int global=1;	

extern int yylineno;

extern "C"
{
	int yylex(void);
	void yyerror(const char* s)
	{
		printf("%s at line: %d\n", s, yylineno);
		return;
	}
}

struct Symbol *newsym;
int no_of_array_elements=0;

struct SymbolTable table[50];		// for storing the symbols
struct SymbolTable methods_table;   // to store the methods (functions)

int current_method_id=0;
int type = 1;

int conds_count=0;       // ******

int top=-1;  // top element

struct Symbol *st[50];



%}

%union {
  int integer;
  double d;
  float f;
  char c;
  char yid[100];
  char character;
  char strconst[100];
  char *a;  
  char lexeme[20];
  int b;
  struct Node* node;
  int p;//parameters
}




%token ADD SUB MUL DIV ASSIGN AND OR XOR LTE GTE EQUAL NOTEQUAL NOT INCREMENT DECREMENT ASGNADD ASGNSUB ASGNDIV ASGNMUL ASGNMOD MOD  
%token '{' '}' '(' ')' '[' ']' ',' LT GT NEGINT_CONST FLOAT_CONSTANT STRING_CONSTANT DOUBLE_CONSTANT CHAR_CONSTANT

%token IF ELSE ELIF VOID FIRST INTEGER DOUBLE STRING BOOL BREAK CONT FOR WHILE SCOL IDENTIFIER INTEGER_CONSTANT FLOAT LONG SWITCH RETURN CASE OUT CHAR END INP 

 // %type <integer>  NEGINT_CONST
%type <p> parameters  parameters_list parameter  //counting no of parameters for a function



%type <node> program funcs func func_name  stmts_list stmt data_type assignment_stmt constant expression value operator conditional_stmt else_if_stmt else_stmt condition relational_operator inp_list array_declaration expn_inc while_loop for_loop

%%
//char *name,int type,union value *val,char tag
program :			funcs FIRST '{'{scope++;} stmts_list '}' {scope--;} END{
						//printf("\nYES\n"); 
						strcpy(cs,"first");
						printf("%s\n",cs);
						sym=createsymbol(cs,0,&valu,'m',0,scope);
						strcpy(cs,"end");	
						s1=createsymbol(cs,0,&valu,'m',0,scope);
						//printf("hello 123\n");
						add_method_to_methodstable(sym); // adding method as it is start 
						add_method_to_methodstable(s1);
						 
						printtable();	// printing the symbol table
						 printf("\n");
						 printf("\n");
						 printf("\n");
						 printf("\n");
						 printfunctiontable(); //printing the functions list;
					} 
					|
					{   
					 	//printf("NO");
					};
					 	  
					 	  
				
funcs:                            funcs func 
                                  {
                                    //printf("func - 1\n");
                                  }
                                  | 
                                  {
                                   
                                  };

func:                             func_name '{'{scope++;} stmts_list  return_stmt SCOL{ s1= pop_stack(); }  '}' {scope--;}
                                  {
                                    //printf("func - 2\n");

                                    s2 = pop_stack();//function name
                                    printf("data type is %s , return type is %s",s2->name,s1->name);
                                    if(s1->type != s2->type){
                                    	printf("Error : Return type doesnt match");
                                    }
                                  };

func_name:                        data_type IDENTIFIER '(' parameters ')' 
                                  {
                                  //  $$ = createNode(function_name_type, NULL, $1, $4, NULL);
                                  printf("no of parameters are %d\n",$4);
                                    //printf("func-3\n");
                                    int paramsize=$4;
                                    struct Symbol *symparam[paramsize];
                                    int indp=0;
                                    while(paramsize!=0)
                                    {
                                    
                                      symparam[indp]=pop_stack();
                                      
                                     paramsize--;
                                     indp++;
                                    }
                                    paramsize=$4;
                                    s1=pop_stack();
                                    set_value(s1->type);
                                    strcpy(cs,yylval.lexeme);
                                    sym = createsymbol(cs, s1->type, &valu, 'f', $4,scope);
                                    while(paramsize!=0)
                                    {
                                     sym->parameter[$4-paramsize]=symparam[$4-paramsize]; 
                                     paramsize--;
                                    }
                                    push_stack(sym);
                                    add_method_to_methodstable(sym);		// adding it to a method table as it is function
                                    //printf("func-added successfully\n");
                                  };	 
                                  
parameters:			parameters_list{
					$$ = $1;
				   } | {
				   //	$$ = NULL;
				   printf("no-parameters \n");
				   }; 
				   
parameters_list:		parameter ',' parameters_list{
					$$ =$3+1;
					//printf("dollar value is %d \n",$$);
				   }| parameter{
				   	$$ = 1;
				   //	printf("dollar 1 value is %d \n",$$);
				   }| {$$=0;printf("dollar 0 value is %d \n",$$);};

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
				} | expn_inc SCOL{
					//printf("\nincrement\n");	
				} | while_loop {};
				

return_stmt	  :    RETURN  expression {
				//printf("return statement successful\n");
			};
					
array_declaration :	data_type IDENTIFIER '[' INTEGER_CONSTANT ']' ASSIGN '{' inp_list '}' {
				//struct Symbol* s3 = pop_stack(); // to get the inp_list
				
				struct Symbol* s4 = pop_stack();
				int size = yylval.integer;	// number of elements
				char *array_name;
				strcpy(array_name,yylval.lexeme);	// to get the array name
				int ele_type = s4->type; // to get the type of elements
				if(ele_type == 0)
					printf("error in declaring void data type\n");
				
				for(int i=0;i<no_of_array_elements;i++){
					struct Symbol* element = pop_stack();
					if(element->type != ele_type){
						printf("error in data type match\n");
					}
				}
				struct Symbol* s5 = createsymbol(array_name,ele_type, &valu, 'a', size,scope);  // creating symbol of array type
				insertsymbol(s5); // inserting symbol 
				

			} | data_type IDENTIFIER '[' INTEGER_CONSTANT ']'{
				//struct Symbol* s3 = pop_stack(); // to get the inp_list
				printf("%d\n",top);
				printf("\n array declaration \n");
				struct Symbol* s4 = pop_stack();
				int size = yylval.integer;	// number of elements changed from token $4 to yylavl.integer
				printf("%d - size \n",size);
				// to get the array name
				printf("%s - name \n",yylval.lexeme);
				int ele_type = s4->type; // to get the type of elements
				printf("%d - %s",size,yylval.lexeme);
				strcpy(cs,yylval.lexeme);
				struct Symbol* s5 = createsymbol(cs,ele_type, &valu, 'a', size,scope);  // creating symbol of array type
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
					if(sym1->type != sym2->type && !( (sym1->type==1 && sym2->type==5)||(sym1->type==5 && sym2->type==1) ) ){
					printf("symb2 parameter type is %d, symb1 expre type is %d \n ",sym2->type,sym1->type);
					printf("expression name is %s \n",sym1->name);
						printf("Error : Assignment is not possible in different types \n");
					}
					else{
						char *var_name = sym2->name;
						//printf("---- %s ----%s----\n",var_name,sym1->name);
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
						
						
						sym = createsymbol(var_name,t,&valu,'v', 0,scope);
						string ts="";
                                    		string t_var = temp_vars.top();
                                    		temp_vars.pop();
                                    		string s_var = var_name;
                                    		string var_var=s_var+"_"+to_string(sym2->scope);
                                    		global++;
                                    		switch(sym2->type){
                                    			case 0:
                                    			
                                    				break;
                                    			case 1:
                                    				ts="int "+var_var;
                                    				temp_code.push_back(ts);
                                    				ts=var_var+" =i "+t_var;
                                    				temp_code.push_back(ts);
                                    				break;
                                    			case 2:
                                    				ts="float "+var_var;
                                    				temp_code.push_back(ts);
                                    				ts=var_var+" =f "+t_var;
                                    				temp_code.push_back(ts);
                                    				break;
                                    			case 3:
                                    				ts="double "+var_var;
                                    				temp_code.push_back(ts);
                                    				ts=var_var+" =d "+t_var;
                                    				temp_code.push_back(ts);
                                    				break;
                                    			case 4:
                                    				ts="bool "+var_var;
                                    				temp_code.push_back(ts);
                                    				ts=var_var+" =b "+t_var;
                                    				temp_code.push_back(ts);
                                    				break;
                                    			case 5:
                                    				ts="char "+var_var;
                                    				temp_code.push_back(ts);
                                    				ts=var_var+" =c "+t_var;
                                    				temp_code.push_back(ts);
                                    				break;
                                    		
                                    		}
						//insertsymbol(sym);
					}
					
				};
			

conditional_stmt :		IF '(' condition ')' '{'{scope++;} stmts_list '}' {scope--;} else_if_stmts {
					
				};
				
else_if_stmts :		else_if_stmts1 else_stmt{
					
				}| {};
else_if_stmts1 :		else_if_stmt else_if_stmts1{
					
				}| {};
else_if_stmt :			ELIF '(' condition ')' '{'{scope++;} stmts_list '}'{scope--;};

else_stmt : 			ELSE '{' {scope++;} stmts_list '}' {scope--;} | {
					
				};

for_loop:			FOR '(' assignment_stmt SCOL condition SCOL expn_inc ')' '{' {scope++;} stmts_list '}'{
					//printf("\ninside for\n");
					scope--;
				};
				
				
expn_inc :			IDENTIFIER INCREMENT{
					
					
					struct SymbolTable current_method_table = table[current_method_id];
	   			 	int ind = generate_key(yylval.lexeme);
	   			 	//printf("_______________ %d _______________",ind);
	   			 	struct Symbol *tmp = current_method_table.symbols[ind];
	   			 	
	   			 	while(tmp){	// checking if the variable is already declared in the method
						if(strcmp(tmp->name,yylval.lexeme) == 0)
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
                                 '(' condition ')'  '{'  {scope++;} stmts_list '}'
                                  {
                                     scope--;                                    
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
					//struct Symbol *s = createsymbol("bool",s1->type,&valu, 'c', 0,scope);
					//push_stack(s);
					
				} | expression {
					//printf("------------------------- condition type  2----------- \n");
					
				};
				
relational_operator : 		   LTE 
                                  {
                                    printf("inside re op\n");
                                    strcpy(valu.sval,"lte");
                                    strcpy(cs,"lte");
                                    struct Symbol * reop = createsymbol(cs,8, &valu, 'c',0,scope);
                                    push_stack(reop);
                                  }
                                  | GTE 
                                  {
                                    
                                    strcpy(valu.sval,"gte");
                                    strcpy(cs,"gte");
                                    struct Symbol * reop = createsymbol(cs,8, &valu, 'c',0,scope);
                                    push_stack(reop);
                                  }
                                  | LT 
                                  {
                                  strcpy(cs,"lt");
                                     strcpy(valu.sval,"lt");
                                    struct Symbol * reop = createsymbol(cs,8, &valu, 'c',0,scope);
                                    push_stack(reop);
                                  }
                                  | GT 
                                  {
                                    strcpy(valu.sval,"gte");
                                    strcpy(cs,"gt");
                                    struct Symbol * reop = createsymbol(cs,8, &valu, 'c',0,scope);
                                    push_stack(reop);
                                  }
                                  | EQUAL 
                                  {
                                     strcpy(valu.sval,"eq");
                                    struct Symbol * reop = createsymbol(cs,8, &valu, 'c',0,scope);
                                    push_stack(reop);
                                  }
                                  | NOTEQUAL
                                  {
                                  strcpy(cs,"neq");
                                     strcpy(valu.sval,"neq");
                                    struct Symbol * reop = createsymbol(cs,8, &valu, 'c',0,scope);
                                    push_stack(reop);
                                  };
                                  
                                  
value :			constant {
					$$ = $1;
				}| IDENTIFIER {
					//printf("value in .y file\n");
					char *var_name = yylval.lexeme;
					struct Symbol * sym_id = NULL;
					struct SymbolTable current_method_table = table[current_method_id];
	   			 	int ind = generate_key(yylval.lexeme);
	   			 	struct Symbol *tmp = current_method_table.symbols[ind];
	   			 	
	   			 	while(tmp){	// checking if the variable exists
						if(strcmp(tmp->name,var_name) ==0)
							break;
    						tmp = tmp->next;
					}
					
					if(tmp==NULL){
						printf("Error : variable %s undeclared \n",yylval.lexeme);
						push_stack(tmp);
						}
					else{
					        //printf("value of identifired in value is %s",var_name);
					        
						push_stack(tmp);
				      string varname= tmp->name;		
                                    string t_var =varname+"_"+to_string(tmp->scope);
		                     temp_vars.push(t_var);
							//tmp->val.ival = valu.ival;
					}
						
					
						//sym = createsymbol(var_name,t,&valu,'v',scope);
				};
				
				
expression :     		expression operator value{
					// to get the last two values related to the expression
					//data type 0-void 1-int 2-float 3-double 4-bool 5-char 6-string 
					struct Symbol * e1 = pop_stack();//value
					struct Symbol * e3 = pop_stack();//operator
					
						//printf("\n----%d\n",top);
					struct Symbol * e2 = pop_stack();//exp
					string valname=temp_vars.top();
					temp_vars.pop();
					string expname=temp_vars.top(); 
					temp_vars.pop();
					//printf("exp value is%s \n",e2->name);
					//printf("%d \n",e1->val.ival);
					printf("%s   %s   %s\n",e1->name,e2->name,e3->name);
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
						
						if(tmp==NULL && strcmp(e2->name,"expression_value")!=0)
							printf("Error : variable %s , %d is undeclared \n",e2->name,e2->val.ival);
						else{
							switch(t){
								case 1:	// value is of type int
									if(e2->type == 1){	// both are integers
									//printf("_____________________________________________rghy\n");
									          string ts="";
                                                                              string t_var = "_t_"+to_string(global);
                              					        ts = "int "+ t_var;
		                     						temp_code.push_back(ts);
		                       				      // ts = t_var+" =i #"+to_string(valu.ival);
		                                                             //temp_code.push_back(ts);
		                                                              temp_vars.push(t_var); 
				 						if(strcmp(e3->name,"+")==0)
				 						{
				 						        string tempexp=t_var+"="+"i "+expname+"+"+"i "+valname;
				 						        temp_code.push_back(tempexp);
				 						        global++;
											valu.ival=e2->val.ival+e1->val.ival;
									        }		
										else if(strcmp(e3->name,"-")==0)
										{
				 						        string tempexp=t_var+"="+"i "+expname+"-"+"i "+valname;
				 						        temp_code.push_back(tempexp);
				 						        global++;										
											valu.ival=e2->val.ival-e1->val.ival;
										}	
										else if(strcmp(e3->name,"*")==0)
										{
				 						        string tempexp=t_var+"="+"i "+expname+"*"+"i "+valname;
				 						        temp_code.push_back(tempexp);
				 						        global++;										
											valu.ival=e2->val.ival*e1->val.ival;
									        }		
										else if(strcmp(e3->name,"/")==0)
										{
				 						        string tempexp=t_var+"="+"i "+expname+"/"+"i "+valname;
				 						        temp_code.push_back(tempexp);
				 						        global++;										
											valu.ival=e2->val.ival/e1->val.ival;
									        }		
										else if(strcmp(e3->name,"%")==0)
										{
				 						        string tempexp=t_var+"="+"i "+expname+"%"+"i "+valname;
				 						        temp_code.push_back(tempexp);
				 						        global++;										
											valu.ival=e2->val.ival%e1->val.ival;  // also add for +=,-=,*=,/=
										}	
									       else
									       {
									          printf("enter valid arthimetic operator for integers instead of %s\n",e3->name);
									       }			
									}
									// complete other cases
									else if(e2->type == 5){
									//char to int conversion , but possible for int to char
										if(strcmp(e3->name,"+")==0)
											valu.ival=(int)(e2->val.ival)+e1->val.ival;
										else if(strcmp(e3->name,"-")==0)
									                valu.ival=(int)(e2->val.ival)-e1->val.ival;
									}
									//printf("%d                      @++++++++++++++++++==@@",valu.ival);
									printf("create expression_value type is %d\n",t);
									strcpy(cs,"expression_value");
									sym = createsymbol(cs,t,&valu,'e', 0,scope);
									break;
								case 2:	// value is of type float
										if(e2->type == 1){
											if(strcmp(e3->name,"+")==0)
												valu.ival=e2->val.ival+(int)e1->val.fval;
											else if(strcmp(e3->name,"-")==0)
												valu.ival=e2->val.ival-e1->val.ival;
											else if(strcmp(e3->name,"*")==0)
												valu.ival=e2->val.ival*e1->val.ival;
											else if(strcmp(e3->name,"/")==0)
												valu.ival=e2->val.ival/e1->val.ival;
											else if(strcmp(e3->name,"%")==0)
												valu.ival=e2->val.ival%e1->val.ival;  // also add for +=,-=,*=,/=
										}
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
					strcpy(cs,"+");
                                	sym = createsymbol(cs, 0, &valu, 'o', 0,scope);
                                	push_stack(sym);
					
				} | SUB {
					strcpy(cs,"-");
                                	sym = createsymbol(cs, 0, &valu, 'o', 0,scope);
                                	push_stack(sym);
					
				} | MUL {
					strcpy(cs,"*");
                                	sym = createsymbol(cs, 0, &valu, 'o', 0,scope);
                                	push_stack(sym);
					
				} | DIV {
				strcpy(cs,"/");
                                	sym = createsymbol(cs, 0, &valu, 'o', 0,scope);
                                	push_stack(sym);
					
				} | MOD {
					strcpy(cs,"%");
                                	sym = createsymbol(cs, 0, &valu, 'o', 0,scope);
                                	push_stack(sym);
					
				}|relational_operator{printf("re is eplored\n");};		


				
constant : 						  INTEGER_CONSTANT 
                                  {
                                    valu.ival = yylval.integer; // setting the value
                                    //char * ivalue;
                                    //sprintf(ivalue,"%d",$1);
                                    strcpy(cs,"int-const");
                                    sym = createsymbol(cs, 1, &valu, 'c', 0,scope);
                                    insertsymbol(sym);
                                    
                                    push_stack(sym);
                                    string ts="";
                                    string t_var = "_t_"+to_string(global);
                                    ts = "int "+ t_var;
		                     temp_code.push_back(ts);
		                     ts = t_var+" =i #"+to_string(valu.ival);
		                     temp_code.push_back(ts);
		                     temp_vars.push(t_var);
		  
		               
                                  } | STRING_CONSTANT {
                                  	strcpy(valu.sval,yylval.strconst);
                                  	strcpy(cs,"string-const");
                                  	sym=createsymbol(cs,6, &valu, 'c', 0,scope);
                                  	insertsymbol(sym);
                                  	
                                  	push_stack(sym);
                                  } | FLOAT_CONSTANT 
                                  {
                                    valu.fval = yylval.f; // setting the value
                                    //char *fvalue = gcvt($1,6,fvalue);
                                    strcpy(cs,"float-const");
                                    sym = createsymbol(cs, 2, &valu, 'c', 0,scope);
                                    insertsymbol(sym);
                                    
                                    push_stack(sym);
                                  }| CHAR_CONSTANT
                                  {
                                    valu.cval=yylval.a[1];
                                    strcpy(cs,"char-const");
                                       sym = createsymbol(cs, 5, &valu, 'c', 0,scope); 
                                       insertsymbol(sym);
                                       push_stack(sym);
                                  } ;


			// | array_dec SCOL | stmts_list dec SCOL |stri SCOL | stmts_list stri SCOL|flot SCOL | stmts_list flot SCOL | ifloop | whileloop | forloop | ;
					
					
//dec : data_type IDENTIFIER  ;


//assign_stmt : parameter assignment  ; // a =

parameter : data_type IDENTIFIER{

                                       char * var_name = yylval.lexeme;
	   			 	struct SymbolTable current_method_table = table[current_method_id];
	   			 	int ind = generate_key(var_name);
	   			 	struct Symbol *tmp = current_method_table.symbols[ind];
	   			 	
	   			 	while(tmp){	// checking if the variable is already declared in the method
						if(strcmp(tmp->name,var_name) ==0)
							break;
    						tmp = tmp->next;
					}
					
					if(tmp==NULL)
					{
		                             set_value(type);	// setting default value based on type
		                            s1 = pop_stack();	// to get the data_type of the identifier
		                            strcpy(cs,yylval.lexeme);
		                            sym = createsymbol(cs, s1->type, &valu, 'v', 0,scope);	
		                            insertsymbol(sym);
		                            push_stack(sym);
		                            }
					else{
						printf("variable already declared");
					}                                            

                                   
	   			 } | IDENTIFIER '[' INTEGER_CONSTANT ']' {
	   			 //   array name	index
	   			 	struct Symbol* s3 = NULL;
	   			 	struct SymbolTable current_method_table = table[current_method_id];
	   			 	int ind = generate_key(yylval.lexeme);
	   			 	struct Symbol *tmp = current_method_table.symbols[ind]; // to get the symbol
	   			 	
	   			 	while(tmp){	// checking if the variable exists
						if(strcmp(tmp->name,yylval.lexeme) ==0)
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
	   			 	char * var_name = yylval.lexeme;
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
			strcpy(cs,"integer");
                        sym = createsymbol(cs, 1, &valu, 'c', 0,scope);
                        push_stack(sym);
                    } | STRING {
                        strcpy(cs,"string");
                        sym = createsymbol(cs, 6, &valu, 'c', 0,scope);
                        push_stack(sym);
                    } | CHAR {
                       strcpy(cs,"char");
                        sym = createsymbol(cs, 5, &valu, 'c', 0,scope);
                        push_stack(sym);
                    } | FLOAT {
                        strcpy(cs,"float");
                        sym = createsymbol(cs, 2, &valu, 'c', 0,scope);
                        push_stack(sym);
                    } | DOUBLE {
                        strcpy(cs,"double");
                        sym = createsymbol(cs, 3, &valu, 'c', 0,scope);
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

struct Symbol *createsymbol(char *name,int type,union value *val,char tag, int no_of_array_eles,int _scope)
{
     struct Symbol *s=(struct Symbol*)malloc(sizeof( struct Symbol )) ;
     s->tag=tag;
     strcpy(s->name,name);
    // printf("%s      --------------------",s->name);
     s->type=type;
     s->scope=_scope;
     s->no_of_elements = no_of_array_eles;
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
	
	//printf("insert symbol into symbol table successful \n");
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
      s->val.cval=s1->val.cval ; 
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


void push_stack(struct Symbol *p)
{
  st[++top]=p;
}

struct Symbol *pop_stack()
{
  //printf("pop-successful\n");
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
	//printf("%s\n",func_name);
	int ind = generate_key(func_name);
	//printf("%d \n",ind);
	//count();
	struct Symbol *tmp = methods_table.symbols[ind];  // to get the fun details in the methods_table
	
	while(tmp && (strcmp(tmp->name,func_name) != 0)){	// checking if the method is already in the methods table
    		tmp = tmp->next;
	}
	//printf("-----\n");
	// it should not have same name
	struct Symbol *ptr = methods_table.symbols[ind];
	if(tmp==NULL){
		//printf("success\n");
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
printf("%10s |%10s |%15s |%10s |%10s |%10s |%10s\n","Name","Class","Type","DataType","Value","NoOfElements","Scope");
printf("-------------------------------------------------------------------------------------------\n");
for(int i=0;i<50;i++){
    for(int j=0;j<50;j++){
      if(table[i].symbols[j] != NULL) {
        struct Symbol* s3 = table[i].symbols[j];
        while(s3 != NULL) {
          printf("%10s |",s3->name); // name of the variable
          switch(s3->tag) {
            case 'c':
              printf("%10s |","Constant");
              break;
            case 'f':
              printf("%10s |","Function");
              break;
            case 'a':
              printf("%10s |","Array");
              break;
            case 'v':
              printf("%10s |","Variable");
              break;
            case 'm':
                printf("%10s |","Main");
            	break;
          }
          switch(s3->tag) {
            case 'c':
              printf("%15s |","constant");
              break;
            case 'f':
              printf("%15s |","Function");
              break;
            case 'a':
              printf("%15s |","Array");
              break;
            case 'v':
              printf("%15s |","Identifier");
              break;
            case 'm':
                printf("%15s |","Main");
            	break;
          }
          type = s3->type;
          switch(type) {
            case 1:
              printf("%10s |","integer");
              break;
            case 2:
              printf("%10s |","float");
              break;   
            case 3:
              printf("%10s |","double");
              break;
            case 5:
              printf("%10s |","character");
              break;              
            case 6:
              printf("%10s |","string");
              break;
            case 4:
              printf("%10s |","boolean");
          }
          switch(type) {
		    case 1:
		      printf("%10d |",s3->val.ival);
		      break;
		    case 2:
		      printf("%10f |",s3->val.fval);
		      break;		      
		    case 3:
		      printf("%10f |",s3->val.dval);
		      break;
		    case 5:
		      printf("%10c |",s3->val.cval);
		      break;		      
		    case 6:
		      printf("%10s |",s3->val.sval);
		      break;
		    case 4:
		      printf("%10d |",s3->val.ival);
		  }
          printf("%10d   |", s3->no_of_elements);
          printf("%10d\n",s3->scope);
          s3 = s3->next;
        }
      }
    }
    
    
  }
}

void printfunctiontable(){
printf("%10s |%10s |%15s |%10s |%10s |%10s |%10s\n","Name","Class","Type","DataType","Value","NoOfElements","Scope");
printf("-------------------------------------------------------------------------------------------\n");

    for(int j=0;j<50;j++){
      if(methods_table.symbols[j] != NULL) {
        struct Symbol* s3 = methods_table.symbols[j];
        while(s3 != NULL) {
          printf("%10s |",s3->name); // name of the variable
          switch(s3->tag) {
            case 'c':
              printf("%10s |","Constant");
              break;
            case 'f':
              printf("%10s |","Function");
              break;
            case 'a':
              printf("%10s |","Array");
              break;
            case 'v':
              printf("%10s |","Variable");
              break;
            case 'm':
                printf("%10s |","Main");
            	break;
          }
          switch(s3->tag) {
            case 'c':
              printf("%15s |","constant");
              break;
            case 'f':
              printf("%15s |","Function");
              break;
            case 'a':
              printf("%15s |","Array");
              break;
            case 'v':
              printf("%15s |","Identifier");
              break;
            case 'm':
                printf("%15s |","Main");
            	break;
          }
          type = s3->type;
          switch(type) {
            case 1:
              printf("%10s |","integer");
              break;
            case 2:
              printf("%10s |","float");
              break;   
            case 3:
              printf("%10s |","double");
              break;
            case 5:
              printf("%10s |","character");
              break;              
            case 6:
              printf("%10s |","string");
              break;
            case 4:
              printf("%10s |","boolean");
          }
          switch(type) {
		    case 1:
		      printf("%10d |",s3->val.ival);
		      break;
		    case 2:
		      printf("%10f |",s3->val.fval);
		      break;		      
		    case 3:
		      printf("%10f |",s3->val.dval);
		      break;
		    case 5:
		      printf("%10c |",s3->val.cval);
		      break;		      
		    case 6:
		      printf("%10s |",s3->val.sval);
		      break;
		    case 4:
		      printf("%10d |",s3->val.ival);
		  }
          printf("%10d   |", s3->no_of_elements);
          printf("%10d\n",s3->scope);
          int psize=s3->no_of_elements;
          while(psize!=0)
          {
          printf("name of param is %10s and data type of param is %d\n",s3->parameter[s3->no_of_elements-psize]->name,s3->parameter[s3->no_of_elements-psize]->type);
          psize--;
          }
          s3 = s3->next;
        }
      }
    }
    
    
    
    for(int i=0;i<temp_code.size();i++){
    	cout<<temp_code[i]<<endl;
    }
  
}








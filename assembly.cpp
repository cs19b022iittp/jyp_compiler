#include<iostream>
#include<bits/stdc++.h>
#include<vector>
#include<fstream>
#include <cstring>

using namespace std;

void tokenize(string str, string delim,
            vector<string> &tok)
{
    size_t pos = 0;
    while ((pos = str.find(delim)) != string::npos) {
        tok.push_back(str.substr(0, pos));
        str.erase(0, pos + delim.length());
    }
    tok.push_back(str);
}

void write_to_file(string main_str){
     ofstream myfile("assembly_code.asm");

    if(myfile.is_open())
    {
        	myfile<<main_str<<endl;
        myfile.close();
    }
}

int main(){

	ifstream temp_file;
	string line;
	temp_file.open("temp_code.txt");
	
	string text_str = ".text \n";
	string global_str=".globl main \n";
	string main_str="main:\n";
	string data_str = ".data\n";
	
	vector<string>v;
	
	while(temp_file){
		getline(temp_file,line);
		
		if(line == "")
			continue;
		else{
		
			string delim = " ";
			vector<string>tok; 
			tokenize(line, delim, tok);
			for (auto &s: tok) {
        			//cout << s << endl;
    			}
    			
    			if(tok[0].substr(tok[0].size()-1, tok[0].size()) == ":")
			{
				string lab_name = tok[0]; 
				main_str += lab_name+"\n";

			}
			else if(tok[0] == "goto")
			{
				string gotolabel = tok[1];
				main_str += "j "+gotolabel+"\n";
			}
			else if(tok[0] == "int")
			{
				if(tok.size() > 2 )
				{
					main_str += "li $8, 1\n";

					for( int i = 2 ; i < tok.size() ; i++ )
					{
						main_str  += "lw $9, " + tok[i] + "\n";
						main_str += "mul $8, $8, $9\n";
					}
					main_str += "li $10, 4\n";
					main_str += "mul $8, $8, $10\n";
					main_str+= "li $2, 9\n";
					main_str += "move $4, $8\n";
					main_str += "syscall\n";
					main_str += "sw $2, "+tok[1]+"\n";
					data_str += tok[1] + ": .word 0\n";
				}
				else
				{
					data_str += tok[1] + ": .word 0\n";  // data
				}
			}
			else if(tok[0] == "char")
			{
				if(tok.size() > 2 )
				{
					main_str += "li $8, 1\n";

					for( int i = 2 ; i < tok.size() ; i++ )
					{
						main_str  += "lw $9, " + tok[i] + "\n";
						main_str += "mul $8, $8, $9\n";
					}
					main_str += "li $10, 4\n";
					main_str += "mul $8, $8, $10\n";
					main_str+= "li $2, 9\n";
					main_str += "move $4, $8\n";
					main_str += "syscall\n";
					main_str += "sw $2, "+tok[1]+"\n";
					data_str += tok[1] + ": .word 0\n";
				}
				else	// data
				{
					data_str += tok[1] + ": .word 0\n";  // data
				}
			}
			else if(tok[0] == "float")
			{
				data_str += tok[1] + ": .float 0.0\n";  // data
			}
			else if(tok[0] == "bool")
			{
				data_str += tok[1] + ": .word 0\n";  // data
			}
			else if(tok[0]== "if"){
		
				string var1 = tok[2];  //left
				string cond_operator = tok[3];  // operator
				string var2 = tok[4];  // right
				string goto_label = tok[7];    // goto label
				string reg1 = "$8";
				string reg2 = "$9";
				
				if(cond_operator.substr(cond_operator.size()-1, cond_operator.size()) == "b")
				{
					main_str += "lw "+reg1+", "+var1+"\n";
				//	cout<<"------------"<<endl;
					if( cond_operator == "==b" )
					{
						if(var2 == "#true")
						{
							main_str += "bnez " +  reg1 + ", " + goto_label + "\n";
						}
						else if(var2 == "#false"){
							main_str+= "beqz " + reg1 + ", " + goto_label + "\n";
						}
					}
					else if( cond_operator == "!=b" )
					{
						if(var2 == "#false")
						{
							main_str += "bnez " +  reg1 + ", " + goto_label + "\n";
						}
						else if(var2 == "#true"){
						//cout<<"++++++++++++++++++++++++++++++++++++++++++++++++++++++"<<endl;
							main_str += "beqz " + reg1 + ", " + goto_label + "\n";
						}
					}
				}
				if(cond_operator.substr(cond_operator.size()-1, cond_operator.size()) == "i")
				{
					if(var1[0] == '#')
					{
						main_str += "li "+reg1+", "+var1.substr(1, var1.length())+"\n";
					}
					else
					{
						main_str += "lw "+reg1+", "+var1+"\n";
					}
					if(var2[0] == '#')
					{
						main_str += "li "+reg2+", "+var2.substr(1, var2.length())+"\n";
					}
					else
					{
						main_str += "lw "+reg2+", "+var2+"\n";
					}


					if(cond_operator == "==i")
					{
						main_str += "beq "+reg1+", "+reg2+", "+goto_label+"\n";
					}
					else if(cond_operator == "<=i")
					{
						main_str += "ble "+reg1+", "+reg2+", "+goto_label+"\n";
					}
					else if(cond_operator == ">=i")
					{
						main_str += "bge "+reg1+", "+reg2+", "+goto_label+"\n";
					}
					else if(cond_operator == "<i")
					{
						main_str += "blt "+reg1+", "+reg2+", "+goto_label+"\n";
					}
					else if(cond_operator == ">i")
					{
						main_str += "bgt "+reg1+", "+reg2+", "+goto_label+"\n";
					}
					else if(cond_operator == "!=i")
					{
						main_str+= "bne "+reg1+", "+reg2+", "+goto_label+"\n";
					}
				}
				else if(cond_operator.substr(cond_operator.size()-1, cond_operator.size()) == "f")
				{
					string f1="$f0", f2="$f1", f3="$f2";

					if(var1[0] == '#')
					{
						main_str += "li.s "+f1+", "+var1.substr(1, var1.length())+"\n";
					}
					else
					{
						main_str += "lwc1 "+f1+", "+var1+"\n";
					}

					if(var2[0] == '#')
					{
						main_str += "li.s "+f2+", "+var2.substr(1, var2.length())+"\n";
					}
					else
					{
						main_str += "lwc1 "+f2+", "+var2+"\n";
					}


					if(cond_operator == "==f")
					{
						main_str += "c.eq.s "+f1+", "+f2+"\n";
					}
					else if(cond_operator == "<=f")
					{
						main_str += "c.le.s "+f1+", "+f2+"\n";
					}
					else if(cond_operator == ">=f")
					{
						main_str += "c.le.s "+f2+", "+f1+"\n";
					}
					else if(cond_operator == "<f")
					{
						main_str += "c.lt.s "+f1+", "+f2+"\n";
					}
					else if(cond_operator == ">f")
					{
						main_str += "c.lt.s "+f2+", "+f1+"\n";
					}
					else if(cond_operator == "!=f")
					{
						main_str += "c.ne.s "+f1+", "+f2+"\n";
					}
					main_str += "bc1t "+goto_label+"\n";
				} 
			}
			else if(tok[0] == "inp")
			{
				string type = tok[1];
				string var1 = tok[2];

				if(type == "int")
				{
					main_str += "li $2, 5\n"; 
					main_str += "syscall\n";

					if(var1[0] != '*')
					{
						main_str += "sw $2, " + var1 + "\n";
					}
					else
					{
						main_str += "lw $4, " + var1.substr(1, var1.length()) + "\n";
						main_str += "sw $2, ($4)\n";
					}
				}
				else if(type == "char")
				{
					main_str += "li $2, 12\n"; 
					main_str += "syscall\n";

					if(var1[0] != '*')
					{
						main_str += "sw $2, " + var1 + "\n";
					}
					else
					{
						main_str += "sw $2, (" + var1.substr(1, var1.length()) + ")\n";
					}
				}
			}
			else if(tok[0] == "print")
			{
				string type = tok[1];
				if( type == "newline" )
				{
					main_str += "li $2, 11\n"; 
					main_str += "lb $4, 10\n";
					main_str += "syscall\n";
					continue;
				}
				string var1 = tok[2];

				if(type == "int")
				{
					if( var1[0] == '*' )
					{
						main_str += "lw $8, " + var1.substr(1, var1.size()) + "\n";
						main_str += "lw $8, ($8)\n";
						main_str += "li $2, 1\n"; 
						main_str += "move $4, $8\n";
						main_str += "syscall\n";
					}
					else
					{
						main_str += "li $2, 1\n"; 
						main_str += "lw $4, " + var1 +"\n";
						main_str += "syscall\n";
					}
				}
				else if(type == "char")
				{
					if( var1[0] == '*' )
					{
						main_str += "lw $8, " + var1.substr(1, var1.size()) + "\n";
						main_str += "lb $8, ($8)\n";
						main_str += "li $2, 11\n"; 
						main_str += "move $4, $8\n";
						main_str += "syscall\n";
					}
					else
					{
						main_str += "li $2, 11\n"; 
						main_str += "lb $4, " + var1 +"\n";
						main_str += "syscall\n";
					}
				}
				else if(type == "str")
				{
					main_str += "li $2, 4\n"; 
					main_str += "lw $4, " + var1 +"\n";
					main_str += "syscall\n";
				}
				else if(type == "float")
				{
					main_str += "li $2, 2\n";
					main_str += "lwc1 $f12, "+var1+"\n";
					main_str += "syscall\n";
				}
				else if(type == "bool")
				{
					main_str += "li $2, 1\n"; 
					main_str += "lw $4, " + var1 +"\n";
					main_str += "syscall\n";
				}                
			}
			else if(tok.size()>=3){
			
			string v1, v2, res, resreg, eq, op;

				string reg1 = "$8";
				string reg2 = "$9";
				string reg3 = "$10";
				string reg4 = "$11";

				string f1 = "$f0";
				string f2 = "$f1";
				string f3 = "$f2";
				string f4 = "$f3";

				res = tok[0]; 
				eq = tok[1];
				
				if( eq == "=b" )
				{
					//cout<<"++++"<<endl;
					v1 = tok[2];

					if( v1[0] == '#')
					{
						if( v1.substr(1, v1.size()) == "true" )
						{
							main_str += "li " + reg1 + ", 1\n";
						}
						else if( v1.substr(1, v1.size()) == "false" )
						{
							main_str += "li " + reg1 + ", 0\n";
						}
					}
					else
					{
						main_str += "lw "+reg1+", "+v1+"\n";
					}

					//	cout<<":::::::::::::"<<endl;
						main_str += "sw " + reg1 + ", " + res + "\n";
					
				}
				else if( eq == "=f")
				{
					v1 = tok[2];
					if( tok.size() == 4 )	//t1 = minus t2
					{
						v1 = tok[3];
					}

					if( v1[0] == '#')
					{
						main_str += "li.s " + f1 + ", " + v1.substr( 1, v1.size() )+"\n";
					}
					else if(v1[0] == '*')
					{
						main_str += "lwc1 "+f1+", "+v1.substr(1, v1.size())+"\n";
						main_str += "lwc1 "+f1+", "+"("+f1+")\n";
					}
					else
					{
						main_str += "lwc1 "+f1+", "+v1+"\n";
					}

					if( tok.size() == 4 )
					{
						main_str += "sub.s "+f1+ ", $zero, "+f1+"\n";
					}


					if( tok.size() == 5 )
					{
						op = tok[3];
						v2 = tok[4];
						int t2 = 0;

						if( v2[0] == '#')
						{
							main_str += "li.s " + f2 + ", " + v2.substr( 1, v2.size() )+"\n";
						}
						else if(v2[0] == '*')
						{
							main_str += "lwc1 "+f2+", "+v2.substr(1, v2.size())+"\n";
							main_str += "lwc1 "+f2+", "+"("+f2+")\n";
						}
						else
						{
							main_str += "lwc1 "+f2+", "+v2+"\n";
						}

						if(op == "+f")
						{
							main_str += "add.s "+ f3 + ", " + f1 + ", " + f2 + "\n";
						}
						else if(op == "-f")
						{
							main_str += "sub.s "+ f3 + ", " + f1 + ", " + f2 + "\n";
						}
						else if(op == "*f")
						{
							main_str+= "mul.s "+ f3 + ", " + f1 + ", " + f2 + "\n";
						}
						else if(op == "/f")
						{
							main_str += "div.s "+ f3 + ", " + f1 + ", " + f2 + "\n";
						}
						resreg = f3;
					}

					if( tok.size() == 3 || tok.size() == 4 )
					{
						resreg = f1;
					}

					if( res[0] == '*')
					{
						main_str += "lwc1 " + f4 + ", " + res.substr(1, res.length()) + "\n";
						main_str+= "swc1 " + resreg + ", (" + f4 + ")\n";  
					}
					else
					{
						main_str += "swc1 " + resreg + ", " + res + "\n";
					}
				}
			
				if(eq == "=i")
				{
					v1 = tok[2];
					
					if( v1[0] == '#')
					{
						main_str += "li " + reg1 + ", " + v1.substr( 1, v1.size() )+"\n";
					}
					else if(v1[0] == '*')
					{
						main_str += "lw "+reg1+", "+v1.substr(1, v1.size())+"\n";
						main_str += "lw "+reg1+", "+"("+reg1+")\n";
					}
					else{

						main_str += "lw "+reg1+", "+v1+"\n";
					}
					if( tok.size() == 5 )
					{
						op = tok[3];
						v2 = tok[4];
						int t2 = 0;

						if( v2[0] == '#')
						{
							main_str += "li " + reg2 + ", " + v2.substr( 1, v2.size() )+"\n";
							t2 = 1;
						}
						else if(v2[0] == '*')
						{
							main_str += "lw "+reg2+", "+v2.substr(1, v2.size())+"\n";
							main_str += "lw "+reg2+", "+"("+reg2+")\n";
						}
						else
						{
							main_str += "lw "+reg2+", "+v2+"\n";
						}


						if(op == "+i")
						{
							t2 == 0 ? main_str += "add "+ reg3 + ", " + reg1 + ", " + reg2 + "\n" : main_str += "addi "+ reg3 + ", " + reg1 + ", " + v2.substr(1, v2.length()) + "\n";
						}
						else if(op == "-i")
						{
							main_str += "sub "+ reg3 + ", " + reg1 + ", " + reg2 + "\n";
						}
						else if(op == "*i")
						{
							main_str += "mul "+ reg3 + ", " + reg1 + ", " + reg2 + "\n";
						}
						else if(op == "/i")
						{
							main_str += "div "+ reg1 + ", " + reg2 + "\n";
							main_str += "mflo "+ reg3 + "\n";
						}
						resreg = reg3;
					}
					if( tok.size() == 3 || tok.size() == 4 )
					{
						resreg = reg1;
					}
					if( res[0] == '*')
					{
						main_str += "lw "+reg4+", "+res.substr(1, res.size())+"\n";
						main_str += "sw "+resreg+", "+"("+reg4+")\n";
					}
					else
					{
						main_str += "sw " + resreg + ", " + res + "\n";
					}
					
					}
					else if(eq == "=c"){
						v1 = tok[2];

						if( v1[0] == '#')
						{
							if( v1.size() == 4 )
							{
								main_str += "li " + reg1 + ", " + to_string((int)v1[2])+"\n";
							}
							else if( v1.size() == 5 )
							{
								if( v1[3] == 'n' )
								{
									main_str += "li " + reg1 + ", 10\n";
								}
							}
						}
						else if(v1[0] == '*')
						{
							main_str += "lw "+reg1+", "+v1.substr(1, v1.size())+"\n";
							main_str += "lb "+reg1+", "+"("+reg1+")\n";
						}
						else
						{
							main_str += "lb "+reg1+", "+v1+"\n";
						}

						if( res[0] == '*')
						{
							main_str += "lw "+reg4+", "+res.substr(1, res.size())+"\n";
							main_str += "sb "+reg1+", "+"("+reg4+")\n";
						}
						else
						{
							main_str += "sb " + reg1 + ", " + res + "\n";
						}
					}
				}
			}
		}
		
	
	main_str += "li $v0, 10\nsyscall\n";
	main_str = data_str +text_str+global_str+ main_str;
	
	temp_file.close();
	
	//cout<<main_str<<endl;
	write_to_file(main_str);
	
	return 0;
	
}

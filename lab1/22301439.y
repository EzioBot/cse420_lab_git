%{

#include"symbol_info.h"

#define YYSTYPE symbol_info*

int yyparse(void);
int yylex(void);

extern FILE *yyin;
void yyerror(char *);

ofstream outlog;

int lines = 1;

// declare any other variables or functions needed here

%}

%token IF ELSE FOR WHILE DO INT FLOAT DECOP   CHAR DOUBLE VOID RETURN BREAK CONTINUE SWITCH CASE DEFAULT GOTO PRINTF ID CONST_INT CONST_FLOAT ADDOP MULOP INCOP RELOP LOGICOP NOT ASSIGNOP LPAREN RPAREN LCURL RCURL LTHIRD RTHIRD COMMA COLON SEMICOLON

%%


start : program
	{
		outlog<<"At line no: "<<lines<<" start : program "<<endl<<endl;
		outlog << $1->getname()<< endl << endl;
		$$ = new symbol_info($1->getname(),"start");
	}
	;

program : program unit
	{
		outlog<<"At line no: "<<lines<<" program : program unit "<<endl<<endl;
		outlog << $1->getname() << " " << $2->getname() << endl << endl;
		$$ = new symbol_info($1->getname()+" "+$2->getname(),"program");
	}
	| unit
	{
		outlog<<"At line no: "<<lines<<" program : unit "<<endl<<endl;
		outlog<<$1->getname()<<endl<<endl;
		$$ = new symbol_info($1->getname(),"program");
	}
	;

unit : var_declaration
	{
		outlog<<"At line no: "<<lines<<" unit : var_declaration "<<endl<<endl;
		outlog<<$1->getname()<<endl<<endl;
		$$ = new symbol_info($1->getname(),"unit");
	}
	| func_definition
	{
		outlog<<"At line no: "<<lines<<" unit : func_definition "<<endl<<endl;
		outlog<<$1->getname()<<endl<<endl;
		$$ = new symbol_info($1->getname(),"unit");
	}
	;

func_definition : type_specifier ID LPAREN parameter_list RPAREN compound_statement 
	{
		outlog<<"At line no: "<<lines<<" func_definition : type_specifier ID LPAREN parameter_list RPAREN compound_statement"<<endl<<endl;
		outlog << $1->getname() << " " << $2->getname() << "(" << $4->getname() << ")" << $6->getname() << endl << endl;
		$$ = new symbol_info($1->getname()+" "+$2->getname()+"("+$4->getname()+") "+$6->getname(),"func_def");
	}
	| type_specifier ID LPAREN RPAREN compound_statement
	{
		outlog<<"At line no: "<<lines<<" func_definition : type_specifier ID LPAREN RPAREN compound_statement"<<endl<<endl;
		outlog<<$1->getname()+" "+$2->getname()+"() "+$5->getname()<<endl<<endl;
		$$ = new symbol_info($1->getname()+" "+$2->getname()+"() "+$5->getname(),"func_def");
	}
	;

parameter_list : parameter_list COMMA type_specifier ID
	{
		outlog<<"At line no: "<<lines<<" parameter_list : parameter_list COMMA type_specifier ID"<<endl<<endl;
		outlog << $1->getname() << "," << $3->getname() << " " << $4->getname() << endl << endl;
		$$ = new symbol_info($1->getname()+","+$3->getname()+" "+$4->getname(),"param");
	}
	| parameter_list COMMA type_specifier
	{
		outlog<<"At line no: "<<lines<<" parameter_list : parameter_list COMMA type_specifier"<<endl<<endl;
		outlog << $1->getname() << "," << $3->getname() << endl << endl;
		$$ = new symbol_info($1->getname()+","+$3->getname(),"param");
	}
	| type_specifier ID
	{
		outlog<<"At line no: "<<lines<<" parameter_list : type_specifier ID"<<endl<<endl;
		outlog << $1->getname() << " " << $2->getname() << endl << endl;
		$$ = new symbol_info($1->getname()+" "+$2->getname(),"param");
	}
	| type_specifier
	{
		outlog<<"At line no: "<<lines<<" parameter_list : type_specifier"<<endl<<endl;
		outlog<<$1->getname()<<endl<<endl;
		$$ = new symbol_info($1->getname(),"param");
	}
	;

compound_statement : LCURL statements RCURL
	{
		outlog<<"At line no: "<<lines<<" compound_statement : LCURL statements RCURL"<<endl<<endl;
		outlog<<"{"<<$2->getname()<<"}"<<endl<<endl;
		$$ = new symbol_info("{"+$2->getname()+"}","compound");
	}
	| LCURL RCURL
	{
		outlog<<"At line no: "<<lines<<" compound_statement : LCURL RCURL"<<endl<<endl;
		outlog<<"{}"<<endl<<endl;
		$$ = new symbol_info("{}","compound");
	}
	;

var_declaration : type_specifier declaration_list SEMICOLON
	{
		outlog<<"At line no: "<<lines<<" var_declaration : type_specifier declaration_list SEMICOLON"<<endl<<endl;
		outlog << $1->getname() << " " << $2->getname() << ";"<< endl << endl;
		$$ = new symbol_info($1->getname()+" "+$2->getname() + ";" ,"var_decl");
	}
	;

type_specifier : INT
	{
		outlog<<"At line no: "<<lines<<" type_specifier : INT "<<endl<<endl;
		outlog<<"INT"<<endl<<endl;
		$$ = new symbol_info("INT","type");
	}
	| FLOAT
	{
		outlog<<"At line no: "<<lines<<" type_specifier : FLOAT "<<endl<<endl;
		outlog<<"FLOAT"<<endl<<endl;
		$$ = new symbol_info("FLOAT","type");
	}
	| VOID
	{
		outlog<<"At line no: "<<lines<<" type_specifier : VOID "<<endl<<endl;
		outlog<<"VOID"<<endl<<endl;
		$$ = new symbol_info("VOID","type");
	}
	;

declaration_list : declaration_list COMMA ID
	{
		outlog<<"At line no: "<<lines<<" declaration_list : declaration_list COMMA ID"<<endl<<endl;
		outlog << $1->getname() << "," << $3->getname() << endl << endl;
		$$ = new symbol_info($1->getname()+","+$3->getname(),"decl");
	}
	| declaration_list COMMA ID LTHIRD CONST_INT RTHIRD
	{
		outlog<<"At line no: "<<lines<<" declaration_list : declaration_list COMMA ID LTHIRD CONST_INT RTHIRD"<<endl<<endl;
		outlog << $1->getname() << "," << $3->getname() << "[" << $5->getname() << "]" << endl << endl;
		$$ = new symbol_info($1->getname()+","+$3->getname()+"["+$5->getname()+"]","decl");
	}
	| ID
	{
		outlog<<"At line no: "<<lines<<" declaration_list : ID"<<endl<<endl;
		outlog<<$1->getname()<<endl<<endl;
		$$ = new symbol_info($1->getname(),"decl");
	}
	| ID LTHIRD CONST_INT RTHIRD
	{
		outlog<<"At line no: "<<lines<<" declaration_list : ID LTHIRD CONST_INT RTHIRD"<<endl<<endl;
		outlog << $1->getname() << "[" << $3->getname() << "]" << endl << endl;
		$$ = new symbol_info($1->getname()+"["+$3->getname()+"]","decl");
	}
	;

statements : statement
	{
		outlog<<"At line no: "<<lines<<" statements : statement"<<endl<<endl;
		outlog<<$1->getname()<<endl<<endl;
		$$ = new symbol_info($1->getname(),"stmts");
	}
	| statements statement
	{
		outlog<<"At line no: "<<lines<<" statements : statements statement"<<endl<<endl;
		outlog << $1->getname() << " " << $2->getname() << endl << endl;
		$$ = new symbol_info($1->getname()+" "+$2->getname(),"stmts");
	}
	;

statement : var_declaration
	{
		outlog<<"At line no: "<<lines<<" statement : var_declaration"<<endl<<endl;
		outlog<<$1->getname()<<endl<<endl;
		$$ = new symbol_info($1->getname(),"stmt");
	}
	| expression_statement
	{
		outlog<<"At line no: "<<lines<<" statement : expression_statement"<<endl<<endl;
		outlog<<$1->getname()<<endl<<endl;
		$$ = new symbol_info($1->getname(),"stmt");
	}
	| compound_statement
	{
		outlog<<"At line no: "<<lines<<" statement : compound_statement"<<endl<<endl;
		outlog<<$1->getname()<<endl<<endl;
		$$ = new symbol_info($1->getname(),"stmt");
	}
	| FOR LPAREN expression_statement expression_statement expression RPAREN statement
	{
		outlog<<"At line no: "<<lines<<" statement : FOR LPAREN expression_statement expression_statement expression RPAREN statement"<<endl<<endl;
		outlog << "for(" << $3->getname() << $4->getname() << $5->getname() << ") " << $7->getname() << endl << endl;
		$$ = new symbol_info("for("+$3->getname()+$4->getname()+$5->getname()+") "+$7->getname(),"stmt");
	}
	| IF LPAREN expression RPAREN statement
	{
		outlog<<"At line no: "<<lines<<" statement : IF LPAREN expression RPAREN statement"<<endl<<endl;
		outlog << "if(" << $3->getname() << ")" << $5->getname() << endl << endl;
		$$ = new symbol_info("if("+$3->getname()+")"+$5->getname(),"stmt");
	}
	| IF LPAREN expression RPAREN statement ELSE statement
	{
		outlog<<"At line no: "<<lines<<" statement : IF LPAREN expression RPAREN statement ELSE statement"<<endl<<endl;
		outlog << "if(" << $3->getname() << ")" << $5->getname() << "else" << $7->getname() << endl << endl;
		$$ = new symbol_info("if("+$3->getname()+")"+$5->getname()+"else"+$7->getname(),"stmt");
	}
	| WHILE LPAREN expression RPAREN statement
	{
		outlog<<"At line no: "<<lines<<" statement : WHILE LPAREN expression RPAREN statement"<<endl<<endl;
		outlog << "while(" << $3->getname() << ")" << $5->getname() << endl << endl;
		$$ = new symbol_info("while("+$3->getname()+")"+$5->getname(),"stmt");
	}
	| PRINTF LPAREN ID RPAREN SEMICOLON
	{
		outlog<<"At line no: "<<lines<<" statement : PRINTF LPAREN ID RPAREN SEMICOLON"<<endl<<endl;
		outlog << "printf(" << $3->getname() << ");" << endl << endl;
		$$ = new symbol_info("printf("+$3->getname()+");","stmt");
	}
	| RETURN expression SEMICOLON
	{
		outlog<<"At line no: "<<lines<<" statement : RETURN expression SEMICOLON"<<endl<<endl;
		outlog << "return " << $2->getname() << ";" << endl << endl;
		$$ = new symbol_info("return "+$2->getname()+";","stmt");
	}
	;

expression_statement : SEMICOLON
	{
		outlog<<"At line no: "<<lines<<" expression_statement : SEMICOLON"<<endl<<endl;
		outlog<<";"<<endl<<endl;
		$$ = new symbol_info(";","expr");
	}
	| expression SEMICOLON
	{
		outlog<<"At line no: "<<lines<<" expression_statement : expression SEMICOLON"<<endl<<endl;
		outlog << $1->getname() << ";" << endl << endl;
		$$ = new symbol_info($1->getname()+";","expr");
	}
	;

variable : ID
	{
		outlog<<"At line no: "<<lines<<" variable : ID"<<endl<<endl;
		outlog<<$1->getname()<<endl<<endl;
		$$ = new symbol_info($1->getname(),"var");
	}
	| ID LTHIRD expression RTHIRD
	{
		outlog<<"At line no: "<<lines<<" variable : ID LTHIRD expression RTHIRD"<<endl<<endl;
		outlog << $1->getname() << "[" << $3->getname() << "]" << endl << endl;
		$$ = new symbol_info($1->getname()+"["+$3->getname()+"]","var");
	}
	;

expression : logic_expression
	{
		outlog<<"At line no: "<<lines<<" expression : logic_expression"<<endl<<endl;
		outlog<<$1->getname()<<endl<<endl;
		$$ = new symbol_info($1->getname(),"expr");
	}
	| variable ASSIGNOP logic_expression
	{
		outlog<<"At line no: "<<lines<<" expression : variable ASSIGNOP logic_expression"<<endl<<endl;
		outlog << $1->getname() << "=" << $3->getname() << endl << endl;
		$$ = new symbol_info($1->getname()+"="+$3->getname(),"expr");
	}
	;

logic_expression : rel_expression
	{
		outlog<<"At line no: "<<lines<<" logic_expression : rel_expression"<<endl<<endl;
		outlog<<$1->getname()<<endl<<endl;
		$$ = new symbol_info($1->getname(),"logic");
	}
	| rel_expression LOGICOP rel_expression
	{
		outlog<<"At line no: "<<lines<<" logic_expression : rel_expression LOGICOP rel_expression"<<endl<<endl;
		outlog << $1->getname() << $2->getname() << $3->getname() << endl << endl;
		$$ = new symbol_info($1->getname()+$2->getname()+$3->getname(),"logic");
	}
	;

rel_expression : simple_expression
	{
		outlog<<"At line no: "<<lines<<" rel_expression : simple_expression"<<endl<<endl;
		outlog<<$1->getname()<<endl<<endl;
		$$ = new symbol_info($1->getname(),"rel");
	}
	| simple_expression RELOP simple_expression
	{
		outlog<<"At line no: "<<lines<<" rel_expression : simple_expression RELOP simple_expression"<<endl<<endl;
		outlog << $1->getname() << $2->getname() << $3->getname() << endl << endl;
		$$ = new symbol_info($1->getname()+$2->getname()+$3->getname(),"rel");
	}
	;

simple_expression : term
	{
		outlog<<"At line no: "<<lines<<" simple_expression : term"<<endl<<endl;
		outlog<<$1->getname()<<endl<<endl;
		$$ = new symbol_info($1->getname(),"simple");
	}
	| simple_expression ADDOP term
	{
		outlog<<"At line no: "<<lines<<" simple_expression : simple_expression ADDOP term"<<endl<<endl;
		outlog << $1->getname() << $2->getname() << $3->getname() << endl << endl;
		$$ = new symbol_info($1->getname()+$2->getname()+$3->getname(),"simple");
	}
	;

term : unary_expression
	{
		outlog<<"At line no: "<<lines<<" term : unary_expression"<<endl<<endl;
		outlog<<$1->getname()<<endl<<endl;
		$$ = new symbol_info($1->getname(),"term");
	}
	| term MULOP unary_expression
	{
		outlog<<"At line no: "<<lines<<" term : term MULOP unary_expression"<<endl<<endl;
		outlog << $1->getname() << $2->getname() << $3->getname() << endl << endl;
		$$ = new symbol_info($1->getname()+$2->getname()+$3->getname(),"term");
	}
	;

unary_expression : ADDOP unary_expression
	{
		outlog<<"At line no: "<<lines<<" unary_expression : ADDOP unary_expression"<<endl<<endl;
		outlog << $1->getname() << $2->getname() << endl << endl;
		$$ = new symbol_info($1->getname()+$2->getname(),"unary");
	}
	| NOT unary_expression
	{
		outlog<<"At line no: "<<lines<<" unary_expression : NOT unary_expression"<<endl<<endl;
		outlog << $1->getname() << $2->getname() << endl << endl;
		$$ = new symbol_info($1->getname()+$2->getname(),"unary");
	}
	| factor
	{
		outlog<<"At line no: "<<lines<<" unary_expression : factor"<<endl<<endl;
		outlog<<$1->getname()<<endl<<endl;
		$$ = new symbol_info($1->getname(),"unary");
	}
	;

factor : variable
	{
		outlog<<"At line no: "<<lines<<" factor : variable"<<endl<<endl;
		outlog<<$1->getname()<<endl<<endl;
		$$ = new symbol_info($1->getname(),"factor");
	}
	| ID LPAREN argument_list RPAREN
	{
		outlog<<"At line no: "<<lines<<" factor : ID LPAREN argument_list RPAREN"<<endl<<endl;
		outlog << $1->getname() << "(" << $3->getname() << ")" << endl << endl;
		$$ = new symbol_info($1->getname()+"("+$3->getname()+")","factor");
	}
	| LPAREN expression RPAREN
	{
		outlog<<"At line no: "<<lines<<" factor : LPAREN expression RPAREN"<<endl<<endl;
		outlog << "(" << $2->getname() << ")" << endl << endl;
		$$ = new symbol_info("("+$2->getname()+")","factor");
	}
	| CONST_INT
	{
		outlog<<"At line no: "<<lines<<" factor : CONST_INT"<<endl<<endl;
		outlog<<$1->getname()<<endl<<endl;
		$$ = new symbol_info($1->getname(),"factor");
	}
	| CONST_FLOAT
	{
		outlog<<"At line no: "<<lines<<" factor : CONST_FLOAT"<<endl<<endl;
		outlog<<$1->getname()<<endl<<endl;
		$$ = new symbol_info($1->getname(),"factor");
	}
	| variable INCOP
	{
		outlog<<"At line no: "<<lines<<" factor : variable INCOP"<<endl<<endl;
		outlog << $1->getname() << $2->getname() << endl << endl;
		$$ = new symbol_info($1->getname()+$2->getname(),"factor");
	}
	| variable DECOP
	{
		outlog<<"At line no: "<<lines<<" factor : variable DECOP"<<endl<<endl;
		outlog << $1->getname() << $2->getname() << endl << endl;
		$$ = new symbol_info($1->getname()+$2->getname(),"factor");
	}
	;

argument_list : arguments
	{
		outlog<<"At line no: "<<lines<<" argument_list : arguments"<<endl<<endl;
		outlog<<$1->getname()<<endl<<endl;
		$$ = new symbol_info($1->getname(),"args");
	}
	| /* empty */
	{
    outlog<<"At line no: "<<lines<<" argument_list : "<<endl<<endl;
    $$ = new symbol_info("","args");
	}
	;

arguments : arguments COMMA logic_expression
	{
		outlog<<"At line no: "<<lines<<" arguments : arguments COMMA logic_expression"<<endl<<endl;
		outlog << $1->getname() << "," << $3->getname() << endl << endl;
		$$ = new symbol_info($1->getname()+","+$3->getname(),"args");
	}
	| logic_expression
	{
		outlog<<"At line no: "<<lines<<" arguments : logic_expression"<<endl<<endl;
		outlog<<$1->getname()<<endl<<endl;
		$$ = new symbol_info($1->getname(),"args");
	}
	;


%%

void yyerror(char *s)
{
    cout << "Error: " << s << endl;
}

int main(int argc, char *argv[])
{
	if(argc != 2) 
	{
        // check if filename given
				return 0; 
	}
	yyin = fopen(argv[1], "r");
	outlog.open("22301439_log.txt", ios::trunc);
	
	if(yyin == NULL)
	{
		cout<<"Couldn't open file"<<endl;
		return 0;
	}
    
	yyparse();
	
	outlog << "Number of lines: " << lines << endl;
	
	outlog.close();
	
	fclose(yyin);
	
	return 0;
}
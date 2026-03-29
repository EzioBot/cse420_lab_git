%{

#include "symbol_table.h"
#include <cstdlib>
#include <fstream>
#include <sstream>

#define YYSTYPE symbol_info*

extern FILE *yyin;
int yyparse(void);
int yylex(void);
extern YYSTYPE yylval;

symbol_table* st    = NULL;
int bucket_size     = 20;
int lines           = 1;
int error_count     = 0;

ofstream outlog;
ofstream outerr;

string current_decl_type;
vector<pair<string,int>>    pending_declarations;
vector<pair<string,string>> current_param_list;


void semantic_error(const string& msg)
{
    outerr << "At line no: " << lines << " " << msg << endl << endl;
    outlog << "At line no: " << lines << " " << msg << endl << endl;
    error_count++;
}

bool types_compatible(const string& lhs, const string& rhs)
{
    if(lhs == "error" || rhs == "error") return true; // already errored
    if(lhs == rhs) return true;
    if(lhs == "float" && rhs == "int") return true;   // int->float is ok
    return false;
}

string resolve_arith_type(const string& t1, const string& t2)
{
    if(t1 == "error" || t2 == "error") return "error";
    if(t1 == "float" || t2 == "float") return "float";
    return "int";
}

void yyerror(char *s)
{
    outlog << "At line " << lines << " " << s << endl << endl;
}

%}

%token IF ELSE FOR WHILE DO BREAK INT CHAR FLOAT DOUBLE VOID RETURN SWITCH CASE DEFAULT CONTINUE PRINTLN ADDOP MULOP INCOP DECOP RELOP ASSIGNOP LOGICOP NOT LPAREN RPAREN LCURL RCURL LTHIRD RTHIRD COMMA SEMICOLON CONST_INT CONST_FLOAT ID

%nonassoc LOWER_THAN_ELSE
%nonassoc ELSE

%%

start : program
    {
        outlog << "At line no: " << lines << " start : program " << endl << endl;
        outlog << "Symbol Table" << endl << endl;
        st->print_all_scopes(outlog);
    }
    ;

program : program unit
    {
        outlog << "At line no: " << lines << " program : program unit " << endl << endl;
        outlog << $1->get_name()+"\n"+$2->get_name() << endl << endl;
        $$ = new symbol_info($1->get_name()+"\n"+$2->get_name(), "program");
    }
    | unit
    {
        outlog << "At line no: " << lines << " program : unit " << endl << endl;
        outlog << $1->get_name() << endl << endl;
        $$ = new symbol_info($1->get_name(), "program");
    }
    ;

unit : var_declaration
     {
        outlog << "At line no: " << lines << " unit : var_declaration " << endl << endl;
        outlog << $1->get_name() << endl << endl;
        $$ = new symbol_info($1->get_name(), "unit");
     }
     | func_definition
     {
        outlog << "At line no: " << lines << " unit : func_definition " << endl << endl;
        outlog << $1->get_name() << endl << endl;
        $$ = new symbol_info($1->get_name(), "unit");
     }
     ;

func_definition : type_specifier ID LPAREN parameter_list RPAREN
        {
            symbol_info* existing = st->lookup_in_current_scope($2->get_name());
            if(existing != NULL) {
                semantic_error("Multiple declaration of function " + $2->get_name());
            } else {
                symbol_info* func_sym = new symbol_info($2->get_name(), $1->get_name());
                func_sym->set_symbol_category("function");
                func_sym->set_data_type($1->get_name());
                func_sym->set_param_count(current_param_list.size());
                string param_det;
                for(int i = 0; i < (int)current_param_list.size(); i++) {
                    func_sym->add_param_type(current_param_list[i].first);
                    if(i > 0) param_det += ", ";
                    param_det += current_param_list[i].first;
                    if(current_param_list[i].second != "_dummy" && current_param_list[i].second != "")
                        param_det += " " + current_param_list[i].second;
                }
                func_sym->set_param_details(param_det);
                st->insert(func_sym);
            }

            
            st->enter_scope();
            outlog << "New ScopeTable with ID " << st->get_current_scope_id() << " created" << endl << endl;

            
            for(int i = 0; i < (int)current_param_list.size(); i++) {
                string pname = current_param_list[i].second;
                if(pname != "_dummy" && pname != "") {
                    symbol_info* existing_p = st->lookup_in_current_scope(pname);
                    if(existing_p != NULL) {
                        semantic_error("Multiple declaration of variable " + pname + " in parameter of " + $2->get_name());
                    } else {
                        symbol_info* p_sym = new symbol_info(pname, "");
                        p_sym->set_symbol_category("variable");
                        p_sym->set_data_type(current_param_list[i].first);
                        st->insert(p_sym);
                    }
                }
            }
        }
        compound_statement
        {
            outlog << "At line no: " << lines << " func_definition : type_specifier ID LPAREN parameter_list RPAREN compound_statement " << endl << endl;
            outlog << $1->get_name() << " " << $2->get_name() << "(" + $4->get_name() + ")\n" << $7->get_name() << endl << endl;

            st->print_all_scopes(outlog);
            outlog << "Scopetable with ID " << st->get_current_scope_id() << " removed" << endl << endl;
            st->exit_scope();

            $$ = new symbol_info($1->get_name()+" "+$2->get_name()+"("+$4->get_name()+")\n"+$7->get_name(), "func_def");
        }
        | type_specifier ID LPAREN RPAREN
        {
            current_param_list.clear();
            symbol_info* existing = st->lookup_in_current_scope($2->get_name());
            if(existing != NULL) {
                semantic_error("Multiple declaration of function " + $2->get_name());
            } else {
                symbol_info* func_sym = new symbol_info($2->get_name(), $1->get_name());
                func_sym->set_symbol_category("function");
                func_sym->set_data_type($1->get_name());
                func_sym->set_param_count(0);
                func_sym->set_param_details("");
                st->insert(func_sym);
            }

            st->enter_scope();
            outlog << "New ScopeTable with ID " << st->get_current_scope_id() << " created" << endl << endl;
        }
        compound_statement
        {
            outlog << "At line no: " << lines << " func_definition : type_specifier ID LPAREN RPAREN compound_statement " << endl << endl;
            outlog << $1->get_name() << " " << $2->get_name() << "()\n" << $6->get_name() << endl << endl;

            st->print_all_scopes(outlog);
            outlog << "Scopetable with ID " << st->get_current_scope_id() << " removed" << endl << endl;
            st->exit_scope();

            $$ = new symbol_info($1->get_name()+" "+$2->get_name()+"()\n"+$6->get_name(), "func_def");
        }
        ;


parameter_list : parameter_list COMMA type_specifier ID
        {
            outlog << "At line no: " << lines << " parameter_list : parameter_list COMMA type_specifier ID " << endl << endl;
            outlog << $1->get_name() << "," << $3->get_name() << " " << $4->get_name() << endl << endl;
            current_param_list.push_back(make_pair($3->get_name(), $4->get_name()));
            $$ = new symbol_info($1->get_name()+","+$3->get_name()+" "+$4->get_name(), "param_list");
        }
        | parameter_list COMMA type_specifier
        {
            outlog << "At line no: " << lines << " parameter_list : parameter_list COMMA type_specifier " << endl << endl;
            outlog << $1->get_name() << "," << $3->get_name() << endl << endl;
            current_param_list.push_back(make_pair($3->get_name(), "_dummy"));
            $$ = new symbol_info($1->get_name()+","+$3->get_name(), "param_list");
        }
        | type_specifier ID
        {
            outlog << "At line no: " << lines << " parameter_list : type_specifier ID " << endl << endl;
            outlog << $1->get_name() << " " << $2->get_name() << endl << endl;
            current_param_list.clear();
            current_param_list.push_back(make_pair($1->get_name(), $2->get_name()));
            $$ = new symbol_info($1->get_name()+" "+$2->get_name(), "param_list");
        }
        | type_specifier
        {
            outlog << "At line no: " << lines << " parameter_list : type_specifier " << endl << endl;
            outlog << $1->get_name() << endl << endl;
            current_param_list.clear();
            current_param_list.push_back(make_pair($1->get_name(), "_dummy"));
            $$ = new symbol_info($1->get_name(), "param_list");
        }
        ;


compound_statement
    : LCURL statements RCURL
      {
        outlog << "At line no: " << lines << " compound_statement : LCURL statements RCURL " << endl << endl;
        outlog << "{\n" + $2->get_name() + "\n}" << endl << endl;
        $$ = new symbol_info("{\n"+$2->get_name()+"\n}", "comp_stmnt");
      }
    | LCURL RCURL
      {
        outlog << "At line no: " << lines << " compound_statement : LCURL RCURL " << endl << endl;
        outlog << "{\n}" << endl << endl;
        $$ = new symbol_info("{\n}", "comp_stmnt");
      }
    ;


scope_block
    : LCURL
      {
        st->enter_scope();
        outlog << "New ScopeTable with ID " << st->get_current_scope_id() << " created" << endl << endl;
      }
      statements RCURL
      {
        outlog << "At line no: " << lines << " compound_statement : LCURL statements RCURL " << endl << endl;
        outlog << "{\n" + $3->get_name() + "\n}" << endl << endl;
        st->print_all_scopes(outlog);
        outlog << "Scopetable with ID " << st->get_current_scope_id() << " removed" << endl << endl;
        st->exit_scope();
        $$ = new symbol_info("{\n"+$3->get_name()+"\n}", "comp_stmnt");
      }
    | LCURL
      {
        st->enter_scope();
        outlog << "New ScopeTable with ID " << st->get_current_scope_id() << " created" << endl << endl;
      }
      RCURL
      {
        outlog << "At line no: " << lines << " compound_statement : LCURL RCURL " << endl << endl;
        outlog << "{\n}" << endl << endl;
        st->print_all_scopes(outlog);
        outlog << "Scopetable with ID " << st->get_current_scope_id() << " removed" << endl << endl;
        st->exit_scope();
        $$ = new symbol_info("{\n}", "comp_stmnt");
      }
    ;


var_declaration : type_specifier declaration_list SEMICOLON
         {
            outlog << "At line no: " << lines << " var_declaration : type_specifier declaration_list SEMICOLON " << endl << endl;
            outlog << $1->get_name() << " " << $2->get_name() << ";" << endl << endl;

            
            if(current_decl_type == "void") {
                semantic_error("variable type can not be void ");
                $$ = new symbol_info($1->get_name()+" "+$2->get_name()+";", "var_dec");
            } else {

            for(int i = 0; i < (int)pending_declarations.size(); i++) {
                string n      = pending_declarations[i].first;
                int    arr_sz = pending_declarations[i].second;

                symbol_info* existing = st->lookup_in_current_scope(n);
                if(existing != NULL) {
                    semantic_error("Multiple declaration of variable " + n);
                    continue;
                }

                symbol_info* sym = new symbol_info(n, "");
                sym->set_data_type(current_decl_type);
                if(arr_sz > 0) {
                    sym->set_symbol_category("array");
                    sym->set_array_size(arr_sz);
                } else {
                    sym->set_symbol_category("variable");
                }
                st->insert(sym);
            }

            $$ = new symbol_info($1->get_name()+" "+$2->get_name()+";", "var_dec");
            }
         }
         ;


type_specifier : INT
        {
            outlog << "At line no: " << lines << " type_specifier : INT " << endl << endl;
            outlog << "int" << endl << endl;
            current_decl_type = "int";
            pending_declarations.clear();
            $$ = new symbol_info("int", "type");
        }
        | FLOAT
        {
            outlog << "At line no: " << lines << " type_specifier : FLOAT " << endl << endl;
            outlog << "float" << endl << endl;
            current_decl_type = "float";
            pending_declarations.clear();
            $$ = new symbol_info("float", "type");
        }
        | VOID
        {
            outlog << "At line no: " << lines << " type_specifier : VOID " << endl << endl;
            outlog << "void" << endl << endl;
            current_decl_type = "void";
            pending_declarations.clear();
            $$ = new symbol_info("void", "type");
        }
        ;


declaration_list : declaration_list COMMA ID
          {
            outlog << "At line no: " << lines << " declaration_list : declaration_list COMMA ID " << endl << endl;
            outlog << $1->get_name() + "," << $3->get_name() << endl << endl;
            pending_declarations.push_back(make_pair($3->get_name(), 0));
            $$ = new symbol_info($1->get_name()+","+$3->get_name(), "decl_list");
          }
          | declaration_list COMMA ID LTHIRD CONST_INT RTHIRD
          {
            outlog << "At line no: " << lines << " declaration_list : declaration_list COMMA ID LTHIRD CONST_INT RTHIRD " << endl << endl;
            outlog << $1->get_name() + "," << $3->get_name() << "[" << $5->get_name() << "]" << endl << endl;
            int sz = atoi($5->get_name().c_str());
            pending_declarations.push_back(make_pair($3->get_name(), sz));
            $$ = new symbol_info($1->get_name()+","+$3->get_name()+"["+$5->get_name()+"]", "decl_list");
          }
          | ID
          {
            outlog << "At line no: " << lines << " declaration_list : ID " << endl << endl;
            outlog << $1->get_name() << endl << endl;
            pending_declarations.push_back(make_pair($1->get_name(), 0));
            $$ = new symbol_info($1->get_name(), "decl_list");
          }
          | ID LTHIRD CONST_INT RTHIRD
          {
            outlog << "At line no: " << lines << " declaration_list : ID LTHIRD CONST_INT RTHIRD " << endl << endl;
            outlog << $1->get_name() << "[" << $3->get_name() << "]" << endl << endl;
            int sz = atoi($3->get_name().c_str());
            pending_declarations.push_back(make_pair($1->get_name(), sz));
            $$ = new symbol_info($1->get_name()+"["+$3->get_name()+"]", "decl_list");
          }
          ;


statements : statement
       {
            outlog << "At line no: " << lines << " statements : statement " << endl << endl;
            outlog << $1->get_name() << endl << endl;
            $$ = new symbol_info($1->get_name(), "stmnts");
       }
       | statements statement
       {
            outlog << "At line no: " << lines << " statements : statements statement " << endl << endl;
            outlog << $1->get_name() << "\n" << $2->get_name() << endl << endl;
            $$ = new symbol_info($1->get_name()+"\n"+$2->get_name(), "stmnts");
       }
       ;

statement : var_declaration
      {
            outlog << "At line no: " << lines << " statement : var_declaration " << endl << endl;
            outlog << $1->get_name() << endl << endl;
            $$ = new symbol_info($1->get_name(), "stmnt");
      }
      | expression_statement
      {
            outlog << "At line no: " << lines << " statement : expression_statement " << endl << endl;
            outlog << $1->get_name() << endl << endl;
            $$ = new symbol_info($1->get_name(), "stmnt");
      }
      | scope_block
      {
            outlog << "At line no: " << lines << " statement : compound_statement " << endl << endl;
            outlog << $1->get_name() << endl << endl;
            $$ = new symbol_info($1->get_name(), "stmnt");
      }
      | FOR LPAREN expression_statement expression_statement expression RPAREN statement
      {
            outlog << "At line no: " << lines << " statement : FOR LPAREN expression_statement expression_statement expression RPAREN statement " << endl << endl;
            outlog << "for(" << $3->get_name() << $4->get_name() << $5->get_name() << ")\n" << $7->get_name() << endl << endl;
            $$ = new symbol_info("for("+$3->get_name()+$4->get_name()+$5->get_name()+")\n"+$7->get_name(), "stmnt");
      }
      | IF LPAREN expression RPAREN statement %prec LOWER_THAN_ELSE
      {
            outlog << "At line no: " << lines << " statement : IF LPAREN expression RPAREN statement " << endl << endl;
            outlog << "if(" << $3->get_name() << ")\n" << $5->get_name() << endl << endl;
            $$ = new symbol_info("if("+$3->get_name()+")\n"+$5->get_name(), "stmnt");
      }
      | IF LPAREN expression RPAREN statement ELSE statement
      {
            outlog << "At line no: " << lines << " statement : IF LPAREN expression RPAREN statement ELSE statement " << endl << endl;
            outlog << "if(" << $3->get_name() << ")\n" << $5->get_name() << "\nelse\n" << $7->get_name() << endl << endl;
            $$ = new symbol_info("if("+$3->get_name()+")\n"+$5->get_name()+"\nelse\n"+$7->get_name(), "stmnt");
      }
      | WHILE LPAREN expression RPAREN statement
      {
            outlog << "At line no: " << lines << " statement : WHILE LPAREN expression RPAREN statement " << endl << endl;
            outlog << "while(" << $3->get_name() << ")\n" << $5->get_name() << endl << endl;
            $$ = new symbol_info("while("+$3->get_name()+")\n"+$5->get_name(), "stmnt");
      }
      | PRINTLN LPAREN ID RPAREN SEMICOLON
      {
            outlog << "At line no: " << lines << " statement : PRINTLN LPAREN ID RPAREN SEMICOLON " << endl << endl;
            outlog << "printf(" << $3->get_name() << ");" << endl << endl;

          
            symbol_info* sym = st->lookup($3->get_name());
            if(sym == NULL) {
                semantic_error("Undeclared variable " + $3->get_name());
            }

            $$ = new symbol_info("printf("+$3->get_name()+");", "stmnt");
      }
      | RETURN expression SEMICOLON
      {
            outlog << "At line no: " << lines << " statement : RETURN expression SEMICOLON " << endl << endl;
            outlog << "return " << $2->get_name() << ";" << endl << endl;
            $$ = new symbol_info("return "+$2->get_name()+";", "stmnt");
      }
      ;

expression_statement : SEMICOLON
            {
                outlog << "At line no: " << lines << " expression_statement : SEMICOLON " << endl << endl;
                outlog << ";" << endl << endl;
                $$ = new symbol_info(";", "expr_stmt");
            }
            | expression SEMICOLON
            {
                outlog << "At line no: " << lines << " expression_statement : expression SEMICOLON " << endl << endl;
                outlog << $1->get_name() << ";" << endl << endl;
                $$ = new symbol_info($1->get_name()+";", "expr_stmt");
            }
            ;


variable : ID
      {
        outlog << "At line no: " << lines << " variable : ID " << endl << endl;
        outlog << $1->get_name() << endl << endl;

        symbol_info* sym = st->lookup($1->get_name());
        string res_type = "error";

        if(sym == NULL) {
            semantic_error("Undeclared variable " + $1->get_name());
        } else {
            string cat = sym->get_symbol_category();
           
            if(cat == "array") {
                semantic_error("variable is of array type : " + $1->get_name());
            } else if(cat == "function") {
                res_type = sym->get_data_type(); // will be caught at call site
            } else {
                res_type = sym->get_data_type();
            }
        }

        $$ = new symbol_info($1->get_name(), res_type);
      }
      | ID LTHIRD expression RTHIRD
      {
        outlog << "At line no: " << lines << " variable : ID LTHIRD expression RTHIRD " << endl << endl;
        outlog << $1->get_name() << "[" << $3->get_name() << "]" << endl << endl;

        symbol_info* sym = st->lookup($1->get_name());
        string res_type = "error";

        if(sym == NULL) {
            semantic_error("Undeclared variable " + $1->get_name());
        } else {
            string cat = sym->get_symbol_category();
           
            if(cat != "array") {
                semantic_error("variable is not of array type : " + $1->get_name());
            } else {
                res_type = sym->get_data_type();
                
                if($3->get_type() != "int" && $3->get_type() != "error") {
                    semantic_error("array index is not of integer type : " + $1->get_name());
                }
            }
        }

        $$ = new symbol_info($1->get_name()+"["+$3->get_name()+"]", res_type);
      }
      ;


expression : logic_expression
       {
            outlog << "At line no: " << lines << " expression : logic_expression " << endl << endl;
            outlog << $1->get_name() << endl << endl;
            $$ = new symbol_info($1->get_name(), $1->get_type());
       }
       | variable ASSIGNOP logic_expression
       {
            outlog << "At line no: " << lines << " expression : variable ASSIGNOP logic_expression " << endl << endl;
            outlog << $1->get_name() << "=" << $3->get_name() << endl << endl;

            string ltype = $1->get_type();
            string rtype = $3->get_type();
            string res_type = ltype;

            if(ltype != "error" && rtype != "error") {
                if(ltype == "int" && rtype == "float") {
                   
                    semantic_error("Warning: Assignment of float value into variable of integer type ");
                } else if(!types_compatible(ltype, rtype)) {
                    semantic_error("Type mismatch in assignment: " + ltype + " = " + rtype);
                }
            }

            $$ = new symbol_info($1->get_name()+"="+$3->get_name(), res_type);
       }
       ;


logic_expression : rel_expression
         {
            outlog << "At line no: " << lines << " logic_expression : rel_expression " << endl << endl;
            outlog << $1->get_name() << endl << endl;
            $$ = new symbol_info($1->get_name(), $1->get_type());
         }
         | rel_expression LOGICOP rel_expression
         {
            outlog << "At line no: " << lines << " logic_expression : rel_expression LOGICOP rel_expression " << endl << endl;
            outlog << $1->get_name() << $2->get_name() << $3->get_name() << endl << endl;
           
            $$ = new symbol_info($1->get_name()+$2->get_name()+$3->get_name(), "int");
         }
         ;

rel_expression : simple_expression
        {
            outlog << "At line no: " << lines << " rel_expression : simple_expression " << endl << endl;
            outlog << $1->get_name() << endl << endl;
            $$ = new symbol_info($1->get_name(), $1->get_type());
        }
        | simple_expression RELOP simple_expression
        {
            outlog << "At line no: " << lines << " rel_expression : simple_expression RELOP simple_expression " << endl << endl;
            outlog << $1->get_name() << $2->get_name() << $3->get_name() << endl << endl;
            
            $$ = new symbol_info($1->get_name()+$2->get_name()+$3->get_name(), "int");
        }
        ;

simple_expression : term
          {
            outlog << "At line no: " << lines << " simple_expression : term " << endl << endl;
            outlog << $1->get_name() << endl << endl;
            $$ = new symbol_info($1->get_name(), $1->get_type());
          }
          | simple_expression ADDOP term
          {
            outlog << "At line no: " << lines << " simple_expression : simple_expression ADDOP term " << endl << endl;
            outlog << $1->get_name() << $2->get_name() << $3->get_name() << endl << endl;
            string res_type = resolve_arith_type($1->get_type(), $3->get_type());
            $$ = new symbol_info($1->get_name()+$2->get_name()+$3->get_name(), res_type);
          }
          ;


term : unary_expression
     {
        outlog << "At line no: " << lines << " term : unary_expression " << endl << endl;
        outlog << $1->get_name() << endl << endl;
        $$ = new symbol_info($1->get_name(), $1->get_type());
     }
     | term MULOP unary_expression
     {
        outlog << "At line no: " << lines << " term : term MULOP unary_expression " << endl << endl;
        outlog << $1->get_name() << $2->get_name() << $3->get_name() << endl << endl;

        string op       = $2->get_name();
        string ltype    = $1->get_type();
        string rtype    = $3->get_type();
        string res_type = resolve_arith_type(ltype, rtype);

        if(op == "%") {
           
            if(ltype != "int" && ltype != "error") {
                semantic_error("Modulus operator on non integer type ");
            }
            if(rtype != "int" && rtype != "error") {
                semantic_error("Modulus operator on non integer type ");
            }
            res_type = "int";
        }

      
        if(op == "%" && $3->get_name() == "0") {
            semantic_error("Modulus by 0 ");
        } else if(op == "/" && $3->get_name() == "0") {
            semantic_error("Division by zero ");
        }

        $$ = new symbol_info($1->get_name()+$2->get_name()+$3->get_name(), res_type);
     }
     ;


unary_expression : ADDOP unary_expression
         {
            outlog << "At line no: " << lines << " unary_expression : ADDOP unary_expression " << endl << endl;
            outlog << $1->get_name() << $2->get_name() << endl << endl;
            $$ = new symbol_info($1->get_name()+$2->get_name(), $2->get_type());
         }
         | NOT unary_expression
         {
            outlog << "At line no: " << lines << " unary_expression : NOT unary_expression " << endl << endl;
            outlog << "!" << $2->get_name() << endl << endl;
            $$ = new symbol_info("!"+$2->get_name(), "int");
         }
         | factor
         {
            outlog << "At line no: " << lines << " unary_expression : factor " << endl << endl;
            outlog << $1->get_name() << endl << endl;
            $$ = new symbol_info($1->get_name(), $1->get_type());
         }
         ;


factor : variable
    {
        outlog << "At line no: " << lines << " factor : variable " << endl << endl;
        outlog << $1->get_name() << endl << endl;
        $$ = new symbol_info($1->get_name(), $1->get_type());
    }
    | ID LPAREN argument_list RPAREN
    {
        outlog << "At line no: " << lines << " factor : ID LPAREN argument_list RPAREN " << endl << endl;
        outlog << $1->get_name() << "(" << $3->get_name() << ")" << endl << endl;

        string res_type = "error";
        symbol_info* func_sym = st->lookup($1->get_name());

        if(func_sym == NULL) {
            semantic_error("Undeclared function: " + $1->get_name());
        } else if(func_sym->get_symbol_category() != "function") {
            semantic_error($1->get_name() + " is not a function");
        } else {
            
            res_type = func_sym->get_data_type();
            if(res_type == "void") {
                semantic_error("operation on void type ");
                res_type = "error";
            }

            
            vector<string> def_types = func_sym->get_param_types();
            int def_cnt = func_sym->get_param_count();

            
            string arg_types_str = $3->get_type(); // e.g. "int,float"
            vector<string> call_types;
            if(arg_types_str != "") {
                stringstream ss(arg_types_str);
                string tok;
                while(getline(ss, tok, ',')) call_types.push_back(tok);
            }

            int call_cnt = (int)call_types.size();
            if(call_cnt != def_cnt) {
                semantic_error("Inconsistencies in number of arguments in function call: " + $1->get_name());
            } else {
                for(int i = 0; i < def_cnt; i++) {
                    if(call_types[i] == "error") continue;
                    if(!types_compatible(def_types[i], call_types[i])) {
                        semantic_error("argument " + to_string(i+1) +
                            " type mismatch in function call: " + $1->get_name());
                    }
                }
            }
        }

        $$ = new symbol_info($1->get_name()+"("+$3->get_name()+")", res_type);
    }
    | LPAREN expression RPAREN
    {
        outlog << "At line no: " << lines << " factor : LPAREN expression RPAREN " << endl << endl;
        outlog << "(" << $2->get_name() << ")" << endl << endl;
        $$ = new symbol_info("("+$2->get_name()+")", $2->get_type());
    }
    | CONST_INT
    {
        outlog << "At line no: " << lines << " factor : CONST_INT " << endl << endl;
        outlog << $1->get_name() << endl << endl;
        $$ = new symbol_info($1->get_name(), "int");
    }
    | CONST_FLOAT
    {
        outlog << "At line no: " << lines << " factor : CONST_FLOAT " << endl << endl;
        outlog << $1->get_name() << endl << endl;
        $$ = new symbol_info($1->get_name(), "float");
    }
    | variable INCOP
    {
        outlog << "At line no: " << lines << " factor : variable INCOP " << endl << endl;
        outlog << $1->get_name() << "++" << endl << endl;
        $$ = new symbol_info($1->get_name()+"++", $1->get_type());
    }
    | variable DECOP
    {
        outlog << "At line no: " << lines << " factor : variable DECOP " << endl << endl;
        outlog << $1->get_name() << "--" << endl << endl;
        $$ = new symbol_info($1->get_name()+"--", $1->get_type());
    }
    ;


argument_list : arguments
              {
                outlog << "At line no: " << lines << " argument_list : arguments " << endl << endl;
                outlog << $1->get_name() << endl << endl;
                $$ = new symbol_info($1->get_name(), $1->get_type());
              }
              |
              {
                outlog << "At line no: " << lines << " argument_list :  " << endl << endl;
                outlog << "" << endl << endl;
                $$ = new symbol_info("", ""); // empty arg list
              }
              ;

arguments : arguments COMMA logic_expression
          {
            outlog << "At line no: " << lines << " arguments : arguments COMMA logic_expression " << endl << endl;
            outlog << $1->get_name() << "," << $3->get_name() << endl << endl;
            
            string combined_types = $1->get_type() + "," + $3->get_type();
            $$ = new symbol_info($1->get_name()+","+$3->get_name(), combined_types);
          }
          | logic_expression
          {
            outlog << "At line no: " << lines << " arguments : logic_expression " << endl << endl;
            outlog << $1->get_name() << endl << endl;
            $$ = new symbol_info($1->get_name(), $1->get_type());
          }
          ;

%%

int main(int argc, char *argv[])
{
    if(argc != 2) {
        cout << "Please input file name" << endl;
        return 0;
    }

    yyin = fopen(argv[1], "r");
    if(yyin == NULL) {
        cout << "Couldn't open file" << endl;
        return 0;
    }

    outlog.open("22301439_log.txt", ios::trunc);
    outerr.open("22301439_error.txt", ios::trunc);

    st = new symbol_table(bucket_size);
    outlog << "New ScopeTable with ID " << st->get_current_scope_id() << " created" << endl << endl;

    yyparse();

    outlog << endl << "Total lines: " << lines << endl;
    outlog << "Total errors: " << error_count << endl;

    outerr << "Total errors: " << error_count << endl;

    outlog.close();
    outerr.close();
    fclose(yyin);
    delete st;

    return 0;
}

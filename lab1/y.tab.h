/* A Bison parser, made by GNU Bison 2.7.  */

/* Bison interface for Yacc-like parsers in C
   
      Copyright (C) 1984, 1989-1990, 2000-2012 Free Software Foundation, Inc.
   
   This program is free software: you can redistribute it and/or modify
   it under the terms of the GNU General Public License as published by
   the Free Software Foundation, either version 3 of the License, or
   (at your option) any later version.
   
   This program is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
   GNU General Public License for more details.
   
   You should have received a copy of the GNU General Public License
   along with this program.  If not, see <http://www.gnu.org/licenses/>.  */

/* As a special exception, you may create a larger work that contains
   part or all of the Bison parser skeleton and distribute that work
   under terms of your choice, so long as that work isn't itself a
   parser generator using the skeleton or a modified version thereof
   as a parser skeleton.  Alternatively, if you modify or redistribute
   the parser skeleton itself, you may (at your option) remove this
   special exception, which will cause the skeleton and the resulting
   Bison output files to be licensed under the GNU General Public
   License without this special exception.
   
   This special exception was added by the Free Software Foundation in
   version 2.2 of Bison.  */

#ifndef YY_YY_Y_TAB_H_INCLUDED
# define YY_YY_Y_TAB_H_INCLUDED
/* Enabling traces.  */
#ifndef YYDEBUG
# define YYDEBUG 1
#endif
#if YYDEBUG
extern int yydebug;
#endif

/* Tokens.  */
#ifndef YYTOKENTYPE
# define YYTOKENTYPE
   /* Put the tokens into the symbol table, so that GDB and other debuggers
      know about them.  */
   enum yytokentype {
     IF = 258,
     ELSE = 259,
     FOR = 260,
     WHILE = 261,
     DO = 262,
     INT = 263,
     FLOAT = 264,
     CHAR = 265,
     DOUBLE = 266,
     VOID = 267,
     RETURN = 268,
     BREAK = 269,
     CONTINUE = 270,
     SWITCH = 271,
     CASE = 272,
     DEFAULT = 273,
     GOTO = 274,
     PRINTF = 275,
     ID = 276,
     CONST_INT = 277,
     CONST_FLOAT = 278,
     ADDOP = 279,
     MULOP = 280,
     INCOP = 281,
     RELOP = 282,
     LOGICOP = 283,
     NOT = 284,
     ASSIGNOP = 285,
     LPAREN = 286,
     RPAREN = 287,
     LCURL = 288,
     RCURL = 289,
     LTHIRD = 290,
     RTHIRD = 291,
     COMMA = 292,
     COLON = 293,
     SEMICOLON = 294
   };
#endif
/* Tokens.  */
#define IF 258
#define ELSE 259
#define FOR 260
#define WHILE 261
#define DO 262
#define INT 263
#define FLOAT 264
#define CHAR 265
#define DOUBLE 266
#define VOID 267
#define RETURN 268
#define BREAK 269
#define CONTINUE 270
#define SWITCH 271
#define CASE 272
#define DEFAULT 273
#define GOTO 274
#define PRINTF 275
#define ID 276
#define CONST_INT 277
#define CONST_FLOAT 278
#define ADDOP 279
#define MULOP 280
#define INCOP 281
#define RELOP 282
#define LOGICOP 283
#define NOT 284
#define ASSIGNOP 285
#define LPAREN 286
#define RPAREN 287
#define LCURL 288
#define RCURL 289
#define LTHIRD 290
#define RTHIRD 291
#define COMMA 292
#define COLON 293
#define SEMICOLON 294



#if ! defined YYSTYPE && ! defined YYSTYPE_IS_DECLARED
typedef int YYSTYPE;
# define YYSTYPE_IS_TRIVIAL 1
# define yystype YYSTYPE /* obsolescent; will be withdrawn */
# define YYSTYPE_IS_DECLARED 1
#endif

extern YYSTYPE yylval;

#ifdef YYPARSE_PARAM
#if defined __STDC__ || defined __cplusplus
int yyparse (void *YYPARSE_PARAM);
#else
int yyparse ();
#endif
#else /* ! YYPARSE_PARAM */
#if defined __STDC__ || defined __cplusplus
int yyparse (void);
#else
int yyparse ();
#endif
#endif /* ! YYPARSE_PARAM */

#endif /* !YY_YY_Y_TAB_H_INCLUDED  */

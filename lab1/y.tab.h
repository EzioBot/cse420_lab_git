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
     DECOP = 265,
     CHAR = 266,
     DOUBLE = 267,
     VOID = 268,
     RETURN = 269,
     BREAK = 270,
     CONTINUE = 271,
     SWITCH = 272,
     CASE = 273,
     DEFAULT = 274,
     GOTO = 275,
     PRINTF = 276,
     ID = 277,
     CONST_INT = 278,
     CONST_FLOAT = 279,
     ADDOP = 280,
     MULOP = 281,
     INCOP = 282,
     RELOP = 283,
     LOGICOP = 284,
     NOT = 285,
     ASSIGNOP = 286,
     LPAREN = 287,
     RPAREN = 288,
     LCURL = 289,
     RCURL = 290,
     LTHIRD = 291,
     RTHIRD = 292,
     COMMA = 293,
     COLON = 294,
     SEMICOLON = 295
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
#define DECOP 265
#define CHAR 266
#define DOUBLE 267
#define VOID 268
#define RETURN 269
#define BREAK 270
#define CONTINUE 271
#define SWITCH 272
#define CASE 273
#define DEFAULT 274
#define GOTO 275
#define PRINTF 276
#define ID 277
#define CONST_INT 278
#define CONST_FLOAT 279
#define ADDOP 280
#define MULOP 281
#define INCOP 282
#define RELOP 283
#define LOGICOP 284
#define NOT 285
#define ASSIGNOP 286
#define LPAREN 287
#define RPAREN 288
#define LCURL 289
#define RCURL 290
#define LTHIRD 291
#define RTHIRD 292
#define COMMA 293
#define COLON 294
#define SEMICOLON 295



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

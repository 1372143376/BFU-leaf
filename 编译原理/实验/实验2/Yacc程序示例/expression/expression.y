%{
#include <ctype.h>
#include <stdio.h>
#define YYSTYPE double 	/*��������ջΪdouble����*/
%}
%token NUMBER	/*�ķ���ʼ������ʡ��*/
%left '+', '-'	/*���ȼ����*/
%left '*', '/'
%right UMINUS	/*���������������һԪ������ͬ�����ȼ�*/
%%
lines	: lines expr '\n'	{ printf("%g\n", $2); }
 	| lines '\n'
 	| /*�մ� */
	| error '\n'	{ yyerror("reenter last line:"); yyerrok(); }
	;
expr	: expr '+' expr	{ $$ = $1 + $3; }
	| expr '-' expr	{ $$ = $1 - $3; }
	| expr '*' expr	{ $$ = $1 * $3; }
	| expr '/' expr	{ $$ = $1 / $3; }
	| '(' expr ')'	{ $$ = $2; }
	| '(' expr error	{ $$ = $2; yyerror("missing ')'"); yyerrok(); }
	| '-' expr %prec UMINUS	{ $$ = -$2; }
	| NUMBER
	;
  %%
  int yylex(void)
  {
  int c;
   while ((c = getchar()) == ' ');
  if (c == '.' || isdigit(c)) {
	ungetc(c, stdin);
	scanf("%lf", &yylval);
	return NUMBER;
  }
  return c;
 }    

/* ��׺���ż����� */

%{
        #define YYSTYPE double          /*��������ֵ��C��������*/
        #include <math.h>
        #include <stdio.h>
        #include <ctype.h>
        int yylex (void);
        void yyerror (char const *);
%}

%token NUM      /*�Ǻ�����,����NUMһ��*/
%left '-' '+'   /*����+,-����Ϊ����*/

/* ��ν������ָ1+2+3������ʽ
   �����������: (1+2)+3
   �������Ե��ҽ��x=y=z����ô��:x=(y=z)
 */
%left '*' '/'   /*Խ�������ȼ�Խ��*/
%left NEG       /*���ڸ����������ͬ,��������һ������ע��,������˵��*/
%right '^'      /*������Ϊ�ҽ��*/

%%
input:          /*��������ǿմ�,��ʹ������һ��ʼ�ͽ��յ�EOF�����ڷ�������*/
        | input line    /*Ҳ������һ��*/
;

line:     '\n'  /*һ�п��Լ򵥵�һ���س�,��ʱ���Դ���*/
        | exp '\n'  { printf ("\t%.10g\n", $1); }
                /*����Ǳ��ʽ,���ӡexp������ֵ,�����������ֵ��������*/
;

exp:      NUM                { $$ = $1;         }
                /*���ʽ���Խ�Ϊһ������,��ʱ��ֵ���������ֵΪ������*/
        | exp '+' exp        { $$ = $1 + $3;    }
                /*���ʽ����Ϊһ�����ʽ������һ��,��Ӧ������ֵҲ���,��ͬ*/
        | exp '-' exp        { $$ = $1 - $3;    }
        | exp '*' exp        { $$ = $1 * $3;    }
        | exp '/' exp        { $$ = $1 / $3;    }
        | '-' exp  %prec NEG { $$ = -$2;        }
                /*���������﷨�ṹ���������ȼ���NEG��ͬ*/
        | exp '^' exp        { $$ = pow ($1, $3); }
        | '(' exp ')'        { $$ = $2;         }
;
%%

/*������ֱ�ӵ���yyparse���з���*/
int main (void)
{
        return yyparse ();
}

/*�ʷ���������
  �Ȿ����lex�����Ķ���,���ﻻ��д��
  ��������򵥵ذ����е�����������,���������ַ���ʽ����
  ����С�ڻ����0��yyparse����Ϊ�������
 */
int yylex (void)
{
        int c;

        while ((c = getchar ()) == ' ' || c == '\t');

        if (c == '.' || isdigit (c)) {
                ungetc (c, stdin);
                scanf ("%lf", &yylval);
                return NUM;
        }

        if (c == EOF) return 0;
        return c;
}

/*������,�򵥵ش�ӡ����*/
void yyerror (char const *s)
{
        fprintf (stderr, "%s\n", s);
}


/* //////////////////////
// pl0Yacc.y
////////////////////// */
%{
	#include "stdio.h" 
	#include "extra.h"
	#include "code.h"
	
	
	#define FILENAME_LENGTH 30
    
	int errorLine=1;
    	int noError=1;
%}

%union{
	char *name;
	int value;
}

%token W_period W_semicolon W_comma W_beginsym W_endsym
%token W_varsym W_constsym W_procedure W_becomes
%token W_oddsym W_neq W_eql W_lss W_gtr W_leq W_geq
%token W_whilesym W_do W_ifsym W_thensym W_callsym W_readsym W_writesym  
%token W_ident W_number

%token <name> W_ident
%token <value> W_number

%%

program	: /* ��ʼ�µĹ��̲����浱ǰ���̵����� */					
		{startBlock(3);}
	block W_period
	;

block	:/* ��ʼ�µĹ���֮ǰ����ת���룬��תλ���ں������ */
		{$<value>$=gen(jmp,0,0);/* ����һ��Ŀ����� */}
	declareList	
		{backFill($<value>1);/* ����ָ��Ŀ����븽�����ֵ */
		/* Ϊ�µĹ��̲��������ڴ�ռ�����һ��Ŀ����� */
		gen(ini,0,getLevVarNum()/* ��ȡ��ǰ���������Ŀ */);}
	statement	
		{gen(opr,0,AP_ret);/* Ϊ�µĹ���֮�󷵻�����һ��Ŀ����� */
		endBlock();/* ����������Ŀǰ�Ĺ��̲����¹����йص����� */}
	;
declareList	: /* null */
		|declareList declare
		;
declare	:constDeclare
	|varDeclare
	|procedureDeclare
	; 
constDeclare: W_constsym constList W_semicolon
	;
constList	: W_ident W_eql W_number	
			{enterConst($1,$3);	}/* �ڷ��ű��еǼ�һ���µĳ��� */
		| constList W_comma W_ident W_eql W_number
			{enterConst($3,$5);	}/* �ڷ��ű��еǼ�һ���µĳ��� */
		;
varDeclare	: W_varsym varList W_semicolon
		;
varList		: W_ident
			{enterVar($1);}/* �ڷ��ű��еǼ�һ���µı��� */
		| varList W_comma W_ident
			{enterVar($3);}/* �ڷ��ű��еǼ�һ���µı��� */
		;
procedureDeclare: W_procedure W_ident W_semicolon
			{enterProc($2);	/* �ڷ��ű��еǼ�һ���µĹ��� */
			/* ��ʼ�µĹ��̲����浱ǰ���̵����� */
			startBlock(3); }
		block W_semicolon
		;
statement	: /* null */
		| W_ident W_becomes expression
			{/* ������ֵ���ʽ��Ӧ��Ŀ����� */
			int l,a;
			table1 tempR;
			/* ͨ�����ұ�ʶ���ڷ��ű��е�λ������ȡ���ű��е�һ�� */
			tempR= getItem(position($<name>1));
			/* ��ȡ��ǰ���ڵĲ�ͱ������ڲ�Ĳ�� */
			l=getLev()-tempR.append.varAppendix.level;
			a= tempR.append.varAppendix.address;
			gen(sto,l,a);/* ����һ��Ŀ����� */}
		| W_beginsym statement statementList W_endsym
		| W_ifsym condition W_thensym	
			{$<value>$=gen(jpc,0,0);/* ����һ��������תĿ����� */}
		statement
			{backFill($<value>4);}/* ����ָ��Ŀ����븽�����ֵ */
		| W_whilesym
			{$<value>$=nextCode();}/* ��ȡ��һ��Ŀ������λ�� */
		condition W_do
			{$<value>$=gen(jpc,0,0);/* ����һ��������תĿ����� */}
		statement
			{gen(jmp,0,$<value>2);/* ����һ����������תĿ����� */
			backFill($<value>5);/* ����ָ��Ŀ����븽�����ֵ */}
		| W_readsym '(' identList ')'            				
		| W_writesym '(' expressionList ')'	            		
			{gen(opr,0,AP_wtl);}/* ����һ����ӡĿ����� */
		| W_callsym W_ident	
			{	/* �����������ô��� */
			int l,a;
			table1 tempR;
			/* ͨ�����ұ�ʶ���ڷ��ű��е�λ������ȡ���ű��е�һ�� */
			tempR= getItem(position($<name>2));
			/* ��ȡ��ǰ���ڵĲ�͹������ڲ�Ĳ�� */
			l=getLev()-tempR.append.procAppendix.level;
			/* ��ȡ��ǰĿ����븽�����ֵ */
			a=getCodeApp(tempR.append.procAppendix.address);
			/* ����һ����������Ŀ����� */
			gen(cal,l,a);}
			;
statementList: /* null */
		| statementList W_semicolon statement
		;
condition	: W_oddsym expression 
			{gen(opr,0,AP_odd);/* ����һ��Ŀ����� */}
		| expression W_eql expression             		
			{gen(opr,0,AP_equ);/* ����һ��Ŀ����� */}
		| expression W_neq expression        	
			{gen(opr,0,AP_neq);/* ����һ��Ŀ����� */}
		| expression W_lss expression              		
			{gen(opr,0,AP_les);/* ����һ��Ŀ����� */}
		| expression W_gtr expression            	
			{gen(opr,0,AP_grt);/* ����һ��Ŀ����� */}
		| expression W_leq expression         	
			{gen(opr,0,AP_lee);/* ����һ��Ŀ����� */}
		| expression W_geq expression     	
			{gen(opr,0,AP_gre);/* ����һ��Ŀ����� */}
		;
identList	: W_ident                                   				
			{	/* �����������Ӧ�Ĵ��� */
			int l,a;
			table1 tempR;
			/* ͨ�����ұ�ʶ���ڷ��ű��е�λ������ȡ���ű��е�һ�� */
			tempR= getItem(position($<name>1));
			/* ��ȡ��ǰ���ڵĲ�ͱ������ڲ�Ĳ�� */
			l=getLev()-tempR.append.varAppendix.level;
			a=tempR.append.varAppendix.address;
			gen(opr,0,AP_red);/* ����һ��Ŀ����� */
			/* ����һ������ջ������������Ŀ����� */
			gen(sto,l,a);}
		| identList W_comma W_ident  				
			{	/* �����������Ӧ�Ĵ��� */
			int l,a;
			table1 tempR;
			/* ͨ�����ұ�ʶ���ڷ��ű��е�λ������ȡ���ű��е�һ�� */
			tempR= getItem(position($<name>3));
			/* ��ȡ��ǰ���ڵĲ�ͱ������ڲ�Ĳ�� */
			l=getLev()-tempR.append.varAppendix.level;
			a=tempR.append.varAppendix.address;
			gen(opr,0,AP_red);/* ����һ��Ŀ����� */
			/* ����һ������ջ������������Ŀ����� */
			gen(sto,l,a);}
			;
expressionList: expression 
			{gen(opr,0,AP_wrt);/* ����һ��Ŀ����� */}
		| expressionList W_comma expression		
			{gen(opr,0,AP_wrt);/* ����һ��Ŀ����� */}
			;
expression	: term
		| '+' term
		| '-' term 									
			{gen(opr,0,AP_neg);/* ����һ��Ŀ����� */}
		| expression '+' term                            			
			{gen(opr,0,AP_add);/* ����һ��Ŀ����� */}
		| expression '-' term							
			{gen(opr,0,AP_sub);/* ����һ��Ŀ����� */}
		;
term		: factor
		| term '*' factor								
			{gen(opr,0,AP_mul);/* ����һ��Ŀ����� */}
		| term '/' factor                      					
			{gen(opr,0,AP_div);/* ����һ��Ŀ����� */}
		;
factor	: W_ident									
		{/* �����û������ʶ���Ĳ����������ͳ������Ͳ�����Ӧ���� */
		int index, kind,l,a,tempInt;
		table1 tempR;
		/* ���ұ�ʶ���ڷ��ű��е�λ�� */
		index=position($<name>1); 
		/* ��ȡ���ű��еǼ������������ */
		kind=getKind(index);
		switch(kind){
		     	case VARIABLE:
				/* ��ȡ���ű��е�һ�� */
				tempR= getItem(index);
				tempInt= tempR.append.varAppendix.level;
				/* ��ȡ��ǰ���ڵĲ�ͱ������ڲ�Ĳ�� */
				l=getLev()-tempInt;
				a=tempR.append.varAppendix.address;
				gen(lod,l,a);/* ����һ�������ŵ�ջ��Ŀ����� */
				break;
		     	case CONSTANT:
				/* ͨ�����ұ�ʶ���ڷ��ű��е�λ������ȡ���ű��е�һ�� */
				tempR=getItem(position($<name>1));
				a=tempR.append.constAppendix.value;
				gen(lit,0,a);/* ����һ�������ŵ�ջ����Ŀ����� */
				break; 
}}
	| W_number     								
		{gen(lit,0,$<value>1);/* ����һ��Ŀ����� */}
	| '(' expression ')'
	;

%%

void yyerror(char* s) {
  fprintf(stderr, s);
  fprintf(stderr,"\tOn Line %d\n",errorLine);
  noError = 0;
}
                
void main(int argc,char ** argv){
	FILE * fileIn=NULL,* fileOut=NULL;/* �����ļ���������� */
	char fileName[FILENAME_LENGTH];
	int haveOutFile=0; 
	if(argc>1){
		fileIn=fopen(argv[1],"r");
		if(fileIn==NULL)
			error("Error in reading file.");		 
		if(argc==3){
			fileOut=fopen(argv[2],"w");
			if(fileOut==NULL)
				error("Error in opening file.");
			haveOutFile=1;
		}
	}
	else{
		printf("Input file:");
		gets(fileName,FILENAME_LENGTH);
		fileIn=fopen(fileName,"r");
		if(fileIn==NULL)
			error("Error in reading file.");
		/* ѯ���Ƿ�������������ļ� */
		if(yesOrNoQuestion("Write compiled codes to file")){
			printf("Output to compileRes.txt\n");
			fileOut=fopen("compileRes.txt","w");
			if(fileOut==NULL)
				error("Error in opening [compileRes.txt] file.");
			haveOutFile=1;
		}
	}
	redirectInput(fileIn);/* �ض��������� */
	yyparse();/* ����Ĺ��� */
	if(noError){/* ����û�д���ʱִ�� */
		if(yesOrNoQuestion("List the compiled codes on screen"))
			listcode(stdout);/* ���Ŀ������嵥����Ļ */
		if(haveOutFile)
			listcode(fileOut);/* ���Ŀ������嵥���ļ� */
		if(yesOrNoQuestion("Execute the program")){	
			haveOutFile=0;
			/* ѯ���Ƿ�������н�����ļ� */
			if(yesOrNoQuestion("Output the execute result to file")){
				printf("Output to executeRes.txt\n");
				fileOut=fopen("executeRes.txt","w");
				if(fileOut==NULL)
					error("Error in opening [executeRes.txt] file.");
				haveOutFile=1;
			}   
			printf("\tStarting the program\n");
			if(haveOutFile)
				interpret(fileOut);/* ��Ŀ�������н���ִ�в��ѽ�������ļ� */
			else
				interpret(NULL);/* ��Ŀ�������н���ִ�в��������Ļ */
			printf("\tProgram terminated\n");
		}
	}
	if(fileIn!=NULL)
		fclose(fileIn);
	if(fileOut!=NULL)
		fclose(fileOut);
}

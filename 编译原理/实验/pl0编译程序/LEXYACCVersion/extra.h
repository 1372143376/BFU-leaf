/* //////////////////////
// extra.h 
// ��ʾyes��noѡ��ĺ���
// �ͱ����˳���ѡ��
////////////////////// */

#include "stdio.h"
#include "stdlib.h"


int yesOrNoQuestion(char * message){
	char result;
	int resultInt=0;
	printf("%s?(yes or no)",message);
	do{
		result=getc(stdin);
	}while(result=='\t' || result==' ');
	resultInt=(result=='y'?1:0);
	do{
		result=getc(stdin);
	}while(result!='\0' && result!='\n');
	return resultInt;
}

void error(char * message){
	printf("%s \n",message);
	exit(1);
}
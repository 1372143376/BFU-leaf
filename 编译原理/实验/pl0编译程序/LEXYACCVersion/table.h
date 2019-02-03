/* //////////////////////
// table.h 
// �ǼǱ���ر����Ͳ���
////////////////////// */

#include "stdio.h"
#include "string.h"
#define LEVMAX 3
#define TXMAX 100
#define AL 10

typedef enum KindOfItemType{/* �������� */
	CONSTANT,
	VARIABLE,
	PROCEDURE
}KindOfItem;

typedef struct ConstAppendixType{/* �������ӽṹ���� */
	int value;
}ConstAppendix;

typedef struct VarAppendixType{/* �������ӽṹ���� */
	int level;
	int address;
}VarAppendix;

typedef struct ProcAppendixType{/* ���̸��ӽṹ���� */
	int level;
	int address;
}ProcAppendix;

typedef union AppendixInfoType{/* ��������,�������������ṹ���� */
	ConstAppendix constAppendix;
	VarAppendix varAppendix;
	ProcAppendix procAppendix;
}InfoAppendix;

typedef struct table1Type{/* �ǼǱ�ĵǼ���Ŀ�ṹ���� */
	char nameOfItem[AL];
	KindOfItem kind;
	InfoAppendix append;
}table1;

static table1 table[TXMAX+1];/* �ǼǱ�ĵǼ���Ŀ���� */

static int levelIndexArray[LEVMAX];/* �Ѿ����뵽�ĸ������Ǽ������������ */
static int levelRegisterArray[LEVMAX];/* �Ѿ����뵽�ĸ������迪�ٿռ��С������ */

static int currentLevelIndex/* ��ǰ���ڲ�Ǽ������ */,currentLevelRegister;/* ��ǰ���ڲ㿪�ٿռ��С */
static int currentLevel=-1;/* ��ǰ���ڲ� */

void startBlock(int alreadyExist){/* ��ʼ����һ���µ�Block�ĵǼǱ����Ӧ���� */
	if(currentLevel==-1){
		currentLevelRegister=alreadyExist;
		currentLevelIndex=0;
		currentLevel++;
	}
	if(currentLevel==LEVMAX-1)
		yyerror("too many neasted block.\n");
	/* ��Ӧ��ֵ���� */
	levelIndexArray[currentLevel]=currentLevelIndex;
	levelRegisterArray[currentLevel]=currentLevelRegister;
	currentLevelRegister=alreadyExist;
	currentLevel++;
}

void endBlock(){/* ����������һ��Block�ı��� */
	currentLevel--;/* ������һ */
	/* ��Ӧ��ֵ�ָ� */
	currentLevelIndex=levelIndexArray[currentLevel];
	currentLevelRegister=levelRegisterArray[currentLevel];
}

int getLev(){/* ���ص�ǰ�� */
	return currentLevel;
}

int getLevVarNum(){/* ���صǼ���Ĵ��� */
	return currentLevelRegister;
}

table1 getItem(int index){/* ���صǼ��� */
	return table[index];
}

KindOfItem getKind(int index){/* ���صǼ�������� */
	return table[index].kind;
}

void enterName(char *newName){/* �ڷ��ű��еǼ�һ����������� */
	if (currentLevelIndex++<TXMAX){
		strcpy(table[currentLevelIndex].nameOfItem, newName);
	}else 
		yyerror("Too many items to register.\n");
}

int enterProc(char *newName)	{/* �ڷ��ű��еǼ�һ���µĹ��� */
	enterName(newName);/* �ڷ��ű��еǼ�һ����������� */
	table[currentLevelIndex].kind=PROCEDURE;/* �Ǽǹ������� */
	table[currentLevelIndex].append.procAppendix.level=currentLevel;/* �Ǽǹ��̵����ڲ� */
	/* �Ǽǹ��̵���ڵ�ַΪ��һ��Ŀ������λ�� */
	table[currentLevelIndex].append.procAppendix.address=nextCode();
	return currentLevelIndex;
}

int enterVar(char *newName)	{/* �ڷ��ű��еǼ�һ���µı��� */
	enterName(newName);/* �ڷ��ű��еǼ�һ����������� */
	table[currentLevelIndex].kind=VARIABLE;/* �ǼǱ������� */
	table[currentLevelIndex].append.varAppendix.level=currentLevel;/* �ǼǱ��������ڲ� */
	table[currentLevelIndex].append.varAppendix.address=currentLevelRegister++;/* �ǼǱ����ĵ�ַ */
	return currentLevelIndex;
}

int enterConst(char *newName,int valueInput)	{/* �ڷ��ű��еǼ�һ���µĳ��� */
	enterName(newName);/* �ڷ��ű��еǼ�һ����������� */
	table[currentLevelIndex].kind=CONSTANT;/* �Ǽǳ������� */
	table[currentLevelIndex].append.constAppendix.value=valueInput;/* �Ǽǳ�����ֵ */
	return currentLevelIndex;
}

int position(char *nameIn){/* ���ұ�ʶ���ڷ��ű��е�λ�� */
	int i;
	i=currentLevelIndex;
	strcpy(table[0].nameOfItem, nameIn);
	/* Ѱ�ҵǼǱ��еĶ����� */
	while(strcmp(nameIn,table[i].nameOfItem))
		i--;
	if(i!=0)
		return i;
	/* ���û���ҵ��򱨴� */
	printf("Undefined ident : %s\n",nameIn);
	yyerror("");
	return 0;
}



/*  //////////////////////
// code.h
// ��������Ϳ������
// �����Ͳ���
////////////////////// */

#include "table.h"
#define CXMAX 200
#define STACKSIZE 500


typedef enum fctType{/* �������� */
	ini,
	lit,
	lod,
	sto,
	cal,
	jmp,
	jpc,
	opr
}fct;

typedef enum AppType{
	AP_ret=0,/* �������ز��� */
	AP_neg,/* �󷴲��� */
	AP_add,/* ��Ͳ��� */
	AP_sub,/* ������� */
	AP_mul,/* ��˲��� */
	AP_div,/* ������� */
	AP_odd,/* ������� */
	AP_equ=8,/* ���Ƿ���Ȳ��� */
	AP_neq,/* ���Ƿ񲻵Ȳ��� */
	AP_les,/* ���Ƿ�С�ڲ��� */
	AP_gre,/* ���Ƿ���ڵ��ڲ��� */
	AP_grt,/* ���Ƿ���ڲ��� */
	AP_lee,/* ���Ƿ�С�ڵ��ڲ��� */
	AP_wrt,/* ��ӡջ��ֵ���� */
	AP_wtl,/* ��ӡ���в��� */
	AP_red/* ��ȡ����������� */
}App;

typedef struct InstructionEnum{/* ָ��ṹ���� */
	fct f;
	int l;
	int a;
}Instruction;

static Instruction code[CXMAX];/* ָ������ */
static int cx=-1;/* ��ǰ����ָ���ָ������ */

int nextCode(){
	return cx+1;
}/* ��ȡ��һ��Ŀ������λ�� */

int getCodeApp(int index){/* ��ȡ��ǰĿ����븽�����ֵ */
	return code[index].a;
}

void checkOverflow(){/* �������Ƿ���� */
	if(cx>=CXMAX)
		yyerror("too many codes.");
}

int gen(fct f,int l,App a){/* ����һ��Ŀ����� */
	cx++;
	checkOverflow();/* �������Ƿ���� */
	code[cx].f=f;
	code[cx].l=l;
	code[cx].a=a;
	return cx;
}

void backFill(int index){/* ����ָ��Ŀ����븽�����ֵ */
	code[index].a=cx+1;
}

void listcode(FILE * file){/* ���Ŀ������嵥 */
	int i=0;
	for(;i<=cx;i++){
		fprintf(file,"%d.\t",i);
		switch(code[i].f){
			case ini:
				fprintf(file,"ini\t");
				break;
			case lit:
				fprintf(file,"lit\t");
				break;
			case lod:
				fprintf(file,"lod\t");
				break;
			case sto:
				fprintf(file,"sto\t");
				break;
			case cal:
				fprintf(file,"cal\t");
				break;
			case jmp:
				fprintf(file,"jmp\t");
				break;
			case jpc:
				fprintf(file,"jpc\t");
				break;
			case opr:
				fprintf(file,"opr\t");
				break;
		}
		fprintf(file,"%d\t%d\n",code[i].l,code[i].a);
	}
}

int base(int l,int beginIn,int stack[STACKSIZE]){/* �õ�����������ַ */
	int returnInt=beginIn;
	while(l-->0)
		returnInt=stack[returnInt];
	return returnInt;
}

void interpret(FILE * file){/* ��Ŀ�������н���ִ�� */
	int s[STACKSIZE]/* ����ָ��Ķ�ջ */,tempInt;
	/* ִ��ָ����Ҫ�ļĴ��� */
	int p=0,t=-1,b=0;
	/* Ŀǰִ�е�ָ��ָ�� */
	Instruction * i;
	/* ��ǰ��ľ�̬���Ͷ�̬�� */
	int staticLink=0,dynamicLink=0;
	/* ��ջ�ĳ�ʼ�� */
	s[0]=s[1]=s[2]=-1;
	do{
		i=code+p;
		switch(i->f){
			case ini:/* �����ڴ�ռ�Ĳ��� */
				t+=i->a;
				break;
			case lit:/* �ѳ����ŵ�ջ���Ĳ��� */
				s[++t]=i->a;
				break;
			case lod:/* �����ŵ�ջ���Ĳ��� */
				/* �õ�����������ַ */
				tempInt=base(i->l,b,s);
				s[++t]=s[tempInt+i->a];
				break;
			case sto:/* �洢ջ�����Ĳ��� */
				/* �õ�����������ַ */
				tempInt=base(i->l,b,s);
				s[tempInt+i->a]=s[t];
				t--;
				break;
			case cal:/* �������õĲ��� */
				/* �õ�����������ַ */
				tempInt=base(i->l,b,s);
				staticLink=s[t+1]=tempInt; 
				dynamicLink=s[t+2]=b;
				s[t+3]=p;
				p=i->a-1;
				b=t+1;
				break;
			case jmp:/* ��������ת�Ĳ��� */
				p=i->a-1;
				break;
			case jpc:/* ������ת�Ĳ��� */
				if(s[t]==0){
					p=i->a-1;	
				}
				t--;
				break;
			case opr:
				switch(i->a){
					case AP_ret:
						/* �������ص���ع��� */
						t=b-1;
						p=s[b+2];
						staticLink=s[b];
						dynamicLink=s[b+1];
						b=s[b];
						/* ��������������ִֹͣ�� */
						if(p==-1)
							return;
						if(dynamicLink==-1)
							return;
						break;
					case AP_neg:/* �󷴲��� */
						s[t]=-s[t];
						break;
					case AP_add:/* ��Ͳ��� */
						t--;
						s[t]+=s[t+1];
						break;
					case AP_sub:/* ������ */
						t--;
						s[t]-=s[t+1];
						break;
					case AP_mul:/* ������� */
						t--;
						s[t]*=s[t+1];
						break;
					case AP_div:/* ���̲��� */
						if(s[t]==0)
							error("Fatal Error: Divided By ZERO.\n");
						t--;
						s[t]/=s[t+1];
						break;
					case AP_odd:/* ������� */
						s[t]=(s[t]%2==0?0:1);
						break;
					case AP_equ:/* ���Ƿ���ͬ���� */
						t--;
						s[t]=(s[t]==s[t+1]?1:0);
						break;
					case AP_neq:/* ���Ƿ�ͬ���� */
						t--;
						s[t]=(s[t]!=s[t+1]?1:0);
						break;
					case AP_les:/* ���Ƿ�С�ڲ��� */
						t--;
						s[t]=(s[t]<s[t+1]?1:0);
						break;
					case AP_gre:/* ���Ƿ���ڵ��ڲ��� */
						t--;
						s[t]=(s[t]>=s[t+1]?1:0);
						break;
					case AP_grt:/* ���Ƿ���ڲ��� */
						t--;
						s[t]=(s[t]>s[t+1]?1:0);
						break;
					case AP_lee:/* ��С�ڵ��ڲ��� */
						t--;
						s[t]=(s[t]<=s[t+1]?1:0);
						break;
					case AP_wrt:/* ��ӡջ�������� */
						if(file!=NULL)
							fprintf(file,"%d",s[t]);
						printf("%d",s[t]);
						break;
					case AP_wtl:/* ��ӡ���в��� */
						if(file!=NULL)
							fprintf(file,"\n");
						printf("\n");
						break;
					case AP_red:/* ��ȡ������ջ�������� */
						if(file!=NULL)
							fprintf(file,"?");
						printf("?");
						scanf("%d",&s[++t]);
						if(file!=NULL)
							fprintf(file,"%d\n",s[t]);
						break;
					default:/* δ֪�������� */
						error("Fatal Error: Unknown Operation.\n");
						break;
				}
				break;
			default:/* δ֪�������� */
				error("Fatal Error: Unknown Operation.\n");
				break;
		}
		p++;
		if(t>=STACKSIZE)
				error("Fatal Error: Stack Overflow.\n");
	}while(1);
}
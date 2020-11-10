%option noyywrap

%top{
    #include <iostream>
    #include <map>
    #include <iomanip>
    #include <fstream>
    #include <stack>
    #include <vector>
    using namespace std;
    //Ϊ��ʵ�������򣬱���洢������Ľṹ�����ĸ�zone�����ĸ�zone 
    //zoneջ��Ϊ���Ҹ��ڵ��� 
    stack<int> zone_stack;

    //��ʶ�����������ƺͷ��ű��е�ָ��
    struct identifier{
    	string name;
    	int no;
        identifier(){}
        identifier(string n,int num){
            name=n;
            no=num;
        }
	};

    //�ṹ��z��zone��ÿ��zone����һ��id�б���һ�����ڵ�ֵ
    struct z{
        vector<identifier>id_list;
        int father;
        z(){
            father=-1;
        }
    }zone[20];

    //��p�ڵ��������Ƿ�ǰ�涨�����ʶ��id
    int find_zone(int p,string id){
	    int i;
        while(p>=0){
        	for(i=0;i<zone[p].id_list.size();++i){
        		if(zone[p].id_list[i].name==id){
        			return p; 
				}
        	}
        	p=zone[p].father;
		}
		return -1;
	}
    void printer(string a,string b){
        cout<<setw(8)<<a<<setw(8)<<b<<endl;
    }
    void printer(string a,string b,int c){
        cout<<setw(8)<<a<<setw(8)<<b<<setw(8)<<c<<endl;
    }
}

%{


    int id_cnt=0,chars=0,lines=0;//id�����ַ��������� 
    int zone_cnt=0;//zone���� 
    int zone_now=0;//��ǰ������ 
    int zone_switch_flag=0;//�Ƿ���Ҫ�л�������һ��idǰ����û��int �� 
%}
SUB     "-"
ASSIGN  "="
EQUAL   "=="
RETURN  "return"
WHILE   "while"
IF      "if"
INT     "int"
word   [a-zA-Z]+
line    \n
char    .
commentline     "//"
commentbegin    "/*"
commentelement .|\n
commentend      "*/"
%x COMMENT_1
%x COMMENT_2



%%
["+"] printer("ADD",yytext);
{SUB} printer("SUB",yytext);
["*"] printer("MUL",yytext);
["/"] printer("DIV",yytext);
["%"] printer("MOD",yytext);
["("] printer("S_LEFT",yytext);
[")"] printer("S_RIGHT",yytext);
["{"] {
    printer("B_LEFT",yytext);
    cout<<endl;
    zone_cnt++;
    zone[zone_cnt].father=zone_now;//���ø��ڵ�
    zone_now=zone_cnt;//�����������ţ���ǰ�������Ȼ���µ�������
    zone_stack.push(zone_now);
}
["}"] {
    printer("B_RIGHT",yytext);
    zone_stack.pop();//���������ţ��ʹ�ջ��pop��zone_cnt
    zone_now=zone_stack.top();
}
[";"] {printer("SEMICOLON",yytext);cout<<endl;}
{ASSIGN} printer("ASSIGN",yytext);//��ƥ������±����ڶ���ζ��壬�̵��ڳ���ǰ��
{EQUAL} printer("EQUAL",yytext);
[0-9]+	printer("NUM",yytext,atoi(yytext));
{RETURN} printer("RETURN",yytext);
{INT} {
    zone_switch_flag=1;
    printer("INT",yytext);
}
{IF} printer("IF",yytext);
{WHILE} printer("WHILE",yytext);
{word} {
        chars+=strlen(yytext);
        if(zone_switch_flag==1){//���ǰ����int���൱���µ�id
            int i;
            for(i=0;i<zone[zone_now].id_list.size();++i){
                //�����ǰ���������Ѿ����������ô����
                if(zone[zone_now].id_list[i].name==yytext){
                    cout<<"error,'"<<yytext<<"' has been declared in this zone"<<endl;
                    break;
                }
            }
            if(i==zone[zone_now].id_list.size()){//���û��������ɹ�������id
                zone[zone_now].id_list.push_back(identifier(yytext,id_cnt));
                printer("ID",yytext,id_cnt);
                id_cnt++;
            }
            zone_switch_flag=0;
        }
        else{//���ǰ��û��int���������ǲ��Ƕ����id
        	int p=zone_now;
        	int find_zone_result=find_zone(p,yytext);
        	if(find_zone_result==-1){//����Ҳ�����δ����error 
        		cout<<"error,'"<<yytext<<"' has not been declared"<<endl;
			}
			else{//�ҵ�����ȷ�������� 
                p=find_zone_result;
                for(int i=0;i<zone[p].id_list.size();++i){
                    if(zone[p].id_list[i].name==yytext){
                        printer("ID",yytext,zone[p].id_list[i].no);
                        break;
                    }
                }
			} 
        }
    }
{line} {lines++;}
{char} {chars++;}
{commentline}   {printf("this is comment part...\n");BEGIN COMMENT_1;}
<COMMENT_1>{line} {BEGIN INITIAL;}
{commentbegin} {printf("this is comment part...\n");BEGIN COMMENT_2;}
<COMMENT_2>{commentelement} {}
<COMMENT_2>{commentend} {BEGIN INITIAL;}
%%

int main(){
    ifstream input("./testin.cpp");
    // ofstream output("./testout");
    zone_stack.push(0);
    yyFlexLexer lexer(&input);
    lexer.yylex();
    cout<<setw(8)<<lines<<setw(8)<<chars<<setw(8)<<id_cnt<<endl;
    return 0;
}
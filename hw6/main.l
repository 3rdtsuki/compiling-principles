%option noyywrap
%{
    #include"common.h"
    #include"main.tab.hh"
    #include <stack>
    using namespace std;
    //Ϊ��ʵ�������򣬱���洢������Ľṹ�����ĸ�zone�����ĸ�zone 
    //zoneջ��Ϊ���Ҹ��ڵ��� 
    stack<int>zone_stack;

    extern action_zone zone[20];

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
        return;
        cerr<<setw(8)<<a<<setw(8)<<b<<endl;
    }
    void printer(string a,string b,int c,string type){
        return;
        cerr<<setw(8)<<a<<setw(8)<<b<<setw(8)<<c<<setw(8)<<type<<endl;
    }
    int zone_cnt=0;//zone���� 
    int zone_now=0;//��ǰ������ 
    int zone_switch_flag=0;//�Ƿ���Ҫ�л�������һ��idǰ����û��int �� 

    bool init_stack=false;//ջ��ʼ��
    bool for_flag=false;//for�Ļ����Ų�Ӱ����������һ������

    int now_line=1;//��ǰ����

    string last_type;//���������type�ؼ��֣���Ϊ��������ʱ�����ԡ�
%}
BLOCKCOMMENT \/\*([^\*^\/]*|[\*^\/*]*|[^\**\/]*)*\*\/
LINECOMMENT \/\/[^\n]*

FLOAT_VAL [0-9]*\.[0-9]+
INT_VAL [0-9]+
ID [[:alpha:]_][[:alpha:][:digit:]_]*
CHAR_VAL \'.+\'
STRING_VAL \".+\"
EOL (\r\n|\n)
WHITE [\t ]
%%
{BLOCKCOMMENT} {cerr<<"COMMENT:"<<yytext<<endl;} /* do nothing */
{LINECOMMENT}  {cerr<<"COMMENT:"<<yytext<<endl;}/* do nothing */

"true" {
    TreeNode *node = new TreeNode(NODE_BOOL);//������
    node->bool_val = true;
    yylval = node;
    node->lineno=now_line;//�к�
    return TRUE;
}
"false" {
    TreeNode *node = new TreeNode(NODE_BOOL);
    node->bool_val = false;
    yylval = node;
    node->lineno=now_line;
    return FALSE;
}

"int" {
    if(init_stack==false){//��ʼ��ջ
        zone_stack.push(0);
        init_stack=true;
    }
    zone_switch_flag=1;//�¶����˱���
    last_type="int";
    return INT;
}
"float" {
    if(init_stack==false){//��ʼ��ջ
        zone_stack.push(0);
        init_stack=true;
    }
    zone_switch_flag=1;//�¶����˱���
    last_type="float";
    return FLOAT;
}
"void" {
    if(init_stack==false){
        zone_stack.push(0);
        init_stack=true;
    }
    zone_switch_flag=1;
    last_type="void";
    return VOID;
}
"char" {
    if(init_stack==false){
        zone_stack.push(0);
        init_stack=true;
    }
    zone_switch_flag=1;
    last_type="char";
    return CHAR;
}

"if" {
    return IF;
}
"while" {
    return WHILE;
}
"else" {
    return ELSE;
}
"for" {//ע��for���涨���i������仯
    for_flag=true;
    zone_cnt++;     //����������++
    zone[zone_cnt].father=zone_now;     //���ø��ڵ�
    zone_now=zone_cnt;      //������for����ǰ�������Ȼ���µ�������
    zone_stack.push(zone_now);
    return FOR;
}
"return" {
    return RETURN;
}

"printf" {
    return PRINTF;
}
"scanf" {
    return SCANF;
}

"==" return EQUAL;
"=" {
    return ASSIGN;
}

"+" return ADD;
"-" return SUB;
"*" return MUL;
"/" return DIV;
"%" return MOD;
">" return LARGER;
"<" return SMALLER;
">=" return LARGER_EQUAL;
"<=" return SMALLER_EQUAL;
"!=" return NOT_EQUAL;
"&&" return AND;
"||" return OR;
"+=" {
    return ADD_SELF;
}
"-=" {
    return SUB_SELF;
}
"++" {
    return ADD_ONE;
}
"--" {
    return SUB_ONE;
}

"!" return NOT;

"&" return GET_ADDR;//ȡ��ַ

"\"" {//����˫���ţ�������string���ͣ�������˫������ô�죿Ҫ�������ж���ż��

    return QUOTA;
}
"," return COMMA;
";" {
    zone_switch_flag=0;
    return SEMICOLON;
}
"(" return LPAREN;
")" return RPAREN;
"{" {
    zone_switch_flag=0;
    if(for_flag==true){//�����for���棬�����򲻱�
        return LBRACE;
    }
    zone_cnt++;     //����������++
    zone[zone_cnt].father=zone_now;     //���ø��ڵ�
    zone_now=zone_cnt;      //�����������ţ���ǰ�������Ȼ���µ�������
    zone_stack.push(zone_now);
    return LBRACE;
}
"}" {
    if(for_flag==true){
        for_flag=false;//����for��������
    }
    zone_stack.pop();//���������ţ��ʹ�ջ��pop��һ��zone
    zone_now=zone_stack.top();
    return RBRACE;
}

{STRING_VAL} {
    TreeNode *node = new TreeNode(NODE_CONST);
    node->string_val = yytext;
    node->varType=VAR_STRING;
    yylval = node;
    printer("STRING",yytext);
    node->lineno=now_line;
    return STRING_VAL;
}

{INT_VAL} {
    TreeNode *node = new TreeNode(NODE_CONST);
    node->int_val = atoi(yytext);
    node->varType=VAR_INTEGER;
    yylval = node;
    printer("INT",yytext);
    node->lineno=now_line;
    return INT_VAL;
}

{FLOAT_VAL} {
    TreeNode *node = new TreeNode(NODE_CONST);
    node->float_val = atof(yytext);
    node->varType=VAR_FLOAT;
    yylval = node;
    printer("FLOAT",yytext);
    node->lineno=now_line;
    return FLOAT_VAL;
}
{CHAR_VAL} {
    TreeNode* node = new TreeNode(NODE_CONST);
    //�ر��ж�\n��\t
    string s=yytext;
    if(s[1]=='\\'&&s[2]=='t'){
        node->char_val=(char)9;
    }
    else if(s[1]=='\\'&&s[2]=='n'){
        node->char_val=(char)10;
    }
    else node->char_val = yytext[1];
    node->varType=VAR_CHAR;
    yylval = node;
    printer("INT",yytext);
    node->lineno=now_line;
    return CHAR_VAL;
}
{ID} {
    TreeNode *node = new TreeNode(NODE_VAR);
    node->var_name = string(yytext);
    yylval = node;

    if(zone_switch_flag==1){//���ǰ����int���൱���µ�id
        int i;
        for(i=0;i<zone[zone_now].id_list.size();++i){
            //�����ǰ���������Ѿ�������ñ�������ô����
            if(zone[zone_now].id_list[i].name==yytext){
                cerr<<"error,'"<<yytext<<"' has been declared in this zone"<<endl;
                break;
            }
        }
        //���û��������ɹ�������id�������뵱ǰ������ķ��ű���
        if(i==zone[zone_now].id_list.size()){
            zone[zone_now].id_list.push_back(identifier(yytext,zone_now,last_type));
            printer("ID",yytext,zone_now,last_type);
            if(last_type=="int"){
                node->varType=VAR_INTEGER;
            }
            else if(last_type=="char"){
                node->varType=VAR_CHAR;
            }
            else if(last_type=="void"){
                node->varType=VAR_VOID;
            }
            else if(last_type=="float"){
                node->varType=VAR_FLOAT;
            }
            node->zone=zone_now;
        }
    }
    //���ǰ��û��type���������ǲ��Ƕ����id
    else{
        int p=zone_now;
        int find_zone_result=find_zone(p,yytext);
        //����Ҳ�����δ����error
        if(find_zone_result==-1){ 
            cerr<<"error,'"<<yytext<<"' has not been declared"<<endl;
        }
        //�ҵ�����ȷ�������� 
        else{
            p=find_zone_result;
            for(int i=0;i<zone[p].id_list.size();++i){
                if(zone[p].id_list[i].name==yytext){
                    identifier this_id=zone[p].id_list[i];
                    printer("ID",this_id.name,this_id.no,this_id.type);

                    node->zone=zone[p].id_list[i].no;
                    break;
                }
            }
        } 
    }
    node->lineno=now_line;
    return ID;
}
{EOL} {//����
    now_line++;
}
{WHITE}


%%

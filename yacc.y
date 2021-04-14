%{  

#include "main.h"
#include <stdarg.h>
#include <queue>
extern "C"    
{   
    void yyerror(const char *s);  
    extern int yylex(void);
    extern int line_numbering;
    extern char * yytext;
}  

Node* int_node(int value);
Node* key_node(string keyword);
Node* op_node(char c);
Node* non_node();
Node* merge(string s,int n,...);
void print(Node* root,int n);
int height(Node* root);
void travel(Node* ptr,int len=0,int mask=0);



%}

%token<m_nInt>INTEGER  
%token<m_Str>QSTRING
%token<m_Str>IDENTIFIER  

%token<m_Str>ASSIGN
%token<m_Str>EQUAL
%token<m_Str>NEQUAL

%token<m_Str>READ
%token<m_Str>WRITE
%token<m_Str>IF
%token<m_Str>ELSE
%token<m_Str>RETURN

%token<m_Str>STRING
%token<m_Str>REAL
%token<m_Str>INT
%token<m_Str>TO
%token<m_Str>FOR
%token<m_Str>WHILE

%token<m_Str>MAIN

%type<nptr>Program
%type<nptr>MethodDecl
%type<nptr>FormalParams
%type<nptr>FormalParam
%type<nptr>SubFormalParam
%type<nptr>Block
%type<nptr>Statement
%type<nptr>SubStmt
%type<nptr>LocalVarDecl
%type<nptr>AssignStmt
%type<nptr>ReturnStmt
%type<nptr>IfStmt
%type<nptr>WriteStmt
%type<nptr>ReadStmt
%type<nptr>BoolExpression
%type<nptr>Expression
%type<nptr>SubMultiplicativeExpr
%type<nptr>MultiplicativeExpr
%type<nptr>SubPrimaryExpr
%type<nptr>PrimaryExpr
%type<nptr>ActualParams
%type<nptr>SubExpression
%type<nptr>Type 
%type<nptr>WhileStmt 
%type<nptr>ForStmt 
 

%%  
Program:
    MethodDecl
    {
        Node *root = merge("Program", 1, $1);
        travel(root);
    }
MethodDecl:
    Type IDENTIFIER '(' FormalParams ')' Block MethodDecl 
    {
        $$ = merge("MethodDecl",7,$1,key_node($2),op_node('('),$4,op_node(')'),$6,$7);
    }
    | Type MAIN IDENTIFIER '(' FormalParams ')' Block MethodDecl
    {
        $$ = merge("MethodDecl",8,$1, key_node($2), key_node($3),op_node('('),$5,op_node(')'),$7,$8);
    }
    | {$$=merge("MethodDecl",1,non_node());}

FormalParams:
    FormalParam SubFormalParam {$$=merge("FormalParams",2,$1,$2);} | {$$=merge("FormalParams",1,non_node());}

FormalParam:  
    Type IDENTIFIER {$$=merge("FormalParam",2,$1,key_node($2));}

SubFormalParam:
    ',' FormalParam SubFormalParam {$$=merge("SubFormalParam",3,op_node(','),$2,$3);} 
    | {$$=merge("SubFormalParam",1,non_node());}

Block:
    '{' Statement '}' {
        Node* root = merge("Block",3,key_node("{"),$2,key_node("}"));
        $$=root;
        }

Statement:
    SubStmt Statement {
        $$ = merge("Statement",2,$1,$2);
    } 
    | {$$=merge("Statement",1,non_node());}

SubStmt:
    LocalVarDecl {$$=merge("SubStmt",1,$1);} 
    | AssignStmt  {$$=merge("SubStmt",1,$1);}
    | ReturnStmt {$$=merge("SubStmt",1,$1);}
    | IfStmt {$$=merge("SubStmt",1,$1);}
    | WriteStmt {$$=merge("SubStmt",1,$1);}
    | ReadStmt {$$=merge("SubStmt",1,$1);}
    | ForStmt {$$=merge("SubStmt",1,$1);}
    | WhileStmt {$$=merge("SubStmt",1,$1);}

ForStmt :
    FOR '(' IDENTIFIER ASSIGN INTEGER TO INTEGER ')' Block
    {$$=merge("ForStmt",9,key_node("FOR"),op_node('('),key_node($3),key_node(":="),int_node($5),key_node("TO"),int_node($7),op_node(')'), $9);}

WhileStmt :
    WHILE '(' BoolExpression ')' Block {$$=merge("WhileStmt",5, key_node("WHILE"), op_node('('), $3, op_node(')'), $5);}


LocalVarDecl :
    Type IDENTIFIER ';' {$$=merge("LocalVarDecl",3,$1,key_node($2),op_node(';'));}
    | Type AssignStmt {$$=merge("LocalVarDecl",2,$1,$2);}

AssignStmt  :
    IDENTIFIER ASSIGN Expression ';' {$$=merge("AssignStmt",4,key_node($1),key_node(":="),$3,op_node(';'));} 
    | IDENTIFIER ASSIGN QSTRING ';' {$$=merge("AssignStmt",4,key_node($1),key_node("!="),key_node($3),op_node(';'));}

ReturnStmt :
    RETURN Expression ';'{$$=merge("ReturnStmt",3,key_node("RETRUN"),$2,op_node(';'));}

IfStmt:
    IF '(' BoolExpression ')'  Block {$$=merge("IfStmt",5,key_node("IF"),op_node('('), $3,op_node(')'), $5);}
    |IF '(' BoolExpression ')' Block ELSE Block 
    {$$=merge("IfStmt",7, key_node("IF"), op_node('('), $3, op_node(')'), $5, key_node("ELSE"), $7);}


WriteStmt:
    WRITE '(' Expression ',' QSTRING ')' ';' {$$=merge("WriteStmt",7,key_node("WRITE"),op_node('('),$3,op_node(','),key_node($5),op_node(')'),op_node(';'));}

ReadStmt:
    READ '(' IDENTIFIER ',' QSTRING ')' ';' 
    {$$=merge("ReadStmt",7,key_node("READ"),op_node('('),key_node($3),op_node(','),key_node($5),op_node(')'),op_node(';'));}

BoolExpression: 
    Expression EQUAL Expression {$$=merge("BoolExpression",3,$1,key_node("EQUAL"),$3);}
    |Expression NEQUAL Expression {$$=merge("BoolExpression",3,$1,key_node("NEQUAL"),$3);}

Expression:
    MultiplicativeExpr SubMultiplicativeExpr {$$=merge("Expression",2,$1,$2);}

SubMultiplicativeExpr:
    '+' MultiplicativeExpr SubMultiplicativeExpr {$$=merge("SubMultiplicativeExpr",3,op_node('+'),$2,$3);}
    | '-' MultiplicativeExpr SubMultiplicativeExpr {$$=merge("SubMultiplicativeExpr",3,op_node('-'),$2,$3);}
    | {$$=merge("SubMultiplicativeExpr",1,non_node());}

MultiplicativeExpr:
    PrimaryExpr SubPrimaryExpr {$$=merge("MultiplicativeExpr",2,$1,$2);}

SubPrimaryExpr:
    '*' PrimaryExpr SubPrimaryExpr {$$=merge("SubPrimaryExpr",3,op_node('*'),$2,$3);}
    | '/' PrimaryExpr SubPrimaryExpr  {$$=merge("SubPrimaryExpr",3,op_node('/'),$2,$3);}
    | {$$=merge("SubPrimaryExpr",1,non_node());}

PrimaryExpr:
    INTEGER {$$=merge("PrimaryExpr",1,int_node($1));}
    | IDENTIFIER {$$=merge("PrimaryExpr",1,key_node($1));} 
    | '(' Expression ')' {$$=merge("PrimaryExpr",3,op_node('('),$2,op_node(')'));}
    | IDENTIFIER '(' ActualParams ')' {$$=merge("PrimaryExpr",4,key_node($1),op_node('('),$3,op_node(')'));}

ActualParams:
    Expression SubExpression {$$=merge("ActualParams",2,$1,$2);}

SubExpression:
    ',' Expression SubExpression {$$=merge("SubExpression",3,op_node(','),$2,$3);}
    | {$$=merge("SubExpression",1,non_node());}

Type:
    INT {$$=merge("Type",1,key_node("INT"));}
    |REAL {$$=merge("Type",1,key_node("REAL"));}
    | STRING {$$=merge("Type",1,key_node("STRING"));}


    

%%

Node* int_node(int value){
    Node* p = new Node();
    p->integer = value;
    p->type = typeCon;
    return p;
}
Node* key_node(string keyword){
    Node* p = new Node();
    p->key_word = keyword;
    p->type = typeKey;
    return p;
}
Node* op_node(char c){
    Node* p = new Node();
    p->opr = c;
    p->type = typeOpr;
    return p;
}
Node* non_node(){
    Node* p = new Node();
    p->type = typeKey;
    p->key_word = "NULL";
    return p;
}
Node* merge(string s, int n,...){
    Node* p = new Node();
    p->type = typeKey;
    p->key_word = s;
    va_list ap;
    va_start(ap, n);
    for(int i=0;i<n;i++)
        p->child.push_back(va_arg(ap, Node*));
    va_end(ap);
    return p;
}

int height(Node* root){
    if(root==NULL)
        return 0;
    int maxn=1;
    for(int a=0;a<root->child.size();a++)
        maxn = max(height(root->child[a])+1,maxn);
    return maxn;
}

void travel(Node* ptr,int len,int mask)  {
    for (int i=0;i<len;++i)
        if (i!=len-1)
            cout<<((mask>>i&1)?"|  ":"   ");
        else    
            cout<<((mask>>i&1)?"|__":"\\__");

    if(!ptr)
        return cout<<"NULL"<<endl, void(0);
    if(ptr->type == typeCon) cout<<ptr->integer;
    cout<<ptr->key_word<<ptr->opr<<endl;

    for (int i=0;i<ptr->child.size();++i) {
        if (i!=ptr->child.size()-1)
            travel(ptr->child[i],len+1,mask|(1<<len));
        else
            travel(ptr->child[i],len+1,mask);
    }
}

void yyerror(const char *s) 
{
    cerr<<s<<" appear in line "<<line_numbering<<":"<<yytext<<endl;
}

int main(int argc, char* argv[])//程序主函数，这个函数也可以放到其它.c, .cpp文件里  
{  
    if(argc==1){
        cout<<"main:no input files\n','pilation terminated.\n";
        return -1;
    }
    char *sFile = argv[1];
    FILE* fp=fopen(sFile, "r");  
    if(fp==NULL)  
    {  
        printf("cannot open %s\n", sFile);  
        return -1;  
    }  
    extern FILE* yyin;  
    yyin=fp;

    printf("begin parsing %s\n", sFile);  
    yyparse();
    puts("end parsing");
    printf("No Error.\n");
    fclose(fp);  

    return 0;  
} 


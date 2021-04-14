<center>
    <font size=7>
        编译原理实验
    </font>
</center>
<center>
    <font size=5>
    </font>
</center>












[TOC]

























## 1. 实验要求

1. 实验目的：扩充已有的样例语言TINY，为扩展TINY语言TINY＋构造词法分析和语法分析程序，从而掌握词法分析和语法分析程序的构造方法 
2. 实验内容：了解样例语言TINY及TINY编译器的实现，了解扩展TINY语言TINY＋，用EBNF描述TINY＋的语法，用C语言扩展TINY的词法分析和语法分析程序，构造TINY＋的语法分析器。
3. 实验要求：将TINY＋源程序翻译成对应的TOKEN序列，并能检查一定的词法错误。将TOKEN序列转换成语法分析树，并能检查一定的语法错误。



## 2. 自定义TINY+语法

### 2.1 循环语句

TINY语法本身没有循环语句，因此加入FOR循环和WHILE循环。
$$
\begin{aligned}
ForStmt &\rightarrow '(' \quad IDENTIFIER \quad ASSIGN \quad INTEGER \quad TO \quad INTEGER \quad ')' Block\\
WhileStmt &\rightarrow '(' \quad BoolExpression \quad  ')' Block
\end{aligned}
$$

### 2.3 加入大括号

之前学习的语言都是使用大括号标记代码段，而TINY本身使用BEGIN和END标记代码块。因此在扩展的TINY+语言中加入了大括号，如下：
$$
\begin{aligned}
Block \rightarrow '\{' \quad Statement \quad '\}'
\end{aligned}
$$


## 3. 语法分析器构造

语法分析器分为词法分析器构造和语法分析器构造。最后程序输出分析树。

### 3.1 词法分析器

词法分析的第一段首先引入头文件。之后定义符号，在lex中符号的定义使用正则表达式，定义如下：

```
/*非数字*/  
nondigit    ([_A-Za-z])  

/*数字*/  
digit       ([0-9])  

/*整数和小数*/  
digits     ({digit}+)  
integer 	({digit}+|{digits}+.{digits}+)


/*标识符*/  
identifier  ({nondigit}({nondigit}|{digit})*)  

/*字符串*/
qstring (\"[^"\n]*["\n])

/*空白字符*/  
blank_chars ([ \f\r\t\v]+)  

/*关键字*/
key_words (READ|WRITE|IF|ELSE|RETURN|STRING|REAL|INT|TO|FOR|WHILE|MAIN)
mul_char (:=|==|!=)
```

由于之后要构造语法树，因此在进行词法分析的时候需要重新定义yylval变量的结构体，定义的结构体如下：

```c
struct Type
{  
    string m_Str; 
    char m_cOp;  
    double m_nInt; 
    Node* nptr; 
};  
#define YYSTYPE Type
```

除了基本的TOKEN的处理，在词法分析阶段也可以处理注释。

遇到/*符号时将状态转换乘COMMENT状态，遇到\*/符号则将状态转换成正常的INIT状态。

```
%x COMMENT

%%
"/*" {
	BEGIN COMMENT;
}

<COMMENT>"*/" {
	BEGIN INITIAL;
}
```

### 3.2 文法分析器

文法分析的第一段和词法分析类似，首先声明头文件，并且声明C语言之后用到的函数。此外在第一段也要lex词法分析过程中返回的TOKEN进行处理。

在第一段声明TOKEN如下：

```
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
```

语法分析的第二段定义了语法的生成式，语法生成式式yacc.y文件的重点，但是由于其代码逻辑和BNCF定义的TINY语言基本相同，因此这里只展示两个生成式的定义过程。

Program的生成式如下：

```
Program:
    MethodDecl
    {
        Node *root = merge("Program", 1, $1);
        travel(root);
    }
```

MethodDecl的生成式如下：

```
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
```

根据BCNF的语法可知本身Program的生成式为$Program \rightarrow MethodDecl \quad MethodDecl^*$，但是在yacc语法中没有直接表示这种关系的声明，因此将MethodDecl和MethodDecl连接，并且让MethodDecl可以等于NULL

### 3.3 分析树构造

语法分析树的构造在生成式中展现，为了方便边构造分析树节点，因此定义了函数merge，接受要被归约的节点，并且将这节点生成新节点作为返回值返回，压入栈中。

merge的函数声明如下：

```c
Node* merge(string s, int n,...)
```

分析树的输出过程如下：

```c
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
```



## 4. 实验结果

测试一个简单的样例file1.txt

```ti
INT f1() 
{
	
}
```

可以看到TOKEN序列图下：

<img src=".\pic\屏幕截图 2021-04-14 220925.png" alt="屏幕截图 2021-04-14 220925" style="zoom: 80%;" />

画出的分析树如下：

<img src="pic\屏幕截图 2021-04-14 221143.png" alt="屏幕截图 2021-04-14 221143" style="zoom:80%;" />

之后测试添加的额外属性FOR，测试源代码在file2.txt中，最终的分析树如下：

<img src="pic\屏幕截图 2021-04-14 221535.png" alt="屏幕截图 2021-04-14 221535" style="zoom:67%;" />

最后展示报错的情况，报错会定位第一个错误出现的位置。错误的源代码放在file3.txt中，报错的结果如下：

<img src=".\pic\屏幕截图 2021-04-14 221800.png" alt="屏幕截图 2021-04-14 221800" style="zoom: 80%;" />
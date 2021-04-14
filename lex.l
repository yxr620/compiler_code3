%{  

#include "main.h"  
#include "yacc.tab.h"

extern "C"
{   
    int yywrap(void);  
    int yylex(void);//这个是lex生成的词法分析函数，yacc的yyparse()里会调用它，如果这里不声明，生成的yacc.tab.c在编译时会找不到该函数  
}  
%}  
%x COMMENT
/*非数字由大小写字母、下划线组成*/  
nondigit    ([_A-Za-z])  

/*一位数字，可以是0到9*/  
digit       ([0-9])  

/*整数或小数*/  
digits     ({digit}+)  
integer 	({digit}+|{digits}+.{digits}+)


/*标识符，以非数字开头，后跟0至多个数字或非数字*/  
identifier  ({nondigit}({nondigit}|{digit})*)  

/*不带双引号的任意字符串*/
qstring (\"[^"\n]*["\n])

/*一个或一段连续的空白符*/  
blank_chars ([ \f\r\t\v]+)  

/*关键字*/
key_words (READ|WRITE|IF|ELSE|RETURN|BEGIN|END|STRING|REAL|INT|TO|FOR|WHILE|ENDIF|ENDFOR|ENDWHILE|MAIN)
mul_char (:=|==|!=)



/*下面%%后开始第2段：规则段*/  
%%  
{key_words} {
	yylval.m_Str = yytext;
	// cout<<"<key word,"<<yytext<<">\n";
	if(!strcmp(yytext,"READ"))
		return READ;
	else if(!strcmp(yytext,"WRITE"))
		return WRITE;
	else if(!strcmp(yytext,"IF"))
		return IF;
	else if(!strcmp(yytext,"ELSE"))
		return ELSE;
	else if(!strcmp(yytext,"RETURN"))
		return RETURN;
	//else if(!strcmp(yytext,"BEGIN"))
	//	return BEGIN_;
	//else if(!strcmp(yytext,"END"))
	//	return END;
	else if(!strcmp(yytext,"STRING"))
		return STRING;
	else if(!strcmp(yytext,"REAL"))
		return REAL;
	else if(!strcmp(yytext,"INT"))
		return INT;
	else if(!strcmp(yytext,"TO"))
		return TO;
	else if(!strcmp(yytext,"FOR"))
		return FOR;
	else if(!strcmp(yytext,"WHILE"))
		return WHILE;
	// else if(!strcmp(yytext,"ENDIF"))
	// 	return ENDIF;
	// else if(!strcmp(yytext,"ENDFOR"))
	// 	return ENDFOR;
	// else if(!strcmp(yytext,"ENDWHILE"))
	// 	return ENDWHILE;
	else if(!strcmp(yytext, "MAIN"))
		return MAIN;
}


{identifier}    {    
            yylval.m_Str=yytext;
			cout<<"<id,"<<yytext<<">\n";
            return IDENTIFIER;  
}  

{integer}       {  
            yylval.m_nInt=atof(yytext);//把识别出的整数串，转换为整型值，
			cout<<"<integer,"<<yytext<<">\n";
            return INTEGER;//向yacc返回: 识别出的记号类型是INTEGER  
        }

{blank_chars}   {   
	//遇空白符时，什么也不做，忽略它们  
        }  

\n      {   
	//遇换行符时，忽略之  
        }  

{mul_char} {
	yylval.m_Str = yytext;
	cout<<"<Multi-character separators,"<<yytext<<">\n";
	if(!strcmp(yytext,":="))
		return ASSIGN;
	if(!strcmp(yytext,"=="))
		return EQUAL;
	if(!strcmp(yytext,"!="))
		return NEQUAL;
}

"/*" {
	BEGIN COMMENT;
}

{qstring} {
	return QSTRING;
}


.       {   
            yylval.m_cOp=yytext[0];
			cout<<"<Single-character operators,"<<yytext<<">\n";
			return *yytext;
        }  

<COMMENT>"*/" {
	BEGIN INITIAL;
}

%%  


int yywrap(void)  
{  
    // puts("-----the file is end");  
    return 1;//返回1表示读取全部结束。如果要接着读其它文件，可以这里fopen该文件，
             //文件指针赋给yyin，并返回0  
} 
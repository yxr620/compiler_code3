%{  

#include "main.h"  
#include "yacc.tab.h"

int line_numbering = 0;

extern "C"
{   
    int yywrap(void);  
    int yylex(void);
}  
%}  
%x COMMENT
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



/*第二段*/  
%%
{key_words} {
	yylval.m_Str = yytext;
	cout<<"<key word,"<<yytext<<">\n";
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
	else if(!strcmp(yytext, "MAIN"))
		return MAIN;
}


{identifier}    {    
            yylval.m_Str=yytext;
			cout<<"<id,"<<yytext<<">\n";
            return IDENTIFIER;  
}  

{integer}       {  
            yylval.m_nInt=atof(yytext);
			cout<<"<integer,"<<yytext<<">\n";
            return INTEGER;  
        }

{blank_chars}   {   
			//忽略空白  
        }  

\n      {   
		line_numbering++; 
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


.     {   
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
    return 1;
} 
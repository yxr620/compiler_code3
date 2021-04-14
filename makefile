main:lex.yy.o  yacc.tab.o  
	g++ lex.yy.o yacc.tab.o -o main 

lex.yy.o:lex.yy.c  yacc.tab.h  main.h  
	g++ -c lex.yy.c  

yacc.tab.o:yacc.tab.c  main.h  
	g++ -c yacc.tab.c  

yacc.tab.c  yacc.tab.h: yacc.y #  
	bison -d yacc.y

lex.yy.c: lex.l # 生成lex.yy.c 
	flex lex.l

clean:  
	# rm main.exe
	rm *.o
	rm lex.yy.c yacc.tab.c yacc.tab.h
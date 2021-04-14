#ifndef MAIN_HPP  
#define MAIN_HPP  

#include <iostream>//使用C++库  
#include <string>  
#include<vector>
#include <stdio.h>//printf和FILE要用的  

using namespace std;  

typedef enum { typeCon, typeOpr, typeKey} nodeEnum;
struct Node{
    nodeEnum type;
    double integer;
    string key_word;
    char opr;
    vector<Node*> child;
};

struct Type
{  
    string m_Str; 
    char m_cOp;  
    double m_nInt; 
    Node* nptr; 
};  
#define YYSTYPE Type

#endif
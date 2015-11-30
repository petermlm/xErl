Nonterminals
    Statements Statement
    Assign
    FunDecl Decl_Args
    Expr_Bool Expr_Bool_OR Expr_Bool_LP Expr_Add Expr_Mult Expr_Un Expr
    CallArgs.

Terminals
    def 'if'
    ':'
    identifier
    integer
    'and' 'or'
    '<' '>' '<=' '>=' '==' '!='
    '+' '-' '*' '/' '%'
    '=' ','
    open close open_b close_b
    nl.

Rootsymbol Statements.

Statements -> Statement : ['$1'].
Statements -> Statement Statements : ['$1' | '$2'].

Statement -> Expr_Add nl : {expr_stat, '$1'}.
Statement -> Assign nl : '$1'.
Statement -> FunDecl nl : '$1'.
Statement -> 'if' Expr_Bool open_b nl Statements close_b nl : {'if', '$2', '$5'}.
Statement -> Statement nl : '$1'.

Assign -> identifier '=' Expr_Add : {assign, '$1', '$3'}.

FunDecl -> def identifier open close ':' Expr_Add :
           {fun_decl, '$2', [], '$6'}.
FunDecl -> def identifier open Decl_Args close ':' Expr_Add :
           {fun_decl, '$2', '$4', '$7'}.

Decl_Args -> identifier : ['$1'].
Decl_Args -> identifier ',' Decl_Args : ['$1' | '$3'].

Expr_Bool -> Expr_Bool_OR 'and' Expr_Bool : {expr_bool, '$2', '$1', '$3'}.
Expr_Bool -> Expr_Bool_OR : '$1'.
Expr_Bool_OR -> Expr_Bool_LP 'or' Expr_Bool_OR : {expr_bool, '$2', '$1', '$3'}.
Expr_Bool_OR -> Expr_Bool_LP : '$1'.

Expr_Bool_LP -> Expr_Add '<' Expr_Bool_LP : {expr_bool_lp, '$2', '$1', '$3'}.
Expr_Bool_LP -> Expr_Add '>' Expr_Bool_LP : {expr_bool_lp, '$2', '$1', '$3'}.
Expr_Bool_LP -> Expr_Add '<=' Expr_Bool_LP : {expr_bool_lp, '$2', '$1', '$3'}.
Expr_Bool_LP -> Expr_Add '>=' Expr_Bool_LP : {expr_bool_lp, '$2', '$1', '$3'}.
Expr_Bool_LP -> Expr_Add '==' Expr_Bool_LP : {expr_bool_lp, '$2', '$1', '$3'}.
Expr_Bool_LP -> Expr_Add '!=' Expr_Bool_LP : {expr_bool_lp, '$2', '$1', '$3'}.
Expr_Bool_LP -> Expr_Add : '$1'.

Expr_Add -> Expr_Mult '+' Expr_Add : {expr, '$2', '$1', '$3'}.
Expr_Add -> Expr_Mult '-' Expr_Add : {expr, '$2', '$1', '$3'}.
Expr_Add -> Expr_Mult : '$1'.

Expr_Mult -> Expr_Un '*' Expr_Mult : {expr, '$2', '$1', '$3'}.
Expr_Mult -> Expr_Un '/' Expr_Mult : {expr, '$2', '$1', '$3'}.
Expr_Mult -> Expr_Un '%' Expr_Mult : {expr, '$2', '$1', '$3'}.
Expr_Mult -> Expr_Un : '$1'.

Expr_Un -> '-' Expr_Un : {neg, '$2'}.
Expr_Un -> Expr : '$1'.

Expr -> integer : {integer, '$1'}.
Expr -> identifier : {variable_usage, '$1'}.
Expr -> open Expr_Add close : '$2'.
Expr -> identifier open close : {fun_call, '$1', []}.
Expr -> identifier open CallArgs close : {fun_call, '$1', '$3'}.

CallArgs -> Expr_Add : ['$1'].
CallArgs -> Expr_Add ',' CallArgs : ['$1' | '$3'].

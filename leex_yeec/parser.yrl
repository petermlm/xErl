Nonterminals
    Statements Statement
    Assign
    FunDecl Decl_Args
    Expr_Add Expr_Mult Expr
    CallArgs
    F.

Terminals
    def ':'
    identifier
    integer
    '+' '-' '*' '/' '='
    ','
    open close
    nl.

Rootsymbol Statements.

Statements -> Statement : ['$1'].
Statements -> Statement Statements : ['$1' | '$2'].

Statement -> Expr_Add nl : '$1'.
Statement -> Assign nl : '$1'.
Statement -> FunDecl nl : '$1'.

Assign -> identifier '=' Expr_Add : {assign, '$1', '$3'}.

FunDecl -> def identifier open close ':' Expr_Add :
           {fun_decl, '$2', [], '$6'}.
FunDecl -> def identifier open Decl_Args close ':' Expr_Add :
           {fun_decl, '$2', '$4', '$7'}.

Decl_Args -> identifier : ['$1'].
Decl_Args -> identifier ',' Decl_Args : ['$1' | '$3'].

Expr_Add -> Expr_Mult '+' Expr_Add : {expr_add, '$2', '$1', '$3'}.
Expr_Add -> Expr_Mult '-' Expr_Add : {expr_add, '$2', '$1', '$3'}.
Expr_Add -> Expr_Mult : '$1'.

Expr_Mult -> Expr '*' Expr_Mult : {expr_mult, '$2', '$1', '$3'}.
Expr_Mult -> Expr '/' Expr_Mult : {expr_mult, '$2', '$1', '$3'}.
Expr_Mult -> Expr : '$1'.

Expr -> F : '$1'.
F -> integer : '$1'.
F -> identifier : {variable_usage, '$1'}.
F -> identifier open close : {fun_call, '$1', []}.
F -> identifier open CallArgs close : {fun_call, '$1', '$3'}.

CallArgs -> Expr_Add : ['$1'].
CallArgs -> Expr_Add ',' CallArgs : ['$1' | '$3'].

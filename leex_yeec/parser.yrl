Nonterminals
    Statements Statement If IfBody
    Assign
    FunDecl DeclArgs
    ExprBool ExprBoolOR ExprBoolLP ExprAdd ExprMult ExprUn Expr
    CallArgs.

Terminals
    def 'if' 'else' 'while'
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

Statement -> ExprAdd nl : {expr_stat, '$1'}.
Statement -> Assign nl : '$1'.
Statement -> FunDecl nl : '$1'.
Statement -> If : '$1'.
Statement -> 'while' ExprBool open_b nl Statements close_b nl : {'while', '$2', '$5'}.
Statement -> Statement nl : '$1'.

If   -> 'if' ExprBool IfBody                                     : {'if', '$2', '$3'}.
If   -> 'if' ExprBool open_b nl Statements close_b 'else' IfBody : {'ifelse', '$2', '$5', '$8'}.

IfBody -> open_b nl Statements close_b nl : '$3'.

Assign -> identifier '=' ExprAdd : {assign, '$1', '$3'}.

FunDecl -> def identifier open close ':' ExprAdd :
           {fun_decl, '$2', [], '$6'}.
FunDecl -> def identifier open DeclArgs close ':' ExprAdd :
           {fun_decl, '$2', '$4', '$7'}.

DeclArgs -> identifier : ['$1'].
DeclArgs -> identifier ',' DeclArgs : ['$1' | '$3'].

ExprBool -> ExprBoolOR 'and' ExprBool : {expr_bool, '$2', '$1', '$3'}.
ExprBool -> ExprBoolOR : '$1'.
ExprBoolOR -> ExprBoolLP 'or' ExprBoolOR : {expr_bool, '$2', '$1', '$3'}.
ExprBoolOR -> ExprBoolLP : '$1'.

ExprBoolLP -> ExprAdd '<' ExprBoolLP : {expr_bool_lp, '$2', '$1', '$3'}.
ExprBoolLP -> ExprAdd '>' ExprBoolLP : {expr_bool_lp, '$2', '$1', '$3'}.
ExprBoolLP -> ExprAdd '<=' ExprBoolLP : {expr_bool_lp, '$2', '$1', '$3'}.
ExprBoolLP -> ExprAdd '>=' ExprBoolLP : {expr_bool_lp, '$2', '$1', '$3'}.
ExprBoolLP -> ExprAdd '==' ExprBoolLP : {expr_bool_lp, '$2', '$1', '$3'}.
ExprBoolLP -> ExprAdd '!=' ExprBoolLP : {expr_bool_lp, '$2', '$1', '$3'}.
ExprBoolLP -> ExprAdd : '$1'.

ExprAdd -> ExprMult '+' ExprAdd : {expr, '$2', '$1', '$3'}.
ExprAdd -> ExprMult '-' ExprAdd : {expr, '$2', '$1', '$3'}.
ExprAdd -> ExprMult : '$1'.

ExprMult -> ExprUn '*' ExprMult : {expr, '$2', '$1', '$3'}.
ExprMult -> ExprUn '/' ExprMult : {expr, '$2', '$1', '$3'}.
ExprMult -> ExprUn '%' ExprMult : {expr, '$2', '$1', '$3'}.
ExprMult -> ExprUn : '$1'.

ExprUn -> '-' ExprUn : {neg, '$2'}.
ExprUn -> Expr : '$1'.

Expr -> integer : {integer, '$1'}.
Expr -> identifier : {variable_usage, '$1'}.
Expr -> open ExprAdd close : '$2'.
Expr -> identifier open close : {fun_call, '$1', []}.
Expr -> identifier open CallArgs close : {fun_call, '$1', '$3'}.

CallArgs -> ExprAdd : ['$1'].
CallArgs -> ExprAdd ',' CallArgs : ['$1' | '$3'].

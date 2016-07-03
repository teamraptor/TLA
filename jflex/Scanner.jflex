package Example;

import java_cup.runtime.SymbolFactory;
%%
%cup
%class Scanner
%{
	public Scanner(java.io.InputStream r, SymbolFactory sf){
		this(r);
		this.sf=sf;
	}
	private SymbolFactory sf;
%}
%eofval{
    return sf.newSymbol("EOF", sym.EOF);
%eofval}

/*
    Macro declaraciones
  
    Declaramos expresiones regulares que despues usaremos en las
    reglas lexicas.
*/

Text = \"[^\"]*\"

Var_name = [A-Za-z]([A-Za-z]|[0-9]|"_")+

Num_def = #{Var_name}

Text_def = \${Var_name}

Def = Num_def|Text_def

Constant_def = const" "{Var_name} 

%%
"\n"                { return sf.newSymbol("Jump", sym.JUMP); }
"+"                 { return sf.newSymbol("Plus", sym.PLUS); }
"-"                 { return sf.newSymbol("Minus", sym.MINUS); }
"*"                 { return sf.newSymbol("Times", sym.TIMES); }
"/"                 { return sf.newSymbol("Divide", sym.DIVIDE); }
"%"                 { return sf.newSymbol("Mod", sym.MOD); }
"("                 { return sf.newSymbol("Left Bracket", sym.LPAREN); }
")"                 { return sf.newSymbol("Right Bracket", sym.RPAREN); }

"<<"                { return sf.newSymbol("Assign", sym.ASSIGN); }  

"<+"                { return sf.newSymbol("Assign Plus", sym.AS_PLUS); }
"<-"                { return sf.newSymbol("Assign Minus", sym.AS_MINUS); }
"<*"                { return sf.newSymbol("Assign Times", sym.AS_TIMES); }
"</"                { return sf.newSymbol("Assign Divide", sym.AS_DIV); }

"BEGIN"             { return sf.newSymbol("Begin", sym.BEGIN); }
"FINISH"            { return sf.newSymbol("Finish", sym.FINISH); }

"out"               { return sf.newSymbol("Out", sym.IO_OUT); }     
"in"                { return sf.newSymbol("In", sym.IO_IN); }  

"if"                { return sf.newSymbol("If", sym.IF); }
"else"              { return sf.newSymbol("Else", sym.ELSE); }
"loop"              { return sf.newSymbol("Loop", sym.LOOP); }
"end"               { return sf.newSymbol("End", sym.END); }

"<"                 { return sf.newSymbol("Less", sym.CMP_LT); }
">"                 { return sf.newSymbol("Greater", sym.CMP_GT); }
"="                 { return sf.newSymbol("Equal", sym.CMP_EQ); }
"~="                { return sf.newSymbol("Not Equal", sym.CMP_NE); }
 
"or"                { return sf.newSymbol("Or", sym.BOOL_OR); }
"and"               { return sf.newSymbol("And", sym.BOOL_AND); } 
"~"                 { return sf.newSymbol("NOT", sym.BOOL_NOT); } 
 
"true"              { return sf.newSymbol("True", sym.TRUE); }                       
"false"             { return sf.newSymbol("False", sym.FALSE); }
    
0 | [1-9][0-9]*     { return sf.newSymbol("Integral Number", sym.NUMBER, new Integer(yytext())); }
{Var_name}          { return sf.newSymbol("Variable name", sym.VAR_NAME, new String(yytext())); }
{Constant_def}      { return sf.newSymbol("Constant name", sym.CONST_DEF, new String(yytext().substring(6))); }
{Num_def}           { return sf.newSymbol("Number definition", sym.NUM_DEF, (new String(yytext())).substring(1)); }
{Text_def}           { return sf.newSymbol("Text definition", sym.TEXT_DEF, (new String(yytext())).substring(1)); }
{Text}              { return sf.newSymbol("Text", sym.TEXT, new String(yytext())); }

[ \t\r\f]           { /* ignore white space. */ }
.                   { System.err.println("Illegal character: "+yytext()); }

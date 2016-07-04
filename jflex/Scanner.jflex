package Raptor;

import java_cup.runtime.SymbolFactory;
import java.util.HashMap;
import java.util.Map;

%%
%cup
%class Scanner
%{

    public enum VariableType { INTEGER, STRING, CONST_INTEGER, CONST_STRING;}

    private static Map<String, VariableType> variables = new HashMap<String, VariableType>();
    
    public static void registerVariable(String name, VariableType type) {
	    variables.put(name, type);
	}
	
	public static boolean variableExists(String name) {
	    return variables.containsKey(name);
	}
	
	public static VariableType getType(String name) {
	    return variables.get(name);
	}
    
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

Var_name = [A-Za-z]([A-Za-z]|[0-9]|"_")*

Num_def = #{Var_name}

Text_def = \${Var_name}

Def = Num_def|Text_def

Num_constant_def = const" "{Num_def} 
Text_constant_def = const" "{Text_def} 

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

{Var_name}          { 
                        String variableName = new String(yytext());
                        if (!variableExists(variableName)) {
                            System.err.println("Use of undeclared variable " + variableName);
                        } else {
                            VariableType type = getType(variableName);
                            switch(type){ 
                                case INTEGER: {
                                    return sf.newSymbol("Variable name", sym.NUM_VAR, variableName); 
                                }
                                case STRING: {
                                    return sf.newSymbol("Variable name", sym.TEXT_VAR, variableName); 
                                }
                                case CONST_INTEGER: {
                                    return sf.newSymbol("Constant name", sym.NUM_CONST, variableName); 
                                }
                                case CONST_STRING: {
                                    return sf.newSymbol("Constant name", sym.TEXT_CONST, variableName); 
                                }
                            } 
                        }
                    }

{Num_constant_def} { 
                        String constantName = (new String(yytext())).substring(7);
                        if (variableExists(constantName)){
                            System.err.println("Illegal redeclaration of constant " + constantName);
                        } else {
                            registerVariable(constantName, VariableType.CONST_INTEGER);
                            return sf.newSymbol("Number constant definition", sym.NUM_CONST_DEF, constantName); 
                        }
                    }

{Text_constant_def} { 
                        String constantName = (new String(yytext())).substring(7);
                        if (variableExists(constantName)){
                            System.err.println("Illegal redeclaration of constant " + constantName);
                        } else {
                            registerVariable(constantName, VariableType.CONST_STRING);
                            return sf.newSymbol("Text constant definition", sym.TEXT_CONST_DEF, constantName); 
                        }
                    }

{Num_def}           { 
                        String variableName = (new String(yytext())).substring(1);
                        if (variableExists(variableName)){
                            System.err.println("Illegal redeclaration of variable " + variableName);
                        } else {
                            registerVariable(variableName, VariableType.INTEGER);
                            return sf.newSymbol("Number definition", sym.NUM_DEF, variableName); 
                        }
                    }

{Text_def}          { 
                        String variableName = (new String(yytext())).substring(1);
                        if (variableExists(variableName)){
                            System.err.println("Illegal redeclaration of variable " + variableName);
                        } else {
                            registerVariable(variableName, VariableType.STRING);
                            return sf.newSymbol("Text definition", sym.TEXT_DEF, variableName); 
                        }
                    }

{Text}              { return sf.newSymbol("Text", sym.TEXT, new String(yytext())); }

[ \t\r\f]           { /* ignore white space. */ }
.                   { System.err.println("Illegal character: "+yytext()); }

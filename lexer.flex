import java.io.FileReader;
import java.io.FileNotFoundException;
import java.io.IOException;
import java.util.ArrayList;
import java.util.HashMap;


class Yytoken {
  public String type;
  public Object value;
  public Yytoken(String type) {
    this.type = type;
  }
  public Yytoken(String type, Object value) {
    this.type = type;
    this.value = value;
  }

  public String toString() {
    return "{"+this.type + ((this.value != null) ? (" : " + this.value) : "")  + "}";
  }
}

class Variable {
  public String type;
  public Object value;
  public Variable(String type, Object value) {
    this.type = type;
    this.value = value;
  }
  public String toString() {
    return "{"+this.type + " : " + this.value  + "}";
  }
}

%%


%unicode

%{
StringBuffer stringBuffer = new StringBuffer();

public static <T> boolean contains(final T[] array, final T v) {
    if (v == null) {
        for (final T e : array)
            if (e == null)
                return true;
    }
    else {
        for (final T e : array)
            if (e == v || v.equals(e))
                return true;
    }

    return false;
}

public static void main(String[] args) throws FileNotFoundException, IOException{
  String[] RESERVED = {"String", "Number"};
  String[] DATA_TYPES = {"STRING_LITERAL", "NUMBER"};

  // Lexing
  FileReader yyin = new FileReader(args[0]);
  boolean isValid = true;
  ArrayList<Yytoken> tokens = new ArrayList<>();
  HashMap<String, Variable> vars = new HashMap<>();

  try {
    Yylex yy = new Yylex(yyin);
    Yytoken t;
    while ((t = yy.yylex()) != null) {
      System.out.println(t.type);
      tokens.add(t);
    }
  }
  catch (Throwable e) {
    isValid = false;
    System.out.println(e.getMessage());
  }
  if (isValid) {
    System.out.println("VALID");
    } else {
      System.out.println("ERROR");
    }

    StringBuilder out = new StringBuilder("Tokens:\n");
    for (Yytoken id : tokens) {
      out.append("  " + id + "\n");
    }
    System.out.println(out.toString());

    // Parsing
    // New Var Stages: 0 = none. 1 = type set. 2 = name set. 3 = val ready.
    int newVarStage = 0;
    int oldVarStage = 0;
    String varName = "";
    String varType = "";
    try {
      for (Yytoken elem : tokens) {
        if (newVarStage == 0 && oldVarStage == 0) {
          if (elem.value != null && contains(RESERVED, String.valueOf(elem.value))) {
            newVarStage = 1;
            varType =  String.valueOf(elem.value);
          }
          if (elem.value != null && elem.type.equals("IDENTIFIER") && vars.keySet().contains(String.valueOf(elem.value))) {
            varName= String.valueOf(elem.value);
            oldVarStage = 1;
          }
        }
        else if (newVarStage > 0) {
          if (newVarStage == 1 && elem.type.equals("IDENTIFIER")) {
            varName = String.valueOf(elem.value);
            if (contains(RESERVED, varName)) {
              throw new Error("Reserved identifier.");
            }
            newVarStage = 2;
          }
          else if (newVarStage == 2 && elem.type.equals("EQ")) {
            newVarStage = 3;
          }
          else if (newVarStage == 3 && contains(DATA_TYPES, String.valueOf(elem.type))) {
            Variable newVar = new Variable(varType, elem.value);
            vars.put(varName, newVar);
            newVarStage = 0;
          }
          else {
            throw new Error("Bad variable definition." );
          }
        }
        else if (oldVarStage > 0) {
          if (oldVarStage == 1 && elem.type.equals("EQ")) {
            oldVarStage = 2;
          }
          else if (oldVarStage == 2 && contains(DATA_TYPES, String.valueOf(elem.type))) {
            varType = String.valueOf(elem.type);
            if (varType.equals("STRING_LITERAL")) {
              varType = "String";
            }
            else if (varType.equals("NUMBER")) {
              varType = "Number";
            }
            Variable oldVar = vars.get(varName);
            if (oldVar.type.equals(varType)) {
              oldVar.value = elem.value;
              oldVarStage = 0;
            }
            else {
              throw new Error("Variable type mismatch." );
            }

          }
          else {
            throw new Error("Bad variable definition." );
          }
        }

      }
    }
    catch (Throwable e) {
      isValid = false;
      System.out.println(e.getMessage());

    }

    if (isValid) {
      System.out.println("VALID");
      } else {
        System.out.println("ERROR");
      }

      out = new StringBuilder("Variables:\n");
      for (String id : vars.keySet()) {
        out.append("  " + id + "," + vars.get(id) + "\n");
      }
      System.out.println(out.toString());






    }
%}

LineTerminator = \r|\n|\r\n
InputCharacter = [^\r\n]
WhiteSpace     = {LineTerminator} | [ \t\f]
Digit          = [:digit:]+
Float          = [:digit:]+\.[:digit:]+
Identifier = [:jletter:] [:jletterdigit:]*
InvalidNumber = [:jletterdigit:]*[:jletter:]*

%state STRING
%state NUMBER

%%
<YYINITIAL> {
/* identifiers */


{InvalidNumber}                { return new Yytoken("INVALID"); }
{Float}                        {  return new Yytoken("FLOAT"); }
{Identifier}                   { return new Yytoken("IDENTIFIER", yytext()); }
{Number}                       { stringBuffer.setLength(0); stringBuffer.append( yytext() ); yybegin(NUMBER); }



/* literals */
\"                             { stringBuffer.setLength(0); yybegin(STRING); }

/* operators */
"="                            { return new Yytoken("EQ"); }
"*"                            { return new Yytoken("TIMES"); }
"+"                            { return new Yytoken("PLUS"); }
"-"                            { return new Yytoken("MINUS"); }
"/"                            { return new Yytoken("DIV"); }
"("                            { return new Yytoken("LFBRACK"); }
")"                            { return new Yytoken("RTBRACK"); }
";"                            { return new Yytoken("SEMIOLON"); }
"<"                            { return new Yytoken("LTHAN"); }
">"                            { return new Yytoken("GTHAN"); }
"=="                           { return new Yytoken("EQCOMP"); }
"<="                           { return new Yytoken("LTHANCOMP"); }
">="                           { return new Yytoken("GTHANCOMP"); }
"."                            { return new Yytoken("PERIOD"); }
"!"                            { return new Yytoken("NOT");}
"!="                           { return new Yytoken("NOTEQ"); }
"//"                           { return new Yytoken("COMMENT"); }
"##"                           { return new Yytoken("COMMENT"); }
"#"                            { return new Yytoken("INVALID"); }




/* whitespace */
{WhiteSpace}                   { /* ignore */ }

}

<NUMBER> {
[:jletter:]                     { throw new Error("Invalid or unexpected token in number <"+yytext()+">");}
{WhiteSpace}                    { yybegin(YYINITIAL);
                               return new Yytoken("NUMBER",
                               Integer.parseInt(stringBuffer.toString())); }
{Number}                       { stringBuffer.append( yytext() ); }
}

<STRING> {
\"                             { yybegin(YYINITIAL);
                               return new Yytoken("STRING_LITERAL",
                               stringBuffer.toString()); }
[^\n\r\"\\]+                   { stringBuffer.append( yytext() ); }
\\t                            { stringBuffer.append('\t'); }
\\n                            { stringBuffer.append('\n'); }
\\r                            { stringBuffer.append('\r'); }
\\\"                           { stringBuffer.append('\"'); }
\\                             { stringBuffer.append('\\'); }
}




/* error fallback */
[^]                              { throw new Error("Illegal character <"+yytext()+">"); }

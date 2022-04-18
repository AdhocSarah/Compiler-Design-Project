import java.io.FileReader;
import java.io.FileNotFoundException;
import java.io.IOException;
import java.util.ArrayList;
import java.util.HashMap;

// Sarah Klein and Lauren Marimon
// Functions as an all-in-one suite to better handle the custom classes defined for this assignment.

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

class Expression {
  public boolean simple;
  public Yytoken LHS;
  public Yytoken OP;
  public Yytoken RHS;
  String[] MATH_OPS = {"PLUS", "MINUS", "TIMES", "DIV"};
  String[] COMP_OPS = {"GTHAN", "LTHAN", "EQCOMP", "GTHANCOMP", "LTHANCOMP", "AND", "OR"};

  public void editExpr(int stage, Yytoken elem) {
    if (stage == 2) {
      LHS = elem;
    } else if (stage == 3) {
      OP = elem;
    } else if (stage == 0) {
      RHS = elem;
    }
  }

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

  public Yytoken condense() {
    if (String.valueOf(LHS.type).equals("NUMBER") && String.valueOf(RHS.type).equals("NUMBER") && contains(MATH_OPS, String.valueOf(OP.type))) {
      return new Yytoken("NUMBER");
  } else if (String.valueOf(LHS.type).equals("NUMBER") && String.valueOf(RHS.type).equals("NUMBER") && contains(COMP_OPS, String.valueOf(OP.type))){
      return new Yytoken("BOOLEAN");
  }
    throw new Error("Type mismatch in expression.");
  }

  public String toString(){
    return "   Expr: " + String.valueOf(LHS.type) + " " + String.valueOf(OP.type) + " " + String.valueOf(RHS.type);

  }


}
class Loop {
    public String type;
    public Yytoken var;
    public Yytoken OP;
    public Yytoken LHS;
    public Yytoken RHS;

    //Checks that the second component that the for loop is a boolean;
    public Yytoken makeExp(){
        Expression exp = new Expression();
        Yytoken comp = new Yytoken();
        exp.LHS = LHS;
        exp.RHS = RHS;
        exp.OP = OP;
        comp = exp.condense();
        if(String.valueOf(comp).equals("BOOLEAN")){
            return comp
        }
        throw new Error("Second component is not a valid boolean expression.");
    }
    //Edits the loop to get new values
    public void editLoop(int stage, Yytoken elem){
        if (stage ==)
        if (stage == 4){
            LHS = elem;
        }else if (stage == 5){
            OP = elem;
        } else if (stage == 6){
            RHS = elem;
        }else{
            if(elem.value.equals("NUMBER")){
                var += elem.value;
            }else {
                throw new Error("Loop cannot be incremented")
            }
        }
    }
}



class Function {
  public ArrayList<String> parameterTypes;
  public Object returnType;

  public Function() {
    this.parameterTypes = new ArrayList<>();
  }

  public void addParams (String parameterType){
    this.parameterTypes.add(parameterType);
  }

  public void setReturn(String returnType) {
    this.returnType = returnType;
  }
  public String toString() {
    return "{Function "+ "(" + this.parameterTypes.toString() + ") : " + this.returnType  + "}";
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
  String[] RESERVED = {"String", "Number", "Function", "Boolean"};
  String[] DATA_STR = {"String", "Number", "Boolean"};
  String[] STATEMENT_TYPE = {"for","if", "else", "else if", "then" };
  String[] DATA_TYPES = {"STRING_LITERAL", "NUMBER", "BOOLEAN"};
  String[] OPERATORS = {"PLUS", "MINUS", "TIMES", "DIV", "GTHAN", "LTHAN", "EQCOMP", "GTHANCOMP", "LTHANCOMP", "AND", "OR"};

  // Lexing
  FileReader yyin = new FileReader(args[0]);
  boolean isValid = true;
  ArrayList<Yytoken> tokens = new ArrayList<>();
  HashMap<String, String> varTypes = new HashMap<>();
  HashMap<String, Function> functs = new HashMap<>();

  try {
    Yylex yy = new Yylex(yyin);
    Yytoken t;
    while ((t = yy.yylex()) != null) {
      /* System.out.println(t.type); */
      tokens.add(t);
    }
  }
  catch (Throwable e) {
    isValid = false;
    System.out.println(e.getMessage());
  }
  if (isValid) {
    System.out.println("LEXER VALID");
    } else {
      System.out.println("LEXER ERROR");
    }

    StringBuilder out = new StringBuilder("Tokens:\n");
    for (Yytoken id : tokens) {
      out.append("  " + id + "\n");
    }
    /* System.out.println(out.toString()); */

    // Parsing
    // New Var Stages: 0 = none. 1 = type set. 2 = name set. 3 = val ready.
    // Old Var States: 0 = none. 1 = name retrieved. 2 = val ready.
    int newVarStage = 0;
    int oldVarStage = 0;
    int functStage = 0;
    String varName = "";
    String varType = "";
    Function funct = new Function();
    String functName = "";
    boolean typeOrName = true;

    // Build Expr. Stages: 0 = none. 1 = building LHS. 2 = getting op. 3 = building RHS.
    int buildExprStage = 0;
    Expression currExpr = new Expression();

    int buildStatement = 0;
    Statement currSt = new Statement();

    //Build loop stages: 0= none. 1 = create var. 2 = eq. 3 = value set
    // 4 = building LHS. 5 = comp. 6 = building RHS.
    // 7 = incrementing
    int buildLoop = 0;
    Loop currLoop = new Loop();


    try {
      for (Yytoken elem : tokens) {
        if (functStage != 0) {
          if (newVarStage != 0 || oldVarStage != 0) {
            throw new Error("Function definition in illegal spot.");
          }
          if (functStage == 1 && String.valueOf(elem.type).equals("IDENTIFIER") && contains(DATA_STR, String.valueOf(elem.value))) {
            funct.setReturn(String.valueOf(elem.value));
            functStage = 2;
          }
          else if (functStage == 2 && String.valueOf(elem.type).equals("IDENTIFIER")) {
            functName = String.valueOf(elem.value);
            functStage = 3;
          }
          else if (functStage == 3 && String.valueOf(elem.type).equals("LFBRACK")) {
            functStage = 4;
            typeOrName = true;
          }
          else if (functStage == 4) {
            if (String.valueOf(elem.type).equals("RTBRACK")) {
              functStage = 0;
              functs.put(functName, funct);
              System.out.println("New Funct: " + functName + " - " + funct.toString());
            }
            else if (typeOrName && String.valueOf(elem.type).equals("IDENTIFIER") && contains(DATA_STR, String.valueOf(elem.value))) {
              funct.addParams(String.valueOf(elem.value));
              typeOrName = false;
            } else if (!typeOrName && String.valueOf(elem.type).equals("IDENTIFIER") && !contains(DATA_STR, String.valueOf(elem.value))) {
              typeOrName = true;
            }
          }

        }
        else if (String.valueOf(elem.type).equals("IDENTIFIER") && String.valueOf(elem.value).equals("Function")) {
          functStage = 1;
          funct = new Function();
        }
        else {
        if (buildExprStage != 0 || (buildExprStage == 0 && contains(DATA_TYPES, String.valueOf(elem.type)))) {
          /* System.out.println("Adding to expr @ " + buildExprStage + " w/ " + String.valueOf(elem.type)); */
          if (buildExprStage < 2) {
            buildExprStage = 2;
          } else if (buildExprStage == 2 && contains(OPERATORS, String.valueOf(elem.type))) {
            // Operator found.
            buildExprStage = 3;
          } else if (buildExprStage == 3) {
              buildExprStage = 0;
          }
          /* System.out.println("Adding to expr @ " + buildExprStage + " w/ " + String.valueOf(elem.type)); */
          currExpr.editExpr(buildExprStage, elem);
          if (buildExprStage == 0) {
            elem = currExpr.condense();
            elem.value = "EXPRESSION";
            /* System.out.println(currExpr);
            System.out.println(elem.type + ((elem.value != null) ? " - "+ elem.value : "")); */
          }
          // TODO: Handle expression building and type checking
          // TODO: Ignore values because we don't calculate
        }
        if (buildLoop != 0 || buildStatement == 0 && containts(STATEMENT_TYPE, String.valueOf(elem.type))){
            if (elem.type.equals("for")){
                currLoop.type = "for";
            }
            currLoop.editLoop(buildLoop,elem);

            if (buildLoop >= 7){
                elem = currLoop.makeExp();
                elem.value = "LOOP";
            }

        }
        System.out.println(elem.type + ((elem.value != null) ? " - "+ elem.value : ""));
        if (buildExprStage == 0 || (buildExprStage == 1 && (newVarStage != 0 || oldVarStage != 0))) {
          if (newVarStage == 0 && oldVarStage == 0) {

            if (elem.value != null && contains(RESERVED, String.valueOf(elem.value))) {
              newVarStage = 1;
              buildExprStage = 0;
              varType =  String.valueOf(elem.value);
            }
            else if (elem.value != null && elem.type.equals("IDENTIFIER") && varTypes.keySet().contains(String.valueOf(elem.value))) {
              varName= String.valueOf(elem.value);
              buildExprStage = 0;
              oldVarStage = 1;
            }
          }
          else if (newVarStage > 0) {
            if (newVarStage == 1 && elem.type.equals("IDENTIFIER")) {
              varName = String.valueOf(elem.value);

              if (contains(RESERVED, varName)) {
                throw new Error("Error: Reserved identifier.");
              }
              newVarStage = 2;
            }
            else if (newVarStage == 2 && elem.type.equals("EQ")) {
              newVarStage = 3;
              buildExprStage = 1;
              currExpr = new Expression();
            }
            else if (newVarStage == 3 && contains(DATA_TYPES, String.valueOf(elem.type))) {
              String valType = String.valueOf(elem.type);
              if (valType.equals("STRING_LITERAL")) {
                valType = "String";
              }
              else if (valType.equals("NUMBER")) {
                valType = "Number";
            }
            else if (valType.equals("BOOLEAN")){
                valType = "Boolean";
            }
              if (valType.equals(varType)) {
                varTypes.put(varName, varType);
                newVarStage = 0;
              }
              else {
                throw new Error("Variable type mismatch." );
              }

            }
            else {
              throw new Error("Bad variable definition." );
            }
          }
          else if (oldVarStage > 0) {
            if (oldVarStage == 1 && elem.type.equals("EQ")) {
              oldVarStage = 2;
              buildExprStage = 1;
              currExpr = new Expression();

            }
            else if (oldVarStage == 2 && contains(DATA_TYPES, String.valueOf(elem.type))) {
              varType = String.valueOf(elem.type);
              if (varType.equals("STRING_LITERAL")) {
                varType = "String";
              }
              else if (varType.equals("NUMBER")) {
                varType = "Number";
              }
              else if (varType.equals("BOOLEAN")){
                  varType = "Boolean";
              }
              if (varTypes.get(varName).equals(varType)) {
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
      }
    }
    catch (Throwable e) {
      isValid = false;
      System.out.println(e.getMessage());

    }

    if (isValid) {
      System.out.println("PARSER VALID");
      } else {
        System.out.println("PARSER ERROR");
      }


      out = new StringBuilder("Variables:\n");
      for (String id : varTypes.keySet()) {
        out.append("  " + id + ": " + varTypes.get(id) + "\n");
      }
      System.out.println(out.toString());

    }
%}

LineTerminator = \r|\n|\r\n
InputCharacter = [^\r\n]
WhiteSpace     = {LineTerminator} | [ \t\f]
Number          = -?[:digit:]+
Float          = [:digit:]+\.[:digit:]+
Identifier = [:jletter:] [:jletterdigit:]*
InvalidNumber = [:jletterdigit:]*[:jletter:]*\
Boolean = true | false


%state STRING
%state NUMBER

%%
<YYINITIAL> {
/* identifiers */

{Identifier}                   { return new Yytoken("IDENTIFIER", yytext()); }
/* {InvalidNumber}                { return new Yytoken("INVALID"); } */
{Float}                        {  return new Yytoken("FLOAT"); }
{Number}                       { stringBuffer.setLength(0); stringBuffer.append( yytext() ); yybegin(NUMBER);}
{Boolean}                      { return new Yytoken("BOOLEAN"); }



/* literals */
\"                             { stringBuffer.setLength(0); yybegin(STRING); }

/* operators */
//SYNTAX
"="                            { return new Yytoken("EQ"); }
"&&"                           { return new Yytoken("AND"); }
"||"                           { return new Yytoken("OR"); }
"."                            { return new Yytoken("PERIOD"); }
"!"                            { return new Yytoken("NOT");}
"("                            { return new Yytoken("LFBRACK"); }
")"                            { return new Yytoken("RTBRACK"); }
";"                            { return new Yytoken("SEMICOLON"); }

//MATH OPERATORS
"*"                            { return new Yytoken("TIMES"); }
"+"                            { return new Yytoken("PLUS"); }
"-"                            { return new Yytoken("MINUS"); }
"/"                            { return new Yytoken("DIV"); }



//COMPARISON OPERATORS
"<"                            { return new Yytoken("LTHAN"); }
">"                            { return new Yytoken("GTHAN"); }
"=="                           { return new Yytoken("EQCOMP"); }
"<="                           { return new Yytoken("LTHANCOMP"); }
">="                           { return new Yytoken("GTHANCOMP"); }
"!="                           { return new Yytoken("NOTEQ"); }


"//"                           { return new Yytoken("COMMENT"); }
"##"                           { return new Yytoken("COMMENT"); }
"#"                            { return new Yytoken("INVALID"); }




/* whitespace */
{WhiteSpace}                   { /* ignore */ }

}

<NUMBER> {
[:jletter:]                     { throw new Error("Invalid or unexpected token in number <"+yytext()+">");}
{WhiteSpace}                    { try {yybegin(YYINITIAL);
                               return new Yytoken("NUMBER",
                               Integer.parseInt(stringBuffer.toString())); } catch (Throwable e) {throw new Error("Invalid number.");}}
[:digit:]                       { stringBuffer.append( yytext() ); }
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

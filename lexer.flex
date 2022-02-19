import java.io.FileReader;
import java.io.FileNotFoundException;
import java.io.IOException;

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
}

%%

%unicode

%{
StringBuffer stringBuffer = new StringBuffer();

public static void main(String[] args) throws FileNotFoundException, IOException{
            FileReader yyin = new FileReader(args[0]);
            boolean isValid = true;
            try {
              Yylex yy = new Yylex(yyin);
              Yytoken t;
              while ((t = yy.yylex()) != null) {
                //System.out.println(t.type);
              }
            }
            catch (Throwable e) {
              isValid = false;
              //System.out.println(e.getMessage());
            }
            if (isValid) {
              System.out.println("VALID");
            } else {
              System.out.println("ERROR");
            }
}
%}

LineTerminator = \r|\n|\r\n
InputCharacter = [^\r\n]
WhiteSpace     = {LineTerminator} | [ \t\f]

Identifier = [:jletter:] [:jletterdigit:]*


%state STRING

%%
<YYINITIAL> {
/* identifiers */
{Identifier}                   { return new Yytoken("IDENTIFIER"); }

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


/* whitespace */
{WhiteSpace}                   { /* ignore */ }
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

# Compiler Design Project

Created for CSU 33071 "Compiler Design" by Sarah Klein and Lauren Marimon.

Currently only handles basic lexing.

### Requirements:
* jflex
* javac

### To Use:

#### Build Lexer:

```sh
jflex lexer.flex

javac Yylex.java
```

#### Run:

Add code to `test.code`

```sh
java Yylex test.code
```

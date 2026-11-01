%{
#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include <string.h>

#define DEG2RAD(x) ((x) * M_PI / 180.0) // Convert degrees to radians

int yylex(void);
void yyerror(const char *s);

char* dec_to_hex(double num) {
    char *res = malloc(20);
    sprintf(res, "%X", (int)num);
    return res;
}

char* dec_to_oct(double num) {
    char *res = malloc(20);
    sprintf(res, "%o", (int)num);
    return res;
}

char* dec_to_bin(double num) {
    /* Build in a stack buffer, then make exactly ONE heap allocation via
       strdup. The original version malloc'd a 65-byte buffer and then
       returned strdup(ptr-into-that-buffer), leaking the original block
       every call. */
    char buf[33];
    int n = (int)num;
    int i = 0;
    for (int bit = 31; bit >= 0; bit--) {
        buf[i++] = (n & (1 << bit)) ? '1' : '0';
    }
    buf[i] = '\0';
    char *ptr = buf;
    while (*ptr == '0' && *(ptr + 1) != '\0') ptr++;
    return strdup(ptr);
}

double hex_to_dec(const char *hex) {
    int num;
    sscanf(hex, "%x", &num);
    return num;
}

double oct_to_dec(const char *oct) {
    int num;
    sscanf(oct, "%o", &num);
    return num;
}

double bin_to_dec(const char *bin) {
    int num = 0;
    while (*bin) {
        num = num * 2 + (*bin++ - '0');
    }
    return num;
}

/* Reject strings containing digits that aren't valid in the given base,
   instead of silently producing garbage (e.g. BIN2DEC("1F") used to
   return 24; OCT2DEC("9") used to return an uninitialized value). */
int is_valid_digits(const char *s, int base) {
    if (!s || !*s) return 0;
    for (const char *p = s; *p; p++) {
        int d;
        if (*p >= '0' && *p <= '9') d = *p - '0';
        else if (*p >= 'a' && *p <= 'f') d = *p - 'a' + 10;
        else if (*p >= 'A' && *p <= 'F') d = *p - 'A' + 10;
        else return 0;
        if (d >= base) return 0;
    }
    return 1;
}
%}

%union {
    double val;
    char* str;
}

%token <val> NUMBER
%token <str> STRING
%token SIN COS TAN LOG LN SQRT EXP
%token DEC2HEX HEX2DEC DEC2OCT OCT2DEC DEC2BIN BIN2DEC
%left '+' '-'
%left '*' '/' '%'
%left UMINUS
%right '^'

%type <val> expression
%type <str> conversion

%%
input:
    /* empty */
    | input line
;

line:
    '\n'
    | expression '\n'   { printf("Result: %g\n", $1); }
    | conversion '\n'   { printf("Result: %s\n", $1); free($1); }
    | error '\n'        { yyerrok; }
;

expression:
      NUMBER
    | expression '+' expression   { $$ = $1 + $3; }
    | expression '-' expression   { $$ = $1 - $3; }
    | expression '*' expression   { $$ = $1 * $3; }
    | expression '/' expression   { $$ = $1 / $3; }
    | expression '%' expression   { $$ = fmod($1, $3); }
    | expression '^' expression   { $$ = pow($1, $3); }
    | '-' expression %prec UMINUS { $$ = -$2; }
    | '(' expression ')'          { $$ = $2; }
    | SIN '(' expression ')'      { $$ = sin(DEG2RAD($3)); }
    | COS '(' expression ')'      { $$ = cos(DEG2RAD($3)); }
    | TAN '(' expression ')'      { $$ = tan(DEG2RAD($3)); }
    | LOG '(' expression ')'      {
          if ($3 <= 0) { yyerror("log of non-positive number"); YYERROR; }
          $$ = log10($3);  /* base-10 log */
      }
    | LN  '(' expression ')'      {
          if ($3 <= 0) { yyerror("ln of non-positive number"); YYERROR; }
          $$ = log($3);    /* natural log */
      }
    | SQRT '(' expression ')'     {
          if ($3 < 0) { yyerror("sqrt of negative number"); YYERROR; }
          $$ = sqrt($3);
      }
    | EXP '(' expression ')'      { $$ = exp($3); }
;

conversion:
      DEC2HEX '(' expression ')'   { $$ = dec_to_hex($3); }
    | DEC2OCT '(' expression ')'   { $$ = dec_to_oct($3); }
    | DEC2BIN '(' expression ')'   { $$ = dec_to_bin($3); }
    | HEX2DEC '(' STRING ')'       {
          double val = hex_to_dec($3); free($3);
          char *res = malloc(50); snprintf(res, 50, "%g", val); $$ = res;
      }
    | OCT2DEC '(' STRING ')'       {
          if (!is_valid_digits($3, 8)) { yyerror("invalid octal digits"); free($3); YYERROR; }
          double val = oct_to_dec($3); free($3);
          char *res = malloc(50); snprintf(res, 50, "%g", val); $$ = res;
      }
    | BIN2DEC '(' STRING ')'       {
          if (!is_valid_digits($3, 2)) { yyerror("invalid binary digits"); free($3); YYERROR; }
          double val = bin_to_dec($3); free($3);
          char *res = malloc(50); snprintf(res, 50, "%g", val); $$ = res;
      }
;
%%

void yyerror(const char *s) {
    fprintf(stderr, "Error: %s\n", s);
}

int main() {
    printf("Calculator with Conversion (Degrees for trig, log base 10)\n");
    printf("Type 'quit' or 'exit' to leave. Constants: pi, e\n");
    printf("Enter expressions or conversions:\n");
    yyparse();
    return 0;
}

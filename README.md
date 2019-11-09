# Assignment Five
Alberto Oliart Ros - Compiler Design
Jesús Antonio González Quevedo - A00399890

Compile using the following.
```bash
lex flex.l && bison -d bison.y
gcc lex.yy.c bison.tab.c -lfl -o run.out
./run.out
```
main: part1.b part2.b double.o
	b part1.b -C link-args='double.o -lm'
	b part2.b -C link-args='double.o -lm'

double.o: double.c
	gcc -Wall -Wextra -c double.c -g -ggdb 

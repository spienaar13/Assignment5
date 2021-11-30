# Macros                                                                                                                                                                                                    
CC = gcc217
# CC = gcc217m                                                                                                                                                                                              
CFLAGS =
CFLAGS = -g                                                                                                                                                                                               
# CFLAGS = -D NDEBUG                                                                                                                                                                                        
# CFLAGS = -D NDEBUG -O                                                                                                                                                                                     
# Dependency rules for non-file targets                                                                                                                                                                     
all: fibc fibs
clobber: clean
         rm -f *~ \#*\#
clean:
        rm -f fibc*.o
        rm -f fibs*.o
# Dependency rules for fibc                                                                                                                                                                     
fibc: fib.o bigint.o bigintadd.o
  $(CC) $(CFLAGS) fibc.o bigint.o bigintadd.o -o fibc
fib.o: fib.c bigint.h
  $(CC) $(CFLAGS) -c fib.c
bigint.o: bigint.c bigint.h bigintprivate.h
  $(CC) $(CFLAGS) -c bigint.c
bigintadd.o: bigintadd.c bigint.h bigintprivate.h
  $(CC) $(CFLAGS) -c bigint.c

# Dependency rules for fibs                                                                                                                                                                     
fibs: fib.o bigint.o bigintadd.o
  $(CC) $(CFLAGS) fibc.o bigint.o bigintadd.o -o fibc
fib.o: fib.c bigint.h
  $(CC) $(CFLAGS) -c fib.c
bigint.o: bigint.c bigint.h bigintprivate.h
  $(CC) $(CFLAGS) -c bigint.c
bigintadd.o: bigintadd.s
  $(CC) $(CFLAGS) -c bigintadd.s


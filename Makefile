# Macros                                                                                                                                                                                                    
CC = gcc217
# CC = gcc217m

#CFLAGS = -g

#CFLAGS = -D NDEBUG                                                                                                                                                                                        
CFLAGS = -D NDEBUG -O                                                                                                                                                                                     
# Dependency rules for non-file targets                                                                                                                                                                     
all: fibc fibs
clobber: clean
	rm -f *~ \#*\#

# Dependency rules for fibc                                                                                                                                                                     
fibc: bigint.h bigintprivate.h 
	$(CC) fib.c bigint.c bigintadd.c -o fibc

# Dependency rules for fibs                                                                                                                                                                     
fibs: bigint.h bigintprivate.h
	$(CC) $(CFLAGS) fib.c bigint.c bigintadd.s -o fibs

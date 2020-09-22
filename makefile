prefix=/usr/local

CFLAGS += -Wall
CXXFLAGS += -D_GLIBCXX_DEBUG -std=c++14 -Wall -Werror -Wno-psabi -fmax-errors=5 
LDLIBS += -lm

all: wspr gpioclk

mailbox.o: mailbox.c mailbox.h
	$(CC) $(CFLAGS) -c mailbox.c

nhash.o: nhash.c nhash.h
	$(CC) $(CFLAGS) -c nhash.c

wspr: mailbox.o nhash.o wspr.cpp mailbox.h
	$(CXX) $(CXXFLAGS) $(LDFLAGS) $(LDLIBS) $(PI_VERSION) -I/opt/vc/include -L/opt/vc/lib -lbcm_host mailbox.o nhash.o wspr.cpp -o wspr

gpioclk: gpioclk.cpp
	$(CXX) $(CXXFLAGS) $(LDFLAGS) $(LDLIBS) $(PI_VERSION) -I/opt/vc/include -L/opt/vc/lib -lbcm_host gpioclk.cpp -o gpioclk

clean:
	$(RM) *.o gpioclk wspr

.PHONY: install
install: wspr
	install -m 4755 wspr $(prefix)/bin
	install -m 4755 gpioclk $(prefix)/bin

.PHONY: uninstall
uninstall:
	$(RM) $(prefix)/bin/wspr $(prefix)/bin/gpioclk


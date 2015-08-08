CXX=clang++
CXXFLAGS=-Wall -Werror -Wextra -pedantic -Wno-char-subscripts -Wno-sign-compare -Wno-unknown-pragmas -g -std=c++14 -Iuri/src/ -fdiagnostics-color -Wl,-E
LIBFLAGS=-shared -fPIC -fvisibility=hidden
LIBS=uri/_build/src/libnetwork-uri.a -lboost_system
LPARSER=-Llib -lsparqlxx-parser
LREADLINE=-lreadline -DUSE_READLINE
#LREADLINE=

.PHONY: test test_parser_internal test_parse test_database_sparqlite clean

all: lib/libsparqlxx-parser.so lib/libsparqlite.so bin/sparql_to_sse bin/sparql test

test: test_parser_internal test_parse test_database_sparqlite

test_parser_internal: bin/test_parser_internal
	./bin/test_parser_internal

test_parse: bin/test_parse
	LD_LIBRARY_PATH=lib ./bin/test_parse

test_database_sparqlite: bin/test_database
	LD_LIBRARY_PATH=lib ./bin/test_database sparqlite

lib/libsparqlxx-parser.so: *.h parser/*.h parser/tokenize.cpp parser/parse.cpp parser/read_*.cpp
	@test -d lib/ || mkdir -p lib/
	$(CXX) $(CXXFLAGS) $(LIBFLAGS) parser/tokenize.cpp parser/parse.cpp parser/read_*.cpp -Wl,-soname,libsparqlxx-parser.so.0 -o ./lib/libsparqlxx-parser.so.0
	rm -f ./lib/libsparqlxx-parser.so
	ln -s libsparqlxx-parser.so.0 ./lib/libsparqlxx-parser.so

bin/test_parser_internal: *.h parser/*.h parser/tokenize.cpp parser/parse.cpp parser/read_*.cpp parser/test.cpp
	@test -d bin/ || mkdir -p bin/
	$(CXX) $(CXXFLAGS) parser/*.cpp $(LIBS) -o bin/test_parser_internal

lib/libsparqlite.so: *.h lib/libsparqlxx-parser.so sparqlite/*.h sparqlite/*.cpp
	@test -d lib/ || mkdir -p lib/
	$(CXX) $(CXXFLAGS) $(LIBFLAGS) sparqlite/database.cpp sparqlite/query.cpp sparqlite/update.cpp sparqlite/think.cpp $(LPARSER) -Wl,-soname,libsparqlite.so.0 -o ./lib/libsparqlite.so.0
	rm -f ./lib/libsparqlite.so
	ln -s libsparqlite.so.0 ./lib/libsparqlite.so

bin/sparql_to_sse: lib/libsparqlxx-parser.so sparql_to_sse/main.cpp
	@test -d bin/ || mkdir -p bin/
	$(CXX) $(CXXFLAGS) sparql_to_sse/main.cpp $(LPARSER) $(LIBS) -o bin/sparql_to_sse

bin/sparql: *.h lib/libsparqlxx-parser.so lib/libsparqlite.so console/main.cpp
	@test -d bin/ || mkdir -p bin/
	$(CXX) $(CXXFLAGS) console/main.cpp -ldl $(LPARSER) $(LREADLINE) $(LIBS) -o bin/sparql

bin/test_parse: tests/test_parse.cpp lib/libsparqlxx-parser.so
	@test -d bin/ || mkdir -p bin/
	$(CXX) $(CXXFLAGS) tests/test_parse.cpp $(LPARSER) $(LIBS) -o bin/test_parse

bin/test_database: *.h tests/test_database.cpp lib/libsparqlite.so
	@test -d bin/ || mkdir -p bin/
	$(CXX) $(CXXFLAGS) tests/test_database.cpp -ldl $(LPARSER) $(LIBS) -o bin/test_database

clean:
	rm -rf bin lib
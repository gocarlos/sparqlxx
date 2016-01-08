#include "../database.h"
#include "../RDF.h"

using namespace sparqlxx;

void test_insert_select_match(char* dsn)
{
	auto db = Database{dsn};

	db.insert({{Iri{"http://lew21.net/a"}, Iri{RDF::type}, Iri{"http://lew21.net/exampletype"}, Iri{"http://whatever"}}});

	auto res = db.select({{Var{"obj"}, Iri{RDF::type}, Iri{"http://lew21.net/exampletype"}, Iri{"http://whatever"}}});
	assert(res.vars.size() == 1);
	assert(res.vars[0] == Var{"obj"});
	assert(res.rows.size() == 1);
	assert(res.rows[0].size() == 1);
	assert(res.rows[0][0].is<Iri>());
	assert(res.rows[0][0].get<Iri>() == Iri{"http://lew21.net/a"});
}

void test_insert_select_nomatch(char* dsn)
{
	auto db = Database{dsn};

	db.insert({{Iri{"http://lew21.net/a"}, Iri{RDF::type}, Iri{"http://lew21.net/exampletype"}, Iri{"http://whatever"}}});

	auto res = db.select({{Var{"obj"}, Iri{RDF::type}, Iri{"XXX"}, Iri{"http://whatever"}}});
	assert(res.vars.size() == 1);
	assert(res.vars[0] == Var{"obj"});
	assert(res.rows.size() == 0);
}

void test_insert_select_two_patterns(char* dsn)
{
	auto db = Database{dsn};

	db.insert({
		{Iri{"http://lew21.net/a"}, Iri{RDF::type}, Iri{"http://lew21.net/exampletype"}, Iri{"http://whatever"}},
		{Iri{"http://lew21.net/exampletype"}, Iri{RDF::type}, Iri{RDF::Class}, Iri{"http://whatever"}},
	});

	auto res = db.select({
		{Var{"obj"}, Iri{RDF::type}, Var{"class"}, Iri{"http://whatever"}},
		{Var{"class"}, Iri{RDF::type}, Iri{RDF::Class}, Iri{"http://whatever"}},
	});

	assert(res.vars.size() == 2);
	assert(res.vars[0] == Var{"obj"});
	assert(res.vars[1] == Var{"class"});
	assert(res.rows.size() == 1);
	assert(res.rows[0].size() == 2);
	assert(res.rows[0][0].is<Iri>());
	assert(res.rows[0][0].get<Iri>() == Iri{"http://lew21.net/a"});
	assert(res.rows[0][1].is<Iri>());
	assert(res.rows[0][1].get<Iri>() == Iri{"http://lew21.net/exampletype"});
}

int main(int argc, char** argv)
{
	assert(argc >= 2);
	test_insert_select_match(argv[1]);
	test_insert_select_nomatch(argv[1]);
	test_insert_select_two_patterns(argv[1]);
	return 0;
}
#include "symbol_info.h"
#include <fstream>
#include <vector>
#include <list>
#include <string>
using namespace std;

class scope_table
{
private:
    int bucket_count;
    int unique_id;
    scope_table *parent_scope = NULL;
    vector<list<symbol_info *>> table;

    int hash_function(string name)
    {
    int hash_val = 0;

    for(char c : name)
    {
        hash_val += (int)c;   // sum of ASCII values
    }

    return hash_val % bucket_count;
    }

public:
    scope_table();
    scope_table(int bucket_count, int unique_id, scope_table *parent_scope = NULL);
    void set_parent_scope(scope_table *parent);
    scope_table *get_parent_scope();
    int get_unique_id();
    symbol_info *lookup_in_scope(symbol_info* symbol);
    symbol_info *lookup(string name);
    bool insert(symbol_info* symbol);
    bool insert_in_scope(symbol_info* symbol);
    bool delete_from_scope(symbol_info* symbol);
    void print_scope_table(ofstream& outlog);
    ~scope_table();

    // you can add more methods if you need
};

// complete the methods of scope_table class
scope_table::scope_table() : bucket_count(0), unique_id(0), parent_scope(NULL) {}

scope_table::scope_table(int n, int id, scope_table *parent) : bucket_count(n), unique_id(id), parent_scope(parent)
{
    table.resize(n);
}

void scope_table::set_parent_scope(scope_table *parent)
{
    parent_scope = parent;
}

scope_table* scope_table::get_parent_scope()
{
    return parent_scope;
}

int scope_table::get_unique_id()
{
    return unique_id;
}

symbol_info* scope_table::lookup(string name)
{
    int idx = hash_function(name);
    for(symbol_info* s : table[idx])
        if(s != NULL && s->get_name() == name) return s;
    return NULL;
}

symbol_info* scope_table::lookup_in_scope(symbol_info* symbol)
{
    if(symbol == NULL) return NULL;
    return lookup(symbol->get_name());
}

bool scope_table::insert_in_scope(symbol_info* symbol)
{
    if(symbol == NULL) return false;
    if(lookup(symbol->get_name()) != NULL) return false;
    int idx = hash_function(symbol->get_name());
    table[idx].push_back(symbol);
    return true;
}

bool scope_table::insert(symbol_info* symbol)
{
    return insert_in_scope(symbol);
}

bool scope_table::delete_from_scope(symbol_info* symbol)
{
    if(symbol == NULL) return false;
    int idx = hash_function(symbol->get_name());
    for(auto it = table[idx].begin(); it != table[idx].end(); it++)
    {
        if(*it != NULL && (*it)->get_name() == symbol->get_name())
        {
            table[idx].erase(it);
            return true;
        }
    }
    return false;
}

void scope_table::print_scope_table(ofstream& outlog)
{
    outlog << "ScopeTable # " << unique_id << endl;

    //iterate through the current scope table and print the symbols and all relevant information
    for(int i = 0; i < bucket_count; i++)
    {
        if(table[i].empty()) continue;
        for(symbol_info* s : table[i])
        {
            if(s != NULL)
            {
                outlog << i << " --> " << endl;
                outlog << "< " << s->get_name() << " : ID >" << endl;
                string cat = s->get_symbol_category();
                if(cat == "variable")
                {
                    outlog << "Variable" << endl;
                    outlog << "Type: " << s->get_data_type() << endl;
                }
                else if(cat == "array")
                {
                    outlog << "Array" << endl;
                    outlog << "Type: " << s->get_data_type() << endl;
                    outlog << "Size: " << s->get_array_size() << endl;
                }
                else if(cat == "function")
                {
                    outlog << "Function Definition" << endl;
                    outlog << "Return Type: " << s->get_data_type() << endl;
                    outlog << "Number of Parameters: " << s->get_param_count() << endl;
                    outlog << "Parameter Details: " << s->get_param_details() << endl;
                }
                outlog << endl;
            }
        }
    }
    outlog << endl;
}

scope_table::~scope_table()
{
    for(int i = 0; i < bucket_count; i++)
        for(symbol_info* s : table[i])
            if(s != NULL) delete s;
}
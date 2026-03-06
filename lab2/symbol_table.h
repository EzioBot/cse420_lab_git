#ifndef SYMBOL_TABLE_H
#define SYMBOL_TABLE_H

#include "scope_table.h"
#include <fstream>
#include <iostream>
using namespace std;

class symbol_table
{
private:
    scope_table *current_scope;
    int bucket_count;
    int current_scope_id;

public:

    // Constructor
    symbol_table(int bucket_count)
    {
        this->bucket_count = bucket_count;
        current_scope_id = 1;

        current_scope = new scope_table(bucket_count, current_scope_id);
    }

    // Destructor
    ~symbol_table()
    {
        while(current_scope != NULL)
        {
            scope_table* temp = current_scope;
            current_scope = current_scope->get_parent_scope();
            delete temp;
        }
    }

    // Enter new scope
    void enter_scope()
    {
        current_scope_id++;

        scope_table* new_scope = new scope_table(bucket_count, current_scope_id);

        new_scope->set_parent_scope(current_scope);

        current_scope = new_scope;
    }

    // Exit current scope
    void exit_scope()
    {
        if(current_scope == NULL) return;

        scope_table* temp = current_scope;
        current_scope = current_scope->get_parent_scope();

        delete temp;
    }

    // Insert symbol in current scope
    bool insert(symbol_info* symbol)
    {
        if(current_scope == NULL) return false;

        return current_scope->insert_in_scope(symbol);
    }

    // Remove symbol from current scope
    bool remove(symbol_info* symbol)
    {
        if(current_scope == NULL) return false;

        return current_scope->delete_from_scope(symbol);
    }

    // Lookup symbol in all scopes
    symbol_info* lookup(symbol_info* symbol)
    {
        scope_table* temp = current_scope;

        while(temp != NULL)
        {
            symbol_info* result = temp->lookup_in_scope(symbol);

            if(result != NULL)
                return result;

            temp = temp->get_parent_scope();
        }

        return NULL;
    }

    // Print current scope
    void print_current_scope(ofstream& outlog)
    {
        if(current_scope != NULL)
            current_scope->print_scope_table(outlog);
    }

    // Print all scopes
    void print_all_scopes(ofstream& outlog)
    {
        outlog<<"################################"<<endl<<endl;

        scope_table *temp = current_scope;

        while (temp != NULL)
        {
            temp->print_scope_table(outlog);
            temp = temp->get_parent_scope();
        }

        outlog<<"################################"<<endl<<endl;
    }
};

#endif
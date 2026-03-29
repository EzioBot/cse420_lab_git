#ifndef SYMBOL_INFO_H
#define SYMBOL_INFO_H

#include<bits/stdc++.h>
using namespace std;

class symbol_info
{
private:
    string name;
    string type;

    // variable / array / function
    string symbol_category;

    // datatype or return type
    string data_type;

    // array size
    int array_size;

    // function parameter information
    vector<string> param_types;
    int param_count;
    string param_details;

    // pointer for hash table chaining
    symbol_info* next;

public:

    // Constructor
    symbol_info(string name = "", string type = "")
    {
        this->name = name;
        this->type = type;

        symbol_category = "";
        data_type = "";
        array_size = 0;
        param_count = 0;
        param_details = "";

        next = NULL;
    }

    // -------- GET--------

    string get_name()
    {
        return name;
    }

    string get_type()
    {
        return type;
    }

    string get_symbol_category()
    {
        return symbol_category;
    }

    string get_data_type()
    {
        return data_type;
    }

    int get_array_size()
    {
        return array_size;
    }

    int get_param_count()
    {
        return param_count;
    }

    vector<string> get_param_types()
    {
        return param_types;
    }

    string get_param_details()
    {
        return param_details;
    }

    void set_param_details(string details)
    {
        param_details = details;
    }

    symbol_info* get_next()
    {
        return next;
    }

    // -------- SET --------

    void set_name(string name)
    {
        this->name = name;
    }

    void set_type(string type)
    {
        this->type = type;
    }

    void set_symbol_category(string category)
    {
        symbol_category = category;
    }

    void set_data_type(string dtype)
    {
        data_type = dtype;
    }

    void set_array_size(int size)
    {
        array_size = size;
    }

    void set_param_count(int count)
    {
        param_count = count;
    }

    void add_param_type(string type)
    {
        param_types.push_back(type);
    }

    void set_param_types(vector<string> types)
    {
        param_types = types;
    }

    void clear_param_types()
    {
        param_types.clear();
    }

    void set_next(symbol_info* next)
    {
        this->next = next;
    }

    // Destructor
    ~symbol_info()
    {
        param_types.clear();   // clear parameter list
        next = NULL;           // detach pointer
    }
};

#endif
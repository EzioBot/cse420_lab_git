#ifndef AST_H
#define AST_H

#include <iostream>
#include <vector>
#include <string>
#include <fstream>
#include <map>

using namespace std;


inline string new_temp(int& temp_count) {
    return "t" + to_string(temp_count++);
}

inline string new_label(int& label_count) {
    return "L" + to_string(label_count++);
}


class ASTNode {
public:
    virtual ~ASTNode() {}
    virtual string generate_code(ofstream& outcode,
                                 map<string, string>& symbol_to_temp,
                                 int& temp_count,
                                 int& label_count) const = 0;
};

// ── ExprNode ──────────────────────────────────────────────────────────────────
class ExprNode : public ASTNode {
protected:
    string node_type;
public:
    ExprNode(string type) : node_type(type) {}
    virtual string get_type() const { return node_type; }
};

// ── VarNode ───────────────────────────────────────────────────────────────────

class VarNode : public ExprNode {
private:
    string name;
    ExprNode* index; // For array access, nullptr for simple variables

public:
    VarNode(string name, string type, ExprNode* idx = nullptr)
        : ExprNode(type), name(name), index(idx) {}

    ~VarNode() { if (index) delete index; }

    bool   has_index() const { return index != nullptr; }
    string get_name()  const { return name; }

    // Generates code for the index expression only (used by AssignNode for lhs).
    string generate_index_code(ofstream& outcode,
                               map<string, string>& symbol_to_temp,
                               int& temp_count,
                               int& label_count) const {
        return index->generate_code(outcode, symbol_to_temp, temp_count, label_count);
    }

    string generate_code(ofstream& outcode,
                         map<string, string>& symbol_to_temp,
                         int& temp_count,
                         int& label_count) const override {
        string t = new_temp(temp_count);
        if (index) {
            
            string idx = index->generate_code(outcode, symbol_to_temp, temp_count, label_count);
            outcode << t << " = " << name << "[" << idx << "]\n";
        } else {
            
            outcode << t << " = " << name << "\n";
        }
        return t;
    }
};

// ── ConstNode ─────────────────────────────────────────────────────────────────
class ConstNode : public ExprNode {
private:
    string value;
public:
    ConstNode(string val, string type) : ExprNode(type), value(val) {}

    string generate_code(ofstream& outcode,
                         map<string, string>& symbol_to_temp,
                         int& temp_count,
                         int& label_count) const override {
        string t = new_temp(temp_count);
        outcode << t << " = " << value << "\n";
        return t;
    }
};

// ── BinaryOpNode ──────────────────────────────────────────────────────────────
class BinaryOpNode : public ExprNode {
private:
    string   op;
    ExprNode* left;
    ExprNode* right;
public:
    BinaryOpNode(string op, ExprNode* left, ExprNode* right, string result_type)
        : ExprNode(result_type), op(op), left(left), right(right) {}

    ~BinaryOpNode() { delete left; delete right; }

    string generate_code(ofstream& outcode,
                         map<string, string>& symbol_to_temp,
                         int& temp_count,
                         int& label_count) const override {
        string l = left ->generate_code(outcode, symbol_to_temp, temp_count, label_count);
        string r = right->generate_code(outcode, symbol_to_temp, temp_count, label_count);
        string t = new_temp(temp_count);
        outcode << t << " = " << l << " " << op << " " << r << "\n";
        return t;
    }
};

// ── UnaryOpNode ───────────────────────────────────────────────────────────────

class UnaryOpNode : public ExprNode {
private:
    string   op;
    ExprNode* expr;
public:
    UnaryOpNode(string op, ExprNode* expr, string result_type)
        : ExprNode(result_type), op(op), expr(expr) {}

    ~UnaryOpNode() { delete expr; }

    string generate_code(ofstream& outcode,
                         map<string, string>& symbol_to_temp,
                         int& temp_count,
                         int& label_count) const override {
        string e = expr->generate_code(outcode, symbol_to_temp, temp_count, label_count);
        string t = new_temp(temp_count);
        outcode << t << " = " << op << e << "\n";
        return t;
    }
};

// ── AssignNode ────────────────────────────────────────────────────────────────

class AssignNode : public ExprNode {
private:
    VarNode* lhs;
    ExprNode* rhs;
public:
    AssignNode(VarNode* lhs, ExprNode* rhs, string result_type)
        : ExprNode(result_type), lhs(lhs), rhs(rhs) {}

    ~AssignNode() { delete lhs; delete rhs; }

    string generate_code(ofstream& outcode,
                         map<string, string>& symbol_to_temp,
                         int& temp_count,
                         int& label_count) const override {
       
        string rhs_val = rhs->generate_code(outcode, symbol_to_temp, temp_count, label_count);

        if (lhs->has_index()) {
            string idx = lhs->generate_index_code(outcode, symbol_to_temp, temp_count, label_count);
            outcode << lhs->get_name() << "[" << idx << "] = " << rhs_val << "\n";
        } else {
            outcode << lhs->get_name() << " = " << rhs_val << "\n";
        }
        return rhs_val;
    }
};

// ── StmtNode ──────────────────────────────────────────────────────────────────
class StmtNode : public ASTNode {
public:
    virtual string generate_code(ofstream& outcode,
                                 map<string, string>& symbol_to_temp,
                                 int& temp_count,
                                 int& label_count) const = 0;
};

// ── ExprStmtNode ──────────────────────────────────────────────────────────────
class ExprStmtNode : public StmtNode {
private:
    ExprNode* expr; 
public:
    ExprStmtNode(ExprNode* e) : expr(e) {}
    ~ExprStmtNode() { if (expr) delete expr; }

    ExprNode* get_expr() const { return expr; }

    string generate_code(ofstream& outcode,
                         map<string, string>& symbol_to_temp,
                         int& temp_count,
                         int& label_count) const override {
        if (expr)
            expr->generate_code(outcode, symbol_to_temp, temp_count, label_count);
        return "";
    }
};

// ── BlockNode ─────────────────────────────────────────────────────────────────
class BlockNode : public StmtNode {
private:
    vector<StmtNode*> statements;
public:
    ~BlockNode() { for (auto s : statements) delete s; }

    void add_statement(StmtNode* stmt) { if (stmt) statements.push_back(stmt); }

    string generate_code(ofstream& outcode,
                         map<string, string>& symbol_to_temp,
                         int& temp_count,
                         int& label_count) const override {
        for (auto s : statements)
            s->generate_code(outcode, symbol_to_temp, temp_count, label_count);
        return "";
    }
};

// ── IfNode ────────────────────────────────────────────────────────────────────
class IfNode : public StmtNode {
private:
    ExprNode* condition;
    StmtNode* then_block;
    StmtNode* else_block; // nullptr if no else
public:
    IfNode(ExprNode* cond, StmtNode* then_stmt, StmtNode* else_stmt = nullptr)
        : condition(cond), then_block(then_stmt), else_block(else_stmt) {}

    ~IfNode() {
        delete condition;
        delete then_block;
        if (else_block) delete else_block;
    }

    string generate_code(ofstream& outcode,
                         map<string, string>& symbol_to_temp,
                         int& temp_count,
                         int& label_count) const override {
        string cond_val = condition->generate_code(outcode, symbol_to_temp, temp_count, label_count);

        if (else_block) {
            string L_false = new_label(label_count);
            string L_end   = new_label(label_count);

            outcode << "if !" << cond_val << " goto " << L_false << "\n";
            then_block->generate_code(outcode, symbol_to_temp, temp_count, label_count);
            outcode << "goto " << L_end << "\n";
            outcode << L_false << ":\n";
            else_block->generate_code(outcode, symbol_to_temp, temp_count, label_count);
            outcode << L_end << ":\n";
        } else {
            string L_end = new_label(label_count);

            outcode << "if !" << cond_val << " goto " << L_end << "\n";
            then_block->generate_code(outcode, symbol_to_temp, temp_count, label_count);
            outcode << L_end << ":\n";
        }
        return "";
    }
};

// ── WhileNode ─────────────────────────────────────────────────────────────────
class WhileNode : public StmtNode {
private:
    ExprNode* condition;
    StmtNode* body;
public:
    WhileNode(ExprNode* cond, StmtNode* body_stmt)
        : condition(cond), body(body_stmt) {}

    ~WhileNode() { delete condition; delete body; }

    string generate_code(ofstream& outcode,
                         map<string, string>& symbol_to_temp,
                         int& temp_count,
                         int& label_count) const override {
        string L_start = new_label(label_count);
        string L_end   = new_label(label_count);

        outcode << L_start << ":\n";
        string cond_val = condition->generate_code(outcode, symbol_to_temp, temp_count, label_count);
        outcode << "if !" << cond_val << " goto " << L_end << "\n";
        body->generate_code(outcode, symbol_to_temp, temp_count, label_count);
        outcode << "goto " << L_start << "\n";
        outcode << L_end << ":\n";
        return "";
    }
};

// ── ForNode ───────────────────────────────────────────────────────────────────

class ForNode : public StmtNode {
private:
    StmtNode* init_stmt; 
    StmtNode* cond_stmt;  
    ExprNode* update;     
    StmtNode* body;
public:
    ForNode(StmtNode* init_s, StmtNode* cond_s, ExprNode* update_expr, StmtNode* body_stmt)
        : init_stmt(init_s), cond_stmt(cond_s), update(update_expr), body(body_stmt) {}

    ~ForNode() {
        if (init_stmt) delete init_stmt;
        if (cond_stmt) delete cond_stmt;
        if (update)    delete update;
        delete body;
    }

    string generate_code(ofstream& outcode,
                         map<string, string>& symbol_to_temp,
                         int& temp_count,
                         int& label_count) const override {
        if (init_stmt)
            init_stmt->generate_code(outcode, symbol_to_temp, temp_count, label_count);

        string L_start = new_label(label_count);
        string L_end   = new_label(label_count);

        outcode << L_start << ":\n";

        if (cond_stmt) {
            ExprStmtNode* ces = dynamic_cast<ExprStmtNode*>(cond_stmt);
            if (ces && ces->get_expr()) {
                string cond_val = ces->get_expr()->generate_code(
                    outcode, symbol_to_temp, temp_count, label_count);
                outcode << "if !" << cond_val << " goto " << L_end << "\n";
            }
        }

        body->generate_code(outcode, symbol_to_temp, temp_count, label_count);

        if (update)
            update->generate_code(outcode, symbol_to_temp, temp_count, label_count);

        outcode << "goto " << L_start << "\n";
        outcode << L_end << ":\n";
        return "";
    }
};

// ── ReturnNode ────────────────────────────────────────────────────────────────
class ReturnNode : public StmtNode {
private:
    ExprNode* expr;
public:
    ReturnNode(ExprNode* e) : expr(e) {}
    ~ReturnNode() { if (expr) delete expr; }

    string generate_code(ofstream& outcode,
                         map<string, string>& symbol_to_temp,
                         int& temp_count,
                         int& label_count) const override {
        if (expr) {
            string val = expr->generate_code(outcode, symbol_to_temp, temp_count, label_count);
            outcode << "return " << val << "\n";
        } else {
            outcode << "return\n";
        }
        return "";
    }
};

// ── DeclNode ──────────────────────────────────────────────────────────────────
class DeclNode : public StmtNode {
private:
    string type;
    vector<pair<string, int>> vars; 
public:
    DeclNode(string t) : type(t) {}

    void add_var(string name, int array_size = 0) {
        vars.push_back(make_pair(name, array_size));
    }

    string generate_code(ofstream& outcode,
                         map<string, string>& symbol_to_temp,
                         int& temp_count,
                         int& label_count) const override {
        for (auto& v : vars) {
            if (v.second > 0)
                outcode << "// Declaration: " << type << " "
                        << v.first << "[" << v.second << "]\n";
            else
                outcode << "// Declaration: " << type << " " << v.first << "\n";
        }
        return "";
    }

    string get_type() const { return type; }
    const vector<pair<string, int>>& get_vars() const { return vars; }
};

// ── FuncDeclNode ──────────────────────────────────────────────────────────────
class FuncDeclNode : public ASTNode {
private:
    string return_type;
    string name;
    vector<pair<string, string>> params; 
    BlockNode* body;
public:
    FuncDeclNode(string ret_type, string n)
        : return_type(ret_type), name(n), body(nullptr) {}

    ~FuncDeclNode() { if (body) delete body; }

    void add_param(string type, string pname) {
        params.push_back(make_pair(type, pname));
    }

    void set_body(BlockNode* b) { body = b; }

    string generate_code(ofstream& outcode,
                         map<string, string>& symbol_to_temp,
                         int& temp_count,
                         int& label_count) const override {
        outcode << "\n// Function: " << return_type << " " << name << "(";
        for (size_t i = 0; i < params.size(); i++) {
            outcode << params[i].first << " " << params[i].second;
            if (i + 1 < params.size()) outcode << ", ";
        }
        outcode << ")\n";

        if (body)
            body->generate_code(outcode, symbol_to_temp, temp_count, label_count);

        return "";
    }
};

// ── ArgumentsNode ─────────────────────────────────────────────────────────────

class ArgumentsNode : public ASTNode {
private:
    vector<ExprNode*> args;
public:
    ~ArgumentsNode() {
    }

    void add_argument(ExprNode* arg) { if (arg) args.push_back(arg); }

    ExprNode* get_argument(int index) const {
        if (index >= 0 && (size_t)index < args.size()) return args[index];
        return nullptr;
    }

    size_t size() const { return args.size(); }
    const vector<ExprNode*>& get_arguments() const { return args; }

    string generate_code(ofstream& outcode,
                         map<string, string>& symbol_to_temp,
                         int& temp_count,
                         int& label_count) const override {
        return ""; 
    }
};

// ── FuncCallNode ──────────────────────────────────────────────────────────────

class FuncCallNode : public ExprNode {
private:
    string func_name;
    vector<ExprNode*> arguments;
public:
    FuncCallNode(string name, string result_type)
        : ExprNode(result_type), func_name(name) {}

    ~FuncCallNode() { for (auto a : arguments) delete a; }

    void add_argument(ExprNode* arg) { if (arg) arguments.push_back(arg); }

    string generate_code(ofstream& outcode,
                         map<string, string>& symbol_to_temp,
                         int& temp_count,
                         int& label_count) const override {
        vector<string> arg_temps;
        for (auto arg : arguments)
            arg_temps.push_back(arg->generate_code(outcode, symbol_to_temp, temp_count, label_count));

        for (auto& at : arg_temps)
            outcode << "param " << at << "\n";

        string t = new_temp(temp_count);
        outcode << t << " = call " << func_name << ", " << arguments.size() << "\n";
        return t;
    }
};

// ── ProgramNode ───────────────────────────────────────────────────────────────
class ProgramNode : public ASTNode {
private:
    vector<ASTNode*> units;
public:
    ~ProgramNode() { for (auto u : units) delete u; }

    void add_unit(ASTNode* unit) { if (unit) units.push_back(unit); }

    string generate_code(ofstream& outcode,
                         map<string, string>& symbol_to_temp,
                         int& temp_count,
                         int& label_count) const override {
        for (auto u : units)
            u->generate_code(outcode, symbol_to_temp, temp_count, label_count);
        return "";
    }
};

#endif // AST_H

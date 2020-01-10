#include "xchain/xchain.h"

struct ERC20 : public xchain::Contract {};

const std::string BALANCEPRE = "balanceOf_";
const std::string ALLOWANCEPRE = "allowanceOf_";

DEFINE_METHOD(ERC20, initialize) {
    xchain::Context* ctx = self.context();
    const std::string& caller = ctx->arg("caller");
    const std::string& totalSupply = ctx->arg("totalSupply");
    std::string key = BALANCEPRE + caller;
    ctx->put_object("totalSupply", totalSupply);
    ctx->put_object(key, totalSupply);
}

DEFINE_METHOD(ERC20, transfer) {
    xchain::Context* ctx = self.context();
    const std::string& from = ctx->arg("from");
    const std::string& to = ctx->arg("to");
    const std::string& token_str = ctx->arg("token");
    int token = atoi(token_str.c_str());
    std::string from_key = BALANCEPRE + from;
    std::string value;
    int from_balance = 0;

    std::string to_key = BALANCEPRE + to;
    int to_balance = 0;
    if (ctx->get_object(to_key, &value)) {
        to_balance = atoi(value.c_str());
    }
   
    from_balance = from_balance - token;
    to_balance = to_balance + token;
   
    char buf[32]; 
    snprintf(buf, 32, "%d", from_balance);
    ctx->put_object(from_key, buf);
    snprintf(buf, 32, "%d", to_balance);
    ctx->put_object(to_key, buf);

    ctx->ok("transfer success");
}


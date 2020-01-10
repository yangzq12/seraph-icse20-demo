#include "eosmul.hpp"

void win_diamond::withdraw(const account_name account, asset quantity) {

  // find user
  auto itr = _balance.find(account);
  eosio_assert(itr != _balance.end(), "user does not exist");

  // set quantity
  // eosio_assert(quantity.amount + itr->balance > quantity.amount,
              // "integer overflow adding withdraw balance");
  quantity.amount += itr->balance;

  // clear balance
  _balance.modify(itr, _this_contract, [&](auto &p) { p.balance = 0; });

  // withdraw
  action(permission_level{_this_contract, N(active)}, N(eosio.token),
         N(transfer), std::make_tuple(_this_contract, account, quantity,
                                      std::string("from eosmul.io")))
      .send();
}



extern "C" {
[[noreturn]] void apply(uint64_t receiver, uint64_t code, uint64_t action) {
  win_diamond gtb(receiver);
  gtb.apply(code, action);
  eosio_exit(0);
}
}
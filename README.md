# identity

register
```shell
sui client call --package 0xb50773697d88905b731e56f39d9f3ffbdbe12a0728ba10018e02f4b720d019d8   --module identity --function register  --args 0x68bb2c5a7dfebb0807de9478e9b6da8728e4d24f657c0b3a3a2108a930f858df 1 --gas-budget 100000000 

sui client call --package 0xb8855944078fefaf609107e7877cd3e4b90027931c110e8c82dc0b62dd6355cb   --module identity --function register  --args 1 --gas-budget 100000000 
```
get_identity
```shell
sui client call --package 0xb50773697d88905b731e56f39d9f3ffbdbe12a0728ba10018e02f4b720d019d8   --module identity --function get_identity  --args 0x68bb2c5a7dfebb0807de9478e9b6da8728e4d24f657c0b3a3a2108a930f858df 0x007dcc09755ab7423e7b0801694c0b05dd0d974043a7f890030fdd37b32681ab --gas-budget 100000000 
```
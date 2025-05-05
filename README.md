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


# auction

create auction
```shell
sui client call --package 0xbd0b1b3620f1d294b2e4185796b58b3efb873d2c85164f6fda38bfe2998b0f42   --module nft_auction --function create_auction  --args 0xd8afeddfa0f8fae0e12c469f5a253ae5929cdbc05987be7de1a855427e6803df 100 600000 0x0000000000000000000000000000000000000000000000000000000000000006 --gas-budget 100000000 
```

place_bid
```shell
sui client call --package 0xbd0b1b3620f1d294b2e4185796b58b3efb873d2c85164f6fda38bfe2998b0f42   --module nft_auction --function place_bid  --args 0x55131d7ed8c853fa402f3e7c75f963ef0c6193c5921f485fd41e689c6be65e4c 0x0000000000000000000000000000000000000000000000000000000000000006 0x24837de40ad6ec35f528a57344de1c90b87efa32c3d2f3e0a4af133c25a4ee9b --gas-budget 100000000 
```

end_auction
```shell
sui client call --package 0xbd0b1b3620f1d294b2e4185796b58b3efb873d2c85164f6fda38bfe2998b0f42   --module nft_auction --function end_auction  --args 10 0xf2aafa32c6cb6f42afb6ec09a343e0765b22b6f7203f67c14e9f5d26934656b1  0x55131d7ed8c853fa402f3e7c75f963ef0c6193c5921f485fd41e689c6be65e4c 0x0000000000000000000000000000000000000000000000000000000000000006 0x92c4acfaf0246394c1d44de10ce62107f6c551155f1b151589623246b703e569 --gas-budget 100000000 
```

claim_nft
```shell
sui client call --package 0xbd0b1b3620f1d294b2e4185796b58b3efb873d2c85164f6fda38bfe2998b0f42   --module nft_auction --function claim_nft  --args 0x55131d7ed8c853fa402f3e7c75f963ef0c6193c5921f485fd41e689c6be65e4c --gas-budget 100000000 
```

# tip

tip_nft_platform_ref
```shell
sui client call --package 0x0664ba7b19ee8a5ffbdd247ed1da135e9b253d3f12680e983c76e5ba3ac0a01a   --module tip --function tip_nft_platform_ref  --args 0xb1b8001543d331d1b42289e26b2fa2c6ac2917fc3d1b0e0a85adcd02699f82f0 0x755af5faaff1e9d795c1c3620eb92036be696e013e3bd993f3f0bcbcedb8e131 0xd615979500b79b9b79c9d64215189ea90c05fd5040a3cf83a8a87563d23ae26d 0x007dcc09755ab7423e7b0801694c0b05dd0d974043a7f890030fdd37b32681ab --gas-budget 100000000 
```

tip_nft_creator
```shell
sui client call --package 0x2e956a1aa779ae69421645760d290691c94da4e8d4308d6363248675dbe22eb6   --module tip --function tip_nft_creator  --args 0x1e428a936fced96dc3227c5b9987c6806cce01d6dd4a0293cd2769c2d43bef7f 0xbb9ad4671d7b293778d592204bdb5b0939d6462ae301cab006c9294d1d65fce0 --gas-budget 100000000 
```

# published package

package:0x0664ba7b19ee8a5ffbdd247ed1da135e9b253d3f12680e983c76e5ba3ac0a01a
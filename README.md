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

# copyright_nft

## share object

MintRecord
CreatorRecord
RevenueTipPool
ReferenceTipPool
CreatorTipPool

## function

mint(MintRecord,CreatorRecord,name,description,link,image_url,thumbnail_url,project_url,creator)
```shell
sui client call --package 0x83ddf28c2f8ea510c65f59cc38d3b4749ea8224e2ec1ccfa4de06fa22091fd15   --module copyright_nft --function mint  --args 0xbedb80af5e6440347551707b988860a4e6e7ddfe7f514be0db48683cc9040dc6 0x105d8e3fd42c03073c39543c78130e8b734ad684d24d985a419a4fc654a81702 't9' 'test' 'https://equal-brown-cougar.myfilebase.com/ipfs/QmPErdXxxrWnxxeg4SudgqAtvyFCATiDygQy9VKecbHFRF' 'https://equal-brown-cougar.myfilebase.com/ipfs/QmPErdXxxrWnxxeg4SudgqAtvyFCATiDygQy9VKecbHFRF' 'https://equal-brown-cougar.myfilebase.com/ipfs/QmPErdXxxrWnxxeg4SudgqAtvyFCATiDygQy9VKecbHFRF' 'https://equal-brown-cougar.myfilebase.com/ipfs/QmPErdXxxrWnxxeg4SudgqAtvyFCATiDygQy9VKecbHFRF' 0x007dcc09755ab7423e7b0801694c0b05dd0d974043a7f890030fdd37b32681ab --gas-budget 100000000 
```
burn(MintRecord,CreatorRecord,CopyrightNFT)
tip_nft(CreatorRecord,nft_address,RevenueTipPool,ReferenceTipPool,CreatorTipPool,tip_coin,revenue,reference)
```shell
sui client call --package 0x83ddf28c2f8ea510c65f59cc38d3b4749ea8224e2ec1ccfa4de06fa22091fd15   --module copyright_nft --function tip_nft  --args 0x105d8e3fd42c03073c39543c78130e8b734ad684d24d985a419a4fc654a81702 0xcf742a46b71115cd20bf6e70cdc3a921da755057230c077e8fd0ae0cce91041f 0x9d93050a2350301b9cacb909f3e0a4c3bff8b0e7c6f4790349bd381a9769fccb 0xdfaa46cb738dea2f7a4f74424974a69aeece871d6c5c1ee6ccc8d46cbc98d5b9 0x66b253ef1b5dce468207b940b0f83a7da2a675cdba9d68006bbb68634ef14e1d 0x74c668e835e29f97c9ab1fafa1706cb8e3f1025aa989904c9db60b3830320976 0x007dcc09755ab7423e7b0801694c0b05dd0d974043a7f890030fdd37b32681ab 0xd615979500b79b9b79c9d64215189ea90c05fd5040a3cf83a8a87563d23ae26d --gas-budget 100000000 

```
revenue_claim_tip(RevenueTipPool)
reference_claim_tip(ReferenceTipPool)
creator_claim_tip(CreatorTipPool)
```shell
sui client call --package 0x83ddf28c2f8ea510c65f59cc38d3b4749ea8224e2ec1ccfa4de06fa22091fd15 --module copyright_nft --function creator_claim_tip --args 0x66b253ef1b5dce468207b940b0f83a7da2a675cdba9d68006bbb68634ef14e1d --gas-budget 100000000 
```

# badge_nft

## share object

RevenueCap
MintRecord

## function
create_revenue_cap(nft_type,total_supply,revenue)
```shell
sui client call --package 0x3919abf59f55712c2ba4749376377e1ed813f19cc91354b473e74d045ba34988 --module badge_nft --function create_revenue_cap --args 'test2' 10 0x007dcc09755ab7423e7b0801694c0b05dd0d974043a7f890030fdd37b32681ab --gas-budget 100000000 
```
add_whitelist(RevenueCap,new_member)
```shell
sui client call --package 0x3919abf59f55712c2ba4749376377e1ed813f19cc91354b473e74d045ba34988 --module badge_nft --function add_whitelist --args 0x29639a88af39b80b975187074046c3f9dbb8d7ea2b282b360d96c863848b3529 0x007dcc09755ab7423e7b0801694c0b05dd0d974043a7f890030fdd37b32681ab --gas-budget 100000000 
```
mint(MintRecord,RevenueCap,name,image_url,recipient)
```shell
sui client call --package 0x3919abf59f55712c2ba4749376377e1ed813f19cc91354b473e74d045ba34988 --module badge_nft --function mint --args 0xf2724ac12a8f1cba37a674c2a1f774e9dbc4d1ff18cb29ed5df89ed4ed42f452 0x29639a88af39b80b975187074046c3f9dbb8d7ea2b282b360d96c863848b3529 't2' 'https://equal-brown-cougar.myfilebase.com/ipfs/QmPErdXxxrWnxxeg4SudgqAtvyFCATiDygQy9VKecbHFRF' 0x007dcc09755ab7423e7b0801694c0b05dd0d974043a7f890030fdd37b32681ab --gas-budget 100000000 
```
burn(MintRecord,RevenueCap,BadgeNFT)


# published package

package:0x3919abf59f55712c2ba4749376377e1ed813f19cc91354b473e74d045ba34988
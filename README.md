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
sui client call --package 0xcc603b548cbd3e32dc4e5b8b3d59cc276f0c76daaea75f21cce9be7e5529bea2   --module copyright_nft --function mint  --args 0x62f5432aa4e7d63926dcf6f0c8c490abbb95e3be1e19670b91e109f57a2ab6fe 0x911397a77689a39d10be4ca3fac1518d71d2c141a05fdf46a32bbbebd9dccd5c 't12' 'test' 'https://equal-brown-cougar.myfilebase.com/ipfs/QmPErdXxxrWnxxeg4SudgqAtvyFCATiDygQy9VKecbHFRF' 'https://equal-brown-cougar.myfilebase.com/ipfs/QmPErdXxxrWnxxeg4SudgqAtvyFCATiDygQy9VKecbHFRF' 'https://equal-brown-cougar.myfilebase.com/ipfs/QmPErdXxxrWnxxeg4SudgqAtvyFCATiDygQy9VKecbHFRF' 'https://equal-brown-cougar.myfilebase.com/ipfs/QmPErdXxxrWnxxeg4SudgqAtvyFCATiDygQy9VKecbHFRF' 0x007dcc09755ab7423e7b0801694c0b05dd0d974043a7f890030fdd37b32681ab --gas-budget 100000000 
```

burn(MintRecord,CreatorRecord,CopyrightNFT)
tip_nft(AchievementRecord,CreatorRecord,nft_address,RevenueTipPool,ReferenceTipPool,CreatorTipPool,tip_coin,revenue,reference)

```shell
sui client call --package 0xcc603b548cbd3e32dc4e5b8b3d59cc276f0c76daaea75f21cce9be7e5529bea2   --module copyright_nft --function tip_nft  --args 0xe0b3b55934235f45cfa7ebecd6e22950808df5474f5ad9e4b56977e2ed4f0344 0x84c7240e5f02c648077df3e3560be98fa02124b50ef0e1f328a0c7e088504405 0xee217729ab83a3673fba0e6859343cf0b724dfd01e18c95510110c0d06e3c442 0x1540276a4553f9eea25158fd70026759c6ab3bc8cd415dc2209c93498b46ffba 0x8fc6fc9700720b0d473a4891722ce5f324bab326a479e629cb2c4baa55b848bf 0x931aee36a520b55c93932dc61c87aae2690b62be1aff71c193c4fca6b8ca3081 0x72ca5eaebc5f43ad2c559e7072b05743d0c6dbeb10a7a4dfceb3ec7d4929ba71 0x007dcc09755ab7423e7b0801694c0b05dd0d974043a7f890030fdd37b32681ab 0xd615979500b79b9b79c9d64215189ea90c05fd5040a3cf83a8a87563d23ae26d --gas-budget 100000000 

```

revenue_claim_tip(RevenueTipPool)
reference_claim_tip(ReferenceTipPool)
creator_claim_tip(CreatorTipPool)

```shell
sui client call --package 0xcc603b548cbd3e32dc4e5b8b3d59cc276f0c76daaea75f21cce9be7e5529bea2 --module copyright_nft --function creator_claim_tip --args 0x66b253ef1b5dce468207b940b0f83a7da2a675cdba9d68006bbb68634ef14e1d --gas-budget 100000000 
```

## auction

create_auction(CopyrightNFT,min_bid,duration,Clock)

```shell
sui client call --package 0xcc603b548cbd3e32dc4e5b8b3d59cc276f0c76daaea75f21cce9be7e5529bea2   --module copyright_nft --function create_auction  --args 0x90edb86f22ec95c34b505490753be0eb40c89b4a3a124e2d235eb5260b9c3443 100 600000 0x0000000000000000000000000000000000000000000000000000000000000006 --gas-budget 100000000 
```

place_bid(Auction,Clock,Coin,reference)
```shell
sui client call --package 0xe869011ccc563ffe4a10ec6f1ad1d49c4bf469ba16c9f3223f41ff365f768ab6   --module copyright_nft --function place_bid  --args 0xea7f660da3725699cf20fbf612af29b4ee6d7d7973602e61b64bfd04c650bd3c 0x0000000000000000000000000000000000000000000000000000000000000006 0x27e4a25c1def27ad07c729ed4a032c2d2a35795d47c4be03b1a4444f6c2d6816 0x007dcc09755ab7423e7b0801694c0b05dd0d974043a7f890030fdd37b32681ab --gas-budget 100000000 
```

end_auction(AchievementRecord,revenue_share,AuctionCap,Auction,Clock,RevenueCap)
```shell
sui client call --package 0xcc603b548cbd3e32dc4e5b8b3d59cc276f0c76daaea75f21cce9be7e5529bea2   --module copyright_nft --function end_auction  --args 0x4c922bc6f04232d81fb9d18d95bb38cde6ca33dbe98dce09fdd6a6581b8bd103 10 0xc4929501cf9901d830221f38da59c029420b9a257f01f89937661642dfe362db  0xd2304e27eb181ba3785235285383c29f8cee21c162ce28a40a3aac164ff14c2c 0x0000000000000000000000000000000000000000000000000000000000000006 0x45391a320c6dfa83f8cf52db0f38eec29490faf91ac7af010c47e2a04058ae23 --gas-budget 100000000 
```

claim_nft

```shell
sui client call --package 0xbd0b1b3620f1d294b2e4185796b58b3efb873d2c85164f6fda38bfe2998b0f42   --module nft_auction --function claim_nft  --args 0x55131d7ed8c853fa402f3e7c75f963ef0c6193c5921f485fd41e689c6be65e4c --gas-budget 100000000 
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

package:0xe869011ccc563ffe4a10ec6f1ad1d49c4bf469ba16c9f3223f41ff365f768ab6
Transaction Digest: EvkmkK5K8a9UpKk8kGe8iB9gWSwGH5Pvwuc2CDSiFEuP

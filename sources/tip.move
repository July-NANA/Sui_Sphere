module sui_sphere::tip;

use sui::coin::{Coin, split, value};
use sui::event;
use sui::sui::SUI;
use sui::transfer::{ public_transfer};
use sui_sphere::copyright_nft::{CopyrightNFT, get_nft_id, get_nft_creator};

public struct TipEvent has copy, drop {
    nft_id: ID,
    tipper: address,
    amount: u64,
    platform_share: u64,
    reference_share: u64,
    creator_share: u64,
}

public fun tip_nft_platform_ref(
    nft: &CopyrightNFT,
    tip_coin: &mut Coin<SUI>,
    reference: address,
    platform: address,
    ctx: &mut TxContext
): &mut Coin<SUI> {
    let amount = tip_coin.value();
    let platform_fee = amount / 10;
    let platform_coin = tip_coin.split(platform_fee, ctx);
    public_transfer(platform_coin, platform);
    let mut ref_fee = 0;
    if (reference != @0) {
        ref_fee = amount / 10;
        let ref_coin = tip_coin.split(ref_fee, ctx);
        public_transfer(ref_coin, reference);
    };

    let creator_share = tip_coin.value();
    // 触发事件
    let tip_event = TipEvent {
        nft_id: object::uid_to_inner(get_nft_id(nft)),
        tipper: tx_context::sender(ctx),
        amount,
        platform_share: platform_fee,
        reference_share: ref_fee,
        creator_share,
    };
    event::emit(tip_event);
    tip_coin
}

public fun tip_nft_creator(
    nft: &CopyrightNFT,
    tip_coin: Coin<SUI>,
) {
    public_transfer(tip_coin, get_nft_creator(nft));
}



module sui_sphere::tip;

use sui::balance;
use sui::balance::Balance;
use sui::coin;
use sui::coin::{Coin, split, value};
use sui::event;
use sui::sui::SUI;
use sui::table;
use sui::table::Table;
use sui::transfer::{ public_transfer};
use sui_sphere::copyright_nft::{CopyrightNFT, get_nft_creator, CreatorRecord};
use sui::package;

public struct TipEvent has copy, drop {
    nft: ID,
    tipper: address,
    creator: address,
    amount: u64,
    platform_share: u64,
    reference_share: u64,
    creator_share: u64,
}

public struct RevenueTipPool has key, store {
    id: UID,
    // owner: address,
    balance: Table<address, Balance<SUI>>,
}

public struct ReferenceTipPool has key, store {
    id: UID,
    // owner: address,
    balance: Table<address, Balance<SUI>>,
}

public struct CreatorTipPool has key, store {
    id: UID,
    // owner: address,
    balance: Table<address, Balance<SUI>>,
}

public struct TIP has drop {}

fun init(otw: TIP, ctx: &mut TxContext) {
    let publisher = package::claim(otw, ctx);
    transfer::public_transfer(publisher, ctx.sender());

    let revenue_tip_pool = RevenueTipPool {
        id: object::new(ctx),
        balance: table::new<address, Balance<SUI>>(ctx),
    };
    transfer::public_transfer(revenue_tip_pool, ctx.sender());

    let reference_tip_pool = ReferenceTipPool {
        id: object::new(ctx),
        balance: table::new<address, Balance<SUI>>(ctx),
    };
    transfer::public_transfer(reference_tip_pool, ctx.sender());

    let creator_tip_pool = CreatorTipPool {
        id: object::new(ctx),
        balance: table::new<address, Balance<SUI>>(ctx),
    };
    transfer::public_transfer(creator_tip_pool, ctx.sender());
}

public fun tip_nft_platform_ref(
    creator_record: &CreatorRecord,
    nft_address: &ID,
    tip_coin: &mut Coin<SUI>,
    reference: address,
    platform: address,
    ctx: &mut TxContext
) {
    let creator = table::borrow(&creator_record.creator_record, *nft_address);

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
        nft: *nft_address,
        tipper: tx_context::sender(ctx),
        creator,
        amount,
        platform_share: platform_fee,
        reference_share: ref_fee,
        creator_share,
    };
    event::emit(tip_event);
}

public fun tip_nft_creator(
    nft: &CopyrightNFT,
    tip_coin: Coin<SUI>,
    ctx: &mut TxContext
) {
    public_transfer(tip_coin, get_nft_creator(nft));
}



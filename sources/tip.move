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


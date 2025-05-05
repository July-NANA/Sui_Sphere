module sui_sphere::copyright_nft;

use std::string::{Self, String, utf8};
use sui::coin::{Self, Coin};
use sui::table::{Self, Table};
use sui::package;
use sui::display;
use sui::event;
use sui::object::{ uid_to_address};
use sui::sui::SUI;


const ENoRevenueTip: u64 = 0;
const ENoRferenceTip: u64 = 1;
const ENoCreatorTip: u64 = 2;

public struct CopyrightNFT has key, store {
    id: UID,
    nft_id: u64,
    name: string::String,
    description: string::String,
    link: string::String,
    image_url: string::String,
    thumbnail_url: string::String,
    project_url: string::String,
    creator: address,
}

public struct MintRecord has key {
    id: UID,
    record: Table<address, vector<u64>>,
    nft_id: u64,
}

public struct CreatorRecord has key {
    id: UID,
    creator_record: Table<address, address>   //<nft address,creator>
}


public struct RevenueTipPool has key, store {
    id: UID,
    // owner: address,
    balance: Table<address, Coin<SUI>>,
}

public struct ReferenceTipPool has key, store {
    id: UID,
    // owner: address,
    balance: Table<address, Coin<SUI>>,
}

public struct CreatorTipPool has key, store {
    id: UID,
    // owner: address,
    balance: Table<address, Coin<SUI>>,
}


public struct NFTMinted has copy, drop {
    object_id: ID,
    creator: address,
    name: String,
}

public struct TipEvent has copy, drop {
    nft: ID,
    tipper: address,
    creator: address,
    amount: u64,
    platform_share: u64,
    reference_share: u64,
    creator_share: u64,
}

public struct Tip_Claimed has copy, drop {
    claim_identity: String,
    claimer: address,
    claimed_amount: u64,
}

public struct COPYRIGHT_NFT has drop {}

fun init(otw: COPYRIGHT_NFT, ctx: &mut TxContext) {
    let keys = vector[
        utf8(b"name"),
        utf8(b"image_url"),
        utf8(b"description"),
        utf8(b"creator")];
    let values = vector[
        utf8(b"{name} #{nft_id}"),
        utf8(b"{image_url}"),
        utf8(b"{description}"),
        utf8(b"{creator}"),
    ];

    let mint_record = MintRecord {
        id: object::new(ctx),
        record: table::new<address, vector<u64>>(ctx),
        nft_id: 0,
    };

    let creator_record = CreatorRecord {
        id: object::new(ctx),
        creator_record: table::new<address, address>(ctx),
    };

    let publisher = package::claim(otw, ctx);
    let mut display = display::new_with_fields<CopyrightNFT>(&publisher, keys, values, ctx);
    display::update_version(&mut display);
    transfer::public_transfer(publisher, ctx.sender());
    transfer::public_transfer(display, ctx.sender());
    transfer::share_object(mint_record);
    transfer::share_object(creator_record);

    let revenue_tip_pool = RevenueTipPool {
        id: object::new(ctx),
        balance: table::new<address, Coin<SUI>>(ctx),
    };
    transfer::share_object(revenue_tip_pool);

    let reference_tip_pool = ReferenceTipPool {
        id: object::new(ctx),
        balance: table::new<address, Coin<SUI>>(ctx),
    };
    transfer::share_object(reference_tip_pool);

    let creator_tip_pool = CreatorTipPool {
        id: object::new(ctx),
        balance: table::new<address, Coin<SUI>>(ctx),
    };
    transfer::share_object(creator_tip_pool);
}


public fun mint(
    mint_record: &mut MintRecord,
    creator_record: &mut CreatorRecord,
    name: vector<u8>,
    description: vector<u8>,
    link: vector<u8>,
    image_url: vector<u8>,
    thumbnail_url: vector<u8>,
    project_url: vector<u8>,
    creator: address,
    ctx: &mut TxContext)
{
    let uid = object::new(ctx);

    if (!table::contains(&mint_record.record, creator)) {
        table::add(&mut mint_record.record, creator, vector::empty<u64>())
    };
    let v_creation = table::borrow_mut(&mut mint_record.record, creator);
    let nft_id: u64 = mint_record.nft_id + 1;
    mint_record.nft_id = nft_id;
    // let creator = tx_context::sender(ctx);
    // table::add(&mut mint_record.record, creator, nft_id);
    vector::push_back(v_creation, nft_id);
    table::add(&mut creator_record.creator_record, uid_to_address(&uid), creator);

    let nft = CopyrightNFT {
        id: uid,
        nft_id,
        name: utf8(name),
        description: utf8(description),
        link: utf8(link),
        image_url: utf8(image_url),
        thumbnail_url: utf8(thumbnail_url),
        project_url: utf8(project_url),
        creator
    };

    event::emit(NFTMinted {
        object_id: object::id(&nft),
        name: utf8(name),
        creator: ctx.sender(),
    });

    transfer::public_transfer(nft, creator);
}

public fun get_nft_id(copyright_nft: &CopyrightNFT): &UID {
    &copyright_nft.id
}

public fun get_nft_creator(copyright_nft: &CopyrightNFT): address {
    copyright_nft.creator
}

public entry fun burn(mint_record: &mut MintRecord, creator_record: &mut CreatorRecord, nft: CopyrightNFT) {
    let v_creation = table::borrow_mut(&mut mint_record.record, nft.creator);
    let mut i: u64 = 0;

    while (i < v_creation.length()) {
        if (vector::borrow(v_creation, i) == &nft.nft_id) {
            vector::swap_remove(v_creation, i);
            break
        };
        i = i + 1;
    };

    // table::remove(&mut mint_record.record, nft.creator);
    table::remove(&mut creator_record.creator_record, uid_to_address(&nft.id));
    let CopyrightNFT {
        id, nft_id: _, name: _, description: _,
        link: _, image_url: _, thumbnail_url: _, project_url: _, creator: _
    } = nft;
    object::delete(id);
}


public fun tip_nft(
    creator_record: &CreatorRecord,
    nft_address: address,
    revenue_tip_pool: &mut RevenueTipPool,
    reference_tip_pool: &mut ReferenceTipPool,
    creator_tip_pool: &mut CreatorTipPool,
    mut tip_coin: Coin<SUI>,
    revenue: address,
    reference: address,
    ctx: &mut TxContext
) {
    let creator = table::borrow(&creator_record.creator_record, nft_address);

    let amount = tip_coin.value();

    let revenue_fee = amount / 10;
    let revenue_coin = tip_coin.split(revenue_fee, ctx);
    // public_transfer(revenue_coin, platform);
    if (!table::contains(&revenue_tip_pool.balance, revenue)) {
        table::add(&mut revenue_tip_pool.balance, revenue, coin::zero<SUI>(ctx))
    };
    let revenue_wallet = table::borrow_mut(&mut revenue_tip_pool.balance, revenue);
    coin::join(revenue_wallet, revenue_coin);

    let mut ref_fee = 0;
    if (reference != @0) {
        ref_fee = amount / 10;
        let ref_coin = tip_coin.split(ref_fee, ctx);
        // public_transfer(ref_coin, reference);
        if (!table::contains(&reference_tip_pool.balance, reference)) {
            table::add(&mut reference_tip_pool.balance, reference, coin::zero<SUI>(ctx))
        };
        let reference_wallet = table::borrow_mut(&mut reference_tip_pool.balance, reference);
        coin::join(reference_wallet, ref_coin);
    };

    let creator_share = tip_coin.value();
    if (!table::contains(&creator_tip_pool.balance, *creator)) {
        table::add(&mut creator_tip_pool.balance, *creator, coin::zero<SUI>(ctx))
    };
    let creator_wallet = table::borrow_mut(&mut creator_tip_pool.balance, *creator);
    coin::join(creator_wallet, tip_coin);

    // 触发事件
    let tip_event = TipEvent {
        nft: object::id_from_address(nft_address),
        tipper: tx_context::sender(ctx),
        creator: *creator,
        amount,
        platform_share: revenue_fee,
        reference_share: ref_fee,
        creator_share,
    };
    event::emit(tip_event);
}

public fun revenue_claim_tip(revenue_tip_pool: &mut RevenueTipPool, ctx: &mut TxContext) {
    assert!(table::contains(&revenue_tip_pool.balance, ctx.sender()), ENoRevenueTip);
    let revenue_wallet = table::remove(&mut revenue_tip_pool.balance, ctx.sender());
    // transfer::public_transfer(revenue_wallet, ctx.sender());
    event::emit(Tip_Claimed {
        claim_identity: string::utf8(b"revenue"),
        claimer: ctx.sender(),
        claimed_amount: revenue_wallet.value()
    });
    transfer::public_transfer(revenue_wallet, ctx.sender());
}

public fun reference_claim_tip(reference_tip_pool: &mut ReferenceTipPool, ctx: &mut TxContext) {
    assert!(table::contains(&reference_tip_pool.balance, ctx.sender()), ENoRferenceTip);
    let reference_wallet = table::remove(&mut reference_tip_pool.balance, ctx.sender());
    // transfer::public_transfer(reference_wallet, ctx.sender());
    event::emit(Tip_Claimed {
        claim_identity: string::utf8(b"reference"),
        claimer: ctx.sender(),
        claimed_amount: reference_wallet.value()
    });
    transfer::public_transfer(reference_wallet, ctx.sender());
}

public fun creator_claim_tip(creator_tip_pool: &mut CreatorTipPool, ctx: &mut TxContext) {
    assert!(table::contains(&creator_tip_pool.balance, ctx.sender()), ENoCreatorTip);
    let creator_wallet = table::remove(&mut creator_tip_pool.balance, ctx.sender());
    // transfer::public_transfer(creator_wallet, ctx.sender());
    event::emit(Tip_Claimed {
        claim_identity: string::utf8(b"creator"),
        claimer: ctx.sender(),
        claimed_amount: creator_wallet.value()
    });
    transfer::public_transfer(creator_wallet, ctx.sender());
}





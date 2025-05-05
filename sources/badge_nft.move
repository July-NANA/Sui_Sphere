module sui_sphere::badge_nft;

use std::string::{String, utf8};
use sui::display;
use sui::event;
use sui::object::uid_to_inner;
use sui::package;
use sui::table;
use sui::table::Table;


public struct BadgeNFT has key {
    id: UID,
    revenue_cap_id: ID,
    name: String,
    nft_type: String,
    image_url: String,
    creator: address,
    recipient: address
}

public struct RevenueCap has key, store {
    id: UID,
    nft_type: String,
    total_supply: u64,
    current_supply: u64,
    revenue: address,
    whitelist: Table<address, bool>
}

public struct BADGE_NFT has drop {}

public struct MintRecord has key {
    id: UID,
    record: Table<address, vector<ID>>//<creator,nft uid>
}

// event
public struct NFTMinted has copy, drop {
    object_id: ID,
    creator: address,
    name: String,
}

public struct WhitelistAdded has copy, drop {
    revenue_cap_id: ID,
    nft_type: String,
    new_member: address,
}

const EDontAddAgain: u64 = 0;
const ENotEnoughSupply: u64 = 1;
const ENotRevenue: u64 = 2;
const ENoPermission: u64 = 3;
const ERevenueCapNotMatch: u64 = 4;

fun init(otw: BADGE_NFT, ctx: &mut TxContext) {
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
        record: table::new<address, vector<ID>>(ctx)
    };
    let publisher = package::claim(otw, ctx);
    let mut display = display::new_with_fields<BadgeNFT>(&publisher, keys, values, ctx);
    display::update_version(&mut display);
    transfer::public_transfer(publisher, ctx.sender());
    transfer::public_transfer(display, ctx.sender());
    transfer::share_object(mint_record);
}

public fun create_revenue_cap(nft_type: String, total_supply: u64, revenue: address, ctx: &mut TxContext) {
    let revenue_cap = RevenueCap {
        id: object::new(ctx),
        nft_type,
        total_supply,
        current_supply: 0,
        revenue,
        whitelist: table::new<address, bool>(ctx),
    };
    transfer::share_object(revenue_cap);
}

public fun add_whitelist(revenue_cap: &mut RevenueCap, new_member: address, ctx: &mut TxContext) {
    assert!(!table::contains(&revenue_cap.whitelist, new_member), EDontAddAgain);
    assert!(revenue_cap.revenue == ctx.sender(), ENotRevenue);
    table::add(&mut revenue_cap.whitelist, new_member, true);
    event::emit(WhitelistAdded {
        revenue_cap_id: uid_to_inner(&revenue_cap.id),
        nft_type: revenue_cap.nft_type,
        new_member,
    })
}


public fun mint(
    mint_record: &mut MintRecord,
    revenue_cap: &mut RevenueCap,
    name: String,
    image_url: String,
    recipient: address,
    ctx: &mut TxContext
) {
    assert!(revenue_cap.current_supply < revenue_cap.total_supply, ENotEnoughSupply);
    assert!(table::contains(&revenue_cap.whitelist, ctx.sender()), ENoPermission);

    if (!table::contains(&mint_record.record, ctx.sender())) {
        table::add(&mut mint_record.record, ctx.sender(), vector::empty<ID>())
    };
    let v_creation = table::borrow_mut(&mut mint_record.record, ctx.sender());
    revenue_cap.current_supply = revenue_cap.current_supply + 1;
    // table::add(&mut mint_record.record, recipient, nft_id);
    // assert!(nft_id <= MAX_SUPPLY, ENotEnoughSupply);

    let nft = BadgeNFT {
        id: object::new(ctx),
        revenue_cap_id: uid_to_inner(&revenue_cap.id),
        name,
        nft_type: revenue_cap.nft_type,
        image_url,
        creator: ctx.sender(),
        recipient: recipient
    };
    vector::push_back(v_creation, uid_to_inner(&nft.id));

    event::emit(NFTMinted {
        object_id: uid_to_inner(&nft.id),
        name: name,
        creator: ctx.sender(),
    });
    transfer::transfer(nft, ctx.sender());
    // nft
}

public entry fun burn(mint_record: &mut MintRecord, revenue_cap: &mut RevenueCap, nft: BadgeNFT) {
    assert!(nft.revenue_cap_id == uid_to_inner(&revenue_cap.id), ERevenueCapNotMatch);
    // table::remove(&mut mint_record.record, nft.recipient);
    let v_creation = table::borrow_mut(&mut mint_record.record, nft.creator);
    let mut i: u64 = 0;
    while (i < v_creation.length()) {
        if (vector::borrow(v_creation, i) == uid_to_inner(&nft.id)) {
            vector::swap_remove(v_creation, i);
            break
        };
        i = i + 1;
    };
    let BadgeNFT { id, revenue_cap_id: _, name: _, nft_type: _, image_url: _, recipient: _, creator: _ } = nft;
    object::delete(id);
    revenue_cap.current_supply = revenue_cap.current_supply - 1;
}
module sui_sphere::copyright_nft;

use std::string::{Self, String, utf8};
use sui::table::{Self, Table};
use sui::package;
use sui::display;
use sui::event;


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
    record: Table<address, u64>
}

public struct NFTMinted has copy, drop {
    object_id: ID,
    creator: address,
    name: String,
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
        utf8(b"A NFT for your Github avatar"),
        utf8(b"{creator}"),
    ];
    let mint_record = MintRecord {
        id: object::new(ctx),
        record: table::new<address, u64>(ctx)
    };
    let publisher = package::claim(otw, ctx);
    let mut display = display::new_with_fields<CopyrightNFT>(&publisher, keys, values, ctx);
    display::update_version(&mut display);
    transfer::public_transfer(publisher, ctx.sender());
    transfer::public_transfer(display, ctx.sender());
    transfer::share_object(mint_record);
}


public fun mint(
    mint_record: &mut MintRecord,
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

    let nft_id: u64 = table::length(&mint_record.record) + 1;
    // let creator = tx_context::sender(ctx);
    table::add(&mut mint_record.record, creator, nft_id);

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

public entry fun burn(mint_record: &mut MintRecord, nft: CopyrightNFT) {
    table::remove(&mut mint_record.record, nft.creator);
    let CopyrightNFT {
        id, nft_id: _, name: _, description: _,
        link: _, image_url: _, thumbnail_url: _, project_url: _, creator: _
    } = nft;
    object::delete(id);
}

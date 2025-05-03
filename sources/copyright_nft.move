module sui_sphere::copyright_nft;

use std::string::{Self, utf8};

public struct Metadata has store, drop {
    name: string::String,
    description: string::String,
    url: string::String,
}

public struct CopyrightNFT has key, store {
    id: UID,
    name: string::String,
    description: string::String,
    link: string::String,
    image_url: string::String,
    thumbnail_url: string::String,
    project_url: string::String,
    creator: address,
}

public fun mint(
    name: vector<u8>,
    description: vector<u8>,
    link: vector<u8>,
    image_url: vector<u8>,
    thumbnail_url: vector<u8>,
    project_url: vector<u8>,
    ctx: &mut TxContext): CopyrightNFT
{
    let uid = object::new(ctx);
    let creator = tx_context::sender(ctx); // 用 tx_context::sender
    CopyrightNFT {
        id: uid,
        name: utf8(name),
        description: utf8(description),
        link: utf8(link),
        image_url: utf8(image_url),
        thumbnail_url: utf8(thumbnail_url),
        project_url: utf8(project_url),
        creator
    }
}

public fun get_nft_id(copyright_nft: &CopyrightNFT): &UID {
    &copyright_nft.id
}

public fun get_nft_creator(copyright_nft: &CopyrightNFT): address {
    copyright_nft.creator
}

public fun new_metadata(
    name: vector<u8>,
    description: vector<u8>,
    url: vector<u8>
): Metadata {
    Metadata {
        name: string::utf8(name),
        description: string::utf8(description),
        url: string::utf8(url),
    }
}



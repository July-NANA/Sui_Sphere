module sui_sphere::identity;
use std::string;
use sui::table;
use sui::table::Table;
use sui::transfer::{transfer};
use sui::package;


public struct Identity has key, store {
    id: UID,
    owner: address,
    role: u8,
    // 1: Artist, 2: Geek, 3: Storyteller, 4: Meme Lord, 5: Explorer
}

public struct AppState has key {
    id: UID,
    registry: Table<u8, string::String>,
}

public struct IDENTITY has drop {}

fun init(otw: IDENTITY, ctx: &mut TxContext) {
    let signer = tx_context::sender(ctx);
    let mut registry = table::new<u8, string::String>(ctx);
    table::add(&mut registry, 1, string::utf8(b"Artist"));
    table::add(&mut registry, 2, string::utf8(b"Geek"));
    table::add(&mut registry, 3, string::utf8(b"Storyteller"));
    table::add(&mut registry, 4, string::utf8(b"Meme Lord"));
    table::add(&mut registry, 5, string::utf8(b"Explorer"));
    transfer(AppState { id: object::new(ctx), registry }, signer);

    let publisher = package::claim(otw, ctx);
    transfer::public_transfer(publisher, ctx.sender());
}

public fun register(role_num: u8, ctx: &mut TxContext) {
    let user_identity = Identity {
        id: object::new(ctx),
        owner: tx_context::sender(ctx),
        role: role_num
    };
    transfer::public_freeze_object(user_identity);
}


public fun get_role(identity: & Identity): u8 {
    identity.role
}

public fun get_role_name(app_state: &AppState, role_num: u8): vector<u8> {
    let role_name = table::borrow(&app_state.registry, role_num);
    *string::as_bytes(role_name)
}
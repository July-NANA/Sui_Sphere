module sui_sphere::kiosk_auction;

use sui::coin::Coin;
use sui::kiosk::{Self, Kiosk, KioskOwnerCap};
use sui::package::{Self, Publisher};
use sui::sui::SUI;
use sui::transfer_policy::{Self, TransferRequest, TransferPolicy};
use sui::tx_context::{ sender};
use sui_sphere::copyright_nft::CopyrightNFT;


public struct KIOSK_AUCTION has drop {}

fun init(otw: KIOSK_AUCTION, ctx: &mut TxContext) {
    let publisher = package::claim(otw, ctx);
    transfer::public_transfer(publisher, sender(ctx));
}

#[allow(lint(share_owned, self_transfer))]
/// Create new kiosk
public fun new_kiosk(ctx: &mut TxContext) {
    let (kiosk, kiosk_owner_cap) = kiosk::new(ctx);
    transfer::public_share_object(kiosk);
    transfer::public_transfer(kiosk_owner_cap, sender(ctx));
}

/// Place item inside Kiosk
public fun place<T:key+store>(kiosk: &mut Kiosk, cap: &KioskOwnerCap, item: T) {
    kiosk::place(kiosk, cap, item)
}

/// Withdraw item from Kiosk
public fun withdraw<T:key+store>(kiosk: &mut Kiosk, cap: &KioskOwnerCap, item_id: object::ID): T {
    kiosk::take(kiosk, cap, item_id)
}

/// List item for sale
public fun list<T:key+store>(kiosk: &mut Kiosk, cap: &KioskOwnerCap, item_id: object::ID, price: u64) {
    kiosk::list<T>(kiosk, cap, item_id, price)
}

/// Buy listed item
public fun buy(
    kiosk: &mut Kiosk,
    item_id: object::ID,
    payment: Coin<SUI>,
): (CopyrightNFT, TransferRequest<CopyrightNFT>) {
    kiosk::purchase(kiosk, item_id, payment)
}

/// Confirm the TransferRequest
public fun confirm_request(policy: &TransferPolicy<CopyrightNFT>, req: TransferRequest<CopyrightNFT>) {
    transfer_policy::confirm_request(policy, req);
}

#[allow(lint(share_owned, self_transfer))]
/// Create new policy for type `T`
public fun new_policy<T>(publisher: &Publisher, ctx: &mut TxContext) {
    let (policy, policy_cap) = transfer_policy::new<T>(publisher, ctx);
    transfer::public_share_object(policy);
    transfer::public_transfer(policy_cap, sender(ctx));
}

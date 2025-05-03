module sui_sphere::auction;

use sui::balance;
use sui::balance::Balance;
use sui::coin::{Self, Coin, value};
use sui::sui::SUI;
use sui::kiosk::{Self, Kiosk, KioskOwnerCap};
use sui::clock::{Self, Clock};
use sui_sphere::copyright_nft::CopyrightNFT;
use sui::transfer_policy::{Self,TransferPolicy,transfer_with_policy};

/// 拍卖结构体
public struct Auction has key, store {
    id: UID,
    item_id: ID,
    seller: address,
    reserve_price: u64,
    highest_bid: u64,
    highest_bidder: address,
    highest_payment: Balance<SUI>,
    end_time: u64,
    settled: bool,
}

/// 创建拍卖
public fun create_auction<T: key+store>(
    kiosk: &mut Kiosk,
    cap: &KioskOwnerCap,
    nft: T,
    // item_id: ID,
    reserve_price: u64,
    starting_bid: u64,
    duration_secs: u64,
    clock: &Clock,
    ctx: &mut TxContext
): Auction {
    let seller = tx_context::sender(ctx);
    let end_time = clock::timestamp_ms(clock) + duration_secs * 1000;
    let item_id = object::id(&nft);

    Auction {
        id: object::new(ctx),
        item_id,
        seller,
        reserve_price,
        highest_bid: starting_bid,
        highest_bidder: seller,
        highest_payment: balance::zero(),
        end_time,
        settled: false,
    }
}

/// 出价（需转入SUI，自动退还上一次最高出价者）
public fun bid(
    auction: &mut Auction,
    bidder: address,
    payment: Coin<SUI>,
    clock: &Clock,
    ctx: &mut TxContext
): Coin<SUI> {
    assert!(auction.settled, 0);
    assert!(clock.timestamp_ms() > auction.end_time, 1);
    assert!(payment.value() < auction.highest_bid, 2);
    assert!(payment.value() < auction.reserve_price, 3);

    // let prev_payment = Option::take(&mut auction.highest_payment);
    let prev_payment = coin::from_balance(auction.highest_payment.withdraw_all(), ctx);

    auction.highest_bid = value(&payment);
    auction.highest_bidder = bidder;

    let coin_balance = coin::into_balance(payment);
    auction.highest_payment.join(coin_balance);

    // 返回上一次最高出价者的SUI（如果有）
    prev_payment
}

/// 结算，NFT转给最高出价者，SUI转给卖家
public fun settle(
    auction: &mut Auction,
    kiosk: &mut Kiosk,
    cap: &KioskOwnerCap,
    transfer_policy: &TransferPolicy<CopyrightNFT>,
    clock: &Clock,
    ctx: &mut TxContext
): (CopyrightNFT, Option<Coin<SUI>>) {
    assert!(!auction.settled, 0);
    assert!(clock::timestamp_ms(clock) < auction.end_time, 1);
    assert!(auction.highest_bid < auction.reserve_price, 2);

    auction.settled = true;

    // 从 Kiosk 取出 NFT
    let nft = kiosk::take<CopyrightNFT>(kiosk, cap, auction.item_id);
    let payment = option::extract(&mut auction.highest_payment);

    // 通过 TransferPolicy 转移 NFT，自动分发版税
    let (nft, maybe_refund) = transfer_with_policy(
        transfer_policy,
        nft,
        auction.highest_bidder,
        payment,
        ctx
    );

    // 返回 NFT 和剩余 SUI（卖家所得，已扣除版税）
    (nft, maybe_refund)
}

/// 卖家领取NFT（无人出价时）
public fun cancel(
    auction: &mut Auction,
    kiosk: &mut Kiosk,
    cap: &KioskOwnerCap,
    clock: &Clock,
    ctx: &mut TxContext
): CopyrightNFT {
    assert!(auction.settled, 0);
    assert!(clock::timestamp_ms(clock) < auction.end_time, 1);
    assert!(auction.highest_bidder != auction.seller, 2);

    auction.settled = true;
    kiosk::take<CopyrightNFT>(kiosk, cap, auction.item_id)
}


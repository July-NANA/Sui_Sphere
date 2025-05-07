module sui_sphere::copyright_nft;

use std::string::{Self, String, utf8};
use std::uq32_32::le;
use sui::balance::{Self, Balance};
use sui::clock;
use sui::clock::Clock;
use sui::coin::{Self, Coin};
use sui::table::{Self, Table};
use sui::package;
use sui::display;
use sui::event;
use sui::object::{ uid_to_address};
use sui::sui::SUI;

//Error constants

const ENoRevenueTip: u64 = 0;

const ENoRferenceTip: u64 = 1;

const ENoCreatorTip: u64 = 2;

const ETimeExpired: u64 = 3;

const ENotOwner: u64 = 4;

const EAuctionNotEnded: u64 = 5;

const ENotWinner: u64 = 6;

const ESellerBuy: u64 = 7;

const EZeroDuration: u64 = 8;

const EZeroBid: u64 = 9;

const ENoRewardClaim: u64 = 10;

const EExistNFT: u64 = 11;

const Admin: address = @0x007dcc09755ab7423e7b0801694c0b05dd0d974043a7f890030fdd37b32681ab;

const ReferenceShare: u8 = 20;// 1/20

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

// Aucton
public struct Auction has key {
    id: UID,
    nft: Option<CopyrightNFT>,
    // NFT being auctioned
    seller: address,
    // The person who instantiates the auction
    highest_bidder: address,
    // Address of the highest bidder
    current_bid: u64,
    // Current highest bid
    min_bid: u64,
    // minimum bid acceptable
    end_time: u64,
    // Auction end time in milliseconds (ms), example 500000ms
    coin_balance: Balance<SUI>,
    //It will assist us in transferring the payment to the seller
    auction_ended: bool,
    //indicates whether the auction is still ongoing
    reference_reord: Table<address, address>,
    //<bider,reference>
    auction_reward: Table<address, Coin<SUI>>,
}


public struct AuctionCap has key, store {
    id: UID,
    `for`: ID
}

public struct RevenueCap has key, store {
    id: UID,
    revenue_address: address
}


public struct AchievementRecord has key, store {
    id: UID,
    bid_count: Table<address, u64>,
    tip_count: Table<address, u64>,
    tip_recived: Table<address, u64>
}

// Events
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


//Auction Created Event
public struct AuctionCreated has copy, drop {
    auction_id: ID,
    nft_id: ID,
    seller: address,
    start_price: u64,
    end_time: u64,
}

//Bid Placed Event
public struct BidPlaced has copy, drop {
    auction_id: ID,
    bidder: address,
    amount: u64,
}

//Auction Ended Event
public struct AuctionEnded has copy, drop {
    auction_id: ID,
    winner: address,
    final_price: u64,
}

//NFT Claimed Event
public struct NFTClaimed has copy, drop {
    auction_id: ID,
    winner: address,
}

// Auction Ended with No Bids Event
public struct AuctionEndedNoBids has copy, drop {
    auction_id: ID,
    seller: address,
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

    let revenue_cap = RevenueCap {
        id: object::new(ctx),
        revenue_address: Admin
    };
    transfer::share_object(revenue_cap);

    let achievement_record = AchievementRecord {
        id: object::new(ctx),
        bid_count: table::new<address, u64>(ctx),
        tip_count: table::new<address, u64>(ctx),
        tip_recived: table::new<address, u64>(ctx),
    };
    transfer::share_object(achievement_record);
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
    if (!table::contains(&creator_record.creator_record, uid_to_address(&uid))) {
        table::add(&mut creator_record.creator_record, uid_to_address(&uid), creator);
    }else {
        abort EExistNFT;
    };

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
    achievement_record: &mut AchievementRecord,
    creator_record: &CreatorRecord,
    nft_address: address,
    revenue_tip_pool: &mut RevenueTipPool,
    reference_tip_pool: &mut ReferenceTipPool,
    creator_tip_pool: &mut CreatorTipPool,
    mut tip_coin: Coin<SUI>,
    mut revenue: address,
    reference: address,
    ctx: &mut TxContext
) {
    //todo need to fix
    revenue = Admin;


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
        ref_fee = amount / (ReferenceShare as u64);
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

    update_achievement_record(&mut achievement_record.tip_recived, *creator, amount);
    update_achievement_record(&mut achievement_record.tip_count, ctx.sender(), 1);
}

fun update_achievement_record(record: &mut Table<address, u64>, owner: address, num: u64) {
    if (!table::contains(record, owner)) {
        table::add(record, owner, num);
    }else {
        let pre_num = table::borrow_mut(record, owner);
        *pre_num = (*pre_num) + num;
    }
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


//Function for creating a new auction
public entry fun create_auction(nft: CopyrightNFT, min_bid: u64, duration: u64, clock: &Clock, ctx: &mut TxContext) {
    // Check if min_bid is zero
    assert!(min_bid > 0, EZeroBid);
    // Check if duration is zero
    assert!(duration > 0, EZeroDuration);

    //Add the duration to get the end time for the auction.
    let end_time = clock::timestamp_ms(clock) + duration;
    //Varibale to store the transaction context
    let seller = ctx.sender();
    //The id for the nft
    let nft_id = object::id(&nft);

    let auction = Auction {
        id: object::new(ctx),
        nft: std::option::some(nft),
        seller,
        highest_bidder: seller,
        current_bid: min_bid,
        min_bid,
        end_time,
        coin_balance: balance::zero(),
        auction_ended: false,
        reference_reord: table::new<address, address>(ctx),
        auction_reward: table::new<address, Coin<SUI>>(ctx),
    };

    let cap = AuctionCap {
        id: object::new(ctx),
        `for`: object::id(&auction)
    };

    event::emit(AuctionCreated {
        auction_id: object::id(&auction),
        nft_id,
        seller,
        start_price: min_bid,
        end_time,
    });

    //Share the auction object
    transfer::share_object(auction);
    transfer::public_transfer(cap, ctx.sender());
}

//Function for placing a new bid
public entry fun place_bid(
    auction: &mut Auction,
    clock: &Clock,
    coin: &mut Coin<SUI>,
    reference: address,
    ctx: &mut TxContext
) {
    let coin_value = coin.value();
    // Check if the bid amount is zero
    assert!(coin_value > 0 && coin_value > auction.current_bid, EZeroBid);
    // check the time
    assert!(clock::timestamp_ms(clock) < auction.end_time, ETimeExpired);
    // check not seller
    assert!(ctx.sender() != auction.seller, ESellerBuy);

    if (!table::contains(&auction.reference_reord, ctx.sender()) && reference != @0) {
        table::add(&mut auction.reference_reord, ctx.sender(), reference);
    };

    //Get the address of the bidder
    let bidder = ctx.sender();

    //Refund process of the previous highest bidder
    if (auction.highest_bidder != auction.seller) {
        transfer::public_transfer(
            coin.split(auction.current_bid, ctx),
            auction.highest_bidder
        );
    };

    //Set the current bid and highest bidder
    auction.current_bid = coin_value;
    auction.highest_bidder = bidder;

    //We update the balance in the auction by calling this function
    update_balance_with_coin(auction, coin_value, coin, ctx);

    event::emit(BidPlaced {
        auction_id: object::id(auction),
        bidder,
        amount: coin_value,
    });
}

//Function that will assist us with updating the coin balance of the auction struct
fun update_balance_with_coin(auction: &mut Auction, new_amount: u64, payment: &mut Coin<SUI>, ctx: &mut TxContext) {
    //Extract the value of the balance
    let current_balance = &mut auction.coin_balance;
    let current_value = current_balance.value();

    // Need to add to the balance
    let to_add = new_amount - current_value;
    let added = payment.split(to_add, ctx);
    current_balance.join(coin::into_balance(added));
}


//Function for ending the auction
public entry fun end_auction(
    achievement_record: &mut AchievementRecord,
    revenue_share: u64,
    cap: &AuctionCap,
    auction: &mut Auction,
    clock: &Clock,
    revenue_cap: &RevenueCap,
    ctx: &mut TxContext
) {
    assert!(object::id(auction) == cap.`for`, ENotOwner);
    //Get the time currently
    assert!(clock::timestamp_ms(clock) >= auction.end_time, EAuctionNotEnded);
    // Mark the auction as ended
    auction.auction_ended = true;

    let auction_reward = &mut auction.auction_reward;

    // Check if there were any bids
    if (auction.highest_bidder == auction.seller) {
        // No bids were placed, return the NFT to the seller
        let nft = std::option::extract(&mut auction.nft);
        transfer::public_transfer(nft, auction.seller);

        event::emit(AuctionEndedNoBids {
            auction_id: object::id(auction),
            seller: auction.seller,
        });
    } else {
        // There was a winning bid
        let winner = auction.highest_bidder;
        let final_price = auction.current_bid;

        let mut payment = coin::take(&mut auction.coin_balance, final_price, ctx);

        //revenue share
        let revenue_value = payment.value() * revenue_share / 100;
        let revenue_coin = payment.split(revenue_value, ctx);
        if (table::contains(auction_reward, revenue_cap.revenue_address)) {
            let remain_coin = table::borrow_mut(auction_reward, revenue_cap.revenue_address);
            coin::join(remain_coin, revenue_coin);
        }else {
            table::add(auction_reward, revenue_cap.revenue_address, revenue_coin);
        };


        // transfer::public_transfer(revenue_coin, revenue_cap.revenue_address);

        //reference share
        if (table::contains(&auction.reference_reord, auction.highest_bidder)) {
            let mut _ref_fee = 0;
            let reference = table::borrow(&auction.reference_reord, auction.highest_bidder);
            _ref_fee = payment.value() / (ReferenceShare as u64);
            let ref_coin = payment.split(_ref_fee, ctx);
            if (table::contains(auction_reward, *reference)) {
                let remain_coin = table::borrow_mut(auction_reward, *reference);
                coin::join(remain_coin, ref_coin);
            }else {
                table::add(auction_reward, *reference, ref_coin);
            };
        };


        // Transfer funds to the seller
        if (table::contains(auction_reward, auction.seller)) {
            let remain_coin = table::borrow_mut(auction_reward, auction.seller);
            coin::join(remain_coin, payment);
        }else {
            table::add(auction_reward, auction.seller, payment);
        };


        event::emit(AuctionEnded {
            auction_id: object::id(auction),
            winner,
            final_price,
        });

        update_achievement_record(&mut achievement_record.bid_count, winner, 1);
    }
}

//Function for the winner to claim their NFT
public fun claim_nft(auction: &mut Auction, ctx: &mut TxContext) {
    // Ensure the auction has ended
    assert!(auction.auction_ended, EAuctionNotEnded);
    // Ensure the claimer is the winner
    assert!(ctx.sender() == auction.highest_bidder, ENotWinner);

    let winner = auction.highest_bidder;

    // Extract the NFT from the auction struct
    let nft = std::option::extract(&mut auction.nft);

    // Transfer the NFT to the winner
    transfer::public_transfer(nft, winner);

    event::emit(NFTClaimed {
        auction_id: object::id(auction),
        winner,
    });
}

public fun claim_reward(auction: &mut Auction, ctx: &mut TxContext) {
    assert!(table::contains(&auction.auction_reward, ctx.sender()), ENoRewardClaim);
    let reward = table::remove(&mut auction.auction_reward, ctx.sender());
    transfer::public_transfer(reward, ctx.sender());
}


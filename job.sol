// SPDX-License-Identifier: MIT
pragma solidity >=0.7.0;

import "hardhat/console.sol";

contract flatSelling {
    address admin;
    address member;

    struct Flat {
        uint estateId;
        address owner;
        uint square;
    }
    struct flatSale {
        uint estateId;
        bool status;
        uint timeToSale;
        bool payed;
        bool adminConfirm;
    }

    struct payships {
        address user;
        uint money;
    }

    mapping (uint => address) public FlatOwner;
    mapping (uint => uint) public FlatSquare;

    mapping (uint => uint) public FlatSellingPrice;
    mapping (uint => bool) public FlatOnSale;
    mapping (uint => uint) public FlatSaleTime;
    mapping (uint => bool) public FlatBuyerConfirm;
    mapping (uint => bool) public FlatAdminConfirm;

    mapping (uint => address) public FlatMostValue;

    payships[] public payshipsArray;

    constructor() {
        admin = 0x5B38Da6a701c568545dCfcB03FcB875f56beddC4;
        member = msg.sender;
        flatAdder(1, admin, 50);
    }

    function flatAdder(uint _id, address _owner, uint _square) public {
        require(admin == msg.sender, "No permissions");
        
        FlatOwner[_id] = _owner;
        FlatSquare[_id] = _square;
    }

    function flatOnSale(uint _id, uint _price, uint _saleTime) public {
        require(msg.sender == admin, "You don't have permission to sale flats");
        require(FlatOnSale[_id] == false, "Flat already on the sale");
        FlatOnSale[_id] = true;
        FlatSaleTime[_id] = block.timestamp + _saleTime;
        FlatSellingPrice[_id] = _price;
    }

    function maxMoneyIdFinder() public view returns (uint) {
        uint previous = 0;
        uint id = 0;
        for (uint i = 0; i < payshipsArray.length; i++) {
            if (payshipsArray[i].money > previous) {
                id = i;
            }
            previous = payshipsArray[i].money;
        } 
        return id;
    }

    function cancelSale(uint _id) public payable {
	require(FlatOnSale[_id] == true, "Flat is not on the sale");
	FlatOnSale[_id] = false;
    for (uint i = 0; i < payshipsArray.length; i++) {
        payable(payshipsArray[i].user).transfer(payshipsArray[i].money);
    } 
    if (FlatAdminConfirm[_id] == true) {
        FlatAdminConfirm[_id] == false;
    }
	}

    function buyerConfirmation(uint _id) public payable returns (bool) {
        require(FlatOnSale[_id] == true, "This flat is not for sale");
        require(msg.sender != FlatOwner[_id], "You can't buy your own flat");
        require(msg.value > FlatSellingPrice[_id]*10**18, "Not enough money");
        FlatBuyerConfirm[_id] = true;
        payshipsArray.push(payships(msg.sender, msg.value));
	    return true;
    }

    uint start = block.timestamp;

    function adminSaleConfirmation(uint _id) public payable returns (bool) {
        require(FlatBuyerConfirm[_id] == true, "Nothing to confirmate");
        FlatSaleTime[_id] = start + 10 seconds;
        FlatAdminConfirm[_id] = true;
        uint money = 0;
        uint previous = 0;
        uint id = 0;
        address user = address(0);
        for (uint i = 0; i < payshipsArray.length; i++) {
            if (payshipsArray[i].money > previous) {
                id = i;
                user = payshipsArray[i].user;
                money = payshipsArray[i].money;
            }
            previous = payshipsArray[i].money;
        } 
        payable(FlatOwner[_id]).transfer(money);
        for (uint i = 0; i < payshipsArray.length; i++) {
            if (i == id) {
                i == i;
            }
            else {
                payable(payshipsArray[i].user).transfer(payshipsArray[i].money);
            }
        } 
        FlatMostValue[_id] = payshipsArray[id].user;
	return true;
   	}
    
    function flatSaleTimeChecker(uint _id) public view{
        require(block.timestamp < FlatSaleTime[_id], "Flat is overtimed");
    }

    function flatSeller(uint _id) public payable {
        require(FlatBuyerConfirm[_id] == true, "Error in proccess");
	    require(FlatAdminConfirm[_id] == true, "Error in proccess");
        FlatOnSale[_id] = false;
        FlatSaleTime[_id] = 0;
        FlatOnSale[_id] = false;
        FlatOwner[_id] = FlatMostValue[_id];
     	}
}

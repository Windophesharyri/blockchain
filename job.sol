// SPDX-License-Identifier: MIT
pragma solidity >=0.7.0;

contract flatSelling {
    address admin;
    address member;

    struct Flat {
        uint estateId;
        address owner;
        uint square;
        uint expirationDate;
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

    Flat[] public flats;
    flatSale[] public salingFlats;
    payships[] public payshipsArray;

    constructor() {
        admin = 0x5B38Da6a701c568545dCfcB03FcB875f56beddC4;
        member = msg.sender;
        flatAdder(1, admin, 50, 7);
    }
    
    // function roleSwap(address _newAdmin, address _newMember) public {
    //     address admin = _newAdmin;
    //     address member = _newMember;
    // }

    function flatAdder(uint _id, address _owner, uint _square, uint _expirationDate) public {
        require(admin == msg.sender, "No permissions");
        
        flats.push(Flat(flats.length + 1, _owner, _square, _expirationDate));
        salingFlats.push(flatSale(_id, false, 0, false, false));
    }

    function flatOnSale(uint _id, uint _price, uint saleTime) public {
        require(msg.sender == admin, "You don't have permission to sale flats");
        require(salingFlats[_id].status == false, "Flat already on the sale");
        salingFlats[_id].estateId = _id;
        salingFlats[_id].status = true;
        salingFlats[_id].timeToSale = saleTime;
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
	require(msg.sender == admin, "You don't have permissions to sale flat");
	require(salingFlats[_id].status == true, "Flat is not on the sale");
	salingFlats[_id].status = false;
    uint id = maxMoneyIdFinder();
    for (uint i = 0; i < payshipsArray.length; i++) {
        payable(payshipsArray[i].user).transfer(payshipsArray[i].money*10**18);
    } 
    if (salingFlats[_id].adminConfirm == true) {
        salingFlats[_id].adminConfirm == false;
    }
	}

    function buyerConfirmation(uint _id) public payable returns (bool) {
        require(salingFlats[_id].status == true, "This flat is not for sale");
        require(msg.sender != flats[_id].owner);
        salingFlats[_id].payed = true;
        payshipsArray.push(payships(msg.sender, msg.value));
	    return true;
    }


    function adminSaleConfirmation(uint _id) public payable returns (bool) {
        require(salingFlats[_id].payed == true, "Nothing to confirmate");
        salingFlats[_id].adminConfirm = true;
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
        payable(admin).transfer(money*10**18);
        for (uint i = 0; i < payshipsArray.length; i++) {
            if (i == id) {
                i == i;
            }
            else {
                payable(payshipsArray[i].user).transfer(payshipsArray[i].money*10**18);
            }
        } 
	return true;
   	}

    function flatSeller(uint _id) public payable {
        require(salingFlats[_id].payed == true, "Error in proccess");
	    require(salingFlats[_id].adminConfirm == true, "Error in proccess");
        salingFlats[_id].status = false;
        salingFlats[_id].timeToSale = 0;
        salingFlats[_id].payed = false;
        flats[_id].owner = msg.sender;
     	}
    
    function arrayChecker() public view returns (Flat[] memory) {
        return flats;
    }
    function arrayCheckerSal() public view returns (flatSale[] memory) {
        return salingFlats;
    }
}

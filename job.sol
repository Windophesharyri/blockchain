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
        uint price;
        uint timeToSale;
        bool payed;
    }

    Flat[] public flats;
    flatSale[] public salingFlats;

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
        
        flats.push(Flat(_id, _owner, _square, _expirationDate));
        salingFlats.push(flatSale(_id, false, 0, 0, false));
    }

    function flatOnSale(uint _id, uint _price, uint saleTime) public {
        require(msg.sender == admin, "You don't have permission to sale flats");
        require(salingFlats[_id].status == false, "Flat already on the sale");
        salingFlats[_id].estateId = _id;
        salingFlats[_id].status = true;
        salingFlats[_id].price = _price;
        salingFlats[_id].timeToSale = saleTime;
    }

    function cancelSale(uint _id) public payable {
	require(msg.sender == admin, "You don't have permissions to sale flat");
	require(salingFlats[_id].status == true, "Flat is not on the sale");
	salingFlats[_id].status = false;
    if (salingFlats[_id].payed == true) {
        payable(msg.sender).transfer(salingFlats[_id].price*10**18);
    }
	}

    function buyerConfirmation(uint _id) public payable returns (bool) {
        require(salingFlats[_id].status == true, "This flat is not for sale");
        require(msg.value == salingFlats[_id].price*10**18, "Not that price");
        salingFlats[_id].payed = true;
	    return true;
    }


    function adminSaleConfirmation(uint _id) public payable returns (bool) {
	payable(admin).transfer(salingFlats[_id].price*10**18);
	return true;
   	}

    function flatSeller(uint _id) public payable {
        bool buyerStatus = buyerConfirmation(_id);
        bool salerStatus = adminSaleConfirmation(_id);
        require(buyerStatus == true, "Error in proccess");
	    require(salerStatus == true, "Error in proccess");
        salingFlats[_id].status = false;
        salingFlats[_id].price = 0;
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
    // function abc () payable {}
    // to.transfer(msg.value)
    // payable(to).transfer(what)
    // function moneyReceiving()
}

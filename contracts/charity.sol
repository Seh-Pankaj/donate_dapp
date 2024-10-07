// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

// ERRORS
error CharityContract__AmountMustBeAboveZero();
error CharityContract__AlreadyDeleted();
error CharityContract__NotAllowedToDelete();
error CharityContract__CharityDoesNotExist();

contract CharityContract {
    // DATA TYPES
    struct Charity {
        string name;
        uint16 id;
        string description;
        uint targetAmountInEther;
        uint collectedAmountInEther;
        uint expiryDate; // in UNIX timestamp
        address creator;
        address[] supporters;
        address[3] topThreeSupporters;
    }

    struct Supporter {
        string name;
        uint24 supporterId;
        address supporterAddress;
    }

    // STATE VARIABLES
    uint16 counter;
    address contractOwner;
    Charity[] charitiesArray;

    // MAPPINGS
    mapping(address => uint) supporterDonation;

    // EVENTS
    event CharityListed(uint16 indexed id);
    event CharityDeleted(uint16 indexed id);
    event DonationSuccessfull(uint amount);

    // MODIFIERS
    modifier deletePreRequisites(uint16 index, address sender) {
        if (charitiesArray[index].id == 0)
            revert CharityContract__AlreadyDeleted();
        if (sender != contractOwner && sender != charitiesArray[index].creator)
            revert CharityContract__NotAllowedToDelete();
        _;
    }

    modifier charityExists(uint16 id) {
        if (id > counter || id <= 0)
            revert CharityContract__CharityDoesNotExist();
        _;
    }

    // CONSTRUCTOR
    constructor() {
        counter = 0;
        contractOwner = msg.sender;
        Charity memory ch;
        charitiesArray.push(ch);
    }

    // FUNCTIONS

    /**
     * @notice This function creates a charity with owner set to whoever calls it
     * @param name Name of charity
     * @param description Description of charity
     * @param targetAmount Target Amount in ether
     * @param expiryDate Expiry Date in UNIX timestamp
     */
    function createCharity(
        string memory name,
        string memory description,
        uint targetAmount,
        uint expiryDate
    ) public {
        counter++;
        Charity memory newCharity;
        newCharity.name = name;
        newCharity.id = counter;
        newCharity.description = description;
        newCharity.targetAmountInEther = targetAmount;
        newCharity.collectedAmountInEther = 0 ether;
        newCharity.expiryDate = expiryDate;
        newCharity.creator = msg.sender;

        charitiesArray.push(newCharity);
        emit CharityListed(counter);
    }

    /**
     * @notice this function deletes an already existing charity
     * @param id id of the charity
     */
    function deleteCharity(
        uint16 id
    ) public deletePreRequisites(id, msg.sender) {
        delete charitiesArray[id];
        emit CharityDeleted(id);
    }

    /**
     * @notice this donate function takes some ether and donates to the charity
     * @param id id of the charity
     */
    function donate(uint16 id) public payable charityExists(id) {
        supporterDonation[msg.sender] += msg.value;
        charitiesArray[id].collectedAmountInEther += msg.value;
        emit DonationSuccessfull(msg.value);
    }

    // GETTER FUNCTIONS

    function getCounter() public view returns (uint16) {
        return counter;
    }

    function getContractOwner() public view returns (address) {
        return contractOwner;
    }

    function getCharity(
        uint16 id
    ) public view charityExists(id) returns (Charity memory) {
        return charitiesArray[id];
    }

    function getCharities() public view returns (Charity[] memory) {
        return charitiesArray;
    }
}

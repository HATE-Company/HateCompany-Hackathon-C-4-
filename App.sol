// SPDX-License-Identifier: GPL-3.0

/*
@author Durmuş Gülbahar
@since 09/09/2022 19:04
*/

pragma solidity >=0.7.0 <0.9.0;


contract App{
 
     address payable owner;
     uint256 entryFee = 39000000000000 wei; // 0.07 $ or 0.000039 ether


     constructor(){
      owner = payable(msg.sender);
    }


    enum Rank{
        BRONZE,
        SILVER,
        GOLD
    }

    //User struct contains informations of user.
    struct UserInfo{
        string username;
        uint256 entryNumber; // Number of entries
        bool isBanned;
        Rank rank; // Rank of user BRONZE-SILVER-GOLD
        uint256 lastPostTime; 
        uint256 karma;
    }

    mapping(address=>UserInfo) public users; //users mapping address => UserInfo

    mapping(address => uint256) public checklist; //checklist of the newcomers who posted 50 entries.


    // @@@@@@@@@@@ EVENTS @@@@@@@@@@@@

    
    event EntryCreated(
        address owner
    );

    
    event UserBanned(
        address _addr
    );

    event ChecklistAdded(
        address _addr
    );

    event Upvoted(
        address _voter,
        address _entryOwner
    );


    //@@@@@@@@@@@ MODIFIERS @@@@@@@@@@@@


    //Controls the user who wants to post entry if banned or not.
    modifier notBanned(address _addr){
        require(users[_addr].isBanned == false,"User banned");
        _;
    }

    //only owner
    modifier onlyOwner() {
        require(msg.sender == owner,"Only Owner");
        _;
    }



    // @@@@@@@   FUNCTIONS    @@@@@@@

    /*
    @dev Get user informations from "users" mapping.
    */
    function getUserInfo(address _addr) public view returns
    (
    string memory username,
    uint256 entryNumber,
    bool isBanned,
    Rank rank,
    uint256 lastPostTime,
    uint256 karma) 
    {
        return (users[_addr].username,  
        users[_addr].entryNumber, 
        users[_addr].isBanned, 
        users[_addr].rank,
        users[_addr].lastPostTime,
        users[_addr].karma); 
    }

    
    /*
    @dev Function that only owner can use to ban users who are posts sensitive contents.
    @params _addr - address who wants to ban
    */
    function banFunction(address _addr) public onlyOwner returns(address){
        users[_addr].isBanned = true;
        emit UserBanned(_addr);
        return _addr;
    }

    
    /*
    @dev If newcomers posted 50 entries, they are adding to "checklist" mapping with their karma points.
    we can fetch karma points of the newcomers who are posted 50 entries.
    */
    function addTheChecklist(address _addr) public returns(bool){
        if(getNumberOfEntries(_addr) >= 50){
            checklist[_addr] = getKarma(_addr);
            emit ChecklistAdded(_addr);
            return true;
        }
        else{
            return false;
        }
    }


    /*
    @dev Takes lastPostTime of the msg.sender and returns true if 1 hours has passed
    */
    function oneHourHasPassed(uint256 _time) public view returns(bool){
        require(block.timestamp > _time + 1 hours,"You need to wait for 1 hours to post.");
        return true;
    }

    /*
    @dev Takes entry fee from users who wants to post. Not implemented different topic/thread.
         Just 1 hour post duration.
    */
    function postEntryWithFee() external payable {

        if(oneHourHasPassed(users[msg.sender].lastPostTime)){

            require(msg.value > entryFee, "Insufficient ether");
            users[msg.sender].entryNumber += 1;
            users[msg.sender].lastPostTime = block.timestamp; //update users lastPostTime
            emit EntryCreated(msg.sender);
        }

    }


    /*
    @dev Users sets username
    @params _username - Username that users want to show up in app
    */
    function setUsername(string memory _username) public {
        users[msg.sender].username = _username;
        
    }


    /*
    @dev Get username of address from "users" .
    @params _addr - address
    */
    function getUsername(address _addr) public view returns(string memory){
        return users[_addr].username;
    }


     /*
    @dev Get number of entries of the user from "entryNumbers"
    @params _addr - address
    */
    function getNumberOfEntries(address _addr) public view returns(uint){
        return users[_addr].entryNumber;
    }


    function banControl(address _addr) public view returns(bool){
        return users[_addr].isBanned;
    }


    function getRank(address _addr) public view returns(Rank){
        return users[_addr].rank;
    }
    


    /*
    @dev We can set rank of the user according to their NFTs automatically.
    */
    function setRank(address _addr, Rank rank) public returns(bool){
        users[_addr].rank = rank;
        return true;
    }


    function getKarma(address _addr) public view returns(uint256){
        return users[_addr].karma;
    }



    /*
    @dev Users can upvote entries. If voters' rank is "BRONZE" and entry owner rank is bigger than "BRONZE".
         Otherwise "BRONZE" users can not upvote each other's entries.
    @params _addr -> Entry owner,
    */
    function upvote(address _addr) public returns(bool){
        if(users[msg.sender].rank == Rank.BRONZE && users[_addr].rank > Rank.BRONZE){
            users[_addr].karma += 1;
            emit Upvoted(msg.sender, _addr);
            return true;
        }
        else{
            revert("You can not upvote the Newcomers' entries.");
        }
    }

    


    receive() external payable{
        revert("Can not send ether to the contract directly");
    }
    fallback() external payable{
        revert("Can not send ether or data to the contract directly");
    }

}

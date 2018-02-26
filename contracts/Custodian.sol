pragma solidity ^0.4.13;

contract Client {

    address owner; // currently not in use
    uint256 seed;
    address public creator;

    event ClientSeedChangedAt(uint256 time);

    modifier onlyCreater(address sender){
        require(sender == creator);
        _;
    }

    /** Internal functions **/
    function getRamdomNumber() internal view returns (uint256) {
        return uint256(keccak256(seed));
    }
    /************************/


    // Constructor
    function Client(uint256 _seed, address _creator) public {
        seed = _seed;
        creator = _creator;
    }

    function changeSeed(uint256 newSeed) public returns (bool success) {
        seed = newSeed;
        ClientSeedChangedAt(now);

        return true;
    }
  
    function getSeed() public view onlyCreater(msg.sender) returns (uint256) {
        return seed;
    }
  
}


contract Custodian {

    uint256 public volume;   // total volume of Clients
    address public owner;
    uint256 seed;
    mapping (uint256 => address) clients;   // store Client IDs --> Client addresses

    event CreateClient(uint256 id, address newAddress);
    event CustodianSeedChangedAt(uint256 time);    
    event UpdateClientFinished(uint256 amountOfClients, uint256 time);    

    modifier onlyOwner(address sender){
        require(sender == owner);
        _;
    }

    /** Internal functions **/
    function getNextID() internal returns (uint256) {
        volume = volume + 1;   // Increment total volume
        return volume;
    }

    function setSeedByAddress(address clientAddress, uint256 newSeed) internal onlyOwner(msg.sender) {
        Client client = Client(clientAddress);
        assert(client.changeSeed(newSeed)); // should receive the value "true" after successfully called the client contract 
    }
    /************************/

    
    // Constructor
    function Custodian() public {
        volume = 0;
        owner = msg.sender;
    }

    // Client creater
    function createClient() public onlyOwner(msg.sender) returns (uint256) {
        var clientID = getNextID();
        address clientAddress = new Client(seed , msg.sender);
        clients[clientID] = clientAddress;
        CreateClient(clientID, clientAddress);

        return clientID;
    }

    // Return Client address
    function getClientAddrByID(uint256 clientID) public view onlyOwner(msg.sender) returns (address) {
        return clients[clientID];
    }

    function setSeed(uint256 newSeed) public onlyOwner(msg.sender) {
        seed = newSeed;
        CustodianSeedChangedAt(now);

        // if there exists client contracts 
        if (volume >= 1) { 
            for (uint256 i = 1; i <= volume; i++) {
                setSeedByAddress(getClientAddrByID(i), newSeed);
            }
        }
    }
    
    function changeOwner(address newOwner) public onlyOwner(msg.sender) {
        owner = newOwner;
    }
}

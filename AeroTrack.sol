pragma solidity ^0.8.19;

contract AeroTrack {
    enum PartStatus { Manufactured, InTransit, Installed, Retired}

    struct Part {
        uint256 serialNumber;
        string partName;
        address manufacturer;
        address currentOwner;
        PartStatus status;
        bool exists;
    }

    struct ManufacturerIdentity {
        string companyName;
        bool isVerified;
    }

    event PartManufactured(uint256 indexed serialNumber, string partName, address manufacturer);
    event OwnershipTransferred(uint256 indexed serialNumber, address oldOwner, address newOwner);
    event MaintenanceLogged(uint256 indexed serialNumber, address mechanic, string report);
    event ManufacturerVerified(address indexed manufacturerAddress, string companyName);

    address public regulatoryAuthority;

    mapping(uint256 => Part) public parts;
    mapping(address => ManufacturerIdentity) public manufacturers;

    constructor() {
        regulatoryAuthority = msg.sender;
    }

    modifier onlyAuthority() {
        require(msg.sender == regulatoryAuthority, "Error: You are not the Authority.");
        _;
    }

    modifier partExists(uint256 _serialNumber) {
        require(parts[_serialNumber].exists == true, "Error: Part does not exist inregistry.");
        _;
    }

    modifier onlyPartOwner(uint256 _serialNumber) {
        require(parts[_serialNumber].currentOwner == msg.sender, "Error: You do not own this part.");
        _;
    }

    modifier onlyVerifiedManufacturer() {
        require(manufacturers[msg.sender].isVerified == true, "Error: Address is not a verified manufacturer.");
        _;
    }


    function verifyManufacturer(address _manufacturer, string memory _companyName)
        public 
        onlyAuthority
    {
        manufacturers[_manufacturer] = ManufacturerIdentity({
            companyName: _companyName,
            isVerified: true
        });
        
        emit ManufacturerVerified(_manufacturer, _companyName);
    }

    function manufacturePart(uint256 _serialNumber, string memory _partName)
        public
        onlyVerifiedManufacturer
    {
        require(parts[_serialNumber].exists == false, "Error: Serial Number already registered!");
        
        parts[_serialNumber] = Part({
            serialNumber: _serialNumber,
            partName: _partName,
            manufacturer: msg.sender,
            currentOwner: msg.sender,
            status: PartStatus.Manufactured,
            exists: true
        });

        emit PartManufactured(_serialNumber, _partName, msg.sender);
    }




    function transferPart(uint256 _serialNumber, address _newOwner)
        public
        partExists(_serialNumber)
        onlyPartOwner(_serialNumber)
    {
        require(_newOwner != address(0), "Error: Cannot transfer to zero address.");

        parts[_serialNumber].currentOwner = _newOwner;
        parts[_serialNumber].status = PartStatus.InTransit;
        
        emit OwnershipTransferred(_serialNumber, msg.sender, _newOwner);
    }


    function logMaintenance(uint256 _serialNumber, string memory _report)
        public 
        partExists(_serialNumber)
        onlyPartOwner(_serialNumber)
    {
        emit MaintenanceLogged(_serialNumber, msg.sender, _report);

        parts[_serialNumber].status = PartStatus.Installed;
    }


    


}
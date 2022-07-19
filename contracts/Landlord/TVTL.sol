// SPDX-License-Identifier: MIT
pragma solidity 0.8.7;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC721/presets/ERC721PresetMinterPauserAutoIdUpgradeable.sol";

import "../Wallet/Wallet.sol";

import "./Landlord.sol";

contract TVTL is ERC721PresetMinterPauserAutoIdUpgradeable, OwnableUpgradeable {
    struct License {
        uint256 performance;
        uint256 startDateTime;
        uint256 endDateTime;
    }

    struct Rent {
        address landlord;
        address tenant;
        uint256 startDateTime;
        uint256 endDateTime;
    }

    struct Land {
        uint8 color;
        License license;
        string message;
        uint8 purpose;
        Rent[] rents;
        uint256 tokenId;
    }

    // tokenId -> Land
    mapping(uint256 => Land) private _lands;

    uint256 private _initialSupply;

    uint256[] private _tokenIds;

    Wallet private _wallet;

    event TVTLRent(Land land);

    function __TVTL_init(
        string memory name,
        string memory symbol,
        string memory baseTokenURI,
        Wallet wallet,
        uint16 initialSupply
    ) public initializer {
        __ERC721PresetMinterPauserAutoId_init(name, symbol, baseTokenURI);
        __Ownable_init();

        setWallet(wallet);

        _initialSupply = initialSupply;
    }

    function init(uint256 tokens) public {
        require(
            _tokenIds.length < _initialSupply,
            "All tokents already minted"
        );

        address owner = owner();

        for (
            uint256 i = 0;
            i < tokens && _tokenIds.length < _initialSupply;
            i++
        ) {
            mint(owner);
        }
    }

    function buyLicense(uint256 tokenId, uint8 licenseId) public payable {
        Land storage land = _lands[tokenId];

        Landlord.LicenseParams memory license = _wallet
            .getLandlordLicenseParams(licenseId);

        require(
            license.price == msg.value,
            "License price is not equal to sending amount"
        );

        // TODO pay profit

        land.license = License({
            performance: license.performance,
            startDateTime: block.timestamp,
            endDateTime: block.timestamp + license.period
        });

        _wallet.transferTo(_msgSender(), license.price);
    }

    function getLand(uint256 tokenId) public view returns (Land memory) {
        return _lands[tokenId];
    }

    function getWallet() external view returns (Wallet) {
        return _wallet;
    }

    function rent(uint256 tokenId) public payable {
        address landlord = owner();
        address tenant = _msgSender();

        require(landlord == ownerOf(tokenId), "Land can't be rented");

        _transfer(landlord, tenant, tokenId);

        Land storage land = _lands[tokenId];

        Landlord.RentParams memory rentParams = _wallet.getLandlordRentParams(
            land.rents.length
        );

        require(landlord == ownerOf(tokenId), "Land can't be rented");

        require(rentParams.price == msg.value / 10**18, "Amount is not equal");

        land.rents.push(
            Rent({
                landlord: landlord,
                tenant: tenant,
                startDateTime: block.timestamp,
                endDateTime: block.timestamp + rentParams.period
            })
        );

        _wallet.transferTo(tenant, rentParams.price);

        emit TVTLRent(land);
    }

    function setMessage(uint256 tokenId, string memory message) public {
        require(
            _msgSender() == ownerOf(tokenId),
            "You are not authorize change message"
        );

        _lands[tokenId].message = message;
    }

    function setWallet(Wallet wallet) public onlyOwner {
        _wallet = wallet;
    }

    function subRent(uint256 tokenId, address tenant) public payable {
        Land storage land = _lands[tokenId];

        require(land.rents.length == 1, "Land is not rent");

        address landlord = _msgSender();

        require(landlord == ownerOf(tokenId), "Land can't be sub rented");

        setMessage(tokenId, "");

        _transfer(landlord, tenant, tokenId);

        Landlord.RentParams memory rentParams = _wallet.getLandlordRentParams(
            land.rents.length
        );

        land.rents.push(
            Rent({
                landlord: landlord,
                tenant: tenant,
                startDateTime: block.timestamp,
                endDateTime: block.timestamp + rentParams.period
            })
        );
    }

    function _afterTokenTransfer(
        address from,
        address to,
        uint256 tokenId
    ) internal virtual override {
        super._afterTokenTransfer(from, to, tokenId);

        if (from == address(0)) {
            _tokenIds.push(tokenId);

            _lands[tokenId].tokenId = tokenId;
        }
    }
}

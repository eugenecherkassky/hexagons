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
        string landId;
        License license;
        string message;
        uint8 purpose;
        Rent[] rents;
    }

    string[] private _landIds;

    // landId -> tokenId
    mapping(string => uint256) private _landIdToTokenId;

    // tokenId -> Land
    mapping(uint256 => Land) private _lands;

    Wallet private _wallet;

    error TVTLRent(string landId);

    function __TVTL_init(
        string memory name,
        string memory symbol,
        string memory baseTokenURI,
        string[] memory landIds,
        Wallet wallet
    ) public initializer {
        __ERC721PresetMinterPauserAutoId_init(name, symbol, baseTokenURI);
        __Ownable_init();

        setWallet(wallet);

        if (landIds.length != 0) {
            return;
        }

        address owner = owner();

        for (uint256 i = 0; i < landIds.length; i++) {
            _landIds.push(landIds[i]);

            mint(owner);
        }
    }

    function buyLicense(string memory landId, uint8 licenseId) public payable {
        uint256 tokenId = _landIdToTokenId[landId];

        Land storage land = _lands[tokenId];

        Landlord.License memory license = _wallet.getLandlordLicense(licenseId);

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

    function getLand(string memory landId)
        public
        view
        returns (Land memory land)
    {
        uint256 tokenId = _landIdToTokenId[landId];

        return _lands[tokenId];
    }

    function getLands() external view returns (Land[] memory) {
        Land[] memory lands;

        for (uint256 i = 0; i < _landIds.length - 1; i++) {
            lands[i] = getLand(_landIds[i]);
        }

        return lands;
    }

    function getWallet() external view returns (Wallet) {
        return _wallet;
    }

    function rent(string memory landId) public payable {
        uint256 tokenId = _landIdToTokenId[landId];

        address landlord = owner();
        address tenant = _msgSender();

        require(landlord == ownerOf(tokenId), "Land can't be rented");

        _transfer(landlord, tenant, tokenId);

        Land storage land = _lands[tokenId];

        Landlord.Rent memory rentParams = _wallet.getLandlordRent(
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

        _wallet.transferTo(tenant, rentParams.price);
    }

    function setMessage(string memory landId, string memory message) public {
        uint256 tokenId = _landIdToTokenId[landId];

        require(
            _msgSender() == ownerOf(tokenId),
            "You are not authorize change message"
        );

        _lands[tokenId].message = message;
    }

    function setWallet(Wallet wallet) public onlyOwner {
        _wallet = wallet;
    }

    function subRent(string memory landId, address tenant) public payable {
        uint256 tokenId = _landIdToTokenId[landId];
        Land storage land = _lands[tokenId];

        require(land.rents.length == 1, "Land is not rent");

        address landlord = _msgSender();

        require(landlord == ownerOf(tokenId), "Land can't be sub rented");

        _transfer(landlord, tenant, tokenId);

        delete land.message;

        Landlord.Rent memory rentParams = _wallet.getLandlordRent(
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
            // token miting
            string memory landId = _landIds[_landIds.length - 1];

            _landIdToTokenId[landId] = tokenId;
        } else {
            Land storage land = _lands[tokenId];

            bool found;

            for (uint8 i = 0; i < land.rents.length; i++) {
                if (found) {
                    // dirty code, delete and pop two different elements from array
                    delete land.rents[i];
                    land.rents.pop();

                    continue;
                }

                if (land.rents[i].landlord == to) {
                    found = true;
                }
            }

            revert TVTLRent({landId: land.landId});
        }
    }
}

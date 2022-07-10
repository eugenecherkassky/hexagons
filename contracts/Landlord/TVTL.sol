// SPDX-License-Identifier: MIT
pragma solidity 0.8.7;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC721/presets/ERC721PresetMinterPauserAutoIdUpgradeable.sol";

import "../Wallet.sol";

contract TVTL is ERC721PresetMinterPauserAutoIdUpgradeable, OwnableUpgradeable {
    struct ActiveLicence {
        uint256 performance;
        uint256 startDateTime;
        uint256 endDateTime;
    }

    struct Licence {
        uint256 performance;
        uint8 purpose;
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
        ActiveLicence licence;
        string message;
        uint8 purpose;
        Rent[] rents;
    }

    string[] private _landIds;

    // landId -> tokenId
    mapping(string => uint256) private _landIdToTokenId;

    // tokenId -> Land
    mapping(uint256 => Land) private _lands;

    Licence[] private _licences;

    Wallet private _wallet;

    error TVTLRent(string landId);

    function __TVTL_init(
        string memory name,
        string memory symbol,
        string memory baseTokenURI,
        string[] memory landIds,
        Licence[] memory licences,
        Wallet wallet
    ) public initializer {
        __ERC721PresetMinterPauserAutoId_init(name, symbol, baseTokenURI);
        __Ownable_init();

        setLicences(licences);
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

    function buyLicence(string memory landId, uint8 licenceId) public payable {
        uint256 tokenId = _landIdToTokenId[landId];

        Land storage land = _lands[tokenId];

        Licence memory licence = _licences[licenceId];

        uint256 price = _wallet.getTVTLLicencePrice(licenceId);

        require(price == msg.value, "Amount is not equal");

        land.licence = ActiveLicence({
            performance: licence.performance,
            startDateTime: block.timestamp,
            endDateTime: block.timestamp + getLicencePeriod()
        });

        _wallet.transferTo(_msgSender(), price);
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

    function getLicences() external view returns (Licence[] memory) {
        return _licences;
    }

    function getLicencePeriod() public pure returns (uint256) {
        return 30 * 24 * 60 * 60;
    }

    function getRentPeriod() public pure returns (uint256) {
        return 365 * 24 * 60 * 60;
    }

    function getRentPrice() public pure returns (uint256) {
        return 100;
    }

    function getSubRentPeriod() public pure returns (uint256) {
        return 30 * 24 * 60 * 60;
    }

    function getWallet() external view returns (Wallet) {
        return _wallet;
    }

    function rent(string memory landId) external {
        uint256 tokenId = _landIdToTokenId[landId];

        address landlord = owner();
        address tenant = _msgSender();

        require(landlord == ownerOf(tokenId), "Land is already rented");

        _transfer(landlord, tenant, tokenId);
    }

    function setLicences(Licence[] memory licences) public onlyOwner {
        delete _licences;

        for (uint8 i = 0; i < licences.length; i++) {
            _licences.push(licences[i]);
        }
    }

    function setMessage(string memory landId, string memory message) public {
        uint256 tokenId = _landIdToTokenId[landId];

        _lands[tokenId].message = message;
    }

    function setWallet(Wallet wallet) public onlyOwner {
        _wallet = wallet;
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

            uint8 rentIndex;

            for (uint8 i = 0; i < land.rents.length; i++) {
                if (rentIndex > 0) {
                    // dirty code, delete and pop two different elements from array
                    delete land.rents[i];
                    land.rents.pop();

                    continue;
                }

                if (land.rents[i].landlord == to) {
                    rentIndex = i;
                }
            }

            if (rentIndex > 0) {
                return;
            }

            if (land.rents.length == 0) {
                // token renting
                land.rents.push(
                    Rent({
                        landlord: from,
                        tenant: to,
                        startDateTime: block.timestamp,
                        endDateTime: block.timestamp + getRentPeriod()
                    })
                );

                _wallet.transferTo(to, getRentPrice());

                return;
            }

            if (land.rents.length == 1) {
                // token subrenting
                land.rents.push(
                    Rent({
                        landlord: from,
                        tenant: to,
                        startDateTime: block.timestamp,
                        endDateTime: block.timestamp + getSubRentPeriod()
                    })
                );

                return;
            }

            revert TVTLRent({landId: land.landId});
        }
    }
}

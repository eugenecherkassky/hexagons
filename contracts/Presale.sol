// SPDX-License-Identifier: MIT
pragma solidity 0.8.7;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

contract Presale is Ownable {
    using SafeMath for uint256;
    using SafeMath for uint256;

    struct pPair {
        address w_address;
        bool status;
        uint256 A;
        uint256 B;
    }

    struct rfStatus {
        bool status;
        uint256 A;
        uint256 B;
    }

    struct refWallet {
        bool status;
        uint256 totalAmount;
    }

    struct refWalletInfo {
        bool status;
        uint256 totalAmount;
        uint256 needAmount;
        uint256 needMoreAmount;
    }

    address public addressTVTtoken;

    bool public ReferalStatus = false;

    mapping(address => refWallet) public referWallets;
    mapping(address => pPair) public sellPairsAddress;
    address[] public listOfPair;
    bool public Paused;
    rfStatus public referBont = rfStatus(false, 0, 0);
    uint256 public TotalTokensSold = 0;
    uint256 public minToStartRefer = 200 * 1e18;

    event BuyTokenRef(
        address indexed _from,
        address indexed _refferrer,
        uint256 _amount
    );

    uint256 public minAmountOut = 10 * 1e18;

    constructor(address _addressTVTtoken, bool _paused) {
        addressTVTtoken = _addressTVTtoken;
        Paused = _paused;
    }

    function setPaused(bool _paused) public onlyOwner {
        Paused = _paused;
    }

    function addReferrer(address _address) public onlyOwner {
        referWallets[_address].status = true;
    }

    function setMinAmountOut(uint256 _MinAmountOut) public onlyOwner {
        minAmountOut = _MinAmountOut;
    }

    function setRefBont(
        bool _status,
        uint256 _raiseAmount,
        uint256 _bontReferrer
    ) public onlyOwner {
        referBont = rfStatus(_status, _raiseAmount, _bontReferrer);
    }

    function ladingTokens(uint256 _amount) public onlyOwner {
        IERC20(addressTVTtoken).transferFrom(
            msg.sender,
            address(this),
            _amount
        );
    }

    function addSellPair(
        address _contract,
        uint256 _A,
        uint256 _B
    ) public onlyOwner {
        if (sellPairsAddress[_contract].status == false) {
            sellPairsAddress[_contract] = pPair(_contract, true, _A, _B);

            IERC20(_contract).approve(address(this), 100000000 * 1e18);

            listOfPair.push(_contract);
        } else {
            sellPairsAddress[_contract] = pPair(_contract, true, _A, _B);
        }
    }

    function setStatusReferralProgramm(bool _status) public onlyOwner {
        ReferalStatus = _status;
    }

    function ApprovalTVTToken() public onlyOwner {
        IERC20(addressTVTtoken).approve(address(this), 100000000000 * 1e18);
    }

    function ApprovalToken(address _contract) public onlyOwner {
        IERC20(_contract).approve(address(this), 100000000000 * 1e18);
    }

    function buyToken(
        address _token,
        address _wallet,
        uint256 _amountIn,
        uint256 _amountOut
    ) public {
        require(Paused == false, "Contract Paused");

        require(_amountOut >= minAmountOut, "Fail_Amoun_Out");

        require(sellPairsAddress[_token].status == true, "NO_PAIR");

        require(IERC20(_token).balanceOf(msg.sender) >= _amountIn, "NO TOKENS");

        uint256 amt = (_amountIn.div(sellPairsAddress[_token].A)).mul(
            sellPairsAddress[_token].B
        );

        require(_amountOut == amt, "Error  Request");

        require(
            IERC20(addressTVTtoken).balanceOf(address(this)) >= _amountOut,
            "NO CONTRACT TOKENS"
        );

        IERC20(_token).transferFrom(msg.sender, address(this), _amountIn);

        IERC20(addressTVTtoken).transferFrom(
            address(this),
            _wallet,
            _amountOut
        );

        referWallets[msg.sender].totalAmount += _amountOut;
        if (!referWallets[msg.sender].status) {
            if (referWallets[msg.sender].totalAmount >= minToStartRefer) {
                referWallets[msg.sender].status = true;
            } else {
                referWallets[msg.sender].status = false;
            }
        }
        TotalTokensSold += _amountOut;
    }

    function buyTokenRef(
        address _token,
        address _wallet,
        address _referrer,
        uint256 _amountIn,
        uint256 _amountOut,
        uint256 _amountOutBon
    ) public {
        require(Paused == false, "Contract Paused");

        require(_amountOutBon >= minAmountOut, "Fail_Amoun_Out");

        require(_wallet != _referrer, "Err_referrer");

        require(referWallets[_referrer].status == true, "No_Referrer");
        require(ReferalStatus == true, "Ref_Disabled");
        require(sellPairsAddress[_token].A > 0, "NO_PAIR");
        require(IERC20(_token).balanceOf(msg.sender) >= _amountIn, "NO_TOKENS");
        uint256 amt = (_amountIn.div(sellPairsAddress[_token].A)).mul(
            sellPairsAddress[_token].B
        );
        uint256 amtBob = ((amt.div(1000)).mul(referBont.A)).add(amt);
        require(_amountOutBon == amtBob, "Error  Request");
        uint256 rBonus = (amt.div(1000)).mul(referBont.B);
        require(
            IERC20(addressTVTtoken).balanceOf(address(this)) >=
                _amountOut.add(rBonus),
            "NO_CONTRACT_TOKENS"
        );
        IERC20(_token).transferFrom(msg.sender, address(this), _amountIn);
        IERC20(addressTVTtoken).transferFrom(
            address(this),
            _wallet,
            _amountOutBon
        );
        IERC20(addressTVTtoken).transferFrom(address(this), _referrer, rBonus);
        referWallets[msg.sender].totalAmount += _amountOut;

        if (!referWallets[msg.sender].status) {
            if (referWallets[msg.sender].totalAmount >= minToStartRefer) {
                referWallets[msg.sender].status = true;
            } else {
                referWallets[msg.sender].status = false;
            }
        }

        TotalTokensSold += _amountOut.add(rBonus);
        emit BuyTokenRef(_wallet, _referrer, rBonus);
    }

    function getRefInfo(address _address)
        public
        view
        returns (refWalletInfo memory _result)
    {
        _result.status = referWallets[_address].status;
        _result.totalAmount = referWallets[_address].totalAmount;
        _result.needAmount = minToStartRefer;

        if (referWallets[_address].totalAmount >= minToStartRefer) {
            _result.needMoreAmount = 0;
        } else {
            _result.needMoreAmount = minToStartRefer.sub(
                referWallets[_address].totalAmount
            );
        }
        return _result;
    }

    function getTVTBalanceOf() public view returns (uint256) {
        return IERC20(addressTVTtoken).balanceOf(address(this));
    }

    function getTokensBalanceOf(address _address)
        public
        view
        returns (uint256)
    {
        return IERC20(_address).balanceOf(address(this));
    }

    function withdrawTVT() public onlyOwner {
        IERC20(addressTVTtoken).transferFrom(
            address(this),
            msg.sender,
            IERC20(addressTVTtoken).balanceOf(address(this))
        );
    }

    function withdrawAll() public onlyOwner {
        for (uint256 i = 0; i < listOfPair.length; i++) {
            IERC20(listOfPair[i]).transferFrom(
                address(this),
                msg.sender,
                IERC20(listOfPair[i]).balanceOf(address(this))
            );
        }
    }

    function getCountPairs() public view returns (uint256) {
        return listOfPair.length;
    }

    function getPairId(uint256 _id) public view returns (pPair memory) {
        return sellPairsAddress[listOfPair[_id]];
    }

    function getAllPairs() public view returns (pPair[] memory) {
        pPair[] memory rt_pPair = new pPair[](listOfPair.length);
        for (uint256 i = 0; i < listOfPair.length; i++) {
            pPair storage tmp_pair = sellPairsAddress[listOfPair[i]];
            rt_pPair[i] = tmp_pair;
        }
        return rt_pPair;
    }

    function getBid() public view returns (pPair[] memory) {
        pPair[] memory lBids = new pPair[](listOfPair.length);
        for (uint256 i = 0; i < listOfPair.length; i++) {
            pPair storage lBid = sellPairsAddress[listOfPair[i]];
            lBids[i] = lBid;
        }
        return lBids;
    }
}

# Starting migrations...

> Network name: 'testnet'
> Network id: 97
> Block gas limit: 29999542 (0x1c9c1b6)

# 1_initial_migration.js

Deploying 'Migrations'

---

Error: **_ Deployment Failed _**

"Migrations" -- senderAddress.toLowerCase is not a function.

    at /Users/ievgencherkaskyi/Projects/tivan/launchpool/node_modules/truffle/build/webpack:/packages/deployer/src/deployment.js:365:1
    at processTicksAndRejections (node:internal/process/task_queues:96:5)
    at Migration._deploy (/Users/ievgencherkaskyi/Projects/tivan/launchpool/node_modules/truffle/build/webpack:/packages/migrate/Migration.js:68:1)
    at Migration._load (/Users/ievgencherkaskyi/Projects/tivan/launchpool/node_modules/truffle/build/webpack:/packages/migrate/Migration.js:55:1)
    at Migration.run (/Users/ievgencherkaskyi/Projects/tivan/launchpool/node_modules/truffle/build/webpack:/packages/migrate/Migration.js:171:1)
    at Object.runMigrations (/Users/ievgencherkaskyi/Projects/tivan/launchpool/node_modules/truffle/build/webpack:/packages/migrate/index.js:150:1)
    at Object.runFrom (/Users/ievgencherkaskyi/Projects/tivan/launchpool/node_modules/truffle/build/webpack:/packages/migrate/index.js:110:1)
    at Object.runAll (/Users/ievgencherkaskyi/Projects/tivan/launchpool/node_modules/truffle/build/webpack:/packages/migrate/index.js:114:1)
    at Object.run (/Users/ievgencherkaskyi/Projects/tivan/launchpool/node_modules/truffle/build/webpack:/packages/migrate/index.js:79:1)
    at runMigrations (/Users/ievgencherkaskyi/Projects/tivan/launchpool/node_modules/truffle/build/webpack:/packages/core/lib/commands/migrate.js:262:1)
    at Object.run (/Users/ievgencherkaskyi/Projects/tivan/launchpool/node_modules/truffle/build/webpack:/packages/core/lib/commands/migrate.js:227:1)
    at Command.run (/Users/ievgencherkaskyi/Projects/tivan/launchpool/node_modules/truffle/build/webpack:/packages/core/lib/command.js:136:1)

Truffle v5.1.65 (core: 5.1.65)
Node v16.14.0
ievgencherkaskyi@MacBook-Pro-MAC launchpool % npx truffle migrate --reset --compile-all --network testnet

# Compiling your contracts...

> Compiling ./contracts/BankAccount.sol
> Compiling ./contracts/BankAccountBase.sol
> Compiling ./contracts/BankAccountSupplier.sol
> Compiling ./contracts/BankAccountUpgradeable.sol
> Compiling ./contracts/Date.sol
> Compiling ./contracts/IBankAccount.sol
> Compiling ./contracts/IBankAccountSupplier.sol
> Compiling ./contracts/IUpgradeable.sol
> Compiling ./contracts/Launchpool/BaseDeposit.sol
> Compiling ./contracts/Launchpool/Condition/AmountCondition.sol
> Compiling ./contracts/Launchpool/Condition/DepositCondition.sol
> Compiling ./contracts/Launchpool/Condition/PeriodCondition.sol
> Compiling ./contracts/Launchpool/Condition/TerminationCondition.sol
> Compiling ./contracts/Launchpool/Deposit.sol
> Compiling ./contracts/Launchpool/ILaunchpool.sol
> Compiling ./contracts/Launchpool/Launchpool.sol
> Compiling ./contracts/Migrations.sol
> Compiling ./contracts/Mint.sol
> Compiling ./contracts/Presale.sol
> Compiling ./contracts/Refillable.sol
> Compiling ./contracts/TVT/BEP20.sol
> Compiling ./contracts/TVT/IBEP20.sol
> Compiling ./contracts/TVT/TVT.sol
> Compiling ./contracts/TVTV/Crowdsale.sol
> Compiling ./contracts/TVTV/TVTVToken.sol
> Compiling ./contracts/TVTV/TVTVTokenCrowdsale.sol
> Compiling ./contracts/Treasury.sol
> Compiling ./contracts/VotingManager.sol
> Compiling @openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol
> Compiling @openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol
> Compiling @openzeppelin/contracts-upgradeable/utils/AddressUpgradeable.sol
> Compiling @openzeppelin/contracts-upgradeable/utils/ContextUpgradeable.sol
> Compiling @openzeppelin/contracts/access/AccessControl.sol
> Compiling @openzeppelin/contracts/access/AccessControlEnumerable.sol
> Compiling @openzeppelin/contracts/access/IAccessControl.sol
> Compiling @openzeppelin/contracts/access/IAccessControlEnumerable.sol
> Compiling @openzeppelin/contracts/access/Ownable.sol
> Compiling @openzeppelin/contracts/security/Pausable.sol
> Compiling @openzeppelin/contracts/security/ReentrancyGuard.sol
> Compiling @openzeppelin/contracts/token/ERC20/IERC20.sol
> Compiling @openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol
> Compiling @openzeppelin/contracts/token/ERC721/ERC721.sol
> Compiling @openzeppelin/contracts/token/ERC721/IERC721.sol
> Compiling @openzeppelin/contracts/token/ERC721/IERC721Receiver.sol
> Compiling @openzeppelin/contracts/token/ERC721/extensions/ERC721Burnable.sol
> Compiling @openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol
> Compiling @openzeppelin/contracts/token/ERC721/extensions/ERC721Pausable.sol
> Compiling @openzeppelin/contracts/token/ERC721/extensions/IERC721Enumerable.sol
> Compiling @openzeppelin/contracts/token/ERC721/extensions/IERC721Metadata.sol
> Compiling @openzeppelin/contracts/token/ERC721/presets/ERC721PresetMinterPauserAutoId.sol
> Compiling @openzeppelin/contracts/utils/Address.sol
> Compiling @openzeppelin/contracts/utils/Context.sol
> Compiling @openzeppelin/contracts/utils/Counters.sol
> Compiling @openzeppelin/contracts/utils/Strings.sol
> Compiling @openzeppelin/contracts/utils/introspection/ERC165.sol
> Compiling @openzeppelin/contracts/utils/introspection/IERC165.sol
> Compiling @openzeppelin/contracts/utils/math/SafeMath.sol
> Compiling @openzeppelin/contracts/utils/structs/EnumerableSet.sol
> Artifacts written to /Users/ievgencherkaskyi/Projects/tivan/launchpool/build/contracts
> Compiled successfully using:

- solc: 0.8.7+commit.e28d00a7.Emscripten.clang

# Starting migrations...

> Network name: 'testnet'
> Network id: 97
> Block gas limit: 30000000 (0x1c9c380)

# 1_initial_migration.js

Deploying 'Migrations'

---

> transaction hash: 0x582f1f59ed6398bbe01d98cf44245825032955a8e0ff92c4f9259b91f5c22a2a
> Blocks: 3 Seconds: 9
> contract address: 0x908E3F8815f0663C6935acbfBbe05a552a41fA75
> block number: 20756487
> block timestamp: 1656912663
> account: 0xeC473a6F28ba1EF107A74ce333E901980D18431d
> balance: 0.90671156
> gas used: 153922 (0x25942)
> gas price: 20 gwei
> value sent: 0 ETH
> total cost: 0.00307844 ETH

Pausing for 10 confirmations...

---

> confirmation number: 1 (block: 20756490)
> confirmation number: 2 (block: 20756491)
> confirmation number: 4 (block: 20756493)
> confirmation number: 5 (block: 20756494)
> confirmation number: 6 (block: 20756495)
> confirmation number: 8 (block: 20756497)
> confirmation number: 9 (block: 20756498)
> confirmation number: 10 (block: 20756499)

> Saving migration to chain.
> Saving artifacts

---

> Total cost: 0.00307844 ETH

# 2_deploy_tvt.js

Deploying 'TVT'

---

> transaction hash: 0x42d4f6dbbaaafb72e1e23fa015ecc7a2f44aff755eef0a98db86ffd02d4dceb4
> Blocks: 2 Seconds: 9
> contract address: 0x11C9C8121b698f84EDA19331Cc1AD35DDE1709B8
> block number: 20756507
> block timestamp: 1656912723
> account: 0xeC473a6F28ba1EF107A74ce333E901980D18431d
> balance: 0.86811708
> gas used: 1887434 (0x1cccca)
> gas price: 20 gwei
> value sent: 0 ETH
> total cost: 0.03774868 ETH

Pausing for 10 confirmations...

---

> confirmation number: 1 (block: 20756510)
> confirmation number: 3 (block: 20756512)
> confirmation number: 4 (block: 20756513)
> confirmation number: 5 (block: 20756514)
> confirmation number: 7 (block: 20756516)
> confirmation number: 8 (block: 20756517)
> confirmation number: 9 (block: 20756518)
> confirmation number: 11 (block: 20756520)

> Saving migration to chain.
> Saving artifacts

---

> Total cost: 0.03774868 ETH

# 3_deploy_presale.js

Deploying 'Presale'

---

> transaction hash: 0x01798d3cff0ab8fb243b367ced4a58d8bb47ed5fa9b86fc59d2b82ba2a47ac05
> Blocks: 3 Seconds: 9
> contract address: 0x7Ef1Dafaa8C71d444ad86cAc9c5478741E587f00
> block number: 20756529
> block timestamp: 1656912789
> account: 0xeC473a6F28ba1EF107A74ce333E901980D18431d
> balance: 0.82715712
> gas used: 2020708 (0x1ed564)
> gas price: 20 gwei
> value sent: 0 ETH
> total cost: 0.04041416 ETH

Pausing for 10 confirmations...

---

> confirmation number: 1 (block: 20756532)
> confirmation number: 3 (block: 20756534)
> confirmation number: 4 (block: 20756535)
> confirmation number: 5 (block: 20756536)
> confirmation number: 7 (block: 20756538)
> confirmation number: 8 (block: 20756539)
> confirmation number: 9 (block: 20756540)
> confirmation number: 11 (block: 20756542)

> Saving migration to chain.
> Saving artifacts

---

> Total cost: 0.04041416 ETH

# 4_deploy_mint.js

Deploying 'Date'

---

> transaction hash: 0xbd526fbc15a45b82216b593d1960e0b7c4d516737c0796dd8198fdd0b132bee1
> Blocks: 3 Seconds: 9
> contract address: 0xEC520b23877e2D3eD23514a48cd9f5F7EE49D0eB
> block number: 20756551
> block timestamp: 1656912855
> account: 0xeC473a6F28ba1EF107A74ce333E901980D18431d
> balance: 0.82516698
> gas used: 72217 (0x11a19)
> gas price: 20 gwei
> value sent: 0 ETH
> total cost: 0.00144434 ETH

Pausing for 10 confirmations...

---

> confirmation number: 1 (block: 20756554)
> confirmation number: 3 (block: 20756556)
> confirmation number: 4 (block: 20756557)
> confirmation number: 5 (block: 20756558)
> confirmation number: 7 (block: 20756560)
> confirmation number: 8 (block: 20756561)
> confirmation number: 9 (block: 20756562)
> confirmation number: 11 (block: 20756564)

Deploying 'Mint'

---

> transaction hash: 0x3bdfb539c0bba9c840307b09e4bae436e23a5c8367995a813e0b47a5435a441c
> Blocks: 3 Seconds: 9
> contract address: 0x35427508e46F27ae136fB96415BAA95155c9917b
> block number: 20756569
> block timestamp: 1656912909
> account: 0xeC473a6F28ba1EF107A74ce333E901980D18431d
> balance: 0.80037562
> gas used: 1239568 (0x12ea10)
> gas price: 20 gwei
> value sent: 0 ETH
> total cost: 0.02479136 ETH

Pausing for 10 confirmations...

---

> confirmation number: 1 (block: 20756572)
> confirmation number: 3 (block: 20756574)
> confirmation number: 4 (block: 20756575)
> confirmation number: 5 (block: 20756576)
> confirmation number: 6 (block: 20756577)
> confirmation number: 8 (block: 20756579)
> confirmation number: 9 (block: 20756580)
> confirmation number: 11 (block: 20756582)

Deploying 'ProxyAdmin'

---

> transaction hash: 0x3b8afd2c0dd9d0d1d9b0f7e57a9a95a02135fd99be8489f6d65c0e797b5a9e03
> Blocks: 3 Seconds: 9
> contract address: 0xD641F13A74D14065EC5CDff1FD0Cd7Dc3E922060
> block number: 20756587
> block timestamp: 1656912963
> account: 0xeC473a6F28ba1EF107A74ce333E901980D18431d
> balance: 0.79072122
> gas used: 482720 (0x75da0)
> gas price: 20 gwei
> value sent: 0 ETH
> total cost: 0.0096544 ETH

Pausing for 10 confirmations...

---

> confirmation number: 2 (block: 20756590)
> confirmation number: 3 (block: 20756591)
> confirmation number: 4 (block: 20756592)
> confirmation number: 6 (block: 20756594)
> confirmation number: 7 (block: 20756595)
> confirmation number: 9 (block: 20756597)
> confirmation number: 10 (block: 20756598)

Deploying 'TransparentUpgradeableProxy'

---

> transaction hash: 0xc4a9e26e9b77af9d550b434ddabf4824703bc48aee4bffafaa64b23fb7c5d662
> Blocks: 3 Seconds: 9
> contract address: 0x2b561A31d3748BC2e339e680f43100d29Ae7502E
> block number: 20756603
> block timestamp: 1656913011
> account: 0xeC473a6F28ba1EF107A74ce333E901980D18431d
> balance: 0.77736396
> gas used: 667863 (0xa30d7)
> gas price: 20 gwei
> value sent: 0 ETH
> total cost: 0.01335726 ETH

Pausing for 10 confirmations...

---

> confirmation number: 1 (block: 20756606)
> confirmation number: 2 (block: 20756607)
> confirmation number: 4 (block: 20756609)
> confirmation number: 5 (block: 20756610)
> confirmation number: 6 (block: 20756611)
> confirmation number: 8 (block: 20756613)
> confirmation number: 9 (block: 20756614)
> confirmation number: 10 (block: 20756615)

> Saving migration to chain.
> Saving artifacts

---

> Total cost: 0.04924736 ETH

# 5_deploy_treasury.js

Deploying 'Treasury'

---

> transaction hash: 0xac90b9210e2f724f6568288a13eb0a73efa15c419e2efd353d74c2ed9af1d77a
> Blocks: 3 Seconds: 9
> contract address: 0x7AD6b85E73A7B95eEf9fAd021Eb9a5CD9C2f35A4
> block number: 20756624
> block timestamp: 1656913074
> account: 0xeC473a6F28ba1EF107A74ce333E901980D18431d
> balance: 0.75713974
> gas used: 932715 (0xe3b6b)
> gas price: 20 gwei
> value sent: 0 ETH
> total cost: 0.0186543 ETH

Pausing for 10 confirmations...

---

> confirmation number: 1 (block: 20756627)
> confirmation number: 2 (block: 20756628)
> confirmation number: 4 (block: 20756630)
> confirmation number: 5 (block: 20756631)
> confirmation number: 6 (block: 20756632)
> confirmation number: 8 (block: 20756634)
> confirmation number: 9 (block: 20756635)
> confirmation number: 10 (block: 20756636)

Deploying 'TransparentUpgradeableProxy'

---

> transaction hash: 0x054d88f7d7d1a80a27989aef7d415ac74c6bc1fbb6ee8c90757706c100ffb99e
> Blocks: 2 Seconds: 5
> contract address: 0xF655DB00D1D7ccC972eFA80D86769458E15a6FB3
> block number: 20756642
> block timestamp: 1656913128
> account: 0xeC473a6F28ba1EF107A74ce333E901980D18431d
> balance: 0.74378204
> gas used: 667885 (0xa30ed)
> gas price: 20 gwei
> value sent: 0 ETH
> total cost: 0.0133577 ETH

Pausing for 10 confirmations...

---

> confirmation number: 1 (block: 20756645)
> confirmation number: 2 (block: 20756646)
> confirmation number: 4 (block: 20756648)
> confirmation number: 5 (block: 20756649)
> confirmation number: 6 (block: 20756650)
> confirmation number: 8 (block: 20756652)
> confirmation number: 9 (block: 20756653)
> confirmation number: 10 (block: 20756654)

> Saving migration to chain.
> Saving artifacts

---

> Total cost: 0.032012 ETH

# 6_deploy_launchpool.js

Deploying 'Launchpool'

---

> transaction hash: 0xd4e39c6786e6d2228c930a8b3b6d2bbe08794ca6afd5a0b6a72a359887085cfe
> Blocks: 3 Seconds: 9
> contract address: 0x4E0c5439FD375986C46FE82b54D854A5cd618ffF
> block number: 20756664
> block timestamp: 1656913194
> account: 0xeC473a6F28ba1EF107A74ce333E901980D18431d
> balance: 0.64043676
> gas used: 5139974 (0x4e6e06)
> gas price: 20 gwei
> value sent: 0 ETH
> total cost: 0.10279948 ETH

Pausing for 10 confirmations...

---

> confirmation number: 2 (block: 20756668)
> confirmation number: 3 (block: 20756669)
> confirmation number: 4 (block: 20756670)
> confirmation number: 6 (block: 20756672)
> confirmation number: 7 (block: 20756673)
> confirmation number: 8 (block: 20756674)
> confirmation number: 10 (block: 20756676)

Deploying 'TransparentUpgradeableProxy'

---

> transaction hash: 0x862e107751db6f4e8365262b9b20a2d96faea883caf5ad57e1ad2a041d74d3c8
> Blocks: 3 Seconds: 9
> contract address: 0x3Ab86854B828D4b2A54372a2b35c752d723A00d9
> block number: 20756682
> block timestamp: 1656913248
> account: 0xeC473a6F28ba1EF107A74ce333E901980D18431d
> balance: 0.62643474
> gas used: 700101 (0xaaec5)
> gas price: 20 gwei
> value sent: 0 ETH
> total cost: 0.01400202 ETH

Pausing for 10 confirmations...

---

> confirmation number: 1 (block: 20756685)
> confirmation number: 2 (block: 20756686)
> confirmation number: 4 (block: 20756688)
> confirmation number: 5 (block: 20756689)
> confirmation number: 6 (block: 20756690)
> confirmation number: 8 (block: 20756692)
> confirmation number: 9 (block: 20756693)
> confirmation number: 10 (block: 20756694)

> Saving migration to chain.
> Saving artifacts

---

> Total cost: 0.1168015 ETH

# 7_deploy_tvtv_token.js

Deploying 'TVTVToken'

---

> transaction hash: 0xfed81aef88ba47b6c5ad873d5b0153fb9f13be04d9e6251124dd897bb2c1942c
> Blocks: 3 Seconds: 9
> contract address: 0xFbE078e329B2Eaed57eb96F11011a5f43aA0d3eE
> block number: 20756703
> block timestamp: 1656913311
> account: 0xeC473a6F28ba1EF107A74ce333E901980D18431d
> balance: 0.55887582
> gas used: 2525477 (0x268925)
> gas price: 20 gwei
> value sent: 0 ETH
> total cost: 0.05050954 ETH

Pausing for 10 confirmations...

---

> confirmation number: 1 (block: 20756706)
> confirmation number: 3 (block: 20756708)
> confirmation number: 4 (block: 20756709)
> confirmation number: 5 (block: 20756710)
> confirmation number: 7 (block: 20756712)
> confirmation number: 8 (block: 20756713)
> confirmation number: 9 (block: 20756714)
> confirmation number: 11 (block: 20756716)

> Saving migration to chain.
> Saving artifacts

---

> Total cost: 0.05050954 ETH

# 8_deploy_tvtv_token_crowdsale.js

Deploying 'TVTVTokenCrowdsale'

---

> transaction hash: 0x9c9d44a24326f38f88a7b21a2e0a66e2d9de0800a6e74c19531c38a243f16ea0
> Blocks: 3 Seconds: 9
> contract address: 0xcb43aDBf64Ea1d0AE87EEBBf5F32adf14599ba6a
> block number: 20756725
> block timestamp: 1656913377
> account: 0xeC473a6F28ba1EF107A74ce333E901980D18431d
> balance: 0.54462818
> gas used: 685092 (0xa7424)
> gas price: 20 gwei
> value sent: 0 ETH
> total cost: 0.01370184 ETH

Pausing for 10 confirmations...

---

> confirmation number: 1 (block: 20756728)
> confirmation number: 3 (block: 20756730)
> confirmation number: 4 (block: 20756731)
> confirmation number: 5 (block: 20756732)
> confirmation number: 7 (block: 20756734)
> confirmation number: 8 (block: 20756735)
> confirmation number: 9 (block: 20756736)
> confirmation number: 11 (block: 20756738)

> Saving migration to chain.
> Saving artifacts

---

> Total cost: 0.01370184 ETH

# 9_deploy_voting_manager.js

Deploying 'VotingManager'

---

> transaction hash: 0x8253b316b0c3e20072072f293e0cc1307d336faccf19346654c2ac8f8ef18a85
> Blocks: 3 Seconds: 9
> contract address: 0x6aBa01C62748A62F9C78d51bFA7523e1AdE9A934
> block number: 20756750
> block timestamp: 1656913452
> account: 0xeC473a6F28ba1EF107A74ce333E901980D18431d
> balance: 0.51526176
> gas used: 1344813 (0x14852d)
> gas price: 20 gwei
> value sent: 0 ETH
> total cost: 0.02689626 ETH

Pausing for 10 confirmations...

---

> confirmation number: 1 (block: 20756753)
> confirmation number: 3 (block: 20756755)
> confirmation number: 4 (block: 20756756)
> confirmation number: 5 (block: 20756757)
> confirmation number: 7 (block: 20756759)
> confirmation number: 8 (block: 20756760)
> confirmation number: 9 (block: 20756761)
> confirmation number: 11 (block: 20756763)

Deploying 'TransparentUpgradeableProxy'

---

> transaction hash: 0x959f7ad9ba4d97cdfe4b4ebc360b9f89a8fe6ab1e07a96627c121435e558c79a
> Blocks: 3 Seconds: 9
> contract address: 0x642CCA9dBF153A856AF40fCC5692D0dFbd37CD7E
> block number: 20756769
> block timestamp: 1656913509
> account: 0xeC473a6F28ba1EF107A74ce333E901980D18431d
> balance: 0.5019397
> gas used: 666103 (0xa29f7)
> gas price: 20 gwei
> value sent: 0 ETH
> total cost: 0.01332206 ETH

Pausing for 10 confirmations...

---

> confirmation number: 1 (block: 20756772)
> confirmation number: 3 (block: 20756774)
> confirmation number: 4 (block: 20756775)
> confirmation number: 5 (block: 20756776)
> confirmation number: 7 (block: 20756778)
> confirmation number: 8 (block: 20756779)
> confirmation number: 9 (block: 20756780)
> confirmation number: 11 (block: 20756782)

> Saving migration to chain.
> Saving artifacts

---

> Total cost: 0.04021832 ETH

# Summary

> Total deployments: 15
> Final cost: 0.38373184 ETH

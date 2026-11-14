# Litedogecoin - LDOGE layer 1 Scrypt Algorithm Technology 
![8b55011e9d71b1e9da2ebfb528d43268](https://github.com/ldoge/LDOGE/blob/master/src/qt/res/icons/litedogecoin-128.png) 

# Punch List 

Enable Proof of work again, Make rewards up to 18 coins per P.O.W. Block, Electrum Wallet, make buildable on all systems

# Modern branch (3.6.1.1)

The `modern` branch builds on current Linux and Windows and fixes syncing and staking problems in 3.6.1.0.
GitHub Actions builds `litedoge-qt` for Linux (x86_64) and a single self-contained `litedoge-qt.exe` for Windows on every push; download them from the run's Artifacts.

What changed for users:

- **Staking**: the staking thread no longer quits for good if the wallet is unlocked (or not encrypted) while it is still syncing.
- **Syncing**: a stalled sync asks again after 60 seconds and moves to another peer if it stays stuck; the tallest peers are used first; 3.6.1.1 nodes send 500 blocks per request (3.6.1.0 sent 50); a repeated request is answered in full; much less work per block.
- **Block files** are kept in a `chain` folder in the data directory and roll over at 25 MiB. Block files from older versions are moved there automatically on the first start, no resync needed.
- **Database cache** defaults to 100 MB (`-dbcache`).
- The wallet learns its public IP address from its peers (no IP lookup website), so it can advertise itself.
- The status bar shows the current block height, and while syncing the speed (blocks/s) and the time left.
- The IRC page opens #litedoge on Libera Chat in your browser (build with `qmake USE_WEBKIT=1` for the old embedded browser).

Building on Ubuntu 22.04+ / Debian 12+:

```
sudo apt install build-essential libssl-dev libdb++-dev libboost-system-dev libboost-filesystem-dev \
  libboost-program-options-dev libboost-thread-dev libboost-chrono-dev libminiupnpc-dev zlib1g-dev \
  qtbase5-dev qttools5-dev-tools libqrencode-dev
qmake USE_UPNP=1 USE_QRCODE=1 litedoge-qt.pro
make -j$(nproc)
```

The wallet uses Berkeley DB 5.3. A wallet.dat opened with it can no longer be opened by builds that use Berkeley DB 4.8, so back it up first.

# LiteDoge dev Repository

LiteDoge-LDOGE is a scrypt algorithm, proof of stake 2.0 based cryptocurrency.

Official Website: https://litedogeofficial.org

Latest Wallets: https://github.com/ldoge/LDOGE/releases

Wiki and Installation guides: https://github.com/ldoge/LDOGE/wiki

Block Explorer: http://blocks.litedogeofficial.org/

Bitcointalk: https://bitcointalk.org/index.php?topic=1308769.0

Development Channel: https://discord.gg/dVWy7MqE2J

# Development process

Developers work in their own trees, then submit pull requests when they think their feature or bug fix is ready.

The patch will be accepted if there is broad consensus that it is a good thing. Developers should expect to rework and resubmit patches if they don't match the project's coding conventions (see coding.txt) or are controversial.

The master branch is regularly built and tested, but is not guaranteed to be completely stable. Tags are regularly created to indicate new stable release versions of LiteDoge.

Feature branches are created when there are major new features being worked on by several people.

From time to time a pull request will become outdated. If this occurs, and the pull is no longer automatically mergeable; a comment on the pull will be used to issue a warning of closure. The pull will be closed 15 days after the warning if action is not taken by the author. Pull requests closed in this manner will have their corresponding issue labeled 'stagnant'.

Issues with no commits will be given a similar warning, and closed after 15 days from their last activity. Issues closed in this manner will be labeled 'stale'.

When Building Litedoge use qmake

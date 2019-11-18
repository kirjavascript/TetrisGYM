# Linux

Dependencies:

	sudo apt-get install make gcc bison git python
	sudo easy_install pip

Set up the repository.

	git clone https://github.com/huderlem/TetrisNESDisasm
	cd TetrisNESDisasm

To build `tetris.nes`:

	make


# OS X

In the shell, run:

	xcode-select --install

Then follow the Linux instructions.


# Windows

To build on Windows, install [**Cygwin**](http://cygwin.com/install.html) with the default settings.

Dependencies are downloaded in the installer rather than the command line.
Select the following packages:
* make
* git
* gcc-core
* python

Then set up the repository. In the **Cygwin terminal**:

	git clone https://github.com/CelestialAmber/TetrisNESDisasm
	cd TetrisNESDisasm

To build `tetris.nes`:

	make

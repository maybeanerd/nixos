# XMage

Getting mage running on NixOS is sadly not trivial, as there are some pitfalls to avoid.

## Installation
 1. Download the assets from the [XMage website](https://xmage.today/)
 2. Extract the archive to a location of your choice
 3. Open a terminal in the extracted folder and run `nix-shell -p jre8`
 > We need do do this because even though the launcher will run on other versions, XMage will _always_ install a local version of java and try using that. This will _never_ work on NixOS due to how the filesystem is structured.
 Instead, we will run both the launcher and the game itself inside a nix-shell with jre8 available.
 4. Run the launcher with `java -Djava.net.preferIPv4Stack=true -jar XMageLauncher-0.3.8.jar`
 5. Check if you need any updates, and install them if needed.
 6. Close the launcher. Start the game client with `java -Xmx4000m -Dfile.encoding=UTF-8 -Dsun.jnu.encoding=UTF-8 -Djava.net.preferIPv4Stack=true -jar ./xmage/mage-client/lib/mage-client-1.4.58.jar &`
 7. Enjoy!

### Quick come-back
If you expect no updates, you can also attempt to quickly jump back in using the following command:

`nix-shell -p jre8 --run 'java -Xmx4000m -Dfile.encoding=UTF-8 -Dsun.jnu.encoding=UTF-8 -Djava.net.preferIPv4Stack=true -jar ./xmage/mage-client/lib/mage-client-1.4.58.jar &'
`
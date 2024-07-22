# AbysseaPopper
FFXI Windower v4 addon that helps with spawning force-spawned Notorious Monsters (NMs).

## How to Install

Download the addon and place the 'AbysseaPopper' folder into your windower `addons` folder (rename it to 'AbysseaPopper' if it has a different name).
In game, run this command: `lua load abysseapopper`

If you want it to load automatically when you log in, I highly recommend configuring it in the Plugin Manager addon, which you can get in the Windower launcher.
Plugin Manager details can be found at https://docs.windower.net/addons/pluginmanager/

## How It Works

Go to an Abyssea zone, target a ??? spawn point, and issue an addon command. Common commands are:
```
//ap pop
```
This command will trade the necessary items from your inventory to spawn the NM, even if it requires multiple items. It will bypass the need for going through the trade window and selecting items from your inventory, saving time and effort.

If you are missing needed items (or they're in a different bag) you will get a warning about which items are missing.

If you are interacting with a spawn point that uses key items to spawn instead of inventory items, you may get a similar warning about missing key items, or if you have all the key items then it will simply interact with the spawn point and you must manually navigate the menu options to spawn the NM from there.

The other common command is:
```
//ap info
```
If you target a spawn point and issue this command, it will tell you what NM spawns there.

Other commands may be found by using the help command:
```
//ap help
```

## TODO / Known Issues
* None

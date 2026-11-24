# Rogue Toolkit for WoW Forever

Rogue Toolkit provides a shared minimap launcher and settings cards for Poison Satchel, Lockpick Atlas, and Combo Point Ledger on Forever 1.60.1, interface 16001. Each companion can also run independently.

## Install

Download `RogueToolkit-v<version>.zip` from [GitHub Releases](https://github.com/cfau214037/rogue-toolkit/releases) and extract it into `World of Warcraft\_forever_\Interface\AddOns`. Install the companion addons you want to use in the same directory, then restart the client.

**Upgrading from 0.2:** Replace the old VenomSatchel install with PoisonSatchel and update the Toolkit hub. Move the old addon folder outside Interface/AddOns while the game is closed. To carry over character preferences, copy the character's WTF SavedVariables/VenomSatchel.lua to PoisonSatchel.lua before first launch. The addon imports the old table. Without a copy, use Load recipes once. Both `/poisonsatchel` and `/venom` open the panel.

Left-click the crossed daggers or type `/rtk` to open Toolkit settings. Each installed tool has an **Enabled** checkbox for this character. Click **Reload UI** to apply changes. Right-click the daggers and hover over a loaded tool to open its submenu for actions, display toggles, and settings. Disabling the hub and reloading restores each standalone launcher according to its own settings.

## Combo Point Ledger

Install Combo Point Ledger separately in the same `Interface/AddOns` directory. In Toolkit settings (`/rtk`), use **Show HUD** for immediate visibility changes and **HUD settings** to choose Dots, Ticks, or Number and edit the position and size. The toolkit minimap menu also offers **Show HUD**, **Edit HUD** or **Lock HUD**, and **Settings** under **Combo Point Ledger**.

## Adding tools and distributing updates

Each tool owns its events, settings, icon and standalone TOC. To integrate another tool, add its adapter to the modules list in `Toolkit.lua` and include its folder ID in the Toolkit TOC's optional dependencies. The list drives the scrollable cards, minimap menu, and launcher handoff.

Update the Toolkit version in `RogueToolkit/RogueToolkit_Forever.toc` and push the matching `v<version>` tag. GitHub Actions publishes a ZIP containing the `RogueToolkit` folder. Each companion is released separately.

## Buy and craft

1. Open the rogue's **Poisons** profession once. Poison Satchel saves learned recipes per character and refreshes them when you reopen the book.
2. Visit a poison supplier. Choose a poison (Show All Ranks includes lower learned ranks) and enter the number of **crafts**. The list shows the count in your bags, the required count, and the quantity to buy. Vendor packs are rounded up and included in the price.
3. Click **Buy ingredients**. Each request waits for the previous stack to reach your bags. If a purchase stops, the panel recalculates the missing quantities.
4. Click **Prepare craft** in the satchel. It opens the selected recipe and fills in the batch quantity. Check the quantity and click **Create** in the Poisons window.

**Example.** Five crafts of Instant Poison IV require ten Dust of Deterioration and five Crystal Vials. If you carry four dust and two vials, the shopping list shows six dust and three vials before vendor-pack rounding. [Forever recipe record](https://forevertome.com/professions/recipes/11341)

## Feasibility and limits

| Feature | Implementation and restriction |
| --- | --- |
| Poison icons at the vendor | The merchant sells server-defined item slots. A companion panel presents each learned recipe and sends ordinary purchases for actual reagent slots. It recognizes poison suppliers by their inventory, including outside major cities. [Merchant slot API](https://warcraft.wiki.gg/wiki/API_GetMerchantNumItems) · [Offer fields](https://warcraft.wiki.gg/wiki/API_C_MerchantFrame.GetItemInfo) |
| Recipe availability | Forever has its own poison data. The addon reads the character's personal Poisons book (skill line 40), learned flags and required single-item reagent slots. An ambiguous mandatory reagent choice excludes that recipe. Newly learned ranks appear after the book refreshes. [Forever profession data](https://forevertome.com/professions/poisons) · [Recipe API](https://warcraft.wiki.gg/wiki/API_C_TradeSkillUI.GetRecipeInfo) |
| Spending | Shopping uses carried inventory, the current vendor's money-only offers, available stock, pack prices, and the per-request stack limit. A closed merchant, insufficient funds, price increase beyond the accepted budget, or missing bag acknowledgment stops the order. Completed purchases stay in your bags. [Purchase API](https://warcraft.wiki.gg/wiki/API_BuyMerchantItem) |
| Crafting | The player prepares the batch out of combat and clicks Create in the Poisons window. The game may interrupt or reject a cast. [OpenTradeSkill](https://warcraft.wiki.gg/wiki/API_C_TradeSkillUI.OpenTradeSkill) · [CraftRecipe](https://warcraft.wiki.gg/wiki/API_C_TradeSkillUI.CraftRecipe) |
| Combining addons | Optional dependencies let each installed module load independently. Toolkit calls the Atlas 0.2.8 menu and registered settings directly. It hides the two module launchers for the session, preserving the saved Atlas launcher preference. Pin management and Where Next remain in the native Atlas menu/settings. |
| Overhead | No bundled UI framework or background polling in either new addon. The launchers update their positions while being dragged. Purchasing advances on bag events, with a short timeout for an unanswered request. |

## Verification

The installed Forever executable used as the version reference reported **1.60.1.71037**. Development checks covered Lua compilation, simulated shopping and crafting, card creation, launcher takeover, archive contents, and icon dimensions. Live merchant transactions, cast completion and visual placement still need an in-game check.

For a live smoke test, open Poisons on a rogue who knows Instant Poison IV, visit a supplier, and buy the difference for one craft with one reagent already in your bags. Compare the displayed total with the money spent, then craft it. Open **Lockpick Atlas → Where Next?** from the daggers and toggle a marker in the Atlas settings card. Disable Toolkit and reload to check the standalone launchers.


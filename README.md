# AMX Mod X Skins API

## Overview

This AMX Mod X plugin provides an API for other plugins to programmatically set and toggle skins for players' weapons and models. The plugin utilizes the NVault library to store and retrieve skin preferences, allowing multiple plugins to work seamlessly without interference.

## Natives

### `set_user_knife(id, skin[])`

Set the skin for the specified player's knife.

### `set_user_butcher(id, skin[])`

Set the skin for the specified player's butcher knife.

### `set_user_usp(id, skin[])`

Set the skin for the specified player's USP pistol.

### `set_user_skin(id, skin[])`

Set the overall skin/model for the specified player.

### `toggle_user_knife(id)`

Toggle the visibility of the specified player's knife.

### `toggle_user_usp(id)`

Toggle the visibility of the specified player's USP pistol.

Now, other plugins can call these functions to manage player skins without conflicting with each other.

## Persistence

Player skin preferences are stored using the NVault library, ensuring that customizations persist even after disconnecting from the server.

# BCC Vehicle Fixes

> A comprehensive RedM script with advanced vehicle fixes and cleanup systems.

## Features

### 🚂 **Enhanced Wagon Removal System**

- **Complete Component Removal**: Removes stuck wagons along with ALL associated components
- **Padlock Detection**: Specifically targets and removes padlocks, chains, and locks
- **Multi-Horse Support**: Handles wagons with teams of up to 6 horses
- **Passenger Removal**: Cleans up drivers, passengers, and guards
- **Attachment Detection**: Finds and removes any objects attached to wagons
- **Proximity-Based Cleanup**: Removes nearby objects that might be wagon components

### 🚤 **Boat Management**

- **NPC Boat Prevention**: Prevents spawning of unwanted NPC boats

### ⚙️ **Advanced Configuration**

- **Fully Configurable**: All distances, detection ranges, and component lists in config
- **Extensible Component List**: Easy to add new wagon component models
- **Performance Tuning**: Adjustable network control and detection settings
- **Debug System**: Built-in logging system for troubleshooting

## Dependencies

- [bcc-utils](https://github.com/BryceCanyonCounty/bcc-utils)

## Installation

1. Download this repository
2. Make sure dependencies are installed/updated and ensured before this script
3. Copy and paste `bcc-vehiclefixes` folder to `resources/bcc-vehiclefixes`
4. Add `ensure bcc-vehiclefixes` to your `server.cfg` file
5. Configure the script (see Configuration section below)
6. Restart server

## Credits and Disclaimers

**Original Implementations:**

- Wagon fix concept from [kaddarem-tebex/RedM-FixWagon](https://github.com/kaddarem-tebex/RedM-FixWagon)
- Boat fix implementation by Apollyon and KTOS on the Cfx Discord

## Need More Support?

- [bcc-vehiclefixes](https://github.com/BryceCanyonCounty/bcc-vehiclefixes)

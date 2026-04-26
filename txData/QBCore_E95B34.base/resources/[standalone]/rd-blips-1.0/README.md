# rd-blips

A comprehensive blip and marker management system for FiveM servers using the QBCore framework. This resource allows server administrators to dynamically create, manage, and organize map blips and markers with job-based permissions and categories.

## Features

- 🎯 Dynamic blip and marker creation/management
- 👥 Job-based access control
- 🏷️ Category-based organization
- 📱 Integration with gs_blips for enhanced display
- 💼 Support for job types and categories
- 🔄 Multi-job compatibility with IF-multijob
- 🎨 Customizable colors and styles
- 📊 Distance-based marker rendering optimization
- 🔐 Admin-only management commands

## Dependencies

### Required
- [qb-core](https://github.com/qbcore-framework/qb-core)
- [oxmysql](https://github.com/overextended/oxmysql)
- [qb-input](https://github.com/qbcore-framework/qb-input)

### Optional
- [gs_blips](https://github.com/GamzkyScripts/gs_blips) - For enhanced blip display
- [IF-multijob] - For multi-job support

## Installation

1. Download the resource
2. Place it in your server's resources folder
3. Import the SQL file:
   ```sql
   mysql -u your_username -p your_database < rd-blips.sql
   ```
4. Add to your server.cfg:
   ```cfg
   ensure rd-blips
   ```

## Configuration

### Basic Configuration
The `config.lua` file contains all configurable options:

```lua
Config.UseGsBlips = true         -- Enable gs_blips integration
Config.UseIFMultijob = true      -- Enable IF-multijob integration
Config.UseJobTypes = true        -- Enable jobtype-based filtering
Config.DefaultMarkerDistance = 50.0    -- Marker render distance
```

### Job Types
Configure job categories in `config.lua`:

```lua
Config.JobTypeCategories = {
    ['leo'] = {'police', 'sheriff', 'statepolice'},
    ['medical'] = {'ambulance', 'doctor'},
    ['mechanic'] = {'mechanic', 'tuner'},
    ['business'] = {'taxi', 'realtor', 'restaurant'},
    ['all'] = {'all'}
}
```

## Usage Guide

### Admin Commands

1. Create a Blip:
```
/createblip
```
- Opens a dialog to create a new blip
- Set sprite, scale, color, description
- Optionally assign to specific jobs

2. Remove a Blip:
```
/removeblip [description]
```

3. Create a Marker:
```
/createmarker
```
- Creates a marker at your current location
- Customize type, scale, color, transparency

4. Remove a Marker:
```
/removemarker [description]
```

### Blip Creation Example

1. Use `/createblip` command
2. Fill in the dialog:
   - Sprite: 60 (Police Station)
   - Scale: 0.8
   - Color: 3 (Blue)
   - Description: "Mission Row PD"
   - Job: "police" (or leave empty for all)

### Marker Creation Example

1. Use `/createmarker` command
2. Fill in the dialog:
   - Type: 1 (Cylinder)
   - Scale: 1.0
   - Color: Red (255), Green (0), Blue (0), Alpha (200)
   - Description: "Evidence Room"

## Blip Types Reference

Common blip sprites are predefined in the config:

```lua
Config.CommonBlipSprites = {
    ['STORE'] = 52,
    ['CLOTHING'] = 73,
    ['GARAGE'] = 357,
    ['GAS_STATION'] = 361,
    ['HOSPITAL'] = 61,
    ['POLICE'] = 60,
    -- See config.lua for full list
}
```

## Marker Types Reference

Available marker types:

```lua
Config.MarkerTypes = {
    ['CYLINDER'] = 1,
    ['ARROW'] = 2,
    ['RING'] = 25,
    ['CHEVRON'] = 27,
    -- See config.lua for full list
}
```

## Integration with gs_blips

When gs_blips is enabled:
- Enhanced blip display with categories
- Dynamic distance updates
- Detailed information boxes
- Job-based filtering

Configure gs_blips settings in `config.lua`:

```lua
Config.GsBlips = {
    DefaultCategory = 'General',
    EnableDynamicDisplay = true,
    DisplayRefreshRate = 1000,
    UseJobCategories = true
}
```

## Troubleshooting

### Common Issues

1. Blips not appearing:
   - Check job permissions
   - Verify blip coordinates
   - Ensure correct job name in config

2. Markers not rendering:
   - Check marker distance setting
   - Verify marker coordinates
   - Check for script errors

3. Permission errors:
   - Verify admin status in QBCore
   - Check command permissions in config

### Support

For support:
1. Check the [Issues](https://github.com/Ronin-Development-Official/rd-blips/issues) page
2. Create a new issue with detailed information
3. Include any relevant error messages

## Contributing

Contributions are welcome! Please:
1. Fork the repository
2. Create a feature branch
3. Submit a pull request

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Credits

- Created by Ronin Development
- Thanks to the QBCore community
- Special thanks to contributors

# Character Style Guide
- 3 colors per sprite only (dark/mid/highlight)
  - the highlight should be used sparingly,

- pokemon sprite sizing
  - weak monsters (first evolution) 32x32
  - medium monsters (second evolution) 48x48
  - strong monsters (third evolution) 64x64

- use tilemap layers instead of drawing freely
  - this is the easiest way for us to make something that looks good and has a consistent style
  - the character template (`/assets/sprites/characters/character_template.aseprite`) is preconfigured with the tileset we should use

## Template
  - the template is stored at `/assets/sprites/characters/character_template.aseprite`
  - the template contains placeholders for weak/medium/strong monsters
  - each placeholder contains three tilemap layers (dark/mid/highlight)
    - each tilemap layer contains only tiles of its particular color
  - the tileset for each layer is as shown below:
![link text](<../../../../../../Desktop/screenshots/Screenshot 2025-05-30 at 9.08.56 PM.png>)

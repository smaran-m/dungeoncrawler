# Dungeoncrawler Prototype
<p align="center">
  <img src="https://i.imgur.com/E3Wtcq8.png" />
  <img src="https://i.imgur.com/5jpZQ5j.gif" />
</p>
<br>Dunjin (working title) is a WIP multiplayer platform fighter using Godot ver 3.5.3. The game is currently in a prototype state.

## Motivation
I wanted to make the TTRPG combat experience more enjoyable, using medieval themes but a real time battle system that allows for a high skill ceiling. I'm using a smash archetype for the character controller, but plan to have this as both a single-player and multiplayer game. This is currently a solo project: I did all the art and code, but the parallax background behind the windows was sourced from [here](https://brullov.itch.io/oak-woods).

## Notes
- You can view the design document [here](https://drive.google.com/file/d/1NdBgawc8S8PDr08acMxUb1v7S21OZg6O/view?usp=drive_link). There is a more extensive working document which I can provide on request.
- The current state of the project was intended for demo/testing at the November ATL Gamedevs meetup. It is still in a primitive, but playable state, with some of the more complex systems not implemented yet.
- Preliminary playtests brought a lot of feedback:
    - Hitboxes are somewhat disjointed
    - Ledge mechanics are in an early state and will be revamped soon.
    - L-cancelling will be added or landing lag will be eliminated entirely

## Features
- All attacks and character interactions occur on a 60fps timescale as is genre standard
- Up to 4 player local multiplayer (engine limitation)
- Character controls inspired by Super Smash Brothers Melee
    - In-depth movement system with wavedashing, moonwalking etc
    - Unique directional attack inputs which change depending on player state (tilts, aerials, etc.)
- Instantly configurable character skins using Aseprite + Aseprite Wizard addon (not configured in-game yet)
- Multiplatform: works on Windows, Linux, MacOS

## Planned additions
Vaguely ordered by priority
- Features
    - Sound
    - Level and character selection
    - More characters
    - Roguelike segment
    - Dynamic sprite additions
- Systems
    - Stitched Wave Function Collapse based procedural level generation
    - Online multiplayer with rollback netcode using Godot Rollback Netcode plugin
    - Multithreaded matchmaking system
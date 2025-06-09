# Jim-BlipController

## What is it?

This script is a blip control script, with the ability to create different "types" of blips

This was born from me playing too much oblivion and wondering how hard it would be to create a popup message saying "You discovered a location" then marking it on a map.

- Saved though Client KVP
- Fully synced through statebags

## Discoverable Blips

These are blips based on poly zones, you enter the zone for the first time, you get a message "Discovered" and the location name, with an optional "description" to go with it

When the player enters it for the first time, it will also mark the blip on the players map too

There are several config options to adjust the display of these popups too

## onDuty Blips

These blips change status based on wether players with a certain job role are on Duty or not, marking the location as "open"

This comes with options to always show the blip or only when they are onDuty, if they are off duty it will show a blip but marked it as "Closed"

## Player Blips

This is currently experimental and needs to be fleshed out more but appears to work on my end

This allows players with set job roles, to see other players with set job roles on their map

It attempts to swap between entity blips and coord blips to keep their locations fully synced

And only shows them when they are on duty

# Installation

- Place the script in your resources folder, eg `resources/[jimextras]`
 - Recommended order: https://jixelpatterns.gitbook.io/docs/troubleshooting/common-issues#load-order
- Add `ensure [jimextras]` to your server.cfg
- Done

# Dependencies

- jim_bridge - https://github.com/jimathy/jim-bridge
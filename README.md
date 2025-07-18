## Overview
This repo holds the Dockerfile and resources Home Assistant needs to install / run a Twingate Connector.

It is based on this [guide]("https://developers.home-assistant.io/docs/add-ons/tutorial/")

## Local Dev
1. Copy the root of this repo to `/addons` on the host of your Home Assistant instance
2. Navigate to the `Settings` tab within your Home Assistant instance. Usually `http://homeassistant.local:8123/config/dashboard`
3. Click the `Add-ons` tab
4. Click the `Add-on Store` button in the bottom right hand corner of the screen
5. Click the ellipses in the top right and click `Check for updates`
6. Search for `Twingate Connector` under `Local add-ons`
7. Click `Install` and wait for the add on to install
8. Navigate to the `Configuration` tab
9. Add an access token to the `access_token` field
10. Add a refresh token to the `refresh_token` field
11. Add your remote network name to the `network` field
12. Navigate back to the `Info` tab
13. Click `Start`
14. To monitor the installation of the connector, look at the `Logs` tab.

## Supported Architectures
- aarch64
- amd64
- armv7

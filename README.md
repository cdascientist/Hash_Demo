# Client side Machine Learning, Clustering, and Data Fragmentation and 3d rendering using Brighterscript Game Engine

An object oriented  machine learning implementation using BrighterScript game engine for the Roku, written in [Brighterscript](https://github.com/rokucommunity/brighterscript)

This project is designed to be used with VScode.

This was originally forked from [Roku-gameEngine](https://github.com/Romans-I-XVI/Roku-gameEngine) by Austin Sojka, and converted into Brighterscript. This work owes a lot to this original project!

## Introduction

The purpose of this project is to make it easy establish a client side framework for Roku device machine learning compute on client devices

By implementing these methodologies:

1- Integration of the Brighter Script Game Engine

2- Illustrating the retrieval of data on I/O side of client device

3- Clustering data on client side

4- Using Kmeans Clustering Machine Learning Algorithm 

5- Placing the Centroid Results into a fragmentation pattern 

6- Implementing the fragmentation according to a Fractal diffusion 

## Cloning and Running Examples

The Client side Machine Learning, Clustering, and Data Fragmentation and 3d rendering repository is on [Github](https://github.com/cdascientist/Hash_Demo.git)

Clone the project:

```
git clone https://github.com/cdascientist/Hash_Demo.git
```

This project an example Roku apps in the `examples` directory. To run them, you will need a Roku and have it set up properly for doing development. See: https://developer.roku.com/en-ca/docs/developer-program/getting-started/developer-setup.md.

To run the examples:

Install dependencies:

```
cd Hash_Demo
npm install
```

```
code Hash_Demo_Application.code-workspace
```

We recommend you install the great [Brightscript Language vscode extension](https://marketplace.visualstudio.com/items?itemName=RokuCommunity.brightscript).

Create/edit a `.env` file to specify the details for you target Roku device:

```env
ROKU_USERNAME=<roku development username - default is rokudev>
ROKU_PASSWORD=<roku development password>
ROKU_HOST=<local IP address of the target roku>
```

Then simply run one of the Debug configurations from the Debug tab.

## Installation


## Documentation

Documentation can be found [here](https://markwpearce.github.io/brighterscript-game-engine)

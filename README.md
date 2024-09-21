# README.md

## Overview

Welcome to the `universal_video_controls` package! This project is designed to provide a comprehensive solution for video controls that can be universally applied to various video players. Below is an overview of the project's structure and its main components.

### Structure

- **universal_video_controls**
  - This directory contains the main package code for the universal video controls.
- **universal_video_controls/example/**
  - This directory contains examples demonstrating how to use the `universal_video_controls` package.
- **universal_video_controls_video_player**
  - This directory contains the interface and implementation for the video player that integrates with the universal video controls.

## Components

### universal_video_controls

This is the core package that provides universal video controls which can be used across different video players. It includes functionalities like play, pause, stop, seek, volume control, and more. The package is based on the `media_kit` controls and serves as a port and generalization of these controls. The goal is to create an abstraction that allows these controls to work with any video player backend, provided that the backend's interface is compatible with the `AbstractPlayer` class.


### universal_video_controls_video_player

This directory includes the interface for the video player, which is designed to work seamlessly with the `universal_video_controls` package. It provides the necessary hooks and methods to control video playback using the universal controls. For reference, you can explore the `VideoPlayerControlsWrapper` class, which is an implementation of the `AbstractPlayer` interface using the `video_player` package.

## AbstractPlayer Class

To ensure compatibility with the `universal_video_controls` package, your video player backend must implement the `AbstractPlayer` class. This abstract class defines the essential methods and properties that any video player must have to be controlled by the universal video controls.


By adhering to this interface, you can integrate any video player backend with the `universal_video_controls` package, making the controls truly universal and adaptable to various environments.



## Getting Started

To get started with the `universal_video_controls` package, you can explore the examples provided in the `universal_video_controls/example/` directory. These examples will guide you through the setup and integration process.

## Installation

Instructions for installing the package can be found in the `universal_video_controls` directory. Make sure to follow the steps provided in the respective README files to ensure a smooth setup.

## Usage

1. **Install the Package**: Follow the installation instructions in the `universal_video_controls` directory.
2. **Explore Examples**: Check out the `universal_video_controls/example/` directory to see how the package can be used in different scenarios.
3. **Integrate Video Player**: Use the interface provided in the `universal_video_controls_video_player` directory to integrate your video player with the universal controls.

## Contributing

We welcome contributions to the `universal_video_controls` project! If you have ideas, suggestions, or improvements, please feel free to submit a pull request or open an issue.

## License

This project is licensed under the MIT License. See the LICENSE file for more details.


Thank you for using `universal_video_controls`!
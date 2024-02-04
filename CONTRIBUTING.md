# Contributing

Thank you for your interest in contributing to Accelerate! We're excited to have you join our community and help improve the project. This document provides guidelines for building and contributing changes.

## Scope

Accelerate aims to support its features universally across a wide range of websites. To maintain long-lasting support and ensure broad compatibility, there are specific guidelines on the types of contributions we accept:

- **Feature Requests**: We encourage any ideas that enhance general usability and functionality. However, we will not accept feature requests that are limited to specific websites (e.g., adding a shortcut for an option in Netflix's video player). This policy helps us focus on features that benefit a wide audience and maintain the extension's long-term viability.
- **Bug Fixes**: We greatly appreciate fixes that improve the user experience in any way. Website-specific bug fixes will be reviewed case-by-case, depending on the impact of the issue and popularity of the website. Since websites frequently change over time, fixes should ideally offer generalized solutions over quick hacks.
- **Documentation**: We also welcome feedback for improving the clarity and quality of our documentation, e.g., [FAQ](https://ritam.me/projects/accelerate/faq/).

## Getting Started

Before you begin, please ensure you have Xcode installed. Familiarity with Swift Package Manager (SPM) for dependency management and code formatting tools like [`swift-format`](https://github.com/apple/swift-format) and [`prettier`](https://prettier.io) is also beneficial. Accelerate is written using Swift and JavaScript.

1. Clone the repository:

```
$ git clone https://github.com/ritamsarmah/accelerate.git
```

2. Navigate to the project directory and open `Accelerate.xcworkspace` in Xcode. This workspace is used for both macOS and iOS projects. Here are descriptions for the key directories:
- `macOS` - Project files for the macOS app and extension.
- `iOS/` - Project files for the iOS app and extension.
- `Common` and `Extensions/` - Swift files used by both macOS/iOS native apps.
- `Web` - JavaScript files and resources used by both macOS/iOS web extensions.

> We recommend removing any previously installed version of Accelerate from the App Store before running the project.

3. Build or run the scheme for the operating system you are targeting. Each scheme builds both the native app and web extension. Running the project will both open the app and install the extension for Safari. You will need to enable the extension from Safari's preferences on the first run.

4. For developing the web extension, we recommend enabling Safari's developer tools from the preferences ( Advanced > Show features for web developers). This will add a **Develop** item to your menu bar that will give you options to debug, breakpoint, and view logs from the web extension on macOS or a connected iOS device.

## Style Guide

Please match the existing coding style as closely as possible. We encourage using formatting tools like `swift-format` and `prettier`, and include respective configuration files in the repository.

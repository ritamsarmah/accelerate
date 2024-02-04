//
//  inject.js
//  Accelerate - Mac
//
//  Created by Ritam Sarmah on 6/12/21.
//  Copyright © 2021 Ritam Sarmah. All rights reserved.
//

/* Global Variables */

var snackbarIcons = {}; // Cached SVGs for icons retrieved from extension

/* Event Listeners */

document.addEventListener("DOMContentLoaded", () => {
    if (!initialized) {
        safari.extension.dispatchMessage("shouldInitialize");
    }
});

window.addEventListener("focus", () => {
    if (initialized) {
        safari.extension.dispatchMessage("didFocus");
    }
});

/** Listens for messages from Safari for various events. */
safari.self.addEventListener("message", event => {
    if (event.name === "initialize") {
        initialize(event.message);
    } else if (event.name === "blocked") {
        logger.i(
            `Disabled on current page: ${location.href}`,
            event.message.rule
        );
    } else if (event.name === "upgrade") {
        logger.i(
            `Accelerate has been upgraded to a new major version. Opening main application...`
        );
    } else if (event.name === "triggerAction" && initialized) {
        // Actions could be externally triggered by global shortcut, toolbar button, or context menu. Check initialization to avoid triggering actions before extension is ready.
        triggerAction(event.message.shortcut);
    }
});

/* Initialization */

function initialize(settings) {
    _initialize(settings);
    snackbarIcons = settings.snackbarIcons;

    // Add contextmenu listener
    document.addEventListener(
        "contextmenu",
        event => {
            safari.extension.setContextMenuEventUserInfo(event, {
                isInitialized: initialized,
                hasVideos: hasVideos,
                currentRate: currentRate
            });
        },
        false
    );
}

/* Overrides */

function shortcutEventListener(event, shortcuts) {
    if (activeElementHasEditableText()) return;

    let keyCombo = event.code;
    keyCombo += event.ctrlKey ? "⌃" : "";
    keyCombo += event.altKey ? "⌥" : "";
    keyCombo += event.shiftKey ? "⇧" : "";
    keyCombo += event.metaKey ? "⌘" : "";

    if (keyCombo in shortcuts) {
        logger.d(`Shortcut recognized for key combination: ${keyCombo}`);
        for (let shortcut of shortcuts[keyCombo]) {
            // Ignore global shortcuts since they will be triggered from Swift
            if (!shortcut.isGlobal) {
                triggerAction(shortcut, event);
            }
        }
    }
}

function getSnackbarIcon(icon) {
    return snackbarIcons[icon];
}

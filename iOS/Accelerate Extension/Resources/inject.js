//
//  inject.js
//  Accelerate - iOS
//
//  Created by Ritam Sarmah on 11/12/21.
//  Copyright © 2021 Ritam Sarmah. All rights reserved.
//

/* Event Listeners */

if (document.readyState !== "loading") {
    initialize();
} else {
    document.addEventListener("DOMContentLoaded", initialize);
}

browser.runtime.onMessage.addListener((request) => {
    switch (request.name) {
        case "ready":
            initialize();
            break;
        case "triggerAction":
            triggerAction(request.shortcut);
            break;
        case "syncRate":
            syncRate();
            break;
        default:
            break;
    }
});

/* Initialization */

function initialize() {
    browser.runtime.sendMessage({ name: "initialize" }).then((response) => {
        // Cancel initialization if settings not ready or Accelerate is blocked on page
        if (!response.ready || !response.allowed) return;

        _initialize(response.settings);
    });
}

/* Overrides */

function shortcutEventListener(event, shortcuts) {
    if (activeElementHasEditableText()) return;

    // NOTE: Accelerate for iOS only supports single letter keys since native app cannot record modifier keys yet
    let keyCombo = event.key.toUpperCase();

    if (keyCombo in shortcuts) {
        logger.d(`Shortcut recognized for key combination: ${keyCombo}`);
        for (let shortcut of shortcuts[keyCombo]) {
            triggerAction(shortcut, event);
        }
    }
}

function setRate(newRate, videos) {
    _setRate(newRate, videos);
    syncRate();
}

function syncRate() {
    browser.runtime.sendMessage({ name: "sync", currentRate: currentRate });
}

function getSnackbarIcon(icon) {
    let iconURL = browser.runtime.getURL(`images/snackbar/${icon}.svg`);
    return `<img src="${iconURL}">`;
}

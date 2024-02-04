//
//  popup.js
//  Accelerate iOS
//
//  Created by Ritam Sarmah on 11/12/21.
//  Copyright © 2021 Ritam Sarmah. All rights reserved.
//

document.addEventListener("alpine:init", () => {
    Alpine.store("initialized", false);
    Alpine.store("isTablet", /MacIntel/.test(navigator.platform));

    initialize();
});

browser.runtime.onMessage.addListener((request) => {
    switch (request.name) {
        case "ready":
            initialize();
            break;
        case "sync":
            Alpine.store("rate", request.currentRate);
            break;
        default:
            break;
    }
});

function initialize() {
    if (Alpine.store("initialized")) return;

    // Request settings from background script
    browser.tabs.query({ currentWindow: true, active: true }).then((tabs) => {
        browser.runtime.sendMessage({ name: "initialize", url: tabs[0].url }).then((response) => {
            // Cancel initialization if settings are not ready
            if (!response.ready) return;

            Alpine.store("allowed", response.allowed);

            if (response.allowed) {
                Alpine.store("rate", response.settings.defaultRate);
                syncRate();

                let shortcuts = response.settings.shortcuts.filter((shortcut) => shortcut.showInPopup);
                Alpine.store("shortcuts", shortcuts);
            }

            Alpine.store("initialized", true);
        });
    });
}

function getIcon(shortcut) {
    return browser.runtime.getURL(`images/actions/${shortcut.action}.svg`);
}

/** Sync rate with current page */
function syncRate() {
    sendMessageToActiveTab({ name: "syncRate" });
}

/** Trigger action on page **/
function triggerAction(shortcut) {
    sendMessageToActiveTab({ name: "triggerAction", shortcut: shortcut });
}

function sendMessageToActiveTab(message) {
    browser.tabs.query({ currentWindow: true, active: true }, (tabs) => {
        browser.tabs.sendMessage(tabs[0].id, message);
    });
}

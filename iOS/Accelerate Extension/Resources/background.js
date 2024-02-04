//
//  background.js
//  Accelerate iOS
//
//  Created by Ritam Sarmah on 11/12/21.
//  Copyright © 2021 Ritam Sarmah. All rights reserved.
//

/* Initialization */
var settings = null;

/** Loads settings from native extension handler */
function initialize() {
    browser.runtime.sendNativeMessage("application.id", { name: "initialize" }, (response) => {
        // Save settings for other scripts to use for initialization
        settings = response.settings;
        logger.isVerbose = settings.isVerboseLogging;
        logger.d("Loading settings...", settings);

        // Notify other scripts that settings are ready
        browser.runtime.sendMessage({ name: "ready" });
    });
}

// Request initialization immediately
initialize();

// Re-initialize after navigation to new page
browser.webNavigation.onCommitted.addListener(() => {
    initialize();
});

// Listen for initialization requests from other scripts
browser.runtime.onMessage.addListener((request, sender, sendResponse) => {
    if (request.name === "initialize") {
        if (settings == null) {
            logger.d(`Deferring initialization of Accelerate on page: ${url}`);
            sendResponse({ ready: false });
            return;
        }

        // Only webpage scripts have valid sender urls
        // Otherwise, the popup includes the url in its request
        let url = sender.url == null ? request.url : sender.url;

        if (isAllowed(url)) {
            logger.d(`Initializing Accelerate on page: ${url}`);
            sendResponse({ ready: true, allowed: true, settings: settings });
        } else {
            logger.d(`Disabled Accelerate on page: ${url}`);
            sendResponse({ ready: true, allowed: false });
        }
    }
});

/* Blocklist */

function isAllowed(url) {
    let prefix = /^(https?:\/\/)?(www\.)?/;

    for (let rule of settings.blocklist) {
        if (rule !== "") {
            rule = rule
                .replace(prefix, "") // Ignore scheme prefix in rule
                .replace(/[.+?^${}()|[\]\\]/g, "\\$&") // Escape regex symbols except for *
                .replace(/\*/g, "(.*)"); // Convert wildcards to regex string

            let regex = new RegExp(`^${rule}.*$`);

            if (regex.test(url.replace(prefix, ""))) {
                return settings.isBlocklistInverted;
            }
        }
    }

    return !settings.isBlocklistInverted;
}

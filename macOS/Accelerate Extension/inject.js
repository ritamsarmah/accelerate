//
//  inject.js
//  Accelerate - Mac
//
//  Created by Ritam Sarmah on 6/12/21.
//  Copyright © 2021 Ritam Sarmah. All rights reserved.
//

/* Global Variables */

var snackbarIcons = {}; // Cached SVGs for icons retrieved from extension
var contextMenuShortcuts = []; // Cached context menu shortcuts
var contextMenuUserInfo = {}; // Cached context menu event user info

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
safari.self.addEventListener("message", (event) => {
  if (event.name === "initialize") {
    initialize(event.message);
  } else if (event.name === "blocked") {
    logger.i(
      `Disabled on current page: ${location.href}`,
      event.message.rule,
    );
  } else if (event.name === "upgrade") {
    logger.i(
      `Accelerate has been upgraded to a new major version. Opening main application...`,
    );
  } else if (event.name === "triggerAction" && initialized) {
    // Actions could be externally triggered by global shortcut or toolbar button.
    // Check initialization to avoid triggering actions before extension is ready.
    triggerAction(event.message.shortcut);
  } else if (event.name === "triggerContextMenuAction" && initialized) {
    triggerAction(contextMenuShortcuts[event.message.index]);
  }
});

/* Initialization */

function initialize(settings) {
  _initialize(settings);
  snackbarIcons = settings.snackbarIcons;
  contextMenuShortcuts = settings.shortcuts.filter(
    (shortcut) => shortcut.showInContextMenu,
  );
  updateContextMenuUserInfo(contextMenuShortcuts);

  document.addEventListener(
    "contextmenu",
    (event) => {
      safari.extension.setContextMenuEventUserInfo(
        event,
        !initialized || !hasVideos ? null : contextMenuUserInfo,
      );
    },
    false,
  );
}

function updateContextMenuUserInfo(shortcuts) {
  contextMenuUserInfo = {};
  for (let i = 0; i < shortcuts.length; i++) {
    const shortcut = shortcuts[i];

    // Hide setRate items if current rate matches
    if (
      shortcut.action === "setRate" &&
      (shortcut.rate ?? defaultRate) === currentRate
    ) {
      continue;
    }

    contextMenuUserInfo[i] = shortcut.description;
  }
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

function setRate(newRate, videos) {
  _setRate(newRate, videos);

  // Pre-configure context menu user info to minimize logic during actual menu render
  updateContextMenuUserInfo(contextMenuShortcuts);
}

function getSnackbarIcon(icon) {
  return snackbarIcons[icon];
}

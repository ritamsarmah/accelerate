//
//  utils.js
//  Accelerate
//
//  Created by Ritam Sarmah on 5/22/22.
//  Copyright © 2022 Ritam Sarmah. All rights reserved.
//

/** Determines if current active element has editable text. */
function activeElementHasEditableText() {
    return (
        document.activeElement.nodeName === "INPUT" ||
        document.activeElement.nodeName === "TEXTAREA" ||
        document.activeElement.isContentEditable
    );
}

/** Return z-index number values for HTML elements by checking parents. */
function getZIndexes(elements) {
    return elements.map(el => {
        let zIndex = "auto";
        do {
            zIndex = getComputedStyle(el)["zIndex"];
            el = el.parentElement;
        } while (zIndex == "auto" && el != null);

        return isNaN(zIndex) ? "-1" : zIndex;
    });
}

/** Return content document for same-origin iframe. Returns null if cross-origin. */
function getIFrameContent(iframe) {
    try {
        // If iframe is same origin, content will not be empty
        let content = iframe.contentDocument || iframe.contentWindow.document;
        if (!!content) {
            return content;
        }
    } catch (error) {
        // do nothing
    }

    return null;
}

/** Returns true if browser supports touch interaction */
function isTouchScreen() {
    return "ontouchstart" in window || navigator.maxTouchPoints > 0;
}

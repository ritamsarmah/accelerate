//
//  utils.js
//  Accelerate
//
//  Created by Ritam Sarmah on 5/22/22.
//  Copyright © 2022 Ritam Sarmah. All rights reserved.
//

/** Determines if current active element has editable text. */
function activeElementHasEditableText() {
    const activeElement = document.activeElement;
    if (activeElement == null) return false;

    // Matches with standard "INPUT" and "TEXTAREA" node names, as well as
    // common keywords for custom input elements (e.g., Reddit search bar)
    const keywords = ["INPUT", "TEXT", "SEARCH", "COMMENT", "COMPOSE", "CHAT"];

    // Check if any attribute name contains any keyword
    function hasKeywordAttribute(element, keywords) {
        if (!element || !element.attributes) return false;

        for (const attr of element.attributes) {
            const hasKeyword = keywords.some(keyword =>
                attr.name.toUpperCase().includes(keyword)
            );

            if (hasKeyword) return true;
        }

        return false;
    }

    return (
        activeElement.isContentEditable ||
        keywords.some(s => activeElement.nodeName.includes(s)) ||
        hasKeywordAttribute(activeElement, keywords)
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

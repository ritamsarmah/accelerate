//
//  snackbar.js
//  Accelerate
//
//  Created by Ritam Sarmah on 5/22/22.
//  Copyright © 2022 Ritam Sarmah. All rights reserved.
//

/** Get snackbar element. */
function getSnackbar() {
    let snackbar = document.getElementById("accel-snackbar");

    // Add snackbar to DOM if doesn't exist
    if (!snackbar) {
        snackbar = document.createElement("DIV");
        snackbar.id = "accel-snackbar";
        logger.d("Snackbar initialized");
    }

    // Move snackbar to full screen element if needed
    let fullscreenElement = document.fullscreenElement;
    if (fullscreenElement != null) {
        fullscreenElement.appendChild(snackbar);
    } else {
        document.body.appendChild(snackbar);
    }

    return snackbar;
}

/** Returns HTML content for snackbar icon. */
function getSnackbarIcon(icon) {
    // NOTE: This is overriden by platform-specific scripts.
    return "";
}

/** Show snackbar. */
function showSnackbar(icon) {
    let snackbar = getSnackbar();

    if (icon != null) {
        snackbar.style.boxSizing = "content-box";
        snackbar.style.width = "36px";
        snackbar.innerHTML = getSnackbarIcon(icon)
    } else {
        snackbar.style.width = "auto";
        snackbar.innerHTML = parseFloat(currentRate.toFixed(2)) + "x";
    }

    // Reset visibility timer and show snackbar
    clearTimeout(snackbarTimeout);
    snackbar.classList.add("show");

    // After 1 second, stop showing snackbar
    snackbarTimeout = setTimeout(function () {
        snackbar.classList.remove("show");
    }, 1000);
}

/**
 * Changes location of snackbar.
 * @param {String} location
 */
function setSnackbarLocation(location) {
    let snackbar = getSnackbar();
    let distance = "50px";
    switch (location) {
        case "Bottom Center":
            snackbar.style.left = "50%";
            snackbar.style.transform = "translate(-50%, 0)";
            snackbar.style.bottom = distance;
            break;
        case "Bottom Left":
            snackbar.style.left = distance;
            snackbar.style.bottom = distance;
            break;
        case "Bottom Right":
            snackbar.style.right = distance;
            snackbar.style.bottom = distance;
            break;
        case "Top Center":
            snackbar.style.left = "50%";
            snackbar.style.transform = "translate(-50%, 0)";
            snackbar.style.top = distance;
            break;
        case "Top Left":
            snackbar.style.left = distance;
            snackbar.style.top = distance;
            break;
        case "Top Right":
            snackbar.style.right = distance;
            snackbar.style.top = distance;
            break;
        default:
            // Hidden
            snackbar.style.visibility = "hidden";
            break;
    }
}

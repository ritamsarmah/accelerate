//
//  core.js
//  Accelerate
//
//  Created by Ritam Sarmah on 5/22/22.
//  Copyright © 2022 Ritam Sarmah. All rights reserved.
//

/* Global Variables */

var initialized = false; // Track to avoid re-initializing
var hasVideos = false; // If true, page has had videos before (used by context menu)

var currentRate = 1.0; // Tracks current video playback rate
var defaultRate = 1.0; // Default rate for videos to start with
var minimumRate = 0.25; // Minimum video playback rate
var maximumRate = 16.0; // Maximum video playback rate

var snackbarTimeout; // For displaying notification
var videoObserver; // Observer for new videos

/** Initialize the extension. May be overriden by platform-specific scripts. */
function initialize(settings) {
    _initialize(settings);
}

/** Helper for initialize for overriding. */
function _initialize(settings) {
    if (initialized) return;

    initialized = true;
    currentRate = settings.defaultRate;
    defaultRate = settings.defaultRate;
    minimumRate = settings.minimumRate;
    maximumRate = settings.maximumRate;
    logger.isVerbose = settings.isVerboseLogging;

    logger.d("Initializing extension...", location.href, settings);

    setSnackbarLocation(settings.snackbarLocation);
    addShortcutListener(settings.shortcuts);

    // Force initial search for videos in DOM
    findVideos();

    // Configure videos lazily as they are inserted
    videoObserver = new MutationObserver(mutations => {
        mutations.forEach(mutation => {
            mutation.addedNodes.forEach(node => {
                if (typeof node === "function") return;

                findVideos(node);

                // Observe shadowRoot for mutations
                if (node.shadowRoot) {
                    videoObserver.observe(node.shadowRoot, {
                        childList: true,
                        subtree: true,
                    });
                }
            });
        });
    });
    videoObserver.observe(document, { childList: true, subtree: true });
}

/* Shortcut Handling */

/** Add keydown listener for shortcuts. */
function addShortcutListener(shortcuts) {
    // Map shortcuts to their matching key combo, supporting duplicate keys
    let shortcutMap = shortcuts.reduce((result, shortcut) => {
        if (shortcut.keyCombo in result) {
            result[shortcut.keyCombo].push(shortcut);
        } else {
            result[shortcut.keyCombo] = [shortcut];
        }
        return result;
    }, {});

    logger.d("Added shortcut listener", shortcutMap);

    document.addEventListener("keydown", event => {
        shortcutEventListener(event, shortcutMap);
    });
}

function shortcutEventListener(event, shortcuts) {
    // NOTE: This is overriden by platform-specific scripts.
}

function triggerAction(shortcut, event) {
    let videos = findVideos();
    if (videos.length == 0) {
        logger.d("No videos found — action canceled");
        return;
    }

    if (event != null) {
        event.preventDefault();
        event.stopPropagation();
    }

    logger.d("Action triggered", shortcut.description);

    // Actions independent of active video
    switch (shortcut.action) {
        case "speedUp":
            setRate(currentRate + shortcut.amount, videos);
            if (shortcut.showSnackbar) showSnackbar();
            return;
        case "slowDown":
            setRate(currentRate - shortcut.amount, videos);
            if (shortcut.showSnackbar) showSnackbar();
            return;
        case "setRate":
            setRate(shortcut.rate, videos);
            if (shortcut.showSnackbar) showSnackbar();
            return;
        case "showRate":
            showSnackbar();
            return;
        default:
            break;
    }

    // NOTE: There will be at least one video at this point
    let activeVideo = getActiveVideo(videos, event);
    if (activeVideo == null) return;

    // Actions dependent on active video
    switch (shortcut.action) {
        case "playOrPause":
            activeVideo.paused ? activeVideo.play() : activeVideo.pause();
            if (shortcut.showSnackbar) {
                showSnackbar(activeVideo.paused ? "pause" : "play");
            }
            return;
        case "skipForward":
            activeVideo.currentTime += shortcut.seconds;
            if (shortcut.showSnackbar) showSnackbar("forward");
            return;
        case "skipBackward":
            activeVideo.currentTime -= shortcut.seconds;
            if (shortcut.showSnackbar) showSnackbar("backward");
            return;
        case "skipToEnd":
            activeVideo.currentTime = activeVideo.duration;
            if (shortcut.showSnackbar) showSnackbar("skip");
            return;
        case "toggleMute":
            activeVideo.muted = !activeVideo.muted;
            if (shortcut.showSnackbar) {
                showSnackbar(activeVideo.muted ? "mute" : "unmute");
            }
            return;
        case "pip":
            activeVideo.webkitSetPresentationMode(
                activeVideo.webkitPresentationMode === "picture-in-picture"
                    ? "inline"
                    : "picture-in-picture"
            );
            if (shortcut.showSnackbar) showSnackbar("pip");
            return;
        case "toggleFullscreen":
            if (!activeVideo.webkitSupportsFullscreen) {
                logger.i("This video does not support full screen");
                return;
            }

            // NOTE: This toggles native player fullscreen, which will be different from a custom website player
            if (!activeVideo.webkitDisplayingFullscreen) {
                activeVideo.webkitEnterFullscreen();
            } else if (document.exitFullscreen) {
                activeVideo.webkitExitFullscreen();
            }
        default:
            break;
    }
}

/* Video */

/** Updates the rate for a list of videos. May be overriden by platform-specific scripts.  */
function setRate(newRate, videos) {
    _setRate(newRate, videos);
}

/** Helper for setRate for overriding. */
function _setRate(newRate, videos) {
    if (videos.length == 0) return;

    if (newRate == null) {
        currentRate = defaultRate;
    } else if (currentRate == newRate) {
        currentRate = defaultRate;
    } else {
        let fixedRate = parseFloat(newRate.toFixed(2)); // Avoids floating point rounding errors
        currentRate = Math.min(Math.max(fixedRate, minimumRate), maximumRate);
    }

    for (let video of videos) {
        video.playbackRate = currentRate;
    }
}

/**
 * Finds all videos that are children of current element using DFS.
 * @param {Element} element
 */
function findVideos(element = document.body) {
    let videos = [];
    let stack = [element];

    while (stack.length != 0) {
        let node = stack.pop();

        if (node.nodeName === "VIDEO") {
            videos.push(node);
        } else if ("children" in node && node.children != null) {
            stack.push(...Array.from(node.children));
        }

        // Automatically detect videos for same-origin iframe on touch devices, since touch cannot focus iframes
        if (isTouchScreen() && node.nodeName === "IFRAME") {
            let iframe = getIFrameContent(node);
            if (iframe != null) {
                stack.push(iframe.body);
            }
        }

        // If node has shadowRoot, walk through it
        if (node.shadowRoot) {
            stack.push(node.shadowRoot);
        }
    }

    // Configure videos found
    for (let video of videos) {
        configureVideo(video);
    }

    return videos;
}

/**
 * Configures and adds listeners to a video for playback control.
 */
function configureVideo(video) {
    // Prevents configuring video multiple times
    if (video.hasAttribute("accel-video")) return;
    video.setAttribute("accel-video", true);

    logger.d("Configured video", video);

    // Remember that we found a video on the page
    hasVideos = true;

    video.webkitPreservesPitch = true; // Safari sets to true by default, but do it just in case
    video.playbackRate = currentRate;

    // Update rate on first time playing video using listeners
    video.addEventListener("canplay", function canPlayListener(event) {
        event.target.playbackRate = currentRate;
        event.target.removeEventListener("canplay", canPlayListener);
    });

    video.addEventListener("play", function playListener(event) {
        event.target.playbackRate = currentRate;
        event.target.removeEventListener("play", playListener);
    });

    // Update rate when video resource loads (e.g., specifically useful when video element gets reused, like on YouTube)
    video.addEventListener("loadstart", event => {
        event.target.playbackRate = currentRate;
    });

    // Listen to speed changes (e.g., default player controls) and sync rates.
    // NOTE: This is also triggered redundantly by Accelerate, but has no side effect.
    video.addEventListener("ratechange", event => {
        if (event.target.readyState > 0) {
            // Manually set current rate to update tracked value without altering video rates.
            currentRate = parseFloat(event.target.playbackRate.toFixed(2));
            logger.d(`Rate set to ${currentRate}`);
        }
    });
}

/**
 * Returns active video on webpage using various heuristics.
 */
function getActiveVideo(videos, event) {
    // Filter out unplayable videos
    videos = videos.filter(v => v.readyState != HTMLMediaElement.HAVE_NOTHING);

    // Select first video if it is the only one
    if (videos.length == 1) {
        logger.d(`Active video is only one found on page`, videos[0]);
        return videos[0];
    }

    // Refine search using event.target or document.activeElement
    let focusedVideos = [];
    if (event != null && event.target != null) {
        // Use event.target
        focusedVideos = findVideos(event.target);
    } else if (document.activeElement != null) {
        // Use active element
        focusedVideos = findVideos(document.activeElement);
    }

    // Filter out unplayable focused videos
    focusedVideos = focusedVideos.filter(
        v => v.readyState != HTMLMediaElement.HAVE_NOTHING
    );

    // Select first focused video if it is the only one
    if (focusedVideos.length == 1) {
        logger.d(
            `Active video is only one found under focused element`,
            focusedVideos[0]
        );
        return focusedVideos[0];
    } else if (focusedVideos.length > 0) {
        videos = focusedVideos;
    }

    // There are multiple videos on the page, so try to guess active video using following heuristics:
    // 1. Highest z-index
    // 2. Currently playing

    let maxIndex = 0;
    let foundDifferentZIndex = false;
    let zIndexes = getZIndexes(videos);

    // Start at index 1, since the maxIndex already defaults to the first video (index 0)
    for (let i = 1; i < zIndexes.length; i++) {
        if (zIndexes[i] != zIndexes[maxIndex]) foundDifferentZIndex = true;
        if (zIndexes[i] > zIndexes[maxIndex]) maxIndex = i;
    }

    // Videos had different z-indexes so use video that was found on top.
    if (foundDifferentZIndex) {
        logger.d("Active video is one with highest z-index", videos[maxIndex]);
        return videos[maxIndex];
    }

    // Return currently playing video, otherwise return first video in list arbitrarily.
    let playingVideos = videos.filter(v => !v.paused);
    if (playingVideos.length != 0) {
        logger.d("Active video is first playing video", playingVideos[0]);
        return playingVideos[0];
    } else {
        logger.d("Active video is first video found", videos[0]);
        return videos[0];
    }
}

//
//  logger.js
//  Accelerate
//
//  Created by Ritam Sarmah on 5/22/22.
//  Copyright © 2022 Ritam Sarmah. All rights reserved.
//

var logger = {
    tag: "Accelerate",
    isVerbose: false,
    e: (message, ...args) => {
        if (logger.isVerbose) {
            console.error(logger.tag, message, ...args);
        }
    },
    w: (message, ...args) => {
        if (logger.isVerbose) {
            console.warn(logger.tag, message, ...args);
        }
    },
    d: (message, ...args) => {
        if (logger.isVerbose) {
            console.debug(logger.tag, message, ...args);
        }
    },
    i: (message, ...args) => {
        console.info(logger.tag, message, ...args);
    }
};

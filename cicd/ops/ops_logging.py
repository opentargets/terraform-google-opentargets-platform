# This module configures the logging subsystem for the different operations tools.

import logging
import logging.config
import sys

LOGGING_CONFIG = {
    "version": 1,
    "formatters": {
        "detailed": {
            "format": "%(asctime)s [%(levelname)-8s] %(name)-20s: %(message)s",
            "datefmt": "%Y-%m-%d %H:%M:%S",
        }
    },
    "handlers": {
        "console": {
            "class": "logging.StreamHandler",
            "stream": "ext://sys.stdout",
            "formatter": "detailed",
            "level": "DEBUG",
        }
    },
    "loggers": {
        "": {
            "handlers": ["console"],
            "level": "DEBUG",
            "propagate": False,
        }
    },
}

logging.config.dictConfig(LOGGING_CONFIG)

if __name__ == "__main__":
    logging.info("This is a test message.")
    logging.error("This is a test error message.")
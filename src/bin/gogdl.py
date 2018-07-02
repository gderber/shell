#!/usr/bin/env python3
"""
Gogdl
GoG Downloader

This is a wrapper for lgogdownloader for commonly used functions
"""

"""
Libraries

sys
argparse
os
"""
import sys
import argparse
import os
import logging
import subprocess
#import logging.config

"""
Global Variables
"""
__version__='0.1.1'

class ColorizingStreamHandler(logging.StreamHandler):

    BLACK = '\033[0;30m'
    RED = '\033[0;31m'
    GREEN = '\033[0;32m'
    BROWN = '\033[0;33m'
    BLUE = '\033[0;34m'
    PURPLE = '\033[0;35m'
    CYAN = '\033[0;36m'
    GREY = '\033[0;37m'

    DARK_GREY = '\033[1;30m'
    LIGHT_RED = '\033[1;31m'
    LIGHT_GREEN = '\033[1;32m'
    YELLOW = '\033[1;33m'
    LIGHT_BLUE = '\033[1;34m'
    LIGHT_PURPLE = '\033[1;35m'
    LIGHT_CYAN = '\033[1;36m'
    WHITE = '\033[1;37m'

    RESET = "\033[0m"

    def __init__(self, *args, **kwargs):
        self._colors = {logging.DEBUG: self.GREEN,
                        logging.INFO: self.RESET,
                        logging.WARNING: self.BROWN,
                        logging.ERROR: self.LIGHT_RED,
                        logging.CRITICAL: self.RED}
        super(ColorizingStreamHandler, self).__init__(*args, **kwargs)

    @property
    def is_tty(self):
        isatty = getattr(self.stream, 'isatty', None)
        return isatty and isatty()

    def emit(self, record):
        try:
            message = self.format(record)
            stream = self.stream
            if not self.is_tty:
                stream.write(message)
            else:
                message = self._colors[record.levelno] + message + self.RESET
                stream.write(message)
            stream.write(getattr(self, 'terminator', '\n'))
            self.flush()
        except (KeyboardInterrupt, SystemExit):
            raise
        except:
            self.handleError(record)

    def setLevelColor(self, logging_level, escaped_ansi_code):
        self._colors[logging_level] = escaped_ansi_code


# create logger
logger = logging.getLogger(__name__)
logger.setLevel(logging.DEBUG)

ch = ColorizingStreamHandler()
ch.setLevel(logging.DEBUG)

# create formatter
formatter = logging.Formatter('%(name)s - %(levelname)s - %(message)s')

# add formatter to ch
ch.setFormatter(formatter)

# add ch to logger
logger.addHandler(ch)

def download(platform,games,directory):
    """
Performs the actual downloading
"""

    logger.debug("Platform: " + platform + "\nGames: " + str(games))
    
    if games is not "downloadallgames":
        game = games.pop()
        logger.info("Domnloading single game: " + str(game))
        subprocess.run(["lgogdownloader","--download","--platform",platform,"--directory",directory,"--game",game])
        if len(games) > 0:
            download(platform,games,directory)
    elif games is "downloadallgames":
        logger.info("Downoaling All Games")
        subprocess.run(["lgogdownloader","--download","--platform",platform,"--directory",directory])
    return 0




def main():
    parser = argparse.ArgumentParser(description="Process parameters")
    parser.add_argument("-d","--directory",
                        default="gogdl",
                        help="Set Directory")
    parser.add_argument("-p","--platform",
                        default="4",
                        help="Set platforms to download",
                        choices=["1","2","3","4","5","6","7","w","m","l"])
    parser.add_argument("games",
                        nargs="*",
                        default="downloadallgames",
                        help="Games to Download, separated bp spaces")
    parser.add_argument("--log",
                        help="Set minimum logging level",
                        choices=["debug","info","warning","error","critical","DEBUG","INFO","WARNING","ERROR","CRITICAL"])
    parser.add_argument("-V", "--version",
                        help="Print version information and exit",
                        action="version",
                        version="%(prog)s " + __version__)
    parser.add_argument("--debug",
                        help="Enable Debugging",
                        action="store_true")
    args = parser.parse_args()


    # Configure Application based on the arguments recieved

    userHome = os.path.expanduser("~")

    if args.debug:
        logging.setLevel(logging.DEBUG)
        ch.setLevel(logging.DEBUG)
    else:
        if args.log:
            # Bind loglevel to the string value obtained from the command line argument
            argloglevel=args.log
            # Convert to upper case to allow the user to specify --log=DEBUG or --log=debug
            loglevel = argloglevel.upper()
            logging.setLevel(loglevel)
            ch.setLevel(loglevel)


    # If debugging enabled, log the arguments passed to the program
    logger.debug("Arguments Processed")

    userHome = os.path.expanduser("~")
    dlDir=userHome + "/" + args.directory
    os.makedirs(dlDir,exist_ok=True)

    download(args.platform,args.games,dlDir)

    return 0

main()

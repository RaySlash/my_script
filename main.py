#!/usr/bin/env python3
"""
JobLog Logger
"""

__author__ = "RaySlash"
__version__ = "0.1"
__license__ = "GPL-3"

import datetime 
import csv
from pathlib import Path

def main():
    var = input("Enter Current JobLog: ")
    date = datetime.datetime.now().strftime('%d/%m/%Y')
    time = datetime.datetime.now().strftime('%H:%M:%S')
    tz = datetime.datetime.now().astimezone().strftime('%Z')
    print(date, time, tz, var)
    input_var = [
        date, time, tz, var
    ]

    # Check file exist
    my_file = Path("./joblog.csv")

    try:
        my_abs_path = my_file.resolve(strict=True)
    except FileNotFoundError:
        with open('joblog.csv', 'w', newline='') as notfoundcsvfile:
            csvwriter = csv.writer(notfoundcsvfile)
            csvwriter.writerows([["Date","Time","Timezone","JobLog"],
                                (input_var)])
    else:
        with open('joblog.csv', 'a', newline='') as writecsvfile:
            csvwriter = csv.writer(writecsvfile)
            csvwriter.writerow(input_var)


if __name__ == "__main__":
    main()

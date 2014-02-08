# campfire_export #

## Quick Start ##

    $ gem install campfire_export
    $ campfire_export

## Features ##

* Saves HTML, XML, and plaintext versions of chat transcripts.
* Exports uploaded files to a day-specific subdirectory for easy access.
* Reports and logs export errors so you know what you're missing.
* Obsessively confirms that everything was exported correctly.

## Installing ##

[Ruby 1.8.7](http://www.ruby-lang.org/en/downloads/) or later is required.
[RubyGems](https://rubygems.org/pages/download) is also required -- I'd
recommend having the latest version of RubyGems installed before starting.

## Configuring ##

The export script will prompt you for config; just run it and away you go. If you
want to run the script repeatedly or want to control the start and end date of
the export, you can create a `.campfire_export.yml` file in your home
directory using this template:

    # Your Campfire subdomain (for 'https://myco.campfirenow.com', use 'myco').
    subdomain:  myco

    # Your Campfire API token (see "My Info" on your Campfire site).
    api_token:  token

    # OPTIONAL: Export start date - the first transcript you want exported.
    # Uncomment to set. Defaults to the date each room was created.
    #start_date: 2010/1/1

    # OPTIONAL: Export end date - the last transcript you want exported.
    # Uncomment to set. Defaults to the date of the last comment in each room.
    #end_date:   2010/12/31

    # OPTIONAL: included rooms - only export transcripts from these rooms
    # Array of string room name
    included_rooms:
    - Test

    # OPTIONAL: excluded rooms - don't export transcripts from these rooms
    # Array of string room name
    excluded_rooms:
    - The place to be

The `start_date` and `end_date` variables are inclusive (that is, if your
end date is Dec 31, 2010, a transcript for that date will be downloaded), and
both are optional. If they are omitted, export will run from the date each
Campfire room was created, until the date of the last message in that room.

The `included_rooms` and `excluded_rooms` are mutually exclusive, that is
you can't define both. `included_rooms` is checked first, if present,
`excluded_rooms` will be ignored.

## Exporting ##

Just run `campfire_export` and your transcripts will be exported into a
`campfire` directory in the current directory, with subdirectories for each
site/room/year/month/day. In those directories, any uploaded files will be
saved with their original filenames, in a directory named for the upload ID
(since transcripts often have the same filename uploaded multiple times, e.g.
`Picture 1.png`). (Note that rooms and uploaded files may have odd filenames
-- for instance, spaces in the file/directory names.) Errors that happen
trying to export will be logged to `campfire/export_errors.txt`.

The Gist I forked had a plaintext transcript export, which I've kept in as
`transcript.txt` in each directory. However, the original XML and HTML are now
also saved as `transcript.xml` and `transcript.html`, which could be useful.

Days which have no messages posted will be ignored, so the resulting directory
structure will be sparse (no messages == no directory).

## Credit ##

First, thanks a ton to [Jeffrey Hardy](https://github.com/packagethief) from
37signals, who helped me track down some bugs in my code as well as some
confusion in what I was getting back from Campfire. His patient and determined
help made it possible to get this working. Thanks, Jeff!

Also, thanks much for all the help, comments and contributions:

* [Brad Greenlee](https://github.com/bgreenlee)
* [Andre Arko](https://github.com/indirect)
* [Brian Donovan](https://github.com/eventualbuddha)
* [Andrew Wong](https://github.com/andrewwong1221)
* [Junya Ogura](https://github.com/juno)
* [Chase Lee](https://github.com/chaselee)
* [Alex Hofsteede](https://github.com/alex-hofsteede)

As mentioned above, some of the work on this was done by other people. The
Gist I forked had contributions from:

* [Pat Allan](https://github.com/freelancing-god)
* [Bruno Mattarollo](https://github.com/bruno)
* [bf4](https://github.com/bf4)

Thanks, all!

- Marc Hedlund, marc@precipice.org

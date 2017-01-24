# scribe

Scribe is a tool I use to automatically determine which event I'm at during a day, generate the appropriate heading and filename, and automatically create and open the file. I have it bound to an unused key on my laptop to make use of it.

## timetable format

The format of a timetable is simple. Each line describes the timetable of one day, with events taking place on specific hours. The line begins with the name of the day and a colon, such as `mon:`. Everything that follows is a comma-separated list of the events on that day, where one event is described by the name of the event, followed by an `@` symbol, followed by a `+`-separated list of the hours on which that event takes place, such as `Some Awesome Event @14+15`. The filename creates an initialism from the name of the event (in this case, `sae`) to separate different events into different directories. Commented lines are supported if they begin with `#` (only whole-line comments supported, a `#` somewhere else in a line is interpreted normally). Configuration options are supported; see section below.

## configuration

A configuration line looks like this:

    %init(Good Lecture)=good

The line begins with a percentage sign (`%`), and all text up until the equals (`=`) sign is the *key* (in this case, `init(Good Lecture)`). All text after (`good`) is the configuration value. Currently configuration options are limited. More options may come in the future. For now, the existing configuration options are:

* `%init(Event Name)=initialism` - this sets the initialism used for the given event name. This might be useful for events with long names, or whose auto-generated initialism isn't very pretty.

## purpose

This was created as a small utility for me to make my note format a bit more consistent. As it is specifically tailored for use by me, some features are missing (eg. exact specification of the duration of events, different timetables on different weeks, etc.) but it does the job for me. Of course, feel free to add features as you see fit.

## license

This is licensed under the BSD 3-clause license; see `LICENSE.md`.

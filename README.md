[braille-css][]
===============

Braille CSS specification: http://braillespecs.github.io/braille-css


Building
--------

First start the [ReSpec][] and [Specref][] services:

    make respec/src
    make specref/src
    docker compose build
    docker compose up respec specref &

Then build the site (target/site/) with:

    make

To build the site without running the tests:

    make SKIP_TESTS


License
-------
Copyright 2014-2016 [Bert Frees][bert]

This program is free software: you can redistribute it and/or modify
it under the terms of the [GNU Lesser General Public License][lgpl]
as published by the Free Software Foundation, either version 3 of
the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
GNU Lesser General Public License for more details.


[braille-css]: https://github.com/braillespecs/braille-css
[respec]: http://www.w3.org/respec
[specref]: http://www.specref.org
[bert]: http://github.com/bertfrees
[lgpl]: http://www.gnu.org/licenses/lgpl.html

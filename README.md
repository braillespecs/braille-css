[braille-css-spec][]
====================

Braille CSS specification: http://snaekobbi.github.io/braille-css-spec


Building
--------

First start the [ReSpec][] and [Specref][] services:

    make respec/src
    make specref/src
    docker compose build
    docker compose up respec specref

Then build the site (target/site/index.html) with:

    make


License
-------
Copyright 2014-2015 [Bert Frees][bert]

This program is free software: you can redistribute it and/or modify
it under the terms of the [GNU Lesser General Public License][lgpl]
as published by the Free Software Foundation, either version 3 of
the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
GNU Lesser General Public License for more details.


[braille-css-spec]: https://github.com/snaekobbi/braille-css-spec
[respec]: http://www.w3.org/respec
[specref]: http://www.specref.org
[bert]: http://github.com/bertfrees
[lgpl]: http://www.gnu.org/licenses/lgpl.html

Sample Code for cPanel Conf 2016

This repository includes a sample applications implementing a UPAI module
and user interface code for a Example of how to build applications on top
of the cPanel platform leveraging the new tools in CJT 2.0, AngularJS,
RequireJS and Bootstrap.

The code is presented as an example, but was not build with all production
level requirement. In some areas, error handling and security issues may
have been ignored to simplify the example.

The code is intended to be delivered in a cPanel plugin for Paper Lantern,
but some of the key components of the plugin installer are not available
with the example.

License:

cPanel Open Source License

Copyright (c) 2016, cPanel, Inc.
All rights reserved.
http://cpanel.net

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are met:

1. Redistributions of source code must retain the above copyright notice,
this list of conditions and the following disclaimer.

2. Redistributions in binary form must reproduce the above copyright notice,
this list of conditions and the following disclaimer in the documentation
and/or other materials provided with the distribution.

3. Neither the name of the owner nor the names of its contributors may be
used to endorse or promote products derived from this software without
specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

Where to find this example:

TODO: Github somewhere

Covered in this example:

    Step 1: Add the applications main template and css
    Step 2: Added application javascript and angular bootstrap
    Step 3: Add router and first view
    Step 4: Use some components from cjt 2.0
    Step 5: Wire up the view with fake data
    Step 6: Wire in the real api. Handle both success and failure
    Step 7: Add the new todo view and its supporting code
    Step 8: Add support for marking the todo done
    Step 9: Adding search and done filter
    Step 10: Editing a todo
    Step 11: Add ability to detele an item

    Extra 1: Optimizing initial load of data
    Extra 2: Optimizing loading of view partials
    Extra 3: TODO: Optimizing requirejs loading

cPanel Resources:

https://documentation.cpanel.net/display/SDK/Guide+to+cPanel+Plugins
https://documentation.cpanel.net/display/SDK/UAPI+-+Custom+UAPI+Modules
https://documentation.cpanel.net/display/SDK/Guide+to+AppConfig
https://styleguide.cpanel.net/

Other Resources:

https://angularjs.org/
http://requirejs.org/
http://getbootstrap.com/

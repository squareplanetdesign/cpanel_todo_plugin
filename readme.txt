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

Copyright 2016 cPanel, Inc.

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.

Branches:

master - out of date
cjt2_pres - code for the cjt2 plugin example presentation at cPanel Conference 2016.
locale_pres - code for the localization of cjt2 plugin example presentation at cPanel Conference 2016.
npmify - experimental branch to package a plugin as an NPM module.

Where to find this example:

https://go.cpanel.net/cjt2_plugin

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

Writing cPanel Plugins:
https://documentation.cpanel.net/display/SDK/Guide+to+cPanel+Plugins

Writing Custom UAPI Extensions:
https://documentation.cpanel.net/display/SDK/UAPI+-+Custom+UAPI+Modules

Tools to Configure Your Plugin:
https://documentation.cpanel.net/display/SDK/Guide+to+AppConfig

Paper Lantern Style Guide:
https://styleguide.cpanel.net/

Privilege Escalation in Extensions:
https://documentation.cpanel.net/display/SDK/Guide+to+API+Privilege+Escalation

We also have a mailing list for plugin developers:

plugindevs@cpanel.net
http://mail.cpanel.net/mailman/options/plugindevs_cpanel.net

Other Resources:

https://angularjs.org/
http://requirejs.org/
http://getbootstrap.com/
https://angular-ui.github.io/bootstrap/
http://fontawesome.io/

Notes:

CJT 2.0 does not yet have a public documentation site. However, we ship extensive documentation in the CJT 2.0
source code. You can find this documentation in JavaScript
comments in the files in: /usr/local/cpanel/base/frontend/paper_lantern/libraries/cjt2

Questions raised during the conference?

1) How do I access resource that require root privileges?

I have added links above to how to implement privilege escallation in the cPanel documentation links.

2) Seems like there is a lot of setup to get started?

This is true for plugins at this time. Internally we use a tool that generates all that boiler plate. I will try to find some time to rework it for plugins and make it available.  Stay tuned.

3) Where is the CJT 2.0 documentation?

Currently this documentation only resides in the source files. You can find these JavaScript files on a server with cPanel installed at:

 /usr/local/cpanel/base/frontend/paper_lantern/libraries/cjt2

4) Where can I get more help?

For help with specific technical problems, you are welcome to open tickets with cPanel if you have a cPanel License.

If there are problems with the code I provided in this example, please feel free to contact me and I can fix them. I also will accept pull requests and bug reports via github on the code provided here.

5) What else is planned for this example?

I am exploring several additional features to add, including:

 * A TODO interface in WHM
 * A TODO interface in Webmail
 * A shared TODO list capability.

However, there are some current limitations with the tools for WHM and Webmail, that limited the way I could write the backend part of this plugin. Stay tuned...
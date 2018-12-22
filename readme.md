# Bookmarks Plugin Readme

##Overview

The bookmarks plugin allows to manage groupchat and URL bookmarks.

##Installation

Copy bookmark.jar into the plugins directory of your Openfire installation.
The plugin will then be automatically deployed. To upgrade to a new version,
copy the new bookmark.jar file over the existing file.

##Upgrading from ClientControl

The functionality provided by the Bookmarks plugin was past of the
ClientControl plugin (up to and including version 1.3.1 of ClientControl).

If you are upgrading from ClientControl, all bookmarks will continue
to be available. It is however recommended to avoid using the Bookmarks
plugin in combination with the ClientControl plugin version 1.3.1 or
earlier.

##Upgrading from Enterprise

If you are upgrading from the Enterprise plugin, and wish to keep your old
bookmarks, you will need to manually run some database scripts to
perform the migration.  Note, if you don't care about your previous
bookmarks, you don't have to worry about these steps.

First, you will need to shut down your Openfire server and remove the
enterprise plugin.  To do this, perform the following steps:

1. Shut down your Openfire server
2. Remove the **enterprise.jar** file and the **enterprise** directory from the plugins directory in your Openfire install root
3. Install this plugin, **clientControl.jar** by copying it into the plugins directory.
4. At this point, you will need to start up Openfire and let it extract and install the **clientControl** plugin.  You can watch for this to occur by looking under the Plugins tab in the Openfire admin console.  Once it appears in the list, continue to the next step.
5. Shut the server back down again.
6. Go into your plugins/clientControl/database directory.  There you will see
some scripts prefixed with **import_**.  Log into your database, switch
to the Openfire's database as you configured during setup (you can find
this information in conf/openfire.xml if you don't remember it), and run
the script that matches the database you are using.  Note that the embedded
database is hsqldb and you can use the script in bin/extra from the Openfire
install root (bin/extra/embedded-db-viewer.sh or
bin/extra/embedded-db-viewer.bat, depending on whether you are using Windows)
to access your embedded database.
7. Once the script has completed, you can start Openfire back up and all of your settings should be the way they were when you were running the Enterprise plugin.

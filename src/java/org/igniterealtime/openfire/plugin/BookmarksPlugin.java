/**
 * Copyright (C) 2016-2024 Ignite Realtime Foundation. All rights reserved.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
package org.igniterealtime.openfire.plugin;

import org.jivesoftware.openfire.container.Plugin;
import org.jivesoftware.openfire.container.PluginManager;
import org.jivesoftware.openfire.container.PluginMetadataHelper;
import org.jivesoftware.openfire.plugin.spark.BookmarkInterceptor;
import org.jivesoftware.util.Version;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import javax.annotation.Nonnull;
import java.io.*;

/**
 * A plugin that implements XEP-0048 "Bookmarks".
 *
 * @author Guus der Kinderen, guus.der.kinderen@gmail.com
 * @see <a href="http://xmpp.org/extensions/xep-0048.html">XEP-0048 Bookmarks</a>
 */
public class BookmarksPlugin implements Plugin
{
    private final static Logger Log = LoggerFactory.getLogger( BookmarksPlugin.class );

    private BookmarkInterceptor bookmarkInterceptor;

    public void initializePlugin( PluginManager manager, File pluginDirectory )
    {
        boolean foundIncompatiblePlugin = false;
        try
        {
            // Check if we Enterprise is installed and stop loading this plugin if found
            if ( checkForEnterprisePlugin(manager) )
            {
                System.out.println( "Enterprise plugin found. Stopping Bookmarks Plugin." );
                foundIncompatiblePlugin = true;
            }

            // Check if we ClientControl (version <= 1.3.1) is installed and stop loading this plugin if found
            if ( checkForIncompatibleClientControlPlugin(manager) )
            {
                System.out.println( "ClientControl plugin v1.3.1 or earlier found. Stopping Bookmarks Plugin." );
                foundIncompatiblePlugin = true;
            }
        }
        catch ( Exception ex )
        {
            Log.warn( "An exception occurred while determining if there are incompatible plugins. Assuming everything is OK.", ex );
        }

        if ( foundIncompatiblePlugin )
        {
            throw new IllegalStateException( "This plugin cannot run next to the Enterprise plugin (any version) or the ClientControl plugin v1.3.1 or earlier." );
        }

        // Create and start the bookmark interceptor, which adds server-managed bookmarks when
        // a user requests their bookmark list.
        bookmarkInterceptor = new BookmarkInterceptor();
        bookmarkInterceptor.start();
    }

    public void destroyPlugin()
    {
        if ( bookmarkInterceptor != null )
        {
            bookmarkInterceptor.stop();
            bookmarkInterceptor = null;
        }
    }

    /**
     * Checks if there's a plugin named "enterprise" in the Openfire plugin directory.
     *
     * @param manager The Openfire plugin manager
     * @return true if the enterprise plugin is found, otherwise false.
     */
    private static boolean checkForEnterprisePlugin(@Nonnull final PluginManager manager)
    {
        return manager.getPluginByName("enterprise").isPresent();
    }

    /**
     * Checks if there's a plugin named "clientControl" in the Openfire plugin directory of which the version is equal
     * to or earlier than 1.3.1.
     *
     * @param manager The Openfire plugin manager
     * @return true if the clientControl plugin (<= 1.3.1) is found, otherwise false.
     */
    private static boolean checkForIncompatibleClientControlPlugin(@Nonnull final PluginManager manager)
    {
        final Plugin clientControlPlugin = manager.getPluginByName("clientControl").orElse(null);
        if (clientControlPlugin == null) {
            return false;
        }

        final Version version = PluginMetadataHelper.getVersion(clientControlPlugin);
        return !version.isNewerThan( new Version( "1.3.1" ) );
    }
}

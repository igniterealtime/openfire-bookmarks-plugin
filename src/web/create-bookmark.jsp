<%@ page contentType="text/html; charset=UTF-8" %>
<%@ page import="org.jivesoftware.openfire.plugin.spark.Bookmark" %>
<%@ page import="org.jivesoftware.util.Log" %>
<%@ page import="org.jivesoftware.util.ParamUtils" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Collection" %>
<%@ page import="java.util.HashMap" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.Map" %>
<%@ page import="java.util.StringTokenizer" %>
<%@ page import="java.util.Iterator"%>
<%@ page import="org.jivesoftware.util.NotFoundException"%>
<%@ page import="org.jivesoftware.util.LocaleUtils"%>
<%@ page import="org.apache.commons.lang3.StringEscapeUtils"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<%
    boolean urlType = false;
    boolean groupchatType = false;    
    String propertyAction = request.getParameter("property");
    String type = request.getParameter("type");
    
    if ("url".equals(type)) {
        urlType = true;
    }
    else {
        groupchatType = true;   
    }

    boolean edit = request.getParameter("edit") != null;
    String bookmarkID = request.getParameter("bookmarkID");

    Bookmark editBookmark = null;
    
    if (edit && bookmarkID != null) {
        try {
            editBookmark = new Bookmark(Long.parseLong(bookmarkID));
            
            if (propertyAction != null) {
                String propName = request.getParameter("propName");            
                String propValue = request.getParameter("propValue");                  
                
                if (propertyAction.equals("set")) {
                    editBookmark.setProperty(propName, propValue);                
                }
                else {
                    editBookmark.deleteProperty(propName);
                }
            
                if (urlType) {
                    response.sendRedirect("url-bookmarks.jsp");
                }
                else if (groupchatType) {
                    response.sendRedirect("groupchat-bookmarks.jsp");
                }
                return;                
            }            
        }
        catch (NotFoundException e) {
            Log.error(e);
        }
    }

    Map<String,String> errors = new HashMap<String,String>();
    String groupchatName = StringEscapeUtils.escapeHtml4(request.getParameter("groupchatName"));
    String groupchatJID = request.getParameter("groupchatJID");  

    boolean autojoin = ParamUtils.getBooleanParameter(request,"autojoin");
    boolean nameAsNick = ParamUtils.getBooleanParameter(request,"nameasnick");
    String avatarUri = request.getParameter("avatarUri");      

    String users = request.getParameter("users");
    String groups = request.getParameter("groups");


    String url = request.getParameter("url");
    String urlName = request.getParameter("urlName");

    boolean isRSS = ParamUtils.getBooleanParameter(request, "rss", false);
    boolean isWebApp = ParamUtils.getBooleanParameter(request, "webapp", false);
    boolean isCollabApp = ParamUtils.getBooleanParameter(request, "collabapp", false);
    boolean isHomePage = ParamUtils.getBooleanParameter(request, "homepage", false);   

    boolean allUsers = ParamUtils.getBooleanParameter(request,"all");

    boolean createGroupchat = request.getParameter("createGroupchatBookmark") != null;
    boolean createURLBookmark = request.getParameter("createURLBookmark") != null;


    boolean submit = false;
    if (createGroupchat || createURLBookmark) {
        submit = true;
    }

    if (submit && createURLBookmark) {
        if (url == null || url.trim().isEmpty()) {
            errors.put("url", LocaleUtils.getLocalizedString("bookmark.url.error", "bookmarks"));
        }

        if (urlName == null || urlName.trim().isEmpty()) {
            errors.put("urlName", LocaleUtils.getLocalizedString("bookmark.urlName.error", "bookmarks"));
        }
    }
    else if (submit && createGroupchat) {
        if (groupchatName == null ||groupchatName.trim().isEmpty()) {
            errors.put("groupchatName", LocaleUtils.getLocalizedString("bookmark.groupchat.name.error", "bookmarks"));
        }

        if (groupchatJID == null || !groupchatJID.contains("@")) {
            errors.put("groupchatJID", LocaleUtils.getLocalizedString("bookmark.groupchat.address.error", "bookmarks"));
        }
    }

    if (!submit && errors.size() == 0) {
        if (editBookmark != null) {
            if (editBookmark.getType() == Bookmark.Type.url) {
                url = editBookmark.getProperty("url");
                urlName = editBookmark.getName();
            }
            else {
                groupchatName = editBookmark.getName();
                autojoin = editBookmark.getProperty("autojoin") != null;
                nameAsNick = editBookmark.getProperty("nameasnick") != null;
                groupchatJID = editBookmark.getValue();
            }

            users = getCommaDelimitedList(editBookmark.getUsers());
            groups = getCommaDelimitedList(editBookmark.getGroups());
            allUsers = editBookmark.isGlobalBookmark();
            isRSS = editBookmark.getProperty("rss") != null;
            isWebApp = editBookmark.getProperty("webapp") != null;
            isCollabApp = editBookmark.getProperty("collabapp") != null;
            isHomePage = editBookmark.getProperty("homepage") != null;            
        }
        else {
            groupchatName = "";
            groupchatJID = "";
            url = "";
            urlName = "";
            users = "";
            groups = "";
        }
    }
    else {
        if ((createURLBookmark || createGroupchat) && errors.size() == 0) {
            Bookmark bookmark = null;

            if (bookmarkID == null) {
                if (createURLBookmark)
                    bookmark = new Bookmark(Bookmark.Type.url, urlName, url);

                if (createGroupchat) {
                    bookmark = new Bookmark(Bookmark.Type.group_chat, groupchatName, groupchatJID);
                }
            }
            else {
                try {
                    bookmark = new Bookmark(Long.parseLong(bookmarkID));
                }
                catch (NotFoundException e) {
                    Log.error(e);
                }
                if (createURLBookmark) {
                    bookmark.setName(urlName);
                    bookmark.setValue(url);
                }
                else {
                    bookmark.setName(groupchatName);
                    bookmark.setValue(groupchatJID);
                }
            }

            List<String> userCollection = new ArrayList<String>();
            List<String> groupCollection = new ArrayList<String>();
            if (users != null) {
                StringTokenizer tkn = new StringTokenizer(users, ",");
                while (tkn.hasMoreTokens()) {
                    userCollection.add(tkn.nextToken());
                }

                bookmark.setUsers(userCollection);
            }

            if (groups != null) {
                StringTokenizer tkn = new StringTokenizer(groups, ",");
                while (tkn.hasMoreTokens()) {
                    groupCollection.add(tkn.nextToken());
                }

                bookmark.setGroups(groupCollection);
            }

            if (allUsers) {
                bookmark.setGlobalBookmark(true);
            }
            else {
                bookmark.setGlobalBookmark(false);
            }

            if (createURLBookmark) {
                if (url != null) {
                    bookmark.setProperty("url", url);
                }

                if (isRSS) bookmark.setProperty("rss", "true"); else bookmark.deleteProperty("rss");
                if (isWebApp) bookmark.setProperty("webapp", "true"); else bookmark.deleteProperty("webapp");
                if (isCollabApp) bookmark.setProperty("collabapp", "true"); else bookmark.deleteProperty("collabapp");
                if (isHomePage) bookmark.setProperty("homepage", "true"); else bookmark.deleteProperty("homepage");                

            }
            else {
                if (autojoin) {
                    bookmark.setProperty("autojoin", "true");
                }
                    else {
                    bookmark.deleteProperty("autojoin");
                }
                if (nameAsNick) {
                    bookmark.setProperty("nameasnick", "true");
                }
                    else {
                    bookmark.deleteProperty("nameasnick");
                }
                if (avatarUri != null && avatarUri.startsWith("data:")) {
                    bookmark.setProperty("avatar_uri", avatarUri);                
                }
            }
        }
    }

    if (submit && errors.size() == 0) {
        if (createURLBookmark) {
            response.sendRedirect("url-bookmarks.jsp?urlCreated=true");
            return;
        }
        else if (createGroupchat) {
            response.sendRedirect("groupchat-bookmarks.jsp?groupchatCreated=true");
        }
    }

    String description = LocaleUtils.getLocalizedString("bookmark.url.create.description", "bookmarks");
    if (groupchatType) {
        description = LocaleUtils.getLocalizedString("bookmark.groupchat.create.description", "bookmarks");
        if(edit){
            description = LocaleUtils.getLocalizedString("bookmark.groupchat.edit.description", "bookmarks");
        }
    }
    else if(edit){
        description = LocaleUtils.getLocalizedString("bookmark.url.edit.description", "bookmarks");
    }

%>
<html>
<head>
    <title><%= editBookmark != null ? LocaleUtils.getLocalizedString("bookmark.edit", "bookmarks") : LocaleUtils.getLocalizedString("bookmark.create", "bookmarks")%></title>
    <meta name="pageID" content="<%= groupchatType ? "groupchat-bookmarks" : "url-bookmarks"%>"/>
    <script type="text/javascript">
        function toggleAllElement(ele, users, groups) {
            users.disabled = ele.checked;
            groups.disabled = ele.checked;
        }

        function showPicker() {
            alert("Not implemented!");
        }

        function validateForms(form) {
            form.users.disabled = form.all.checked;
            form.groups.disabled = form.all.checked;
        }
        
        function doedit(propName, propValue) {
            document.propForm.property.value = "set";
            document.propForm.propName.value = propName;
            document.propForm.propValue.value = propValue;            
        }
                
        function dodelete(propName) {            
            document.propForm.property.value = "delete";
            document.propForm.propName.value = propName;        
            document.propForm.submit();            
        }   
        
        function doicon() {
            var uploadAvatar = document.getElementById("uploadAvatar")
            console.debug("doicon", uploadAvatar);
                        
            if (uploadAvatar) for (var i = 0, file; file = uploadAvatar.files[i]; i++) {
            
                if (file.name.endsWith(".png") || file.name.endsWith(".jpg") || file.name.endsWith(".webp") || file.name.endsWith(".gif"))
                {
                    var reader = new FileReader();

                    reader.onload = function(event)
                    {
                        var dataUri = event.target.result;
                        console.debug("doicon", dataUri);

                        var sourceImage = new Image();

                        sourceImage.onload = function() {
                            var canvas = document.createElement("canvas");
                            canvas.width = 32;
                            canvas.height = 32;
                            canvas.getContext("2d").drawImage(sourceImage, 0, 0, 32, 32);
                            document.f.avatarUri.value = canvas.toDataURL();
                        }

                        sourceImage.src = dataUri;
                    };

                    reader.onerror = function(event) {
                        console.error("doicon - error", event);
                    };

                    reader.readAsDataURL(file);
                }
            }        
        }
    </script>
    <style type="text/css">
        .div-border {
            border: 1px;
            border-color: #ccc;
            border-style: dotted;
        }
    </style>
</head>

<body>

<!-- Create URL Bookmark -->
<p>
    <%= description%>
</p>


<% if (submit && errors.size() == 0 && createURLBookmark) { %>
<div class="success">
   <fmt:message key="bookmark.created" />
</div>
<% } %>


<% if (urlType) { %>
<form id="urlForm" name="urlForm" action="create-bookmark.jsp" method="post">
    <table class="div-border" cellpadding="3">
        <tr valign="top">
            <td><b><fmt:message key="bookmark.url.name" />:</b></td>
            <td><input type="text" name="urlName" size="30" value="<%=urlName %>"/><br/>
                <% if (errors.get("urlName") != null) { %>
                <span class="jive-error-text"><%= errors.get("urlName")%><br/></span>
                <% } %>
                <span class="jive-description"><fmt:message key="bookmark.url.name.description" /></span></td>

        </tr>
        <tr valign="top">
            <td><b><fmt:message key="bookmark.url" />:</b></td>
            <td><input type="text" name="url" size="30" value="<%=url %>"/><br/>
                <% if (errors.get("url") != null) { %>
                <span class="jive-error-text"><%= errors.get("url")%><br/></span>
                <% } %>
                <span class="jive-description">eg. http://www.acme.com</span></td>
        </tr>
        <tr valign="top">
            <td><b><fmt:message key="users" />:</b></td>
            <td><input type="text" name="users" size="30" value="<%= users%>"/><br/>
                <span class="jive-error-text"></span></td>
            <!--
            <td><img src="images/icon_browse_14x13.gif"/></td><td><a href="javascript:showPicker();"><fmt:message key="bookmark.browse.users" /></a></td>-->
            <td><input type="checkbox" name="all" <%= allUsers ? "checked" : "" %> onclick="toggleAllElement(this, document.urlForm.users, document.urlForm.groups);"/>All Users</td>
        </tr>

        <tr valign="top">
            <td><b><fmt:message key="groups" />:</b></td>
            <td><input type="text" name="groups" size="30" value="<%= groups %>"/><br/><span
                class="jive-error-text"></span></td><!--
            <td><img src="images/icon_browse_14x13.gif"/></td><td><a href="javascript:showPicker();"><fmt:message key="bookmark.browse.groups" /></a></td>-->
        </tr>
        <% if (errors.get("noUsersOrGroups") != null) { %>
        <tr>
            <td colspan="2" class="jive-error-text"><fmt:message key="bookmark.users.groups.error" /></td>
        </tr>
        <% } %>
        <tr><td><b><fmt:message key="bookmark.create.rss.feed" /></b></td><td><input type="checkbox" name="rss" <%= isRSS ? "checked" : "" %>/></td></tr>
        <tr><td><b><fmt:message key="bookmark.create.web.app" /></b></td><td><input type="checkbox" name="webapp" <%= isWebApp ? "checked" : "" %>/></td></tr>
        <tr><td><b><fmt:message key="bookmark.create.collab.app" /></b></td><td><input type="checkbox" name="collabapp" <%= isCollabApp ? "checked" : "" %>/></td></tr>
        <tr><td><b><fmt:message key="bookmark.create.home.page" /></b></td><td><input type="checkbox" name="homepage" <%= isHomePage ? "checked" : "" %>/></td></tr>

        <tr><td></td><td><input type="submit" name="createURLBookmark"
                                value="<%= editBookmark != null ? LocaleUtils.getLocalizedString("bookmark.save.changes", "bookmarks") : LocaleUtils.getLocalizedString("create", "bookmarks")  %>"/>
            &nbsp;<input type="button" value="<fmt:message key="cancel" />"
                         onclick="window.location.href='url-bookmarks.jsp'; return false;">
        </td>
        </tr>

    </table>
    <input type="hidden" name="type" value="url"/>
    <% if (editBookmark != null) { %>
    <input type="hidden" name="bookmarkID" value="<%= editBookmark.getBookmarkID()%>"/>
    <input type="hidden" name="edit" value="true" />
    <% } %>

<script type="text/javascript">
   validateForms(document.urlForm);
</script>
</form>

<% }
else { %>

<form name="f" id="f" action="create-bookmark.jsp" method="post">

    <table class="div-border" cellpadding="3">
        <tr valign="top">
            <td><b><fmt:message key="group.chat.bookmark.name" />:</b></td>
            <td colspan="3"><input type="text" name="groupchatName" size="40" value="<%= groupchatName %>"/><br/>
                <% if (errors.get("groupchatName") != null) { %>
                <span class="jive-error-text"><%= errors.get("groupchatName")%><br/></span>
                <% } %>
                <span class="jive-description">eg. Discussion Room</span></td>
        </tr>
        <tr valign="top">
            <td><b><fmt:message key="group.chat.bookmark.address" />:</b></td>
            <td colspan="3"><input type="text" name="groupchatJID" size="40" value="<%= groupchatJID %>"/><br/>
                <% if (errors.get("groupchatJID") != null) { %>
                <span class="jive-error-text"><%= errors.get("groupchatJID")%><br/></span>
                <% } %>
                <span class="jive-description">eg. myroom@conference.example.com</span></td>
        </tr>

        <tr valign="top">
            <td><b><fmt:message key="users" />:</b></td>
            <td><input type="text" name="users" size="30" value="<%= users%>"/><br/>
                <span class="jive-error-text"></span></td>
            <!--
            <td><img src="images/icon_browse_14x13.gif"/></td><td><a href="javascript:showPicker();"><fmt:message key="bookmark.browse.users" /></a></td>-->
            <td><input type="checkbox" name="all" <%= allUsers ? "checked" : "" %> onclick="toggleAllElement(this, document.f.users, document.f.groups);"/><fmt:message key="bookmark.create.all.users" /></td>
        </tr>

        <tr valign="top">
            <td><b><fmt:message key="groups" />:</b></td>
            <td><input type="text" name="groups" size="30" value="<%= groups %>"/><br/><span
                class="jive-error-text"></span></td>
            <!--
            <td><img src="images/icon_browse_14x13.gif"/></td><td><a href="javascript:showPicker();"><fmt:message key="bookmark.browse.groups" /></a></td>-->
        </tr>
        <tr>
            <td><b><fmt:message key="group.chat.bookmark.autojoin" />:</b></td><td><input type="checkbox" name="autojoin" <%= autojoin ? "checked" : "" %>/></td>
        </tr>
        <tr>
            <td><b><fmt:message key="group.chat.bookmark.nameasnick" />:</b></td><td><input type="checkbox" name="nameasnick" <%= nameAsNick ? "checked" : "" %>/></td>
        </tr>
        <tr>
            <input type="hidden" name="avatarUri" value=""/>        
            <td><b><fmt:message key="group.chat.bookmark.icon" />:</b></td><td><input onchange="doicon()" name='uploadAvatar' id='uploadAvatar' type='file' name='files[]'> </td>
        </tr>        
        <tr>
            <td></td>
            <td><input type="submit" name="createGroupchatBookmark"  value="<%= editBookmark != null ? LocaleUtils.getLocalizedString("bookmark.save.changes", "bookmarks") : LocaleUtils.getLocalizedString("create", "bookmarks")  %>"/>&nbsp;
                <input type="button" value="Cancel" onclick="window.location.href='groupchat-bookmarks.jsp'; return false;">
            </td>
        </tr>

    </table>
    <input type="hidden" name="type" value="groupchat"/>
    <% if (editBookmark != null) { %>
    <input type="hidden" name="bookmarkID" value="<%= editBookmark.getBookmarkID()%>"/>
    <input type="hidden" name="edit" value="true" />
    <% } %>

<script type="text/javascript">
    validateForms(document.f);
</script>
</form>

<% } %>
<% if (editBookmark != null) { %>
<form name="propForm" id="propForm" action="create-bookmark.jsp" method="post">
    <input type="hidden" name="type" value="<%= groupchatType ? "groupchat" : "url" %>"/>    
    <input type="hidden" name="property" value="set"/>
    <input type="hidden" name="edit" value="true" />
    <input type="hidden" name="bookmarkID" value="<%= editBookmark.getBookmarkID()%>"/>    
    <div class="jive-table">
        <table cellspacing="0" width="100%">
            <th><fmt:message key="property.property.name"/></th>
            <th><fmt:message key="property.property.value"/></th>
            <th><fmt:message key="property.edit"/></th>
            <th><fmt:message key="property.delete"/></th>            
            <%
                Iterator<String> itr = editBookmark.getPropertyNames();
                while (itr.hasNext()) {
                    String propName = itr.next();
                    String propValue = editBookmark.getProperty(propName);
                    String formatValue = propValue;
                    
                    if (propValue.startsWith("data:"))  formatValue = "<img src='" + propValue + "' />";
                    if (propName.contains("password")) formatValue = "*************";
            %>
            <tr>
                <td><%=propName%></td>
                <td><%=formatValue%></td>
                <td><img src="/images/edit-16x16.gif" border="0" width="16" 
                    height="16" alt="Edit Property" onclick="doedit('<%=propName%>', '<%=propValue%>')"></td>
                <td><img src="/images/delete-16x16.gif" border="0" width="16"
                    height="16" alt="Delete Property" onclick="dodelete('<%=propName%>')"></td>
            </tr>

            <%
                }
            %>
        </table>
    </div>
    <div class="jive-table">
        <table cellpadding="0" cellspacing="0" border="0" width="100%">
            <thead>
                <tr>
                    <th colspan="2"><fmt:message key="property.edit.property"/></th>
                </tr>
            </thead>
            <tbody>
                <tr valign="top">
                    <td><fmt:message key="property.property.name"/>:</td>
                    <td><input type="textfield" id="propName" name="propName"
                        value=""></td>
                </tr>
                <tr valign="top">
                    <td><fmt:message key="property.property.value"/>:</td>
                    <td><textarea cols="45" rows="5" id="propValue" name="propValue" style="z-index: auto; position: relative; line-height: normal; font-size: 13.3333px; transition: none; background: transparent !important;"></textarea>
                    </td>
                </tr>

            </tbody>
            <tfoot>
                <tr>
                    <td colspan="2"><input type="submit" value="Save" /></td>
                </tr>
            </tfoot>
        </table>
    </div>
</form>
<% } %>
</body>
</html>

<%!
    /**
     * A more elegant string representing all users that this bookmark
     * "belongs" to.
     *
     * @return the string.
     */
    public String getCommaDelimitedList(Collection<String> strings) {
        StringBuilder buf = new StringBuilder();
        for (String string : strings) {
            buf.append(string);
            buf.append(",");
        }

        String returnStr = buf.toString();
        if (returnStr.endsWith(",")) {
            returnStr = returnStr.substring(0, returnStr.length() - 1);
        }


        return returnStr;
    }

%>

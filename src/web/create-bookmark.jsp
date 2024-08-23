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
<%@ page import="org.jivesoftware.util.NotFoundException"%>
<%@ page import="org.jivesoftware.util.LocaleUtils"%>
<%@ page import="org.slf4j.LoggerFactory" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<%
    boolean isUrlType = false;
    boolean isGroupchatType = false;
    String propertyAction = request.getParameter("property");
    String type = request.getParameter("type");
    
    if ("url".equals(type)) {
        isUrlType = true;
    }
    else {
        isGroupchatType = true;
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
            
                if (isUrlType) {
                    response.sendRedirect("url-bookmarks.jsp");
                }
                else if (isGroupchatType) {
                    response.sendRedirect("groupchat-bookmarks.jsp");
                }
                return;                
            }            
        }
        catch (NotFoundException e) {
            Log.error(e);
        }
    }

    Map<String,String> errors = new HashMap<>();
    String groupchatName = request.getParameter("groupchatName");
    String groupchatJID = request.getParameter("groupchatJID");  

    boolean isAutojoin = ParamUtils.getBooleanParameter(request,"autojoin");
    boolean isNameAsNick = ParamUtils.getBooleanParameter(request,"nameasnick");
    String avatarUri = request.getParameter("avatarUri");      

    String users = request.getParameter("users");
    String groups = request.getParameter("groups");


    String url = request.getParameter("url");
    String urlName = request.getParameter("urlName");

    boolean isRSS = ParamUtils.getBooleanParameter(request, "rss", false);
    boolean isWebApp = ParamUtils.getBooleanParameter(request, "webapp", false);
    boolean isCollabApp = ParamUtils.getBooleanParameter(request, "collabapp", false);
    boolean isHomePage = ParamUtils.getBooleanParameter(request, "homepage", false);   

    boolean isAllUsers = ParamUtils.getBooleanParameter(request,"all");

    boolean isCreateGroupchat = request.getParameter("createGroupchatBookmark") != null;
    boolean isCreateURLBookmark = request.getParameter("createURLBookmark") != null;


    boolean isSubmit = false;
    if (isCreateGroupchat || isCreateURLBookmark) {
        isSubmit = true;
    }

    if (isSubmit && isCreateURLBookmark) {
        if (url == null || url.trim().isEmpty()) {
            errors.put("url", LocaleUtils.getLocalizedString("bookmark.url.error", "bookmarks"));
        }

        if (urlName == null || urlName.trim().isEmpty()) {
            errors.put("urlName", LocaleUtils.getLocalizedString("bookmark.urlName.error", "bookmarks"));
        }
    }
    else if (isSubmit && isCreateGroupchat) {
        if (groupchatName == null ||groupchatName.trim().isEmpty()) {
            errors.put("groupchatName", LocaleUtils.getLocalizedString("bookmark.groupchat.name.error", "bookmarks"));
        }

        if (groupchatJID == null || !groupchatJID.contains("@")) {
            errors.put("groupchatJID", LocaleUtils.getLocalizedString("bookmark.groupchat.address.error", "bookmarks"));
        }
    }

    if (!isSubmit && errors.isEmpty()) {
        if (editBookmark != null) {
            if (editBookmark.getType() == Bookmark.Type.url) {
                url = editBookmark.getProperty("url");
                urlName = editBookmark.getName();
            }
            else {
                groupchatName = editBookmark.getName();
                isAutojoin = editBookmark.getProperty("autojoin") != null;
                isNameAsNick = editBookmark.getProperty("nameasnick") != null;
                groupchatJID = editBookmark.getValue();
            }

            users = getCommaDelimitedList(editBookmark.getUsers());
            groups = getCommaDelimitedList(editBookmark.getGroups());
            isAllUsers = editBookmark.isGlobalBookmark();
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
        if ((isCreateURLBookmark || isCreateGroupchat) && errors.isEmpty()) {
            Bookmark bookmark = null;

            if (bookmarkID == null) {
                if (isCreateURLBookmark)
                    bookmark = new Bookmark(Bookmark.Type.url, urlName, url);

                if (isCreateGroupchat) {
                    bookmark = new Bookmark(Bookmark.Type.group_chat, groupchatName, groupchatJID);
                }
            }
            else {
                try {
                    bookmark = new Bookmark(Long.parseLong(bookmarkID));
                    if (isCreateURLBookmark) {
                        bookmark.setName(urlName);
                        bookmark.setValue(url);
                    }
                    else {
                        bookmark.setName(groupchatName);
                        bookmark.setValue(groupchatJID);
                    }
                }
                catch (NotFoundException e) {
                    LoggerFactory.getLogger("create-bookmarks.jsp").error("Bookmark not found: {}", bookmarkID, e);
                }
            }

            List<String> userCollection = new ArrayList<>();
            List<String> groupCollection = new ArrayList<>();
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

            if (isAllUsers) {
                bookmark.setGlobalBookmark(true);
            }
            else {
                bookmark.setGlobalBookmark(false);
            }

            if (isCreateURLBookmark) {
                if (url != null) {
                    bookmark.setProperty("url", url);
                }

                if (isRSS) bookmark.setProperty("rss", "true"); else bookmark.deleteProperty("rss");
                if (isWebApp) bookmark.setProperty("webapp", "true"); else bookmark.deleteProperty("webapp");
                if (isCollabApp) bookmark.setProperty("collabapp", "true"); else bookmark.deleteProperty("collabapp");
                if (isHomePage) bookmark.setProperty("homepage", "true"); else bookmark.deleteProperty("homepage");                

            }
            else {
                if (isAutojoin) {
                    bookmark.setProperty("autojoin", "true");
                }
                    else {
                    bookmark.deleteProperty("autojoin");
                }
                if (isNameAsNick) {
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

    if (isSubmit && errors.isEmpty()) {
        if (isCreateURLBookmark) {
            response.sendRedirect("url-bookmarks.jsp?urlCreated=true");
            return;
        }
        else if (isCreateGroupchat) {
            response.sendRedirect("groupchat-bookmarks.jsp?groupchatCreated=true");
        }
    }

    String description = LocaleUtils.getLocalizedString("bookmark.url.create.description", "bookmarks");
    if (isGroupchatType) {
        description = LocaleUtils.getLocalizedString("bookmark.groupchat.create.description", "bookmarks");
        if(edit){
            description = LocaleUtils.getLocalizedString("bookmark.groupchat.edit.description", "bookmarks");
        }
    }
    else if(edit){
        description = LocaleUtils.getLocalizedString("bookmark.url.edit.description", "bookmarks");
    }

    pageContext.setAttribute("editBookmark", editBookmark);
    pageContext.setAttribute("bookmarkType", isGroupchatType ? Bookmark.Type.group_chat.name() : Bookmark.Type.url.name());
    pageContext.setAttribute("description", description);
    pageContext.setAttribute("url", url);
    pageContext.setAttribute("urlName", urlName);
    pageContext.setAttribute("errors", errors);
    pageContext.setAttribute("isCreateURLBookmark", isCreateURLBookmark);
    pageContext.setAttribute("isSubmit", isSubmit);
    pageContext.setAttribute("isAllUsers", isAllUsers);
    pageContext.setAttribute("isAutojoin", isAutojoin);
    pageContext.setAttribute("isNameAsNick", isNameAsNick);
    pageContext.setAttribute("isRSS", isRSS);
    pageContext.setAttribute("isWebApp", isWebApp);
    pageContext.setAttribute("isCollabApp", isCollabApp);
    pageContext.setAttribute("isHomePage", isHomePage);
    pageContext.setAttribute("users", users);
    pageContext.setAttribute("groups", groups);
    pageContext.setAttribute("groupchatName", groupchatName);
    pageContext.setAttribute("groupchatJID", groupchatJID);
%>
<html>
<head>
    <title><c:choose>
        <c:when test="${not empty editBookmark}">
            <fmt:message key="bookmark.edit"/>
        </c:when>
        <c:otherwise>
            <fmt:message key="bookmark.create"/>
        </c:otherwise>
    </c:choose></title>
    <meta name="pageID" content="${bookmarkType eq 'group_chat' ? 'groupchat-bookmarks' : 'url-bookmarks'}"/>
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
    <c:out value="${description}"/>
</p>


<c:if test="${isSubmit and empty errors and isCreateURLBookmark}">
    <div class="success">
        <fmt:message key="bookmark.created" />
    </div>
</c:if>

<c:choose>
    <c:when test="${bookmarkType eq 'url'}">
        <form id="urlForm" name="urlForm" action="create-bookmark.jsp" method="post">
            <table class="div-border" cellpadding="3">
                <tr valign="top">
                    <td><b><label for="urlName"><fmt:message key="bookmark.url.name" />:</label></b></td>
                    <td><input type="text" name="urlName" id="urlName" size="30" value="<c:out value="${urlName}"/>"/><br/>
                        <c:if test="${not empty errors['urlName']}">
                            <span class="jive-error-text"><c:out value="${errors['urlName']}"/><br/></span>
                        </c:if>
                        <span class="jive-description"><fmt:message key="bookmark.url.name.description" /></span></td>
                </tr>
                <tr valign="top">
                    <td><b><label for="url"><fmt:message key="bookmark.url" />:</label></b></td>
                    <td><input type="text" name="url" id="url" size="30" value="<c:out value="${url}"/>"/><br/>
                        <c:if test="${not empty errors['url']}">
                            <span class="jive-error-text"><c:out value="${errors['url']}"/><br/></span>
                        </c:if>
                        <span class="jive-description">eg. http://www.acme.com</span></td>
                </tr>
                <tr valign="top">
                    <td><b><label for="users"><fmt:message key="users" />:</label></b></td>
                    <td><input type="text" name="users" id="users" size="30" value="<c:out value="${users}"/>"/><br/>
                        <span class="jive-error-text"></span></td>
                    <!--
                    <td><img src="images/icon_browse_14x13.gif"/></td><td><a href="javascript:showPicker();"><fmt:message key="bookmark.browse.users" /></a></td>-->
                    <td><input type="checkbox" id="all" name="all" ${isAllUsers ? 'checked' : ''} onclick="toggleAllElement(this, document.urlForm.users, document.urlForm.groups);"/><label for="all">All Users</label></td>
                </tr>

                <tr valign="top">
                    <td><b><label for="groups"><fmt:message key="groups" />:</label></b></td>
                    <td><input type="text" name="groups" id="groups" size="30" value="<c:out value="${groups}"/>"/><br/><span
                        class="jive-error-text"></span></td><!--
                    <td><img src="images/icon_browse_14x13.gif"/></td><td><a href="javascript:showPicker();"><fmt:message key="bookmark.browse.groups" /></a></td>-->
                </tr>
                <c:if test="${not empty errors['noUsersOrGroups']}">
                    <tr>
                        <td colspan="2" class="jive-error-text"><fmt:message key="bookmark.users.groups.error" /></td>
                    </tr>
                </c:if>
                <tr><td><b><label for="rss"><fmt:message key="bookmark.create.rss.feed" /></label></b></td><td><input type="checkbox" name="rss" id="rss" ${isRSS ? 'checked' : ''}/></td></tr>
                <tr><td><b><label for="webapp"><fmt:message key="bookmark.create.web.app" /></label></b></td><td><input type="checkbox" name="webapp" id="webapp" ${isWebApp ? 'checked' : ''}/></td></tr>
                <tr><td><b><label for="collabapp"><fmt:message key="bookmark.create.collab.app" /></label></b></td><td><input type="checkbox" name="collabapp" id="collabapp" ${isCollabApp ? 'checked' : ''}/></td></tr>
                <tr><td><b><label for="homepage"><fmt:message key="bookmark.create.home.page" /></label></b></td><td><input type="checkbox" name="homepage" id="homepage" ${isHomePage ? 'checked' : ''}/></td></tr>

                <tr><td></td><td>
                    <c:choose>
                        <c:when test="${not empty editBookmark}">
                            <c:set var="buttonLabel"><fmt:message key="bookmark.save.changes"/></c:set>
                        </c:when>
                        <c:otherwise>
                            <c:set var="buttonLabel"><fmt:message key="create"/></c:set>
                        </c:otherwise>
                    </c:choose>
                    <input type="submit" name="createURLBookmark" value="<c:out value="${buttonLabel}"/>"/>
                    &nbsp;<input type="button" value="<fmt:message key="cancel" />"
                                 onclick="window.location.href='url-bookmarks.jsp'; return false;">
                </td>
                </tr>

            </table>
            <input type="hidden" name="type" value="url"/>
            <c:if test="${not empty editBookmark}">
                <input type="hidden" name="bookmarkID" value="<c:out value="${editBookmark.bookmarkID}"/>"/>
                <input type="hidden" name="edit" value="true" />
            </c:if>

        <script type="text/javascript">
           validateForms(document.urlForm);
        </script>
        </form>

    </c:when>
    <c:when test="${bookmarkType eq 'group_chat'}">

        <form name="f" id="f" action="create-bookmark.jsp" method="post">

            <table class="div-border" cellpadding="3">
                <tr valign="top">
                    <td><b><label for="groupchatName"><fmt:message key="group.chat.bookmark.name" />:</label></b></td>
                    <td colspan="3"><input type="text" name="groupchatName" id="groupchatName" size="40" value="<c:out value="${groupchatName}"/>"/><br/>
                        <c:if test="${not empty errors['groupchatName']}">
                            <span class="jive-error-text"><c:out value="${errors['groupchatName']}"/><br/></span>
                        </c:if>
                        <span class="jive-description">eg. Discussion Room</span></td>
                </tr>
                <tr valign="top">
                    <td><b><label for="groupchatJID"><fmt:message key="group.chat.bookmark.address" />:</label></b></td>
                    <td colspan="3"><input type="text" name="groupchatJID" id="groupchatJID" size="40" value="<c:out value="${groupchatJID}"/>"/><br/>
                        <c:if test="${not empty errors['groupchatJID']}">
                            <span class="jive-error-text"><c:out value="${errors['groupchatJID']}"/><br/></span>
                        </c:if>
                        <span class="jive-description">eg. myroom@conference.example.com</span></td>
                </tr>

                <tr valign="top">
                    <td><b><label for="grusers"><fmt:message key="users" />:</label></b></td>
                    <td><input type="text" name="users" id="grusers" size="30" value="<c:out value="${users}"/>"><br/>
                        <span class="jive-error-text"></span></td>
                    <!--
                    <td><img src="images/icon_browse_14x13.gif"/></td><td><a href="javascript:showPicker();"><fmt:message key="bookmark.browse.users" /></a></td>-->
                    <td><input type="checkbox" name="all" id="grall" ${isAllUsers ? 'checked' : ''} onclick="toggleAllElement(this, document.f.users, document.f.groups);"/><label for="grall"><fmt:message key="bookmark.create.all.users" /></label></td>
                </tr>

                <tr valign="top">
                    <td><b><label for="grgroups"><fmt:message key="groups" />:</label></b></td>
                    <td><input type="text" name="groups" id="grgroups" size="30" value="<c:out value="${groups}"/>"/><br/><span
                        class="jive-error-text"></span></td>
                    <!--
                    <td><img src="images/icon_browse_14x13.gif"/></td><td><a href="javascript:showPicker();"><fmt:message key="bookmark.browse.groups" /></a></td>-->
                </tr>
                <tr>
                    <td><b><label for="autojoin"><fmt:message key="group.chat.bookmark.autojoin" />:</label></b></td><td><input type="checkbox" name="autojoin" id="autojoin" ${isAutojoin ? 'checked' : ''}/></td>
                </tr>
                <tr>
                    <td><b><label for="nameasnick"><fmt:message key="group.chat.bookmark.nameasnick" />:</label></b></td><td><input type="checkbox" name="nameasnick" id="nameasnick" ${isNameAsNick ? 'checked' : ''}/></td>
                </tr>
                <tr>
                    <input type="hidden" name="avatarUri" value=""/>
                    <td><b><fmt:message key="group.chat.bookmark.icon" />:</b></td><td><input onchange="doicon()" name='uploadAvatar' id='uploadAvatar' type='file' name='files[]'> </td>
                </tr>
                <tr>
                    <td></td>
                    <td><c:choose>
                            <c:when test="${not empty editBookmark}">
                                <c:set var="buttonLabel"><fmt:message key="bookmark.save.changes"/></c:set>
                            </c:when>
                            <c:otherwise>
                                <c:set var="buttonLabel"><fmt:message key="create"/></c:set>
                            </c:otherwise>
                        </c:choose>
                        <input type="submit" name="createGroupchatBookmark" value="<c:out value="${buttonLabel}"/>"/>
                        <input type="button" value="Cancel" onclick="window.location.href='groupchat-bookmarks.jsp'; return false;">
                    </td>
                </tr>

            </table>
            <input type="hidden" name="type" value="groupchat"/>
            <c:if test="${not empty editBookmark}">
                <input type="hidden" name="bookmarkID" value="<c:out value="${editBookmark.bookmarkID}"/>"/>
                <input type="hidden" name="edit" value="true" />
            </c:if>

        <script type="text/javascript">
            validateForms(document.f);
        </script>
        </form>

    </c:when>
</c:choose>

<c:if test="${not empty editBookmark}">
    <form name="propForm" id="propForm" action="create-bookmark.jsp" method="post">
        <input type="hidden" name="type" value="<c:out value="${bookmarkType eq 'group_chat' ? 'groupchat' : 'url'}"/>"/>
        <input type="hidden" name="property" value="set"/>
        <input type="hidden" name="edit" value="true" />
        <input type="hidden" name="bookmarkID" value="<c:out value="${editBookmark.bookmarkID}"/>"/>
        <div class="jive-table">
            <table cellspacing="0" width="100%">
                <th><fmt:message key="property.property.name"/></th>
                <th><fmt:message key="property.property.value"/></th>
                <th><fmt:message key="property.edit"/></th>
                <th><fmt:message key="property.delete"/></th>
                <c:forEach items="${editBookmark.properties}" var="propEntry" varStatus="status">
                    <tr>
                        <td><c:out value="${propEntry.key}"/></td>
                        <td><c:choose>
                            <c:when test="${propEntry.key.contains('password')}">*************</c:when>
                            <c:when test="${propEntry.value.startsWith('data:')}"><img src="<c:out value="${propEntry.value}"/>"/></c:when>
                            <c:otherwise><c:out value="${propEntry.value}"/></c:otherwise>
                        </c:choose></td>
                        <td><img src="/images/edit-16x16.gif" border="0" width="16"
                                 height="16" alt="Edit Property" onclick="doedit('<c:out value="${propEntry.key}"/>', '<c:out value="${propEntry.value}"/>')"></td>
                        <td><img src="/images/delete-16x16.gif" border="0" width="16"
                                 height="16" alt="Delete Property" onclick="dodelete('<c:out value="${propEntry.key}"/>')"></td>
                    </tr>
                </c:forEach>
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
                        <td><input id="propName" name="propName" value=""></td>
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
</c:if>
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

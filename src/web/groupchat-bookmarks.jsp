<%@ page contentType="text/html; charset=UTF-8" %>
<%@ page import="org.jivesoftware.openfire.plugin.spark.Bookmark" %>
<%@ page import="org.jivesoftware.openfire.plugin.spark.BookmarkManager" %>
<%@ page import="java.util.Collection"%>
<%@ page import="java.util.stream.Collectors" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<%
    boolean bookmarkCreated = request.getParameter("bookmarkCreated") != null;

    boolean delete = request.getParameter("delete") != null;
    final Collection<Bookmark> bookmarks = BookmarkManager.getBookmarks().stream().filter(bookmark -> bookmark.getType()==Bookmark.Type.group_chat).collect(Collectors.toList());
    pageContext.setAttribute("bookmarkCreated", bookmarkCreated);
    pageContext.setAttribute("delete", delete);
    pageContext.setAttribute("bookmarks", bookmarks);
%>
<html>
<head>
    <title><fmt:message key="group.chat.bookmark.title" /></title>
    <meta name="pageID" content="groupchat-bookmarks"/>
    <style type="text/css">
        .div-border {
            border: 1px solid #CCCCCC;
            -moz-border-radius: 3px;
        }
    </style>
</head>

<body>

<p>
    <fmt:message key="group.chat.bookmark.description" />
</p>

<c:if test="${bookmarkCreated}">
    <div class="success">
        <fmt:message key="group.chat.bookmark.created" />
    </div>
</c:if>

<c:if test="${delete}">
    <div class="success">
         <fmt:message key="group.chat.bookmark.removed" />
    </div>
</c:if>

<br/>

    <div class="div-border" style="padding: 12px; width: 95%;">
        <table class="jive-table" cellspacing="0" width="100%">
            <th><fmt:message key="group.chat.bookmark.name" /></th><th><fmt:message key="group.chat.bookmark.address"/></th><th><fmt:message key="group.chat.bookmark.icon" /></th><th><fmt:message key="users" /></th><th><fmt:message key="groups" /></th><th><fmt:message key="group.chat.bookmark.autojoin" /></th><th><fmt:message key="group.chat.bookmark.nameasnick" /></th><th><fmt:message key="options" /></th>
            <c:choose>
                <c:when test="${empty bookmarks}">
                    <tr>
                        <td colspan="8" align="center"><fmt:message key="group.chat.bookmark.none" /></td>
                    </tr>
                </c:when>
                <c:otherwise>
                    <c:forEach items="${bookmarks}" var="bookmark">
                        <tr style="border-left: none;">
                            <td><c:out value="${bookmark.name}"/></td>
                            <td><c:out value="${bookmark.value}"/></td>
                            <td><c:if test="${not empty bookmark.avatarUri}"><img width='16' src='<c:out value="${bookmark.avatarUri}"/>'></c:if></td>
                            <td><c:choose><c:when test="${bookmark.globalBookmark}">All</c:when><c:otherwise><fmt:formatNumber value="${bookmark.users.size()}"/> <fmt:message key="group.chat.bookmark.users"/></c:otherwise></c:choose></td>
                            <td><c:choose><c:when test="${bookmark.globalBookmark}">All</c:when><c:otherwise><fmt:formatNumber value="${bookmark.groups.size()}"/> <fmt:message key="group.chat.bookmark.groups"/></c:otherwise></c:choose></td>
                            <td><c:if test="${bookmark.autojoin}"><img alt="<fmt:message key="group.chat.bookmark.autojoin" />" src='/images/check.gif'></c:if></td>
                            <td><c:if test="${bookmark.nameAsNick}"><img alt="<fmt:message key="group.chat.bookmark.nameasnick" />" src='/images/check.gif'></c:if></td>
                            <td>
                                <a href="create-bookmark.jsp?edit=true&bookmarkID=<c:out value="${bookmark.bookmarkID}"/>"><img src="/images/edit-16x16.gif" border="0" width="16" height="16" alt="Edit Bookmark"/></a>
                                <a href="confirm-bookmark-delete.jsp?bookmarkID=<c:out value="${bookmark.bookmarkID}"/>"><img src="/images/delete-16x16.gif" border="0" width="16" height="16" alt="Delete Bookmark"/></a>
                            </td>
                        </tr>
                    </c:forEach>
                </c:otherwise>
            </c:choose>
            <tr>
                <td colspan="8">
                    <a href="create-bookmark.jsp?type=group_chat"><img src="/images/add-16x16.gif" border="0" align="texttop" style="margin-right: 3px;"/><fmt:message key="group.chat.bookmark.add" /></a>
                </td>
            </tr>
        </table>
    </div>

</body>
</html>

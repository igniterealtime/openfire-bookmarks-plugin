<%@ page contentType="text/html; charset=UTF-8" %>
<%@ page errorPage="/error.jsp" %>
<%@ page import="org.jivesoftware.openfire.plugin.spark.Bookmark" %>
<%@ page import="org.jivesoftware.openfire.plugin.spark.BookmarkManager" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<%
    String bookmarkID = request.getParameter("bookmarkID");

    Bookmark bookmark = new Bookmark(Long.parseLong(bookmarkID));

    boolean delete = request.getParameter("delete") != null;

    if (delete && bookmarkID != null) {
        BookmarkManager.deleteBookmark(Long.parseLong(bookmarkID));

        if(bookmark.getType() == Bookmark.Type.group_chat){
            response.sendRedirect("groupchat-bookmarks.jsp?delete=true");
        }
        else {
            response.sendRedirect("url-bookmarks.jsp?delete=true");
        }
        return;
    }

    pageContext.setAttribute("bookmark", bookmark);
%>
<html>
<head>
    <title><fmt:message key="bookmark.delete.confirm" /></title>
    <meta name="pageID" content="${bookmark.type.name() eq 'group_chat' ? "groupchat-bookmarks" : "url-bookmarks"}"/>
    <style type="text/css">
        .field-text {
            font-size: 12px;
            font-family: verdana;
        }

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
    <fmt:message key="bookmark.delete.confirm.prompt" />
</p>


<c:choose>
    <c:when test="${bookmark.type eq 'url'}">
        <form name="urlForm" action="confirm-bookmark-delete.jsp" method="post">
            <table class="div-border">
                <tr valign="top">
                    <td><b><fmt:message key="bookmark.delete.url.urlname" /></b></td>
                    <td><c:out value="${bookmark.name}"/></td>
                </tr>
                <tr valign="top">
                    <td><b><fmt:message key="bookmark.delete.url.url" /></b></td>
                    <td><c:out value="${bookmark.value}"/></td>
                </tr>
                <tr valign="top">
                    <td><b><fmt:message key="bookmark.delete.url.users" /></b></td>
                    <td>
                        <c:choose>
                            <c:when test="${bookmark.globalBookmark}">
                                ALL
                            </c:when>
                            <c:otherwise>
                                <c:forEach items="${bookmark.users}" var="user" varStatus="status">
                                    <c:out value="${user}"/><c:if test="${not status.last}">, </c:if>
                                </c:forEach>
                            </c:otherwise>
                        </c:choose>
                    </td>
                </tr>
                <tr valign="top">
                    <td><b><fmt:message key="bookmark.delete.url.groups" /></b></td>
                    <td>
                        <c:choose>
                            <c:when test="${bookmark.globalBookmark}">
                                ALL
                            </c:when>
                            <c:otherwise>
                                <c:forEach items="${bookmark.groups}" var="group" varStatus="status">
                                    <c:out value="${group}"/><c:if test="${not status.last}">, </c:if>
                                </c:forEach>
                            </c:otherwise>
                        </c:choose>
                    </td>
                </tr>
                <tr><td></td>
                    <td>
                        <input type="submit" name="delete" value="<fmt:message key="bookmark.delete.url.submit" />"/>&nbsp;
                        <input type="button" value="<fmt:message key="bookmark.delete.url.cancel" />"
                               onclick="window.location.href='url-bookmarks.jsp'; return false;">
                    </td>
                </tr>

            </table>
            <input type="hidden" name="bookmarkID" value="${bookmark.bookmarkID}"/>
        </form>
    </c:when>
    <c:when test="${bookmark.type.name() eq 'group_chat'}">
        <form name="f" action="confirm-bookmark-delete.jsp" method="post">

            <table class="div-border" width="50%">
                <tr valign="top">
                    <td><b><fmt:message key="bookmark.delete.chat.groupname" /></b></td>
                    <td class="field-text"><c:out value="${bookmark.name}"/></td>
                </tr>
                <tr valign="top">
                    <td><b><fmt:message key="bookmark.delete.chat.address" /></b></td>
                    <td class="field-text"><c:out value="${bookmark.value}"/></td>
                </tr>
                <tr valign="top">
                    <td><b><fmt:message key="bookmark.delete.chat.users" /></b></td>
                    <td class="field-text">
                        <c:choose>
                            <c:when test="${bookmark.globalBookmark}">
                                ALL
                            </c:when>
                            <c:otherwise>
                                <c:forEach items="${bookmark.users}" var="user" varStatus="status">
                                    <c:out value="${user}"/><c:if test="${not status.last}">, </c:if>
                                </c:forEach>
                            </c:otherwise>
                        </c:choose>
                    </td>
                </tr>

                <tr valign="top">
                    <td><b><fmt:message key="bookmark.delete.chat.groups" /></b></td>
                    <td class="field-text">
                        <c:choose>
                            <c:when test="${bookmark.globalBookmark}">
                                ALL
                            </c:when>
                            <c:otherwise>
                                <c:forEach items="${bookmark.groups}" var="group" varStatus="status">
                                    <c:out value="${group}"/><c:if test="${not status.last}">, </c:if>
                                </c:forEach>
                            </c:otherwise>
                        </c:choose>
                    </td>
                </tr>
                <tr>
                    <td><b><fmt:message key="bookmark.delete.chat.autojoin" /></b></td>
                    <td><c:if test="${bookmark.autojoin}"><img src='/images/check.gif'></c:if></td>
                </tr>
                <tr>
                    <td><b><fmt:message key="bookmark.delete.chat.nameasnick" /></b></td>
                    <td><c:if test="${bookmark.nameAsNick}"><img src='/images/check.gif'></c:if></td>
                </tr>
                <tr>
                    <td></td>
                    <td>
                        <input type="submit" name="delete" value="<fmt:message key="bookmark.delete.chat.submit" />">
                        <input type="button" value="<fmt:message key="bookmark.delete.chat.cancel" />"
                               onclick="window.location.href='groupchat-bookmarks.jsp'; return false;">
                </td>
                </tr>

            </table>
            <input type="hidden" name="bookmarkID" value="${bookmark.bookmarkID}"/>
        </form>
    </c:when>
</c:choose>
</body>
</html>

<%@page import="com.liferay.portal.kernel.exception.SystemException"%>
<%@page import="com.liferay.portal.kernel.util.PrefsPropsUtil"%>
<%@page import="com.liferay.lms.util.LmsConstant"%>
<%@page import="java.util.HashSet"%>
<%@page import="java.util.Set"%>
<%@page import="java.util.Collections"%>
<%@page import="com.liferay.lms.learningactivity.calificationtype.CalificationType"%>
<%@page import="com.liferay.lms.learningactivity.calificationtype.CalificationTypeRegistry"%>
<%@page import="com.liferay.lms.learningactivity.courseeval.CourseEval"%>
<%@page import="com.liferay.lms.learningactivity.courseeval.CourseEvalRegistry"%>
<%@page import="java.util.Map"%>
<%@page import="java.util.HashMap"%>
<%@page import="com.liferay.portal.kernel.util.ArrayUtil"%>
<%@page import="com.liferay.portal.kernel.util.ListUtil"%>
<%@page import="com.liferay.lms.learningactivity.LearningActivityType"%>
<%@page import="com.liferay.lms.learningactivity.LearningActivityTypeRegistry"%>
<%@page import="com.liferay.portal.model.LayoutSetPrototype"%>
<%@page import="com.liferay.portal.service.LayoutSetPrototypeLocalServiceUtil"%>
<%@page import="com.liferay.portal.service.LayoutSetPrototypeServiceUtil"%>
<%@page import="org.apache.commons.lang.ArrayUtils"%>
<%@page import="com.liferay.portal.service.RoleLocalServiceUtil"%>
<%@page import="com.liferay.portal.model.Role"%>
<%@page import="com.liferay.lms.service.LmsPrefsLocalServiceUtil"%>
<%@page import="com.liferay.lms.model.LmsPrefs"%>
<%@ include file="/init.jsp"%>
<%
LmsPrefs prefs=LmsPrefsLocalServiceUtil.getLmsPrefsIni(themeDisplay.getCompanyId());
if(prefs!=null){
	long editorRoleId=prefs.getEditorRole();
	Role editor=RoleLocalServiceUtil.getRole(editorRoleId);
	long teacherRoleId=prefs.getTeacherRole();
	Role teacher=RoleLocalServiceUtil.getRole(teacherRoleId);
	boolean linkResources = false;
	try {
		linkResources = PrefsPropsUtil.getBoolean(themeDisplay.getCompanyId(), LmsConstant.RESOURCE_INTERNAL_DOCUMENT_LINKED);
	} catch (SystemException e) {
		e.printStackTrace();
	}			
	List<Long> layoutSetTemplateIds = ListUtil.toList(StringUtil.split(prefs.getLmsTemplates(),",",0L));
	List<Long> activityids = ListUtil.toList(StringUtil.split(prefs.getActivities(), ",", 0L));
	List<Long> courseEvalIds = ListUtil.toList(StringUtil.split(prefs.getCourseevals(),",",0L));
	List <Long> calificationTypeIds = ListUtil.toList(StringUtil.split(prefs.getScoretranslators(),",",0L));	
%>

<liferay-ui:success message="your-request-completed-successfully" key="ok" />
<liferay-ui:success message="lms-configuration.upgrade-ok" key="upgrade-ok" />
<c:if test="${not empty counter}">
	<div class="portlet-msg-success"><liferay-ui:message key="groups-changed" arguments="<%=new String[]{request.getParameter(\"counter\")} %>" /></div>
</c:if>


<liferay-portlet:actionURL name="changeSettings" var="changeSettingsURL"/>

<aui:form action="<%=changeSettingsURL %>" method="POST">
<aui:input type="hidden" name="redirect" value="<%= currentURL %>" />

<liferay-ui:header title="lms-activities"/>
<ul id="lms-sortable-activities-contentor">
<%

LearningActivityTypeRegistry learningActivityTypeRegistry = new LearningActivityTypeRegistry();
List<LearningActivityType> learningActivityTypes = learningActivityTypeRegistry.getLearningActivityTypes();
LearningActivityType [] learningActivityTypesCopy = new LearningActivityType[learningActivityTypes.size()];
Set<Long> learningActivityTypeIds = new HashSet<Long>();
Map<Long, Integer> mapaLats = new HashMap<Long, Integer>();

for (LearningActivityType learningActivityType : learningActivityTypes) {
	learningActivityTypeIds.add(learningActivityType.getTypeId());
}

int index = 0;
for (Long curActId : activityids)
{
	if (learningActivityTypeIds.contains(curActId)) {
		mapaLats.put(curActId, index++);
	}
}

for (LearningActivityType learningActivityType : learningActivityTypes) {
	Integer orderInt = mapaLats.get(learningActivityType.getTypeId());
	if (orderInt != null) {
		learningActivityTypesCopy[orderInt] = learningActivityType;
	} else {
		learningActivityTypesCopy[index++] = learningActivityType;
	}
}

for (LearningActivityType learningActivityType : learningActivityTypesCopy) {
	%>
	<li class="lms-sortable-activities">
		<aui:input type="checkbox" name="activities" label="<%= learningActivityType.getName() %>" checked="<%= (mapaLats.containsKey(learningActivityType.getTypeId())) %>" value="<%= learningActivityType.getTypeId() %>" />
	</li>
	<%
}
%>
</ul>

<liferay-ui:header title="allowed-site-templates" />
<aui:field-wrapper>
<%

for(LayoutSetPrototype layoutsetproto:LayoutSetPrototypeLocalServiceUtil.search(themeDisplay.getCompanyId(),true,0, 1000000,null))
{
	boolean checked=false;
	if(ArrayUtils.contains(layoutSetTemplateIds.toArray(), layoutsetproto.getLayoutSetPrototypeId()))
	{
		checked=true;
	}
	%>
	
	<aui:input type="checkbox" name="lmsTemplates" 
	label="<%=layoutsetproto.getName(themeDisplay.getLocale())  %>" checked="<%=checked %>" value="<%=layoutsetproto.getLayoutSetPrototypeId()%>" />
	<%
}
%>
</aui:field-wrapper>

<liferay-ui:header title="course-correction-method" />
<aui:field-wrapper>
<%
CourseEvalRegistry courseEvalRegistry = new CourseEvalRegistry();
for(CourseEval courseEval:courseEvalRegistry.getCourseEvals())
{
	boolean checked=false;
	String writechecked="false";
	if(courseEvalIds!=null &&courseEvalIds.size()>0 && ArrayUtil.contains(courseEvalIds.toArray(), courseEval.getTypeId()))
	{
		checked=true;
		writechecked="true";
	}
	%>
	
	<aui:input type="checkbox" name="courseEvals" 
	label="<%=courseEval.getName()  %>" checked="<%=checked %>" value="<%=courseEval.getTypeId()%>" />
	<%
}
%>
</aui:field-wrapper>

<liferay-ui:header title="calificationType" />
<aui:field-wrapper>
<%
CalificationTypeRegistry calificationTypeRegistry = new CalificationTypeRegistry();
for(CalificationType calificationType :calificationTypeRegistry.getCalificationTypes())
{
	boolean checked=false;
	String writechecked="false";
	if(calificationTypeIds!=null &&calificationTypeIds.size()>0 && ArrayUtils.contains(calificationTypeIds.toArray(), calificationType.getTypeId()))
	{
		checked=true;
		writechecked="true";
	}
	%>
	
	<aui:input type="checkbox" name="calificationTypes" 
	label="<%=LanguageUtil.get(locale, calificationType.getTitle(locale))  %>" checked="<%=checked %>" value="<%=calificationType.getTypeId()%>" />
	<%
}
%>
</aui:field-wrapper>


<liferay-ui:header title="show-hide-activity" />
<aui:field-wrapper>

	
	<aui:input type="checkbox" name="showHideActivity"
	label="show-hide-activity" checked="<%=prefs.getShowHideActivity()%>" value="<%=prefs.getShowHideActivity()%>" />

</aui:field-wrapper>

<liferay-ui:header title="configuration-courses" />
<aui:field-wrapper>

	<aui:input type="checkbox" name="viewCoursesFinished"
	label="view-courses-finished" checked="<%=prefs.getViewCoursesFinished()%>" value="<%=prefs.getViewCoursesFinished()%>" />
	<aui:input type="checkbox" name="linkResources"
		label="link-internal-resources" checked="<%=linkResources%>" value="<%=linkResources%>" />
</aui:field-wrapper>




<aui:field-wrapper>
	<aui:button type="submit" value="save" />
</aui:field-wrapper>

</aui:form>




<%
}
%>


<script type="text/javascript">
	AUI().ready(
	    'aui-sortable',
	   function(A) {
	        window.<portlet:namespace/>lmsActivitiesSortable = new A.Sortable(
	            {
	                nodes: '.lms-sortable-activities'
	            }
	        );
	    }
	);	
</script>
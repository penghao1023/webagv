<%@ page language="java" %>
<%@ page contentType="text/html;charset=GBK"%>
<%@ page import="com.software.main.*,com.software.main.db.*"%>
<%@ page import="com.software.util.*,com.software.common.*"%>
<%@ page import="org.apache.commons.logging.*"%>
<%@ page import="java.io.*,java.util.*"%>
<%@page import="com.alibaba.fastjson.JSON" %>
<%!
private static Log log = LogFactory.getLog(Tool.class);
%>
<%
log.debug("ListJquery");
StringBuffer str = new StringBuffer();
String keyfield = (String)request.getAttribute("keyfield");
String[] dickeys = (String[])request.getAttribute("dickeys");
String[][] dicvalues = (String[][])request.getAttribute("dicvalues");
String[] fields = (String[])request.getAttribute("fields");
String OperateField = (String)request.getAttribute("OperateField");
List diclist = new ArrayList();
for (int i = 0; i < dickeys.length; i ++) {
    diclist.add("\"" + dickeys[i] + "\": [\"" + Tool.join("\", \"", dicvalues[i]) + "\"]");
}
int currpage = ParamUtils.getIntParameter(request, "page", 1);
Map extMaps = (Map)request.getAttribute("Ext");
List paras = HttpTool.getSavedUrlForm(request, "Ext");
List urls = (List)paras.get(0);
List forms = (List)paras.get(1);
urls.addAll((List)paras.get(2));
String url = Tool.join("&", urls);
PageControl pc = (PageControl)request.getAttribute("PageControl");
//Ĭ��ֵ����
List YesNooptions = (List)request.getAttribute("YesNooptions");
List TaskNameoptions = (List)request.getAttribute("TaskNameoptions");
List CarNameoptions = (List)request.getAttribute("CarNameoptions");
%>
<html>
<head>
<title> <%=request.getAttribute("describe")%> </title>
<jsp:include page="/jqueryinc.jsp">
<jsp:param value="metro-blue" name="style"/>
</jsp:include>
<script type="text/javascript">
var keyfield = "<%=keyfield%>";
var OperateField = "<%=OperateField%>";
var datagrid;
var editRow = undefined;
$(function () {
    $("#dlg").dialog("close");
    initData();
});
 function initData(){
    datagrid = $("#dadagrid").datagrid({
            url: 'CarSchedulingAction.jsp?cmd=json',
            iconCls: 'icon-save',
            pagination: true,
        	 rownumbers: true,
            pageSize: <%=pc.getShownum()%>,
            pageList: [<%=pc.getShownum()%>, <%=pc.getShownum()*2%>, <%=pc.getShownum()*3%>, <%=pc.getShownum()*4%>],
            fit: true,
            fitColumn: false,
            striped: true,
            nowap: true, 
            border: false,
            idField: keyfield,
            columns: [[ 
        <%
        List rows = new ArrayList();
        for(int i=0;i<fields.length;i++){
            	int listFieldIndex = 0;
            	for(int j=0;j<dickeys.length;j++)
            	{
                		if(dickeys[j]==fields[i])
                		{
                    			listFieldIndex = j;
                    			break;
                		}
            	}
            	Map map = new HashMap();
            	map.put("field",dickeys[listFieldIndex]+"");
            	map.put("title",dicvalues[listFieldIndex][1]+"");
            	map.put("sortable","true");
            	map.put("halign","center");
            	if(dickeys[listFieldIndex].equals(keyfield))
            	{
                		map.put("checkbox","true");
            	}
            	rows.add(JSON.toJSONString(map));
        }
        out.print(Tool.join(",\r\n",rows));%>
        ,{
            title:"����",
            field:"<%=OperateField%>",
            halign:"center",
            align:"center",
            formatter : function(value, rowData, rowIndex) {
                	var keyid = eval("rowData."+keyfield);
                	return '<input type="button"  value="�޸�" onclick="modifyFun(\''+ keyid +'\')"></button>';
             		  },
            width:80
        }
        ]],
        queryParams : sy.serializeObject($("#CarScheduling_queryForm").form()),
        	toolbar : '#toolbar',
        	onDblClickRow :onClickRow
    })
}
//$('.datagrid-header div').css("textAlign","center");
 function reloadData(){
    	$("#dadagrid").datagrid("load");
}
//��ѯ
function searchFun()
{
    	$("#dadagrid").datagrid("load",sy.serializeObject($("#CarScheduling_queryForm").form()));
}
//�����հ�ť�����¼�
function clearSearch() {
    	$("#dadagrid").datagrid("load", {});//���¼������ݣ�����д���ݣ����̨����ֵ��Ϊ��
    	$("#CarScheduling_queryForm").find("input").val("");//�ҵ�form�����µ�����input��ǩ�����
}
//����
function addFun() {
    	$("#openDlgIframe")[0].src="<%=request.getAttribute("classname")%>Action.jsp?cmd=jqueryCreate";
    	$("#openDlgDiv").dialog("open");
}
//�޸�
function modifyFun(id) {
    	$("#openDlgIframe")[0].src="<%=request.getAttribute("classname")%>Action.jsp?cmd=jqueryModify&"+keyfield+"="+id;
    	$("#openDlgDiv").dialog("open");
}
//ɾ��
function delFun() {
    	var rows = $("#dadagrid").datagrid("getChecked");
    	var ids = [];
    	if (rows.length > 0 ) {
        		$.messager.confirm("ȷ��", "���Ƿ�Ҫɾ����ǰѡ�еļ�¼��", function(r) {
            		if (r) {
                			$.messager.progress({
                    			title : "��ʾ",
                    			text : "���ݴ����У����Ժ�...."
                	});
                	for ( var i = 0; i < rows.length; i++) {
                    			ids.push(rows[i].Id);
                	}
                	$.getJSON("<%=request.getAttribute("classname")%>Action.jsp?cmd=jqueryDeletelist", {
                    		idlist : ids.join(",")
                    	}, function(result) {
                    		if (result.success) {
                        			reloadData();
                    		}
                    		if(result.msg && result.msg.length>0)
                    			{
                        				$.messager.alert("��ʾ", result.msg, "info");
                    			}
                    			$.messager.progress("close");
                		});
            	}
        	});
    	}else
    	{
        		$.messager.alert("��ʾ", "��ѡ���¼���ٽ���ɾ������", "info");
    	}
}
</script>
</head>
<body class="easyui-layout">
<div data-options="region:'center',split:true" title="" style="">
<table id="dadagrid">
</table>
<div id="toolbar" style="display: none;">
<a href="#" class="easyui-linkbutton" data-options="iconCls:'icon-add'" style="width:80px" onClick="addFun();">����</a>
<a href="#" class="easyui-linkbutton" data-options="iconCls:'icon-no'" style="width:80px" onClick="delFun();">ɾ��</a>
</div>
<div id="menu" class="easyui-menu" style="width:120px;display:none;">
<div onClick="" iconCls="icon-add">����</div>
<div onClick="" iconCls="icon-remove">ɾ��</div>
<div onClick="" iconCls="icon-edit">�޸�</div>
</div>
<div id="dlg" class="easyui-dialog" title="����/�޸�" data-options="iconCls:'icon-save'" style="width:800px;height:500px;padding:10px">
</div>
<div id="openDlgDiv" class="easyui-window" closed="true" modal="true" title="����/�޸�" style="width:800px;height:550px;overflow:hidden">
	<iframe scrolling="auto" id="openDlgIframe" frameborder="0"  src="" style="width:100%;height:99%;"></iframe>
</div>
</div>
<div data-options="region:'north',split:true" title="��ѯ" style="height: 110px; overflow: auto;">
<form id="CarScheduling_queryForm" name="CarScheduling_queryForm" method="post">
<table border="0" width="100%" cellspacing="0" id="searchTable" class="tableForm datagrid-toolbar">
<input type="hidden" name="cmd" id="cmd" value="listjquery">
<%=Tool.join("\n", forms)%>
<td>
<div align="right">С��</div>
</td><td>
<%=HtmlTool.renderSelect(CarNameoptions, ParamUtils.getParameter(request,"_Carid_",""), "_Carid_", "")%>
<%//radio��ʽ%>
<%//CarNameoptions.remove(0);%>
<%//=HtmlTool.renderRadio(CarNameoptions, ParamUtils.getParameter(request,"_Carid_",""), "_Carid_", "")%>
<%//checkbox��ʽ%>
<%//=HtmlTool.renderCheckBox(CarNameoptions, ParamUtils.getParameter(request,"_Carid_",""), "_Carid_", "")%>
</td>
<td>
<div align="right">����ID</div>
</td><td>
<%=HtmlTool.renderSelect(TaskNameoptions, ParamUtils.getParameter(request,"_Taskid_",""), "_Taskid_", "")%>
<%//radio��ʽ%>
<%//TaskNameoptions.remove(0);%>
<%//=HtmlTool.renderRadio(TaskNameoptions, ParamUtils.getParameter(request,"_Taskid_",""), "_Taskid_", "")%>
<%//checkbox��ʽ%>
<%//=HtmlTool.renderCheckBox(TaskNameoptions, ParamUtils.getParameter(request,"_Taskid_",""), "_Taskid_", "")%>
</td>
<td>
<div align="right">�����ٶ�</div>
</td><td>
<input name="_Dqsd_" id="_Dqsd_"value="<%=ParamUtils.getParameter(request, "_Dqsd_", "")%>">
</td>
</tr><tr>
<td>
<div align="right">��ص�ѹ</div>
</td><td>
<input name="_Dqdy_" id="_Dqdy_"value="<%=ParamUtils.getParameter(request, "_Dqdy_", "")%>">
</td>
<td>
<div align="right">����״̬</div>
</td><td>
<%=HtmlTool.renderSelect(YesNooptions, ParamUtils.getParameter(request,"_Fzzt_",""), "_Fzzt_", "")%>
<%//radio��ʽ%>
<%//YesNooptions.remove(0);%>
<%//=HtmlTool.renderRadio(YesNooptions, ParamUtils.getParameter(request,"_Fzzt_",""), "_Fzzt_", "")%>
<%//checkbox��ʽ%>
<%//=HtmlTool.renderCheckBox(YesNooptions, ParamUtils.getParameter(request,"_Fzzt_",""), "_Fzzt_", "")%>
</td>
<td>
<div align="right">����״̬</div>
</td><td>
<%=HtmlTool.renderSelect(YesNooptions, ParamUtils.getParameter(request,"_Yxzt_",""), "_Yxzt_", "")%>
<%//radio��ʽ%>
<%//YesNooptions.remove(0);%>
<%//=HtmlTool.renderRadio(YesNooptions, ParamUtils.getParameter(request,"_Yxzt_",""), "_Yxzt_", "")%>
<%//checkbox��ʽ%>
<%//=HtmlTool.renderCheckBox(YesNooptions, ParamUtils.getParameter(request,"_Yxzt_",""), "_Yxzt_", "")%>
</td>
</tr><tr>
<td>
<div align="right">���</div>
</td><td>
<input name="_Qd_" id="_Qd_"value="<%=ParamUtils.getParameter(request, "_Qd_", "")%>">
</td>
<td>
<div align="right">�յ�</div>
</td><td>
<input name="_Zd_" id="_Zd_"value="<%=ParamUtils.getParameter(request, "_Zd_", "")%>">
</td>
<td>
<div align="right">����ʱ��</div>
</td><td>
<input name="_Yxtime_" id="_Yxtime_"value="<%=ParamUtils.getParameter(request, "_Yxtime_", "")%>">
</td>
</tr><tr>
<input type="hidden" name="_TaskRemark_" id="_TaskRemark_" value="<%=ParamUtils.getParameter(request, "_TaskRemark_", "")%>">
</tr><tr><td colspan="8" align="center">
<a href="javascript:void(0)" class="easyui-linkbutton" data-options="iconCls:'icon-search'" style="width:80px" onclick="searchFun()">��ѯ</a>
<a href="javascript:void(0)" class="easyui-linkbutton" data-options="iconCls:'icon-reload'" style="width:80px"  onclick="clearSearch()">���</a>
</td></tr></table>
	</form>
</div>
</body>
</html>
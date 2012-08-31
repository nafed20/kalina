<%@ webservice language="C#" class="ElementACSSStateService" %>          

using System;
using System.Web.Services;
using CrystalDecisions.Shared;
using CrystalDecisions.CrystalReports.Engine;
using CrystalDecisions.ReportSource;
using CrystalDecisions.Web.Services;


[WebService(Namespace = "http://crystaldecisions.com/reportwebservice/9.1/")]
public class ElementACSSStateService : ReportServiceBase                 
{
    
//---------------------------------------------------------------

    public static DateTime DateBeginP = System.DateTime.Today;
    public static DateTime DateEndP = System.DateTime.Today;
    public static bool IsArchiveP = false;

    [System.Web.Services.WebMethod()]
    public double SendData1(DateTime DateBegin, DateTime DateEnd, bool IsArchive)
    {
    DateBeginP = DateBegin;
    DateEndP = DateEnd;
    IsArchiveP = IsArchive;

    return 1;

    }
//---------------------------------------------------------------
    
    private ReportDocument ReportDoc = new ReportDocument();
    private const string DATE_BEGIN_FIELD = "dateBegin";
    private const string DATE_END_FIELD = "dateEnd";

    public ElementACSSStateService()                                     
    {                 
        ReportDoc.FileName = this.Server.MapPath("ElementACSSState.rpt");
        LogOn(); // осуществляется вход в SQL базу данных
        LoadData(); // загружаются в отчет входные параметры  
        this.ReportSource = ReportDoc; // формируется отчет
    }

    private void LoadData()
    {

        ParameterValues currentParameterValues = new ParameterValues();
        ParameterDiscreteValue parameterDiscreteValue = new ParameterDiscreteValue();
        ParameterFieldDefinitions parameterFieldDefinitions = ReportDoc.DataDefinition.ParameterFields;
        ParameterFieldDefinition parameterFieldDefinition = null;

        parameterDiscreteValue.Value = DateBeginP;
        currentParameterValues.Add(parameterDiscreteValue);
        parameterFieldDefinition = parameterFieldDefinitions[DATE_BEGIN_FIELD];
        parameterFieldDefinition.ApplyCurrentValues(currentParameterValues);

        currentParameterValues = new ParameterValues();
        parameterDiscreteValue = new ParameterDiscreteValue();
        parameterDiscreteValue.Value = DateEndP;
        currentParameterValues.Add(parameterDiscreteValue);
        parameterFieldDefinition = parameterFieldDefinitions[DATE_END_FIELD];
        parameterFieldDefinition.ApplyCurrentValues(currentParameterValues);

    }    
    
    private void LogOn()
    {
      
        string database = String.Empty;
        string cs = System.Configuration.ConfigurationManager.ConnectionStrings[0].ConnectionString;
        string[] prms = cs.Split(';');
        if (IsArchiveP)
        {
            database = "Archive";
        }
        else
        {
            database = prms[3].Split('=')[1];
        }
        
        string dataSource = prms[0].Split('=')[1];
        string user = prms[1].Split('=')[1];
        string password = prms[2].Split('=')[1];
        
        ReportDoc.SetDatabaseLogon(user, password, dataSource, database);

        ConnectionInfo connectInfo = new ConnectionInfo();
        connectInfo.ServerName = dataSource;
        connectInfo.DatabaseName = database;
        connectInfo.UserID = user;
        connectInfo.Password = password;

        TableLogOnInfo tblLogOn = new TableLogOnInfo();

        Tables tables = ReportDoc.Database.Tables;

        foreach (Table table in tables)
        {
            tblLogOn = table.LogOnInfo;
            tblLogOn.ConnectionInfo = connectInfo;
            table.ApplyLogOnInfo(tblLogOn);
        }

    }

    [WebMethod]
    public void CloseReport() // очистка
    {
        ReportDoc.Database.Dispose();
        this.ReportDoc.Close();
        this.ReportDoc.Dispose();
        GC.Collect();
    }
    
} 




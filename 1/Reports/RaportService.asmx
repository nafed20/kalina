<%@ webservice language="C#" class="RaportService" %>

using System;
using System.Web.Services;
using CrystalDecisions.Shared;
using CrystalDecisions.CrystalReports.Engine;
using CrystalDecisions.ReportSource;
using CrystalDecisions.Web.Services;
using Custom.Configuration;

[ WebService( Namespace="http://crystaldecisions.com/reportwebservice/9.1/" ) ]
public class RaportService : ReportServiceBase
{
    private ReportDocument ReportDoc = new ReportDocument();
//    private Service mainService = null;
    private const string DATE_BEGIN_FIELD = "dateBegin";
    private const string DATE_END_FIELD = "dateEnd";
    private const string ACCOUNT_ELEMENTS = "accountElements";
    private const string ACCOUNT_FAILURE = "accountFailure";
    
    public RaportService()
    {
        //
        // TODO: Add any constructor code required
        // 
        //mainService = new Service();
        ReportDoc.FileName = this.Server.MapPath("Raport.rpt");
        LoadData();
        this.ReportSource = ReportDoc;
    }
    private void LoadData()
    {
        LogOn();
                
        ParameterValues currentParameterValues = new ParameterValues();
        ParameterDiscreteValue parameterDiscreteValue = new ParameterDiscreteValue();
        ParameterFieldDefinitions parameterFieldDefinitions = ReportDoc.DataDefinition.ParameterFields;
        ParameterFieldDefinition parameterFieldDefinition = null;

        parameterDiscreteValue.Value = CachingData.DateBegin;
        currentParameterValues.Add(parameterDiscreteValue);

        parameterFieldDefinition = parameterFieldDefinitions[DATE_BEGIN_FIELD];
        parameterFieldDefinition.ApplyCurrentValues(currentParameterValues);

        currentParameterValues = new ParameterValues();
        parameterDiscreteValue = new ParameterDiscreteValue();
        parameterDiscreteValue.Value = CachingData.DateEnd;
        currentParameterValues.Add(parameterDiscreteValue);

        parameterFieldDefinition = parameterFieldDefinitions[DATE_END_FIELD];
        parameterFieldDefinition.ApplyCurrentValues(currentParameterValues);

        currentParameterValues = new ParameterValues();
        parameterDiscreteValue = new ParameterDiscreteValue();
        parameterDiscreteValue.Value = CachingData.AccountElements;
        currentParameterValues.Add(parameterDiscreteValue);

        parameterFieldDefinition = parameterFieldDefinitions[ACCOUNT_ELEMENTS];
        parameterFieldDefinition.ApplyCurrentValues(currentParameterValues);

        currentParameterValues = new ParameterValues();
        parameterDiscreteValue = new ParameterDiscreteValue();
        parameterDiscreteValue.Value = CachingData.AccountFailure;
        currentParameterValues.Add(parameterDiscreteValue);

        parameterFieldDefinition = parameterFieldDefinitions[ACCOUNT_FAILURE];
        parameterFieldDefinition.ApplyCurrentValues(currentParameterValues);

    }
    private void LogOn()
    {
        string database = String.Empty;
        string cs = Globals.GetConnectionStringSettings().ConnectionString;
        string[] prms = cs.Split(';');

        if (CachingData.IsArchive)
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

        //int tttddd = CachingData.accountElements;
        //string dataString1 = ToString(tttddd);  //public static string ToString(DateTime value)
        //string dataString2 = Convert.ToString(CachingData.accountFailure);
        //string[] lines = { dataString2 };//, dataString2 
        //string[] lines = { user, password, dataSource, database, cs};
        //System.IO.File.WriteAllLines(@"C:\Inetpub\wwwroot\WebService\Reports\WriteLines.txt", lines);
            
        
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
    public byte[] GetReportDocument(string format)
    {
        ExportFormatType eft = ExportFormatType.NoFormat;
        
        switch(format)
        {
            case "Word":
                eft = ExportFormatType.WordForWindows;
                break;
            case "Excel":
                eft = ExportFormatType.Excel;
                break;
        }
        
        byte[] buffer = null;
        System.IO.Stream stream = ReportDoc.ExportToStream(eft);
        stream.Position = 0;
        buffer = new byte[stream.Length];
        stream.Read(buffer, 0, (int)stream.Length);

        return buffer;
    }
    [WebMethod]
    public void CloseReport()
    {
        ReportDoc.Database.Dispose();
        this.ReportDoc.Close();
        this.Dispose();
    }
}



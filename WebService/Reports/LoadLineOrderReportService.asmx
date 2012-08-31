<%@ webservice language="C#" class="LoadLineOrderReportService" %>

using System;
using System.Web.Services;
using CrystalDecisions.Shared;
using CrystalDecisions.CrystalReports.Engine;
using CrystalDecisions.ReportSource;
using CrystalDecisions.Web.Services;
using System.Data.SqlClient;
using System.Data.Sql;
using System.Data;
using System.Configuration;

[ WebService( Namespace="http://crystaldecisions.com/reportwebservice/9.1/" ) ]
public class LoadLineOrderReportService : ReportServiceBase
{
    // --------- параметры службы -----------------------
   //public static int idCds;
    private static bool isArchiveP;
    private static int idPeriod = 0;
    private static string idLine = "";
    private static string variantPlan = "";
   
    string dd;
    //------------ конец параметры -------------------
    private ReportDocument report = new ReportDocument();
    private string conectionstring;
    private ConnectionInfo connectInfo;
    // --------------------------- Соединиение с БД -------------------------------
    public LoadLineOrderReportService()
    {
            report.FileName = this.Server.MapPath("LoadLineReport.rpt");
            conectionstring = ConfigurationManager.ConnectionStrings[0].ConnectionString;
            ConnectionInfo connectInfo = new ConnectionInfo();
            string[] prms = conectionstring.Split(';');
            string dataSource = prms[0].Split('=')[1];
            string user = prms[1].Split('=')[1];
            string password = prms[2].Split('=')[1];
            string database="";
            if (isArchiveP)
            {
                database = "Archive";
            }
            else
            {
                database = prms[3].Split('=')[1];
            }
            report.SetDatabaseLogon(user, password, dataSource, database);
            connectInfo.ServerName = dataSource;
            connectInfo.DatabaseName = database;
            connectInfo.UserID = user;
            connectInfo.Password = password;
            TableLogOnInfo tblLogOn = new TableLogOnInfo();
            Tables tables = report.Database.Tables;
            foreach (Table table in tables)
            {
                tblLogOn = table.LogOnInfo;
                tblLogOn.ConnectionInfo = connectInfo;
                table.ApplyLogOnInfo(tblLogOn);
            }
            ParameterDiscreteValue val_period = new ParameterDiscreteValue();
            ParameterDiscreteValue val_line = new ParameterDiscreteValue();
            ParameterDiscreteValue val_plan = new ParameterDiscreteValue();
            val_period.Value = idPeriod;
            val_line.Value = idLine;
            val_plan.Value = variantPlan;
            report.SetParameterValue("val_period", val_period);
            report.SetParameterValue("val_line", val_line);
            report.SetParameterValue("variantPlan", val_plan); 
            this.ReportSource = report;

    }
    //----------------------Метод для передачи параметров --------------------------
    [WebMethod]
    public void SetParamForReport(string _variantPlan, int _idPeriod, string _idLine, bool _isArchive)
    {
        idPeriod = _idPeriod;
        idLine = _idLine;
        isArchiveP = _isArchive;
        variantPlan = _variantPlan;
    }
    [WebMethod]
    public string CloseReport333()
    {
        return idLine;
    }
    // ------------------------ Освобождение ресурсов ------------------------------  
    [WebMethod]
    public void CloseReport()
    {
        this.report.Database.Dispose();
        this.report.Close();
        this.report.Dispose();
        GC.Collect();
    }

}



<%@ webservice language="C#" class="SchemeOrderReportService" %>

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
using System.Collections.Generic;

[ WebService( Namespace="http://crystaldecisions.com/reportwebservice/9.1/" ) ]
public class SchemeOrderReportService : ReportServiceBase
{
    // --------- параметры службы -----------------------
        private static string variantPlan = "";
        private static int idSite;
        private static bool isArchiveP;
        private static int idPeriod;

  
    
    //------------ конец параметры -------------------
    private ReportDocument report = new ReportDocument();
    private string conectionstring;
    private ConnectionInfo connectInfo;
    private string cs;
    // --------------------------- Соединиение с БД -------------------------------
    public SchemeOrderReportService()
    {
            report.FileName = this.Server.MapPath("SchemeOrderReport.rpt");
            LogOn(); // осуществляется вход в SQL базу данных
            LoadData();  
            this.ReportSource = report;

    }
    //----------------------Метод для передачи параметров --------------------------
    [WebMethod]
    public void SetParamForReport(string _variantPlan, int _idPeriod, int _idSite, bool _isArchive)
    {
        variantPlan = _variantPlan;
        idSite = _idSite;
        isArchiveP = _isArchive;
        idPeriod = _idPeriod;
    }
    private void LoadData()
    {
        ParameterDiscreteValue val_period = new ParameterDiscreteValue();
        ParameterDiscreteValue val_site = new ParameterDiscreteValue();
        ParameterDiscreteValue val_plan = new ParameterDiscreteValue();
        val_period.Value = idPeriod;
        val_site.Value = idSite;
        val_plan.Value = variantPlan;
        report.SetParameterValue("@idPeriod", val_period);
        report.SetParameterValue("@idSite", val_site);
        report.SetParameterValue("variantPlan", val_plan);

    }
    private void LogOn()
    {

        string database = String.Empty;
        cs = System.Configuration.ConfigurationManager.ConnectionStrings[0].ConnectionString;
        string[] prms = cs.Split(';');
        if (isArchiveP)
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

        report.SetDatabaseLogon(user, password, dataSource, database);

        ConnectionInfo connectInfo = new ConnectionInfo();
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


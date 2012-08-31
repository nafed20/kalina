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
        try
        {
            report = new ReportDocument();
            this.Server.ScriptTimeout = 3000;
           // this.Session.Timeout = 3;
            report.FileName = this.Server.MapPath("SchemeOrderReport.rpt");
            LogOn(); // осуществляется вход в SQL базу данных
            LoadData();
           // report.VerifyDatabase();
            this.ReportSource = report;
        }
        catch (Exception e) { DebugString += e.Message; }

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
        try
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
            // System.Threading.Thread.Sleep(1000);

            // DEBUG

            ParameterDiscreteValue v1 = new ParameterDiscreteValue();
            string v = String.Empty;
            v += v1.Value = report.Subreports[1].Name;
            //v += "\n База "+ report.Subreports[1].Database.Tables[0].LogOnInfo.ConnectionInfo.DatabaseName;
            //v += "\n логин " + report.Subreports[1].Database.Tables[0].LogOnInfo.ConnectionInfo.UserID;
            //v += "\n пароль " + report.Subreports[1].Database.Tables[0].LogOnInfo.ConnectionInfo.Password;
            //v += "\n ПК " + report.Subreports[1].Database.Tables[0].LogOnInfo.ConnectionInfo.ServerName;
            //v += "\n База " + report.Database.Tables[0].LogOnInfo.ConnectionInfo.DatabaseName;
            //v += " логин " + report.Database.Tables[0].LogOnInfo.ConnectionInfo.UserID;
            //v += " пароль " + report.Database.Tables[0].LogOnInfo.ConnectionInfo.Password;
            //v += " ПК " + report.Database.Tables[0].LogOnInfo.ConnectionInfo.ServerName;
            v += "\n33" + DebugString;
            v1.Value = v;
            report.SetParameterValue("myVar", v1);
        }
        catch (Exception e) { DebugString += e.Message; }
    }
    string DebugString;
    
    private void LogOn()
    {
        try
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

            connectInfo = new ConnectionInfo();
            connectInfo.ServerName = dataSource;
            connectInfo.DatabaseName = database;
            connectInfo.UserID = user;
            connectInfo.Password = password;
            TableLogOnInfo tblLogOn = null;

            Tables tables = report.Database.Tables;
            foreach (ReportDocument subreport in report.Subreports)
            {
                foreach (Table table_subrep in subreport.Database.Tables)
                {
                    table_subrep.LogOnInfo.ConnectionInfo.ServerName = connectInfo.ServerName;
                    table_subrep.LogOnInfo.ConnectionInfo.Password = connectInfo.Password;
                    table_subrep.LogOnInfo.ConnectionInfo.UserID = connectInfo.UserID;
                    table_subrep.LogOnInfo.ConnectionInfo.DatabaseName = connectInfo.DatabaseName;
                    tblLogOn = table_subrep.LogOnInfo;
                    table_subrep.ApplyLogOnInfo(tblLogOn);
                }
            }
            foreach (Table table in tables)
            {
                tblLogOn = table.LogOnInfo;
                tblLogOn.ConnectionInfo = connectInfo;
                table.ApplyLogOnInfo(tblLogOn);
                DebugString += "111 - " + table.LogOnInfo.ConnectionInfo.Password;
            }

           
           // report.Refresh();
        }
        catch (Exception e) { DebugString += e.Message; }
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


<%@ WebService Language="C#" CodeBehind="ReportsDC.asmx.cs" Class="WebServiceAcontur.ReportsDC" %>
using System;
using System.Collections;
using System.ComponentModel;
using System.Data;
using System.Linq;
using System.Web;
using System.Web.Services;
using System.Web.Services.Protocols;
using System.Xml.Linq;
using CrystalDecisions.Shared;
using CrystalDecisions.CrystalReports.Engine;
using CrystalDecisions.ReportSource;
using CrystalDecisions.Web.Services;
using System.Configuration;

namespace WebServiceAcontur
{
    /// <summary>
    /// Сводное описание для ReportsDC
    /// </summary>
    // Чтобы разрешить вызывать веб-службу из сценария с помощью ASP.NET AJAX, раскомментируйте следующую строку. 
    // [System.Web.Script.Services.ScriptService]
    [WebService(Namespace = "http://crystaldecisions.com/reportwebservice/9.1/")]
    public class ReportsDC : ReportServiceBase
    {
    // --------- параметры службы -----------------------
        private static DateTime dateB = DateTime.Now;
        private static DateTime dateE = DateTime.Now;
        private static string addr_site = string.Empty;
        private static string addr_ndr = string.Empty;
        private static bool isArchiveP;
        public static string string_report;

    //------------ конец параметры -------------------
    private ReportDocument report = new ReportDocument();
    private string conectionstring;
   // private ConnectionInfo connectInfo;
    // --------------------------- Соединиение с БД -------------------------------
    public ReportsDC()
    {
        report.FileName = this.Server.MapPath("WatchReport.rpt");
            conectionstring = ConfigurationManager.ConnectionStrings[0].ConnectionString;
            ConnectionInfo connectInfo = new ConnectionInfo();
            string[] prms = conectionstring.Split(';');
            string dataSource = prms[0].Split('=')[1];
            string user = prms[1].Split('=')[1];
            string password = prms[2].Split('=')[1];
            string database = "";
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

            //ParameterDiscreteValue val_dateB = new ParameterDiscreteValue();
            //ParameterDiscreteValue val_dateE = new ParameterDiscreteValue();
            //ParameterDiscreteValue val_addr_site = new ParameterDiscreteValue();
            //ParameterDiscreteValue val_addr_ndr = new ParameterDiscreteValue();
            //val_dateB.Value = dateB;
            //val_dateE.Value = dateE;
            //val_addr_site.Value = addr_site;
            //val_addr_ndr.Value = addr_ndr;
            report.SetParameterValue("addr_site", addr_site);
            report.SetParameterValue("addr_ndr", addr_ndr);
            report.SetParameterValue("DateB", dateB);
            report.SetParameterValue("DateE", dateE);

            this.ReportSource = report;

    }
    //----------------------Метод для передачи параметров --------------------------
    [WebMethod]
    public void SetParamForReport(DateTime _dateB, DateTime _dateE,string _addr_site,string _addr_ndr, bool _isArchive)
    {
        dateB = _dateB;
        dateE = _dateE;
        addr_site = _addr_site;
        addr_ndr = _addr_ndr;
        isArchiveP = _isArchive;
    }
    
    // ------------------------ Освобождение ресурсов ------------------------------  
    [WebMethod]
    public void CloseReport()
    {
        //this.report.Database.Dispose();
        this.report.Close();
        this.report.Dispose();
        GC.Collect();
    }

}
}

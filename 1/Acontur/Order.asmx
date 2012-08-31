<%@ WebService Language="C#" CodeBehind="Order.asmx.cs" Class="WebServiceAcontur.OrderPrint" %>

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
    public class OrderPrint : ReportServiceBase
    {
    // --------- параметры службы -----------------------
        private static int id;
        private static bool isArchiveP;
    //------------ конец параметры -------------------
    private ReportDocument report = new ReportDocument();
    private string conectionstring;
   // private ConnectionInfo connectInfo;
    // --------------------------- Соединиение с БД -------------------------------
    public OrderPrint()
    {
        report.FileName = this.Server.MapPath("WatchOrderReport.rpt");
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

            ParameterDiscreteValue val_id = new ParameterDiscreteValue();
            val_id.Value = id;
            report.SetParameterValue("id", val_id);
            this.ReportSource = report;

    }
    //----------------------Метод для передачи параметров --------------------------
    [WebMethod]
    public void SetParamForReport(int _id, bool _isArchiveP)
    {
        id = _id;
        isArchiveP = _isArchiveP;
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

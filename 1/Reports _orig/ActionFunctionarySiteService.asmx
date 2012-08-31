<%@ webservice language="C#" class="ActionFunctionarySiteService" %>          

using System;
using System.Web.Services;
using CrystalDecisions.Shared;
using CrystalDecisions.CrystalReports.Engine;
using CrystalDecisions.ReportSource;
using CrystalDecisions.Web.Services;
using System.Collections.Generic;
using System.Data.SqlClient;
using System.Data;

[WebService(Namespace = "http://crystaldecisions.com/reportwebservice/9.1/")]
public class ActionFunctionarySiteService : ReportServiceBase                 
{
    
//---------------------------------------------------------------
    
        public static int StationNumberP = 0;
        public static DateTime DateBeginP = System.DateTime.Today;
        public static DateTime DateEndP = System.DateTime.Today;
        public static int ArmP = 0;
        public static string ArmNameP = "";
        public static int UidP = 0;
        public static bool IsArchiveP = false;
        public static List<eArm> listArm;
        public struct eArm
        {
            public string ArmName;
            public string ArmSite;
            public int Id;
        }
    
        [System.Web.Services.WebMethod()]
        public double SendData5(DateTime DateBegin, DateTime DateEnd, int Arm, string ArmName, int Uid, bool isArchive)
        
        {
            DateBeginP = DateBegin;
            DateEndP = DateEnd;
            ArmP = Arm;
            ArmNameP = ArmName;
            UidP = Uid;
            IsArchiveP = isArchive;
            return 1;

        }
        [System.Web.Services.WebMethod()]
        public List<eArm> GetListArms()
        {
            string cs = System.Configuration.ConfigurationManager.ConnectionStrings[0].ConnectionString;
            SqlConnection sql_conn = new SqlConnection(cs);
            DataSet dataset = new DataSet();
            listArm = new List<eArm>();
            SqlDataAdapter adArm = new SqlDataAdapter();
            sql_conn.Open();
            adArm.SelectCommand = new SqlCommand(@"select id,Name,(select (select id from Elements Where id = el2.parent) from Elements as el2 Where id = el1.parent) from Elements as el1 Where class LIKE '%Comp' AND parent > 0", sql_conn);
            adArm.Fill(dataset, "Arms");
            /************************* Узлы******************************/
            SqlDataAdapter adSites = new SqlDataAdapter();
            adSites.SelectCommand = new SqlCommand(@"EXEC pListStations", sql_conn);
            adSites.Fill(dataset, "Sites");
            int id_arms,id_armsite,id_site;
            string name_arm = String.Empty, callsing = String.Empty;
            eArm el;
            foreach (DataRow arm in dataset.Tables["Arms"].Rows)
            {
                id_arms = arm.Field<int>(0);
                name_arm = arm.Field<string>(1);
                id_armsite = Convert.ToInt32(arm.Field<int>(2));
                /****************************** УЗЛЫ ****************************************************/
                foreach (DataRow site in dataset.Tables["Sites"].Rows)
                {
                    if (id_armsite == site.Field<int>(0))
                    {
                        callsing = site.Field<string>(1);
                      
                    }
                }
                el.ArmName = name_arm;
                el.ArmSite = callsing;
                el.Id = id_arms;
                listArm.Add(el);
            }
            /************************************************************/
            sql_conn.Close();
            return listArm;

        }
//---------------------------------------------------------------
    
    private ReportDocument ReportDoc = new ReportDocument();
    
    public ActionFunctionarySiteService()                                     
    {
        ReportDoc.FileName = this.Server.MapPath("ActionFunctionarySite.rpt");
        LogOn(); // осуществляется вход в SQL базу данных
        LoadData(); // загружаются в отчет входные параметры  
        this.ReportSource = ReportDoc; // формируется отчет
    }
    
    private void LoadData()
    {
        ParameterDiscreteValue val_datebegin = new ParameterDiscreteValue();
        ParameterDiscreteValue val_dateend = new ParameterDiscreteValue();
        ParameterDiscreteValue val_arm = new ParameterDiscreteValue();
        ParameterDiscreteValue val_armname = new ParameterDiscreteValue();
        ParameterDiscreteValue val_uid = new ParameterDiscreteValue();
        val_datebegin.Value = DateBeginP;
        val_dateend.Value = DateEndP;
        val_arm.Value = ArmP;
        val_armname.Value = ArmNameP;
        val_uid.Value = UidP;
        ReportDoc.SetParameterValue("dateBegin", val_datebegin);
        ReportDoc.SetParameterValue("dateEnd", val_dateend);
        ReportDoc.SetParameterValue("idArm", val_arm);
        ReportDoc.SetParameterValue("ArmName", val_armname);
        ReportDoc.SetParameterValue("uid", val_uid);

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




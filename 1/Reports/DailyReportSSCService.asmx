<%@ webservice language="C#" class="DailyReportSSCService" %>

using System;
using System.Web.Services;
using CrystalDecisions.Shared;
using CrystalDecisions.CrystalReports.Engine;
using CrystalDecisions.ReportSource;
using CrystalDecisions.Web.Services;
using System.Collections.Generic;
using System.Data.SqlClient;
using System.Data;

[ WebService( Namespace="http://crystaldecisions.com/reportwebservice/9.1/" ) ]
public class DailyReportSSCService : ReportServiceBase
{
    //---------------------------------------------------------------

    public static string CallSignP = "";
    public static int StationNumberP = 0;
    public static int idVariantOfPlaneP = 33;
    public static DateTime DateBegin = System.DateTime.Today;
    public static bool IsArchiveP = false;

    [System.Web.Services.WebMethod()]
    public double SendData2(int StationNumber, string CallSign, string DateB, bool IsArchive,int Id_vp)
    {

    StationNumberP = StationNumber;//SiteID
    CallSignP = CallSign;
    DateBegin = Convert.ToDateTime(DateB);
    IsArchiveP = IsArchive;
    idVariantOfPlaneP = Id_vp;

    return 1;

    }
    //---------------------------------------------------------------
    
    private ReportDocument ReportDoc = new ReportDocument();

    public DailyReportSSCService()
    {
        ReportDoc.FileName = this.Server.MapPath("DailyReportSSC.rpt");
        LogOn(); // осуществляется вход в SQL базу данных
        LoadData(); // загружаются в отчет входные параметры
        this.ReportSource = ReportDoc; // формируется отчет
    }
    
    
    private void LoadData()
    {
        ParameterDiscreteValue val_dateB = new ParameterDiscreteValue();
        ParameterDiscreteValue val_dateE = new ParameterDiscreteValue();
        ParameterDiscreteValue val_site = new ParameterDiscreteValue();
        ParameterDiscreteValue val_callsign = new ParameterDiscreteValue();
        ParameterDiscreteValue val_idvp = new ParameterDiscreteValue();
        DateTime DateEnd = DateBegin.AddDays(1);
        val_dateB.Value = DateBegin;
        val_dateE.Value = DateEnd;
        val_site.Value = StationNumberP;
        val_callsign.Value = CallSignP;
        val_idvp.Value = idVariantOfPlaneP;
        ReportDoc.SetParameterValue("dateBegin", val_dateB);
        ReportDoc.SetParameterValue("dateEnd", val_dateE);
        ReportDoc.SetParameterValue("idSite", val_site);
        ReportDoc.SetParameterValue("CallSign", val_callsign);
        ReportDoc.SetParameterValue("idvpmain", val_idvp);
        
       
    }
    [WebMethod]
    public List<VarOfPlane> GetVarOfPlane(string s_lt, string s_rt)
    {
        string cs = System.Configuration.ConfigurationManager.ConnectionStrings[0].ConnectionString;
        DateTime lt = Convert.ToDateTime(s_lt);
        DateTime rt = Convert.ToDateTime(s_rt);
        //string cs = @"Data Source=arm-ds-senat\SQLEXPRESS;Initial Catalog=acssnew;user=sa;password=smart";
        SqlConnection sqlconnect = new SqlConnection(cs);
        List<VarOfPlane> list = null;
        try
        {
            sqlconnect.Open();
            SqlDataAdapter sqlda = new SqlDataAdapter();
            sqlda.SelectCommand = new SqlCommand(@"SELECT * FROM VariantsOfplane WHERE entered is not null", sqlconnect);
            DataSet ds = new DataSet();
            list = new List<VarOfPlane>();
            VarOfPlane el;
            sqlda.Fill(ds, "VoP");
            DateTime term_through = DateTime.Now;
            if (ds.Tables["VoP"] != null)
                foreach (DataRow dr in ds.Tables["VoP"].Rows)
                {
                    if (dr.IsNull("executed") && dr.IsNull("anniented"))
                        term_through = DateTime.Now;
                    if (dr.IsNull("anniented") && !dr.IsNull("executed"))
                        term_through = dr.Field<DateTime>("executed");
                    if (!dr.IsNull("anniented") && !dr.IsNull("executed"))
                        term_through = dr.Field<DateTime>("anniented");
                    if (rt >= dr.Field<DateTime>("entered") && lt <= term_through)
                    {
                        el.id_var = dr.Field<int>("id");
                        el.Name_var = dr.Field<string>("name") + " №" + dr.Field<string>("number");
                        list.Add(el);
                    }
                }
        }
        catch { }
        finally
        {
            sqlconnect.Close();
        }
        return list;

    }
    public struct VarOfPlane
    {
        public string Name_var;
        public int id_var;
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



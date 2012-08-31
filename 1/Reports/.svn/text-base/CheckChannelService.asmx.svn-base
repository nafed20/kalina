<%@ webservice language="C#" class="CheckChannelReportService" %>

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
public class CheckChannelReportService : ReportServiceBase
{
    //---------------------------------------------------------------

    public static string CallSignP = "";
   // public static DateTime DateBegin = System.DateTime.Today;
    public static int id_vp = 0;
    public static bool IsArchiveP = false;
    [System.Web.Services.WebMethod()]
    public double SendData2(string CallSign, int _id_vp, bool IsArchive)
    {
        CallSignP = CallSign;
        //DateBegin = Convert.ToDateTime(DateB);
        //DateEnd = Convert.ToDateTime(DateE);
        id_vp = _id_vp;
        IsArchiveP = IsArchive;
        return 1;
    }
    //---------------------------------------------------------------
    
    private ReportDocument ReportDoc = new ReportDocument();
    SqlConnection sql_conn;
    public CheckChannelReportService()
    {
        try
        {
            ReportDoc.FileName = this.Server.MapPath("CheckChannel.rpt");
            LogOn(); // осуществляется вход в SQL базу данных
            LoadData(); // загружаются в отчет входные параметры  
            this.ReportSource = ReportDoc; // формируется отчет
        }
        catch
        { return; }
    }


    private void LoadData()
    {
        //ParameterDiscreteValue val_dateB = new ParameterDiscreteValue();
        ParameterDiscreteValue val_id_vp = new ParameterDiscreteValue();
        ParameterDiscreteValue val_callsign = new ParameterDiscreteValue();
       // val_dateB.Value = DateBegin;
        val_id_vp.Value = id_vp;
        val_callsign.Value = CallSignP;
        //ReportDoc.SetParameterValue("dateBegin", val_dateB);
        ReportDoc.SetParameterValue("id_vp", val_id_vp);
        ReportDoc.SetParameterValue("CallSign", val_callsign);


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
    /***********************************************************************************************/
    [WebMethod]
    public List<VarOfPlane> GetVarOfPlaneOnDate(string s_lt, string s_rt)
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

    [WebMethod]
    public List<eVarOfPlane> GetVarOfPlane()
    {
        List<eVarOfPlane> list = null;
        try
        {
            sql_conn = new SqlConnection(System.Configuration.ConfigurationManager.ConnectionStrings[0].ConnectionString);
            sql_conn.Open();
            SqlDataAdapter sqlda = new SqlDataAdapter();
            sqlda.SelectCommand = new SqlCommand(@"EXEC pCC_GetListVariants", sql_conn);
            DataSet ds = new DataSet();
            list = new List<eVarOfPlane>();
            eVarOfPlane el;
            sqlda.Fill(ds, "VoP"); 
            if(ds.Tables["VoP"] != null)
                foreach (DataRow dr in ds.Tables["VoP"].Rows)
                {
                        el.id_var = dr.Field<int>("id");
                        el.name_var = dr.Field<string>("name");
                        el.dt_from = dr.Field<DateTime>("t_f").ToString();
                        el.dt_to = dr.Field<DateTime>("t_t").ToString();
                        el.state = dr.Field<string>("state");
                        el.mode = dr.Field<string>("mode");
                        list.Add(el);
                }
        }
        catch { return null; }
        finally 
        { 
            sql_conn.Close();
        }
        return list;

    }

    [WebMethod]
    public List<eChannel> GetChannelList(int period,int cds)
    {
        try
        {
            sql_conn = new SqlConnection(System.Configuration.ConfigurationManager.ConnectionStrings[0].ConnectionString);
            sql_conn.Open();
            DataTable table_channels = new DataTable("Channels");
            SqlDataAdapter adChannels = new SqlDataAdapter();
            adChannels.SelectCommand = new SqlCommand(@"SELECT ci.item_id,ci.cds_id,SUBSTRING(props,0,CHARINDEX(char(10),props,0)) as props,ci.attachment,ci.capacity,ci.mediumstyle_id,gt.code,(SUBSTRING(props,CHARINDEX(char(10),props,0)+1,
            CHARINDEX(char(10),props, CHARINDEX(char(10),props,0)+1)-
            CHARINDEX(char(10),props,0)-1)
            ) as num_block FROM cdsitems ci join generictable gt on gt.name = ci.attachment where  ci.period_id = " + period.ToString() + " AND attachment is not null AND cds_id = "+cds.ToString(), sql_conn);
            adChannels.Fill(table_channels);
            List<eChannel> list_channels = new List<eChannel>();
            eChannel el_ch;
            /****************************** ЗАПОЛНЕНИЕ СПИСКА ****************************************************/
            foreach (DataRow row in table_channels.Rows)
            {
                el_ch.id = row.Field<int>("item_id");
                el_ch.cds_id = row.Field<int>("cds_id");
                el_ch.name_channel = row.Field<string>("props");
                el_ch.attachment = row.Field<string>("attachment");
                el_ch.capacity = "-";
                if (row.Field<int>("code") == 1)
                    el_ch.capacity = @"Eth\" + row.Field<decimal>("capacity").ToString();
                if (row.Field<int>("code") == 2)
                    el_ch.capacity = @"ОЦК\64x" + row.Field<decimal>("capacity").ToString();
                el_ch.num_block = row.Field<string>("num_block").ToString();
                el_ch.style = row.Field<int>("mediumstyle_id");
                list_channels.Add(el_ch);
            }

            return list_channels;
        }
        catch { return null; 
        }
        finally { sql_conn.Close(); }
    }
    [WebMethod]
    public List<ePeriod> GetPeriodforVariant(int vp)
    {
        try
        {
            sql_conn = new SqlConnection(System.Configuration.ConfigurationManager.ConnectionStrings[0].ConnectionString);
            sql_conn.Open();
            DataTable table_periods = new DataTable("Periods");
            SqlDataAdapter adPeriod = new SqlDataAdapter();
            adPeriod.SelectCommand = new SqlCommand(@"select im.id,im.t_from,im.t_throught,im.idvariant,m.name from intervalmode im join modes m on m.id = im.idmode where im.idvariant =" + vp.ToString(), sql_conn);
            adPeriod.Fill(table_periods);
            List<ePeriod> list_periods = new List<ePeriod>();
            ePeriod el_p;
            /****************************** ЗАПОЛНЕНИЕ СПИСКА ****************************************************/
            foreach (DataRow row in table_periods.Rows)
            {
                el_p.id = row.Field<int>("id");
                el_p.t_from = row.Field<int>("t_from");
                el_p.t_throught = row.Field<int>("t_throught");
                el_p.mode = row.Field<string>("name");
                list_periods.Add(el_p);
            }

            return list_periods;
        }
        catch
        {
            return null;
        }
        finally { sql_conn.Close(); }
    }
    [WebMethod]
    public void AddCheck(string cds_name, int id_cdsitem, string name_channel, string type_bw, string type_test, string kind_test, string num_block_sp,int id_period, int minute)
    {
        try
        {
            sql_conn = new SqlConnection(System.Configuration.ConfigurationManager.ConnectionStrings[0].ConnectionString);
            sql_conn.Open();
            SqlCommand insertCommand = new SqlCommand(@"insert into channelcheck (cds_name,id_cdsitem,name_channel,type_bw,type_test,kind_test,num_block_sp,minute,id_period) values ('" + cds_name + "','" + id_cdsitem + "','" + name_channel + "','" + type_bw + "','" + type_test + "','" + kind_test + "','" + num_block_sp + "'," + minute.ToString() + ","+id_period.ToString()+")", sql_conn);
            insertCommand.ExecuteNonQuery();
        }
        catch { }
        finally { sql_conn.Close(); }
    }
    [WebMethod]
    public void AddCheckAndExec(string cds_name, int id_cdsitem, string name_channel, string type_bw, string type_test, string kind_test, string num_block_sp, int id_period, int minute)
    {
        try
        {
            sql_conn = new SqlConnection(System.Configuration.ConfigurationManager.ConnectionStrings[0].ConnectionString);
            sql_conn.Open();
            string state;
            SqlCommand sql_checkstate = new SqlCommand("select top 1 state from cdsstate where cds_item = " + id_cdsitem.ToString() + " AND date_begin <= '" + DateTime.Now.ToString() + "' ORDER BY date_begin DESC", sql_conn);
            DataTable t = new DataTable("checkfails");
            SqlDataAdapter da = new SqlDataAdapter();
            da.SelectCommand = sql_checkstate;
            da.Fill(t);
            DataRow row;
            if (t.Rows.Count > 0)
            {
                row = t.Rows[0];
                string fails = row.Field<string>(0);
                if (fails.IndexOf("F") > -1)
                    state = "Авария";
                else state = "Норма";
            }
            else
            {
                state = "Норма";
            }


            SqlCommand insertCommand = new SqlCommand(@"insert into channelcheck (cds_name,id_cdsitem,name_channel,type_bw,type_test,kind_test,num_block_sp,minute,id_period,status) values ('" + cds_name + "','" + id_cdsitem + "','" + name_channel + "','" + type_bw + "','" + type_test + "','" + kind_test + "','" + num_block_sp + "'," + minute .ToString()+ "," + id_period.ToString()+",'" + state + "')", sql_conn);
            insertCommand.ExecuteNonQuery();
        }
        catch { }
        finally { sql_conn.Close(); }
    }
    [WebMethod]
    public DataTable GetChecksTable(string site)
    {
        try
        {
            sql_conn = new SqlConnection(System.Configuration.ConfigurationManager.ConnectionStrings[0].ConnectionString);
            sql_conn.Open();
            DataTable table_checkchannels = new DataTable("CheckTable");
            SqlDataAdapter adCheckChannels = new SqlDataAdapter();
            if(site != string.Empty)
                adCheckChannels.SelectCommand = new SqlCommand(@"SELECT c.id,cds_name,id_cdsitem,name_channel,type_bw,type_test,kind_test,num_block_sp,(cast(minute as varchar(40)) + ' мин. в ('+cast(im.t_from as varchar(40)) + ' - ' + cast(im.t_throught as varchar(40))+')') date_test,minute,id_period, status FROM ChannelCheck c join intervalmode im on im.id = c.id_period where cds_name like'" + site + "%'", sql_conn); //id,cds_name,name_channel,type_bw,type_test,kind_test,date_test,status
            else
                adCheckChannels.SelectCommand = new SqlCommand(@"SELECT c.id,cds_name,id_cdsitem,name_channel,type_bw,type_test,kind_test,num_block_sp,(cast(minute as varchar(40)) + ' мин. в ('+cast(im.t_from as varchar(40)) + ' - ' + cast(im.t_throught as varchar(40))+')') date_test,minute,id_period, status FROM ChannelCheck c join intervalmode im on im.id = c.id_period", sql_conn);
            adCheckChannels.Fill(table_checkchannels);
            return table_checkchannels;
        }
        catch { return null; }
        finally { sql_conn.Close(); }
    }

    [WebMethod]
    public void ChangeState(int id_check ,int cds, DateTime date_check)
    {
        try
        {
            string state;
            sql_conn = new SqlConnection(System.Configuration.ConfigurationManager.ConnectionStrings[0].ConnectionString);
            sql_conn.Open();
            SqlCommand sql_checkstate = new SqlCommand("select top 1 state from cdsstate where cds_item = " + cds.ToString() + " AND date_begin <= '" + date_check.ToString() + "' ORDER BY date_begin DESC ", sql_conn);
            DataTable t = new DataTable("checkfails");
            SqlDataAdapter da = new SqlDataAdapter();
            da.SelectCommand = sql_checkstate;
            da.Fill(t);
            DataRow row;
            if (t.Rows.Count > 0)
            {
                row = t.Rows[0];
                string fails = row.Field<string>(0);
                if (fails.IndexOf("F") > -1)
                    state = "Авария";
                else state = "Норма";
            }
            else
            {
                state = "Норма";
            }
            SqlCommand sql_command = new SqlCommand("update ChannelCheck SET status = '" + state + "' WHERE id = " + id_check.ToString(), sql_conn);
            sql_command.ExecuteNonQuery();
        }
        catch { return; }
        finally { sql_conn.Close(); }
    }
    [WebMethod]
    public List<eTypeTN> GetTypeTN()
    {
        try
        {
            sql_conn = new SqlConnection(System.Configuration.ConfigurationManager.ConnectionStrings[0].ConnectionString);
            sql_conn.Open();
            DataTable table_transportnetwork = new DataTable();
            SqlDataAdapter adTN = new SqlDataAdapter();
            adTN.SelectCommand = new SqlCommand(@"SELECT * FROM Mediumstyles ", sql_conn);
            adTN.Fill(table_transportnetwork);
            List<eTypeTN> list_tn = new List<eTypeTN>();
            eTypeTN el_tn;
            /****************************** ЗАПОЛНЕНИЕ СПИСКА ****************************************************/
            foreach (DataRow row in table_transportnetwork.Rows)
            {
                el_tn.id = row.Field<int>("style_id");
                el_tn.name_tn = row.Field<string>("style_name");
                list_tn.Add(el_tn);
            }

            return list_tn;
        }
        catch { return null; }
        finally { sql_conn.Close(); }
    }
    [WebMethod]
    public List<eCds> GetCds(int id_period,string site)
    {
        try
        {
            sql_conn = new SqlConnection(System.Configuration.ConfigurationManager.ConnectionStrings[0].ConnectionString);
            sql_conn.Open();
            DataSet dataset = new DataSet();
            SqlDataAdapter adSites = new SqlDataAdapter();
            adSites.SelectCommand = new SqlCommand(@"EXEC pListStations", sql_conn);
            adSites.Fill(dataset, "Sites");
            SqlDataAdapter adCds = new SqlDataAdapter();
            adCds.SelectCommand = new SqlCommand(@"SELECT Cds.* FROM (SELECT distinct cds_id FROM Intervalmode im JOIN cdsitems ci ON im.id = ci.period_id WHERE period_id = " + id_period.ToString() + " AND attachment is not null) t1 join cds on t1.cds_id = Cds.id", sql_conn);
            adCds.Fill(dataset, "Cds");
            List<eSite> list_site = new List<eSite>();  
            eSite el_site;
            /******************************ЗАПОЛНЕНИЕ СТРУКТУРЫ УЗЛОВ****************************************************/

            foreach (DataRow row in dataset.Tables["Sites"].Rows)
            {
                el_site.id = row.Field<int>(0);
                el_site.callsign_site = row.Field<string>(1);
                list_site.Add(el_site);
            }
            eCds el_cds;
            List<eCds> list_cds = new List<eCds>();
            if (site == string.Empty)
                foreach (DataRow row in dataset.Tables["Cds"].Rows)
                {
                    el_cds.id = row.Field<int>(0);
                    el_cds.name_cds = list_site.Find(p => p.id == row.Field<int>(1)).callsign_site + " - " + list_site.Find(p => p.id == row.Field<int>(2)).callsign_site;
                    string find_in_listCds = list_cds.Find((pp => pp.name_cds == (list_site.Find(p1 => p1.id == row.Field<int>(2)).callsign_site + " - " + list_site.Find(p2 => p2.id == row.Field<int>(1)).callsign_site))).name_cds;
                    if (find_in_listCds != list_site.Find(p => p.id == row.Field<int>(2)).callsign_site + " - " + list_site.Find(p => p.id == row.Field<int>(1)).callsign_site)
                        list_cds.Add(el_cds);
                }
            else
                foreach (DataRow row in dataset.Tables["Cds"].Rows)
                {
                    el_cds.id = row.Field<int>(0);
                    el_cds.name_cds = list_site.Find(p => p.id == row.Field<int>(1)).callsign_site + " - " + list_site.Find(p => p.id == row.Field<int>(2)).callsign_site;
                    if (list_site.Find(p => p.id == row.Field<int>(1)).callsign_site == site)
                    list_cds.Add(el_cds);
                }
            return list_cds;
        }
        catch { return null; }
        finally { sql_conn.Close(); }
    }
    //********************************************************//
       public struct eTypeTN
    {
        public int id;
        public string name_tn;
        
    }
    public struct eVarOfPlane
    {
        public int id_var;
        public string name_var;
        public string dt_from;
        public string dt_to;
        public string state;
        public string mode;

    }
    public struct VarOfPlane
    {
        public string Name_var;
        public int id_var;
    }
    public struct eChannel
    {
        public int id;
        public int cds_id;
        public string name_channel;
        public string attachment;
        public int style;
        public string capacity;
        public string num_block;
    }
    public struct eCds 
    {
        public int id;
        public string name_cds;
    }
    public struct ePeriod
    {
        public int id;
        public string mode;
        public int t_from;
        public int t_throught;
    }
    public struct eSite
    {
        public int id;
        public string callsign_site;
    }
    private static string[] System_TN = { "Проводная", "Спутниковая" };
    private static string[] TypeTest = { "Проверка состояния", "Измерение параметров" };

}



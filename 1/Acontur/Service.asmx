<%@ WebService Language="C#" Class="WebServiceAcontur.Service1" %>
using System;
using System.Collections;
using System.ComponentModel;
using System.Data;
using System.Linq;
using System.Web;
using System.Web.Services;
using System.Web.Services.Protocols;
using System.Xml.Linq;
using System.Data.SqlClient;
using System.Collections.Generic;
using System.Configuration;
using CrystalDecisions.CrystalReports.Engine;
using CrystalDecisions.ReportSource;
using CrystalDecisions.Shared;

namespace WebServiceAcontur
{
    /// <summary>
    /// Сводное описание для Service1
    /// </summary>
    /// 
    [WebService(Namespace = "http://tempuri.org/")]
    [WebServiceBinding(ConformsTo = WsiProfiles.BasicProfile1_1)]
    [ToolboxItem(false)]
    // Чтобы разрешить вызывать веб-службу из сценария с помощью ASP.NET AJAX, раскомментируйте следующую строку. 
    // [System.Web.Script.Services.ScriptService]
    
    public class Service1 : System.Web.Services.WebService
    {
        //private  SqlConnection sql_conn;
        private string conectionstring {get;set;}
        private  DataSet dataset = new DataSet();
        //[WebMethod]
        //public string GetConnectionString()
        //{
        //    conectionstring = ConfigurationManager.ConnectionStrings[0].ConnectionString;
        //    return conectionstring; }
        public Service1()
        {
            this.Initialize();
            
        }
        private void Initialize()
        {
            try
            {
                listNdr.Clear();
                listStations.Clear();
                /*************************** ЗАПОЛНЕНИЕ ЗАДАНИЙ  ********************************/
                conectionstring = ConfigurationManager.ConnectionStrings[0].ConnectionString;
                
            }
            catch
            { return ; }
        }
        [WebMethod]
        public DataTable GetTableOrders(string addrequest)
        {
            SqlConnection sql_conn = null;
            try
            {
                sql_conn = new SqlConnection(conectionstring);
                sql_conn.Open();
                SqlDataAdapter adDC = new SqlDataAdapter();
                adDC.SelectCommand = new SqlCommand(@"SELECT id,type_mesg,text,date_send,date_performance,date_exec,addresse_NDR,addresse_site, sender_NDR,sender_site,priory,status FROM DC WHERE parrent is NULL " +addrequest, sql_conn);
                //if (ndr != string.Empty && adr_site != string.Empty)
               //     adDC.SelectCommand = new SqlCommand(@"SELECT id,type_mesg,text,date_send,date_performance,date_exec,addresse_NDR,addresse_site, sender_NDR,sender_site,priory,status FROM DC WHERE parrent is NULL AND ((addresse_NDR = '" + ndr + "' AND addresse_site ='" + adr_site + "')  OR (sender_ndr = '" + ndr + "' AND sender_site = '" + adr_site + "'))", sql_conn);
               // if (ndr == string.Empty && adr_site == string.Empty)
                //    adDC.SelectCommand = new SqlCommand(@"SELECT id,type_mesg,text,date_send,date_performance,date_exec,addresse_NDR,addresse_site,sender_NDR,sender_site,priory,status FROM DC WHERE parrent is NULL", sql_conn);
                adDC.Fill(dataset, "Orders");
                
            }
            catch { return null; }
            finally { sql_conn.Close(); }
            return dataset.Tables["Orders"];
        }
        [WebMethod]
        public DataTable GetTableReports(int parrentOrder)
        {
            SqlConnection sql_conn = null;
            try
            {
                sql_conn = new SqlConnection(conectionstring);
                sql_conn.Open();
                SqlDataAdapter adRep = new SqlDataAdapter();
                if (parrentOrder > 0)
                    adRep.SelectCommand = new SqlCommand(@"SELECT id,text,date_send,addresse_NDR,sender_NDR,addresse_site,sender_site FROM DC WHERE parrent is not null AND parrent =" + parrentOrder.ToString(), sql_conn);
                else
                    adRep.SelectCommand = new SqlCommand(@"SELECT id,text,date_send,addresse_NDR,sender_NDR,addresse_site,sender_site FROM DC WHERE parrent is not null", sql_conn); ;
                adRep.Fill(dataset, "Reports");

            }
            catch { return null; }
            finally { sql_conn.Close(); }
            return dataset.Tables["Reports"];
        }
        [WebMethod]
        public int GetCountMessgAndOrders(string Site,string Ndr)
        {
            SqlConnection sql_conn = null;
             int count;
             try
             {
                sql_conn = new SqlConnection(conectionstring);
                if (sql_conn.State != ConnectionState.Open)
                    sql_conn.Open();
                SqlDataAdapter ad = new SqlDataAdapter();
                 DataTable t = new DataTable("Count");
                ad.SelectCommand = new SqlCommand(@"select count(id) from dc where type_mesg not like '%исок%' and type_mesg not like '%оклад%' and addresse_ndr like '"+Ndr+"' and addresse_site like '"+Site+"'", sql_conn);
                ad.Fill(dataset, "Count");

                count = dataset.Tables["Count"].Rows[0].Field<int>(0);
               
                return count;
                }
                catch{return -1;}
               // return count;
        }

        [WebMethod]
        public string[] GetMessageStatus()
        {
            return MessageStatus;
        }
        [WebMethod]
        public string[] GetMessageType(int role)
        {
            //if (role == 0)
            //    return MessageType1;
            //if (role == 1)
            //    return MessageType1;
            //if (role == 2)
            //    return MessageType2;
            //if(role == 3)
                return MessageType;
           // return null;
        }
        [WebMethod]
        public string[] GetMessagePriory()
        {
            return MessagePriory;
        }
        [WebMethod]
        public string[] GetFilterCategory()
        {
            return FilterCategory;
        }
        [WebMethod]
        public string[] GetSiteList()
        {
            SqlConnection sql_conn = null;
            List<string> listsite = new List<string>();
            try{
                sql_conn = new SqlConnection(conectionstring);
                SqlDataAdapter adSites = new SqlDataAdapter();
                adSites.SelectCommand = new SqlCommand(@"EXEC pListStations", sql_conn);
                adSites.Fill(dataset, "Sites");
                eStations el_site;
                int id_site;
                string callsing;
                /******************************ЗАПОЛНЕНИЕ СТРУКТУРЫ УЗЛОВ****************************************************/
                foreach (DataRow txt in dataset.Tables["Sites"].Rows)
                {
                    id_site = txt.Field<int>(0);
                    callsing = txt.Field<string>(1);
                    el_site.StationId = id_site;
                    el_site.StationsName = callsing;
                    listStations.Add(el_site);
                }
            
                foreach (eStations el in listStations)
                    listsite.Add(el.StationsName);
            
                }catch{return null;}
            return listsite.ToArray();
        }
        [WebMethod]
        public string[] GetInfoFunctionary(int id)
        {
            SqlConnection sql_conn = null;
            string[] result = new string[4]; // 0 - роль, 1 - ндр(string), 2 - позывной узла, 3- ндр(int)
            try
            {
                sql_conn = new SqlConnection(conectionstring);
                if (sql_conn.State != ConnectionState.Open)
                    sql_conn.Open();
                SqlDataAdapter adFI = new SqlDataAdapter();
                adFI.SelectCommand = new SqlCommand(@"select id,nd,site_id,(SELECT number FROM NumberDuty WHERE id = nd AND id >0),role_id from (select fi.*,l.role_id from FunctionaryInfo fi join logins l on fi.functionary_id = l.functionary_id ) as t1 where id = " + id.ToString(), sql_conn);
                adFI.Fill(dataset, "Users");
                DataRow txt = dataset.Tables["Users"].Rows[0];
               
                result[0] = txt.Field<int>(4).ToString();
                result[1] = txt.Field<string>(3).ToString();
                result[3] = txt.Field<int>(1).ToString();
                int siteid = txt.Field<int>(2);
                this.GetSiteList();
                foreach (eStations el_site in listStations)
                {
                    if (el_site.StationId == siteid)
                        result[2] = el_site.StationsName;
                   // else result[2] = "";
                }
            }
            catch { }
            finally { sql_conn.Close(); }
            
            return result;
        }
        [WebMethod]
        public List<eNdr> GetNdrList()
        {
            SqlConnection sql_conn = null;
            try
            {
                sql_conn = new SqlConnection(conectionstring);
                List<eNdr> listndr = new List<eNdr>();
                SqlDataAdapter adSiteNdr = new SqlDataAdapter();
                DataTable t = new DataTable("listNdr");
                /*************************** ЗАПОЛНЕНИЕ СТРУКТУРЫ НДР  ********************************/
                adSiteNdr.SelectCommand = new SqlCommand(@"select * from dutyposts", sql_conn);
                adSiteNdr.Fill(t);
                eNdr el;
                foreach (DataRow row in t.Rows)
                {
                    el.Post = row.Field<string>("numberofpost");
                    el.NdrName = row.Field<string>("numberofduty");
                    el.callsingSite = row.Field<string>("site");
                    listndr.Add(el);
                }
                return listndr;
            }
            catch { return null; }
            finally { sql_conn.Close(); }

            
        }
        [WebMethod]
        public List<eNdr> GetNdrListOnSite(string site)
        {
            SqlConnection sql_conn = null;
            try
            {
                sql_conn = new SqlConnection(conectionstring);
                List<eNdr> listndr = new List<eNdr>();
                SqlDataAdapter adSiteNdr = new SqlDataAdapter();
                DataTable t = new DataTable("listNdr");
                /*************************** ЗАПОЛНЕНИЕ СТРУКТУРЫ НДР  ********************************/
                adSiteNdr.SelectCommand = new SqlCommand(@"select * from dutyposts where site = '" + site + "'", sql_conn);
                adSiteNdr.Fill(t);
                eNdr el;
                foreach (DataRow row in t.Rows)
                {
                    el.Post = row.Field<string>("numberofpost");
                    el.NdrName = row.Field<string>("numberofduty");
                    el.callsingSite = row.Field<string>("site");
                    listndr.Add(el);
                }
                return listndr;
            }
            catch { return null; }
            finally { sql_conn.Close(); }


        }
        //**********************************Меняет статус задания на "ознакомлен" *************************************/
        [WebMethod]
        public bool UpdateStatusOrderOnAcquaint(int id)
        {
            SqlConnection sql_conn = null;
            try
            {
                sql_conn = new SqlConnection(conectionstring);
                if (id > 0)
                {
                    if (sql_conn.State == ConnectionState.Closed)
                        sql_conn.Open();
                    SqlCommand sql_command = new SqlCommand("update DC SET status = '" + MessageStatus[1] + "' WHERE id = " + id.ToString(), sql_conn);
                    sql_command.ExecuteNonQuery();
                    sql_conn.Close();
                }
            }
            catch { return false; }
            return true;
        }
        //**********************************Меняет статус задания на "отменён" *************************************/
        [WebMethod]
        public bool UpdateStatusOrderOnCancel(int id)
        {
            SqlConnection sql_conn = null;
            try
            {
                sql_conn = new SqlConnection(conectionstring);
                if (id > 0)
                {
                    if (sql_conn.State == ConnectionState.Closed)
                        sql_conn.Open();
                    SqlCommand sql_command = new SqlCommand("update DC SET status = '" + MessageStatus[3] + "' WHERE id = " + id.ToString(), sql_conn);
                    sql_command.ExecuteNonQuery();
                    sql_conn.Close();
                }
            }
            catch { return false; }
            return true;
        }
        [WebMethod]
        public bool TransferDate(int id, DateTime TransferOn, bool what) // если бул "тру", то переноситя время исполнения, иначе время приступления к выполнению
        {
            SqlConnection sql_conn = null;
            try
            {
                sql_conn = new SqlConnection(conectionstring);
                if (id > 0)
                {
                    if (sql_conn.State == ConnectionState.Closed)
                        sql_conn.Open();
                    SqlCommand sql_command;
                    if(what)
                        sql_command = new SqlCommand("update DC SET date_exec = '" + TransferOn.ToShortDateString() + " " + TransferOn.ToLongTimeString() + "' WHERE id = " + id.ToString(), sql_conn);
                    else
                        sql_command = new SqlCommand("update DC SET date_performance = '" + TransferOn.ToShortDateString() + " " + TransferOn.ToLongTimeString() + "' WHERE id = " + id.ToString(), sql_conn);
                    sql_command.ExecuteNonQuery();
                    sql_conn.Close();
                }
            }
            catch { return false; }
            return true;
        }
        [WebMethod]
        public bool EditOrder(int id, string text, string addr_ndr, string addr_site, string priory,string status, DateTime date_perf, DateTime date_exec) // если бул "тру", то переноситя время исполнения, иначе время приступления к выполнению
        {
            SqlConnection sql_conn = null;
            try
            {
                sql_conn = new SqlConnection(conectionstring);
                List<eNdr> listNdr = this.GetNdrListOnSite(addr_site);
                if (id > 0)
                {
                    foreach (eNdr val1 in listNdr)
                    {
                        if (addr_ndr.IndexOf(val1.NdrName) > -1 && addr_site.IndexOf(val1.callsingSite) > -1)
                        {
                            if (sql_conn.State == ConnectionState.Closed)
                                sql_conn.Open();
                            SqlCommand sql_command;
                            sql_command = new SqlCommand("update DC SET text = '" + text + "',priory = '" + priory + "',addresse_ndr = '" + val1.NdrName + "',addresse_site = '" + addr_site + "',date_exec = '" + date_exec + "',date_performance = '" + date_perf + "',status = '" + status + "' WHERE id = " + id.ToString(), sql_conn);
                            sql_command.ExecuteNonQuery();
                            sql_conn.Close();
                        }
                    }
                }
            }
            catch { return false; }
            finally { sql_conn.Close(); }
            return true;
        }
        [WebMethod]
        public bool ReportOnOrder(int id_parent, string text, string ndr_addr, string site_addr, string ndr_sender, string site_sender)
        {
            SqlConnection sql_conn = null;
            //int varNdrAddr = 0;
            try
            {
                sql_conn = new SqlConnection(conectionstring);
                if (sql_conn.State != ConnectionState.Open)
                    sql_conn.Open();
                //this.GetNdrListOnSite(site_addr);
                string sql_qwery = "INSERT INTO DC VALUES ('Доклад','" + text + "'," + id_parent.ToString() + ",'" + DateTime.Now + "','" + DateTime.Now + "','" + DateTime.Now + "','" + ndr_addr + "','" + site_addr + "','" + ndr_sender + "','" + site_sender + "','-','-')";
                SqlCommand sql_command = new SqlCommand(sql_qwery, sql_conn);
                sql_command.ExecuteNonQuery();
                if (id_parent > 0)
                {
                    sql_command = new SqlCommand("update DC SET status = 'Выполнено' WHERE id = " + id_parent.ToString(), sql_conn);
                    sql_command.ExecuteNonQuery();
                }
                return true;
            }

            catch { return false; }
            finally { sql_conn.Close(); }
        }
        [WebMethod]
        public bool CreateOrder(string type_mesg, string text, string date_performance, string date_exec, string addresse_NDR, string addresse_site, string sender_NDR, string sender_site, string priory, string status)
        {
            SqlConnection sql_conn = null;
            try
            {
                sql_conn = new SqlConnection(conectionstring);
                if (sql_conn.State == ConnectionState.Closed)
                    sql_conn.Open();
                string sql_qwery = "INSERT INTO DC VALUES ('" + type_mesg + "','" + text + "'," + "NULL" + ",'" + DateTime.Now + "','" + date_performance + "','" + date_exec + "','" + addresse_NDR + "','" + addresse_site + "','" + sender_NDR + "','" + sender_site + "','"+priory+"','"+status+"')";
                SqlCommand sql_command = new SqlCommand(sql_qwery, sql_conn);
                sql_command.ExecuteNonQuery();
            }
            catch { return false; }
            finally { sql_conn.Close(); }
            return true;
        }
        //*******************************************КЛАСС С ДАННЫМИ***************************************************/
        [WebMethod]
        public List<ePosts> GetListPosts()
        {
            SqlConnection sql_conn = null;
            List<ePosts> list_posts = new List<ePosts>();
            try
            {
                sql_conn = new SqlConnection(conectionstring);
                if (sql_conn.State != ConnectionState.Open)
                    sql_conn.Open();
                DataTable Posts = new DataTable("Posts");
                SqlDataAdapter adP = new SqlDataAdapter();
                adP.SelectCommand = new SqlCommand(@"select id,parent,name,(select (SELECT ss.callsing from fListStations(3) ss where id = el2.id) from elements el2 where el1.parent = el2.id)  as callsignsite from elements el1 where class = 'room'", sql_conn);
                adP.Fill(Posts);
                ePosts el;
                foreach (DataRow row in Posts.Rows)
                {
                    el.name_post = row.Field<string>("name");
                    el.sitecallsign = row.Field<string>("callsignsite");
                    list_posts.Add(el);
                }
                return list_posts;
            }
            catch { return null;}
            finally { sql_conn.Close(); }
        
        }
        [WebMethod]
        public void InsertNdr(string numberofduty,string numberofpost,string site)
        {
            SqlConnection sql_conn = null;
            try
            {
                sql_conn = new SqlConnection(conectionstring);
                if (sql_conn.State != ConnectionState.Open)
                    sql_conn.Open();
                SqlCommand adP = new SqlCommand(@"insert into dutyposts values ('" + numberofduty + "','" + numberofpost + "','" + site + "')", sql_conn);
                adP.ExecuteNonQuery();
            }
            catch {}
            finally { sql_conn.Close(); }

        }
        [WebMethod]
        public void DeleteNdr(string numberofduty, string numberofpost, string site)
        {
            SqlConnection sql_conn = null;
            try
            {
                sql_conn = new SqlConnection(conectionstring);
                if (sql_conn.State != ConnectionState.Open)
                    sql_conn.Open();
                SqlCommand adP = new SqlCommand(@"delete from dutyposts where numberofduty = '" + numberofduty + "' AND numberofpost = '" + numberofpost + "' AND site = '" + site + "'", sql_conn);
                adP.ExecuteNonQuery();
            }
            catch { }
            finally { sql_conn.Close(); }

        }
        [WebMethod]
        public string[] GetNumberofDuty()
        {
            SqlConnection sql_conn = null;
            List<string> list_nd = new List<string>();
            try
            {
                sql_conn = new SqlConnection(conectionstring);
                if (sql_conn.State != ConnectionState.Open)
                    sql_conn.Open();
                DataTable t = new DataTable("NumberofDuty");
                SqlDataAdapter adP = new SqlDataAdapter();
                adP.SelectCommand = new SqlCommand(@"select number from numberduty", sql_conn);
                adP.Fill(t);
                foreach (DataRow row in t.Rows)
                {
                    list_nd.Add(row.Field<string>("number"));
                }
                return list_nd.ToArray();
            }
            catch { return null; }
            finally { sql_conn.Close(); }

        }
        [WebMethod]
        public string GetTimeChange()
        {
            SqlConnection sql_conn = null;
            string timechange;
            try
            {
                sql_conn = new SqlConnection(conectionstring);
                if (sql_conn.State != ConnectionState.Open)
                    sql_conn.Open();
                DataTable t = new DataTable("params");
                SqlDataAdapter adP = new SqlDataAdapter();
                adP.SelectCommand = new SqlCommand(@"select value from params where class = 10", sql_conn);
                adP.Fill(t);
               // row = t.Rows[0]
                timechange = t.Rows[0].Field<string>("value");
                return timechange;
            }
            catch { return null; }
            finally { sql_conn.Close(); }

        }
        [WebMethod]
        public void SetTimeChange(string date)
        {
            SqlConnection sql_conn = null;
            try
            {
                sql_conn = new SqlConnection(conectionstring);
                if (sql_conn.State != ConnectionState.Open)
                    sql_conn.Open();
                SqlCommand adP = new SqlCommand(@"update params SET value = '" + date + "' where class = 10" , sql_conn);
                adP.ExecuteNonQuery();
            }
            catch { }
            finally { sql_conn.Close(); }


        }
        [WebMethod]
        public void AddStandartMessage(string question)
        {
            SqlConnection sql_conn = null;
            try
            {
                sql_conn = new SqlConnection(conectionstring);
                if (sql_conn.State != ConnectionState.Open)
                    sql_conn.Open();
                SqlCommand adP = new SqlCommand(@"insert params(class,value) Values (20,'" + question + "') ", sql_conn);// + date + "' where class = 10", sql_conn);
                adP.ExecuteNonQuery();
            }
            catch { }
            finally { sql_conn.Close(); }


        }
         [WebMethod]
        public void AddStandartTask(string question)
        {
            SqlConnection sql_conn = null;
            try
            {
                sql_conn = new SqlConnection(conectionstring);
                if (sql_conn.State != ConnectionState.Open)
                    sql_conn.Open();
                SqlCommand adP = new SqlCommand(@"insert params(class,value) Values (30,'" + question + "') ", sql_conn);// + date + "' where class = 10", sql_conn);
                adP.ExecuteNonQuery();
            }
            catch { }
            finally { sql_conn.Close(); }


        }
          [WebMethod]
        public void AddStandartAnswer(string answer)
        {
            SqlConnection sql_conn = null;
            try
            {
                sql_conn = new SqlConnection(conectionstring);
                if (sql_conn.State != ConnectionState.Open)
                    sql_conn.Open();
                SqlCommand adP = new SqlCommand(@"insert params(class,value) Values (40,'" + answer + "') ", sql_conn);// + date + "' where class = 10", sql_conn);
                adP.ExecuteNonQuery();
            }
            catch { }
            finally { sql_conn.Close(); }


        }
          [WebMethod]
          public void DelStandart(string value)
          {
              SqlConnection sql_conn = null;
              try
              {
                  sql_conn = new SqlConnection(conectionstring);
                  if (sql_conn.State != ConnectionState.Open)
                      sql_conn.Open();
                  SqlCommand adP = new SqlCommand(@"DELETE from params WHERE Value = '" + value + "' ", sql_conn);// + date + "' where class = 10", sql_conn);
                  adP.ExecuteNonQuery();
              }
              catch { }
              finally { sql_conn.Close(); }


          }
          [WebMethod]
          public string[] GetStandartTask()
          {
              SqlConnection sql_conn = null;
              List<string> list_stdtsk = new List<string>();
              try
              {
                  sql_conn = new SqlConnection(conectionstring);
                  if (sql_conn.State != ConnectionState.Open)
                      sql_conn.Open();
                  DataTable t = new DataTable("Std_Task");
                  SqlDataAdapter adP = new SqlDataAdapter();
                  adP.SelectCommand = new SqlCommand(@"select value from params where class = 30", sql_conn);
                  adP.Fill(t);
                  foreach (DataRow row in t.Rows)
                  {
                      list_stdtsk.Add(row.Field<string>("value"));
                  }
                  return list_stdtsk.ToArray();
              }
              catch { return null; }
              finally { sql_conn.Close(); }

          }
          [WebMethod]
          public string[] GetStandartMessage()
          {
              SqlConnection sql_conn = null;
              List<string> list_stdmsg = new List<string>();
              try
              {
                  sql_conn = new SqlConnection(conectionstring);
                  if (sql_conn.State != ConnectionState.Open)
                      sql_conn.Open();
                  DataTable t = new DataTable("Std_Msg");
                  SqlDataAdapter adP = new SqlDataAdapter();
                  adP.SelectCommand = new SqlCommand(@"select value from params where class = 20", sql_conn);
                  adP.Fill(t);
                  foreach (DataRow row in t.Rows)
                  {
                      list_stdmsg.Add(row.Field<string>("value"));
                  }
                  return list_stdmsg.ToArray();
              }
              catch { return null; }
              finally { sql_conn.Close(); }

          }
          [WebMethod]
          public string[] GetStandartAnswer()
          {
              SqlConnection sql_conn = null;
              List<string> list_stdans = new List<string>();
              try
              {
                  sql_conn = new SqlConnection(conectionstring);   
                  if (sql_conn.State != ConnectionState.Open)
                      sql_conn.Open();
                  DataTable t = new DataTable("Std_Answer");
                  SqlDataAdapter adP = new SqlDataAdapter();
                  adP.SelectCommand = new SqlCommand(@"select value from params where class = 40", sql_conn);
                  adP.Fill(t);
                  foreach (DataRow row in t.Rows)
                  {
                      list_stdans.Add(row.Field<string>("value"));
                  }
                  return list_stdans.ToArray();
              }
              catch { return null; }
              finally { sql_conn.Close(); }

          }
            static public string[] MessageStatus = { "Не выполнено", "Ознакомлен", "Выполнено","Отменен" };
            static public string[] MessageType = { "Распоряжение", "Приказание", "Извещение" };
            static public string[] MessageType2 = { "Распоряжение", "Извещение" };
            static public string[] MessageType3 = { "Информация"};
            static public string[] MessagePriory = { "Важно", "Срочно", "Норма" };
            static public string[] FilterCategory = { "Узлу отправителя", "Узлу получателя", "НДР получателя", "НДР отправителя", "Статус", "Приоритет", "Характер" };
            static public List<eNdr> listNdr = new List<eNdr>();
            public struct eNdr
            {
                public string NdrName;
                public string callsingSite;
                public string Post;
            }
            //список Узлов
            public static List<eStations> listStations = new List<eStations>();
            public struct eStations
            {
                public string StationsName;
                public int StationId;
            }
            public struct ePosts
            {
                public string sitecallsign;
                public string name_post;
            }
            //static public int NDR;
            //static public string Site;

        
    }
   
}

<%@ webservice language="C#" class="FuncForReports" %>

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
public class FuncForReports : WebService //ReportServiceBase
{
    //---------------------------------------------------------------




    //---------------------------------------------------------------
    
    private static string cs;
    public FuncForReports() { }
   
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
    
   
    
}



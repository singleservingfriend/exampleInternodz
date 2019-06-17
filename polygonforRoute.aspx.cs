using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Linq;
using System.Web;
using System.Web.Configuration;
using System.Web.UI;
using System.Web.UI.WebControls;

public partial class deliverer_tryPolygonforRoute : System.Web.UI.Page
{
    protected void Page_Load(object sender, EventArgs e)
    {
        if (Session["SEusid"] == null)
        {
            Response.Redirect("~/index.aspx");
        }

        int usertype = Convert.ToInt32(((DataView)sqldatacheck.Select(DataSourceSelectArguments.Empty))[0]["usertype"].ToString());
        if (usertype != 2)
        {
            Response.Redirect("~/Default.aspx");
        }

        if (Request.QueryString["start"] == null || Request.QueryString["end"] == null || Request.QueryString["distance"] == null || Request.QueryString["start"].Equals("") || Request.QueryString["end"].Equals("") || Request.QueryString["distance"].Equals(""))
        {
            Response.Redirect("addDelivery.aspx");
        }

        if (!IsPostBack)
        {
            SqlConnection con = new SqlConnection(WebConfigurationManager.ConnectionStrings["interCs"].ToString());
            SqlCommand command = new SqlCommand();
            command.Connection = con;
            command.CommandText = "SELECT users.userId, nods.latitude, users.defaultpoint, nods.longitude FROM users INNER JOIN nods ON users.userId = nods.userId AND users.defaultpoint = nods.node_id WHERE ((users.whichcity = " + Session["SEcity"] + ") AND (usertype = 1 OR usertype = 5) AND (active = 1))";
            con.Open();
            SqlDataReader dr = command.ExecuteReader();

            List<DefaultArray> list = new List<DefaultArray>();

            while (dr.Read())
            {
                DefaultArray itemList = new DefaultArray
                {
                    Latitude = dr["latitude"].ToString(),
                    Longitude = dr["longitude"].ToString(),
                    UserId = dr["userId"].ToString()
                };
                list.Add(itemList);
            }
            int i = 1;
            foreach (DefaultArray item in list)
            {
                sentstring.Value = sentstring.Value + (item.UserId + "-" + item.Latitude + "," + item.Longitude);
                if (i != list.Count) { sentstring.Value += '&'; }
                i++;
            }
        }

    }

    public class DefaultArray
    {
        public string Latitude { get; set; }
        public string Longitude { get; set; }
        public string UserId { get; set; }
    }
}

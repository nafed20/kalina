using System;
using System.Web;
using System.Collections.Generic;
using System.Linq;
using System.Runtime.Serialization;
using System.ServiceModel;
using System.Text;
using System.IO;
using System.Drawing;
using System.Drawing.Imaging;
using DAL;

// NOTE: If you change the class name "Service" here, you must also update the reference to "Service" in Web.config and in the associated .svc file.
[ServiceBehavior(InstanceContextMode = InstanceContextMode.Single, ConcurrencyMode = ConcurrencyMode.Single)]
public class SqlProviderService : ISqlProviderService
{
    #region Схема
    
    public List<ItemDetails> LoadSites(int schema_id, out ErrCode err)
    {
        err = new ErrCode();

        List<ItemDetails> sites = SiteProvider.CurrentProvider.GetSites(schema_id, out err);

        return sites;
    }
    
    public List<SchemaDetails> GetListOfSchemes(out ErrCode err)
    {
        err = null;
        List<SchemaDetails> schemes = SiteProvider.CurrentProvider.GetListOfSchemes(out err);

        return schemes;
    }
    
    public List<ItemDetails> GetSchema(int schema_id, out ErrCode err)
    {
        err = null;
        List<ItemDetails> schema = SiteProvider.CurrentProvider.GetSchema(schema_id, out err);
        return schema;
    }
    
    public void DeleteSchema(int schema_id, out ErrCode err)
    {
        err = null;
        SiteProvider.CurrentProvider.DeleteSchema(schema_id, out err);
    }
    
    public ErrCode SaveSchema(ItemDetails[] schema, out ItemDetails[] so)
    {
        so = null;

        ErrCode err = SiteProvider.CurrentProvider.SaveSchema(schema, out so);

        return err;
    }
    #region Сохранение схемы в транзакции
    
    public ErrCode SaveSchemaTran(ItemDetails[] schema, out ItemDetails[] so)
    {
        so = null;

        ErrCode err = SiteProvider.CurrentProvider.SaveSchemaTran(schema, out so);

        return err;
    }

    #endregion
    #region Элементы первого уровня узла
    
    public List<ItemDetails> LoadElementsOfFirstLevel(int site_id, out ErrCode err)
    {
        err = new ErrCode();
        List<ItemDetails> elements = SiteProvider.CurrentProvider.LoadElementsOfFirstLevel(site_id, out err);

        return elements;
    }
    #endregion
    #region Удаление элемента
    public void DeleteElement(int element_id, out ErrCode err)
    {
        SiteProvider.CurrentProvider.DeleteElement(element_id, out err);
    }
    #endregion
    #endregion

    #region НСИ
    #region Элементы НСИ
    public List<ItemDetails> LoadUnits(int parent_id, out ErrCode err)
    {
        err = new ErrCode();
        List<ItemDetails> elements = SiteProvider.CurrentProvider.LoadUnits(parent_id, out err);

        return elements;
    }
    #endregion
    #endregion

    #region Подразделение, НДР
    public List<Subdivision> GetSubdivisions(out ErrCode err)
    {
        err = null;
        List<Subdivision> subdivisions = SiteProvider.CurrentProvider.LoadSubdivisions(out err);

        return subdivisions;
    }
    public List<NumberDuty> GetND(out ErrCode err)
    {
        err = null;
        List<NumberDuty> nds = SiteProvider.CurrentProvider.LoadND(out err);

        return nds;
    }
    #endregion
    #region Пользователи
    
    public List<RolesDetails> GetRoles(out ErrCode err)
    {
        err = null;

        List<RolesDetails> rds = SiteProvider.CurrentProvider.LoadRoles(out err);

        return rds;
    }
    
    public void SaveFunctionary(FunctionaryDetails fd, out int id, out ErrCode err)
    {
        err = null;
        id = 0;
        SiteProvider.CurrentProvider.SaveFunctionary(fd, out id, out err);
    }
    
    public void UpdateFunctionary(FunctionaryDetails fd, out ErrCode err)
    {
        err = null;

        SiteProvider.CurrentProvider.UpdateFunctionary(fd, out err);
    }
    
    public void DeleteFunctionary(int functionary_id, out ErrCode err)
    {
        err = null;
        SiteProvider.CurrentProvider.DeleteFunctionary(functionary_id, out err);
    }
    
    public List<FunctionaryDetails> LoadFunctionaries(out ErrCode err)
    {
        err = null;
        List<FunctionaryDetails> fds = SiteProvider.CurrentProvider.LoadFunctionaries(out err);

        return fds;
    }
    
    public LoginDetails LoadLogin(int functionary_id, out ErrCode err)
    {
        err = null;

        return SiteProvider.CurrentProvider.GetLogin(functionary_id, out err);
    }
    
    public void SaveLogin(int functionary_id, string login, string password, int role_id, out ErrCode err)
    {
        err = null;
        SiteProvider.CurrentProvider.SaveLogin(functionary_id, login, password, role_id, out err);
    }
    
    public ErrCode AuthenticateUser(LoginDetails login, out int functionary_id, out string role)
    {
        ErrCode err = SiteProvider.CurrentProvider.AuthenticateUser(login, out functionary_id, out role);

        return err;
    }
    #endregion

    #region Дежурства
    #region Реквизиты дежурного
    
    public DutyDetails GetEssentialElementsOfDuty(int uid, out ErrCode err)
    {
        DutyDetails dd = SiteProvider.CurrentProvider.GetEssentialElementsOfDuty(uid, out err);

        return dd;
    }
    #endregion
    #region Журнал дежурств
    
    public ErrCode Duty(int functionary_id, string feature, int site_id, int arm)
    {
        ErrCode err = SiteProvider.CurrentProvider.Duty(functionary_id, feature, site_id, arm);

        return err;
    }
    #endregion
    #region Метка времени
    
    public ErrCode SetLastTime(int functionary_id)
    {
        ErrCode err = SiteProvider.CurrentProvider.SetLastTime(functionary_id);

        return err;
    }
    #endregion
    #endregion

    #region Изображения
    public List<PicturePackage> LoadIcons(out ErrCode err)
    {
        err = null;
        List<PicturePackage> icons = new List<PicturePackage>();

        try
        {
            err = new ErrCode();

            string path = System.Web.Hosting.HostingEnvironment.MapPath("/WCF/SqlProviderService");  //Server.MapPath("/WebService");
            string fullPath = path + @"\images\";

            DirectoryInfo dir = new DirectoryInfo(fullPath);
            FileInfo[] iconFiles = dir.GetFiles();


            foreach (FileInfo f in iconFiles)
            {
                if ((f.Extension == ".ico") || (f.Extension == ".ICO") || (f.Extension == ".bmp") || (f.Extension == ".png"))
                {
                    PicturePackage package = new PicturePackage();
                    System.Drawing.Image icon = System.Drawing.Image.FromFile(fullPath + f.Name);
                    MemoryStream stream = new MemoryStream();
                    icon.Save(stream, ImageFormat.Png);
                    stream.Position = 0;

                    int length = stream.GetBuffer().Length;

                    package.SegmentBuffer = new byte[length];

                    Array.Copy(stream.GetBuffer(), package.SegmentBuffer, length);

                    icons.Add(package);
                }
            }

            return icons;
        }
        catch (Exception ex)
        {
            err.Number = -1;
            err.Message = ex.Message;

            return icons;
        }
    }
    #endregion
    #region Стили
    
    public ErrCode SaveStyle(PicturePackage style, out int id)
    {
        id = -1;

        ErrCode err = SiteProvider.CurrentProvider.SaveStyle(style, out id);

        return err;
    }
    
    public List<PicturePackage> LoadStyles(out ErrCode err)
    {
        err = new ErrCode();

        List<PicturePackage> styles = SiteProvider.CurrentProvider.LoadStyles(out err);

        return styles;
    }
    
    public ErrCode DeleteStyle(int id)
    {
        ErrCode err = SiteProvider.CurrentProvider.DeleteStyle(id);

        return err;
    }
    
    public ErrCode ApplyStyle(int element_id, int style_id)
    {
        ErrCode err = SiteProvider.CurrentProvider.ApplyStyle(element_id, style_id);

        return err;
    }
    
    public PicturePackage LoadStyle(int element_id, out ErrCode err)
    {
        PicturePackage style = SiteProvider.CurrentProvider.LoadStyle(element_id, out err);

        return style;
    }
    #region Загрузка стилей кабеля
    
    public List<MediumStyle> LoadMediumStyles(out ErrCode err)
    {
        List<MediumStyle> styles = SiteProvider.CurrentProvider.LoadMediumStyles(out err);

        return styles;
    }
    #endregion
    #endregion

    #region Значки видов связи
    public ErrCode SaveImage(DAL.Image image, out int id)
    {
        id = 0;
        ErrCode err = SiteProvider.CurrentProvider.SaveImage(image, out id);

        return err;
    }
    public ErrCode DeleteImage(DAL.Image image)
    {
        ErrCode err = SiteProvider.CurrentProvider.DeleteImage(image);

        return err;
    }
    public List<DAL.Image> LoadImages(out ErrCode err)
    {
        List<DAL.Image> images = SiteProvider.CurrentProvider.LoadImages(out err);

        return images;
    }
    public DAL.Image GetImageById(int id, out ErrCode err)
    {
        return SiteProvider.CurrentProvider.GetImageById(id, out err);
    }
    public DAL.Image GetImageByName(string name, out ErrCode err)
    {
        return SiteProvider.CurrentProvider.GetImageByName(name, out err);
    }
    #endregion

    #region Загрузка портов

    public ElementPorts LoadPorts(int element_id, out ErrCode err)
    {
        err = new ErrCode();

        ElementPorts eps = SiteProvider.CurrentProvider.LoadPorts(element_id, out err);

        return eps;
    }
    
    public List<ElementPorts> LoadAllPorts(List<int> ids, out ErrCode err)
    {
        err = new ErrCode();

        List<ElementPorts> eps = SiteProvider.CurrentProvider.LoadAllPorts(ids, out err);

        return eps;
    }

    #endregion
    #region Сохранение порта
    
    public ErrCode SavePort(PortDetails port, out int id)
    {
        ErrCode err = SiteProvider.CurrentProvider.SavePort(port, out id);

        return err;
    }
    #endregion
    #region Сохранение всех портов
    
    public List<int> SavePorts(PortDetails[] ports, out ErrCode err)
    {
        List<int> ids = SiteProvider.CurrentProvider.SavePorts(ports, out err);

        return ids;
    }
    
    public List<int> SavePortsTran(PortDetails[] ports, out ErrCode err)
    {
        List<int> ids = SiteProvider.CurrentProvider.SavePortsTran(ports, out err);

        return ids;
    }

    #endregion
    #region Удаление порта
    
    public ErrCode DeletePort(int port_id)
    {
        ErrCode err = SiteProvider.CurrentProvider.DeletePort(port_id);

        return err;
    }
    #endregion

    #region Загрузка соединения порта
    
    public ErrCode LoadPortConnection(int port_id1, int port_id2, out int connection_id)
    {
        ErrCode err = SiteProvider.CurrentProvider.LoadPortConnection(port_id1, port_id2, out connection_id);

        return err;
    }
    #endregion
    #region Загрузка всех соединений порта
    
    public List<UnitDetails> LoadAllPortsConnections(out ErrCode err)
    {
        List<UnitDetails> uds = SiteProvider.CurrentProvider.LoadAllPortsConnections(out err);

        return uds;
    }
    #endregion
    #region Сохранение соединения порта
    
    public ErrCode SavePortConnection(int port_id1, int port_id2)
    {
        ErrCode err = SiteProvider.CurrentProvider.SavePortConnection(port_id1, port_id2);

        return err;
    }
    #endregion
    #region Сохранение всех соединений портов
    
    public ErrCode SaveAllPortConnection(PortConnectionDetails[] pcs)
    {
        ErrCode err = SiteProvider.CurrentProvider.SaveAllPortConnection(pcs);

        return err;
    }
    
    public ErrCode SaveAllPortConnectionTran(PortConnectionDetails[] pcs)
    {
        ErrCode err = SiteProvider.CurrentProvider.SaveAllPortConnectionTran(pcs);

        return err;
    }

    #endregion
    #region Удаление соединения порта
    
    public ErrCode DeletePortConnection(int port_id1, int port_id2)
    {
        ErrCode err = SiteProvider.CurrentProvider.DeletePortConnection(port_id1, port_id2);

        return err;
    }
    #endregion

    #region Загрузка соединения
    
    public ErrCode LoadConnection(int element_id1, int element_id2, out int connection_id)
    {
        ErrCode err = SiteProvider.CurrentProvider.LoadConnection(element_id1, element_id2, out connection_id);

        return err;
    }
    #endregion
    #region Сохранение соединения порта
    
    public ErrCode SaveConnection(int element_id1, int element_id2)
    {
        ErrCode err = SiteProvider.CurrentProvider.SaveConnection(element_id1, element_id2);

        return err;
    }
    
    public ErrCode SaveConnectionTran(int element_id1, int element_id2)
    {
        ErrCode err = SiteProvider.CurrentProvider.SaveConnectionTran(element_id1, element_id2);

        return err;
    }

    #endregion
    #region Удаление соединения
    
    public ErrCode DeleteConnection(int element_id1, int element_id2)
    {
        ErrCode err = SiteProvider.CurrentProvider.DeleteConnection(element_id1, element_id2);

        return err;
    }
    
    public ErrCode DeleteConnectionTran(int element_id1, int element_id2)
    {
        ErrCode err = SiteProvider.CurrentProvider.DeleteConnectionTran(element_id1, element_id2);

        return err;
    }

    #endregion

    #region Кабели
    #region Загрузка всех кабелей
    
    public List<MediaDetails> LoadAllMedia(out ErrCode err)
    {
        err = new ErrCode();

        List<MediaDetails> mediaList = SiteProvider.CurrentProvider.LoadAllMedia(out err);

        return mediaList;
    }
    #endregion
    #region Загрузка кабеля по его идентификатору
    
    public MediaDetails LoadMedia(int media_id, out ErrCode err)
    {
        err = new ErrCode();

        MediaDetails md = SiteProvider.CurrentProvider.LoadMedia(media_id, out err);

        return md;
    }
    #endregion
    #region Загрузка кабеля по идентификатору соединения
    
    public List<MediaDetails> LoadMediaForConnectId(int connection_id, out ErrCode err)
    {
        err = new ErrCode();

        List<MediaDetails> mediaList = SiteProvider.CurrentProvider.LoadMediaForConnectId(connection_id, out err);

        return mediaList;
    }
    #endregion
    #region Сохранение кабеля
    
    public ErrCode SaveMedia(MediaDetails media, out int id)
    {
        ErrCode err = new ErrCode();
        id = 0;
        err = SiteProvider.CurrentProvider.SaveMedia(media, out id);

        return err;
    }
    
    public ErrCode SaveMediaTran(MediaDetails media, out int id)
    {
        ErrCode err = new ErrCode();
        id = 0;
        err = SiteProvider.CurrentProvider.SaveMediaTran(media, out id);

        return err;
    }

    #endregion
    #region Удаление кабеля
    
    public ErrCode DeleteMedia(int media_id)
    {
        ErrCode err = SiteProvider.CurrentProvider.DeleteMedia(media_id);

        return err;
    }
    #endregion
    #endregion

    #region Альтернативные элементы
    
    public AlterElement LoadAlterElement(int element_id, out ErrCode err)
    {
        AlterElement ae = SiteProvider.CurrentProvider.LoadAlterElement(element_id, out err);

        return ae;
    }
    
    public List<AlterElement> LoadAlterElements(out ErrCode err)
    {
        List<AlterElement> aes = SiteProvider.CurrentProvider.LoadAlterElements(out err);

        return aes;
    }
    
    public ErrCode SaveAlterElement(AlterElement ae, out int id)
    {
        ErrCode err = SiteProvider.CurrentProvider.SaveAlterElement(ae, out id);

        return err;
    }
    
    public ErrCode SaveAlterElementTran(AlterElement ae, out int id)
    {
        ErrCode err = SiteProvider.CurrentProvider.SaveAlterElementTran(ae, out id);

        return err;
    }

    #endregion

    #region Информационные направления связи
    
    public ErrCode SaveIcd(int alter_id1, int alter_id2, out int id)
    {
        id = -1;

        ErrCode err = SiteProvider.CurrentProvider.SaveIcd(alter_id1, alter_id2, out id);

        return err;
    }
    
    public ErrCode SaveIcdTran(int alter_id1, int alter_id2, out int id)
    {
        id = -1;

        ErrCode err = SiteProvider.CurrentProvider.SaveIcdTran(alter_id1, alter_id2, out id);

        return err;
    }

    
    public List<UnitDetails> LoadAllIcd(out ErrCode err)
    {
        err = new ErrCode();
        List<UnitDetails> icds = SiteProvider.CurrentProvider.LoadAllIcd(out err);

        return icds;
    }
    
    public ErrCode DeleteIcd(int alter_id1, int alter_id2)
    {
        ErrCode err = SiteProvider.CurrentProvider.DeleteIcd(alter_id1, alter_id2);

        return err;
    }
    
    public List<IcdItem> LoadIcdItems(out ErrCode err)
    {
        List<IcdItem> icdItems = SiteProvider.CurrentProvider.LoadIcdItems(out err);

        return icdItems;
    }
    
    public ErrCode SaveIcdItem(int item_id, int icd_id, string props, out int id)
    {
        ErrCode err = SiteProvider.CurrentProvider.SaveIcdItem(item_id, icd_id, props, out id);

        return err;
    }
    
    public ErrCode DeleteIcdItem(int item_id)
    {
        ErrCode err = SiteProvider.CurrentProvider.DeleteIcdItem(item_id);

        return err;
    }
    
    public List<IcdWithNameDetails> LoadAllIcdWithNames(int workMode, out ErrCode err)
    {
        List<IcdWithNameDetails> listIcd = SiteProvider.CurrentProvider.LoadAllIcdWithNames(workMode, out err);

        return listIcd;
    }

    #endregion

    #region Направления связи
    
    public int SaveСd(int element_id1, int element_id2, out ErrCode err)
    {
        int id = SiteProvider.CurrentProvider.SaveCd(element_id1, element_id2, out err);

        return id;
    }
    
    public int SaveСdTran(int element_id1, int element_id2, out ErrCode err)
    {
        int id = SiteProvider.CurrentProvider.SaveCdTran(element_id1, element_id2, out err);

        return id;
    }

    
    public List<UnitDetails> LoadAllCd(out ErrCode err)
    {
        err = new ErrCode();
        List<UnitDetails> cds = SiteProvider.CurrentProvider.LoadAllСd(out err);

        return cds;
    }
    
    public ErrCode DeleteCd(int element_id1, int element_id2)
    {
        ErrCode err = SiteProvider.CurrentProvider.DeleteСd(element_id1, element_id2);

        return err;
    }
    
    public List<CdsItem> LoadCdsItems(int period_id, out ErrCode err)
    {
        List<CdsItem> cdsItems = SiteProvider.CurrentProvider.LoadCdsItems(period_id, out err);

        return cdsItems;
    }
    
    public ErrCode SaveCdsItem(int item_id, int cds_id, int port_id1, int port_id2, string props, string attachment, int mediumstyle_id, double capacity, int period_id, out int id)
    {
        ErrCode err = SiteProvider.CurrentProvider.SaveCdsItem(item_id, cds_id, port_id1, port_id2, props, attachment, mediumstyle_id, capacity, period_id, out id);

        return err;
    }
    
    public ErrCode DeleteCdsItem(int item_id)
    {
        ErrCode err = SiteProvider.CurrentProvider.DeleteCdsItem(item_id);

        return err;
    }

    #endregion

    #region Архивы и рабочие массивы
    
    public ErrCode CreateBackupDevice()
    {
        ErrCode err = SiteProvider.CurrentProvider.CreateBackupDevice();

        return err;
    }
    
    public ErrCode GetExpireDay(out int expire_day, out string date_overwrite)
    {
        ErrCode err = SiteProvider.CurrentProvider.GetExpireDay(out expire_day, out date_overwrite);

        return err;
    }
    
    public ErrCode SaveExpireDay(int expire_day, string date_overwrite)
    {
        ErrCode err = SiteProvider.CurrentProvider.SaveExpireDay(expire_day, date_overwrite);

        return err;
    }

    
    public ErrCode GetExpireArchive(out int expire_time, out string date_del)
    {
        ErrCode err = SiteProvider.CurrentProvider.GetExpireArchive(out expire_time, out date_del);

        return err;
    }
    
    public ErrCode SaveExpireArchive(int expire_time, string date_del)
    {
        ErrCode err = SiteProvider.CurrentProvider.SaveExpireArchive(expire_time, date_del);

        return err;
    }
    
    public ErrCode CreateBackup()
    {
        ErrCode err = SiteProvider.CurrentProvider.CreateBackup();

        return err;
    }
    
    public ErrCode DeleteStatisticDataFromWorkArray()
    {
        ErrCode err = SiteProvider.CurrentProvider.DeleteStatisticDataFromWorkArray();

        return err;
    }
    /* 
     public ErrCode UpdateExpireDay(string date_action)
     {
         //ErrCode err = SiteProvider.CurrentProvider.UpdateExpireDay(date_action);

         return err;
     }*/
    
    public ErrCode DeleteBackupDevice()
    {
        ErrCode err = SiteProvider.CurrentProvider.DeleteBackupDevice();

        return err;
    }
    
    public List<Archive> LoadAllBackup(out ErrCode err)
    {
        List<Archive> archives = null;
        archives = SiteProvider.CurrentProvider.GetAllBackup(out err);

        return archives;
    }
    
    public ErrCode RestoreFromBackup(int file)
    {
        ErrCode err = SiteProvider.CurrentProvider.RestoreDBFromBackup(file);

        return err;
    }
    
    public byte IsArchiveExist(out ErrCode err)
    {
        return SiteProvider.CurrentProvider.IsArchiveExists(out err);
    }
    #endregion

    #region Журнал событий
    
    public ErrCode WriteEvent(string message, int uid, int element_id, string code, int arm)
    {
        ErrCode err = SiteProvider.CurrentProvider.WriteEvent(message, uid, element_id, code, arm);

        return err;
    }
    #endregion 

    #region Запись изменения состояния оборудования
    
    public ErrCode WriteElementStatus(int element_id, string code, string status, int site_id)
    {
        ErrCode err = SiteProvider.CurrentProvider.WriteElementState(element_id, code, status, site_id);

        return err;
    }
    #endregion

    #region Запись изменения состояния НС
    
    public ErrCode WriteCdStatus(int cds_item, string status)
    {
        ErrCode err = SiteProvider.CurrentProvider.WriteCdStatus(cds_item, status);

        return err;
    }
    #endregion

    #region Сохранение и удаление подразделений
    
    public ErrCode SaveSubdivision(Subdivision _subdivision, out int subdivision_id)
    {
        ErrCode err = SiteProvider.CurrentProvider.SaveSubdivision(_subdivision, out subdivision_id);

        return err;
    }
    
    public ErrCode DeleteSubdivision(int subdivision_id)
    {
        ErrCode err = SiteProvider.CurrentProvider.DeleteSubdivision(subdivision_id);

        return err;
    }
    #endregion

    #region Сохранение и удаление НДР
    
    public ErrCode SaveNumberDuty(NumberDuty nd, out int number_id)
    {
        ErrCode err = SiteProvider.CurrentProvider.SaveNumberDuty(nd, out number_id);

        return err;
    }
    
    public ErrCode DeleteNumberDuty(int number_id)
    {
        ErrCode err = SiteProvider.CurrentProvider.DeleteNumberDuty(number_id);

        return err;
    }
    #endregion

    #region Сохранение, загрузка и удаление ведомств
    
    public ErrCode SaveDepartment(DepartmentDetails _department, out int department_id)
    {
        ErrCode err = SiteProvider.CurrentProvider.SaveDepartment(_department, out department_id);

        return err;
    }
    
    public ErrCode DeleteDepartment(int department_id)
    {
        ErrCode err = SiteProvider.CurrentProvider.DeleteDepartment(department_id);

        return err;
    }
    
    public List<DepartmentDetails> LoadDepartments(out ErrCode err)
    {
        err = null;
        List<DepartmentDetails> departments = SiteProvider.CurrentProvider.LoadDepartments(out err);

        return departments;
    }
    #endregion

    #region Сохранение, загрузка и удаление населённых пунктов
    
    public ErrCode SaveSettlement(SettlementDetail _settlement, out int settlement_id)
    {
        ErrCode err = SiteProvider.CurrentProvider.SaveSettlement(_settlement, out settlement_id);

        return err;
    }
    
    public ErrCode DeleteSettlement(int settlement_id)
    {
        ErrCode err = SiteProvider.CurrentProvider.DeleteSettlement(settlement_id);

        return err;
    }
    
    public List<SettlementDetail> LoadSettlements(out ErrCode err)
    {
        err = null;
        List<SettlementDetail> settlements = SiteProvider.CurrentProvider.LoadSettlements(out err);

        return settlements;
    }
    #endregion

    #region Кэш данных
    
    public ErrCode SaveParamsIntoCache(CachedData cachedData)
    {
        ErrCode err = new ErrCode();
        /*DataTable cdat = tempData1.Tables["CachingData"];
        ErrCode err = new ErrCode();
        DataRow row = tempData1.Tables["CachingData"].Rows[0];
        row.BeginEdit();
            row["functionary_id"] = cachedData.FunctionaryId;
        row.EndEdit();
        row.AcceptChanges();
        err.Message = "Редактирование строки";
        err.Number = Convert.ToInt32(tempData1.Tables["CachingData"].Rows[0]["functionary_id"]);*/
        /*CachingData.DateBegin = cachedData.DateBegin;
        CachingData.DateEnd = cachedData.DateEnd;
        CachingData.SiteId = cachedData.SiteID;
        CachingData.Callsign = cachedData.Callsign;
        CachingData.IsArchive = cachedData.IsArchive;
        CachingData.FunctionaryId = cachedData.FunctionaryId;
        CachingData.LastName = cachedData.LastName;
        CachingData.FirstName = cachedData.FirstName;
        CachingData.Patronymic = cachedData.Patronymic;
        CachingData.Status = cachedData.Status;
        CachingData.AccountFailure = cachedData.AccountFailure;
        CachingData.AccountElements = cachedData.AccountElements;*/

        return err;
    }
    
    public CachedData LoadCachedData()
    {
        //CachedData lastCachedData = new CachedData();
        //lastCachedData.FunctionaryId = CachingData.FunctionaryId;

        /*DataTableReader reader = tempData1.CreateDataReader();
        id = 0;
        
        while(reader.Read())
        {
            lastCachedData = new CachedData();
            lastCachedData.FunctionaryId = Convert.ToInt32(reader["functionary_id"]);
            id = Convert.ToInt32(reader["functionary_id"]);
        }*/
        return null;//lastCachedData;
    }
    #endregion
    #region Расположение отчётов
    
    public ErrCode SetReportsPath(string rpath)
    {
        ErrCode err = SiteProvider.CurrentProvider.SetReportsPath(rpath);

        return err;
    }
    
    public string LoadReportsPath(out ErrCode err)
    {
        err = new ErrCode();

        string rpath = SiteProvider.CurrentProvider.LoadReportsPath(out err);

        return rpath;
    }
    #endregion
    #region Количество комплектов оборудования
    
    public int LoadAccountElements(DateTime dtBegin, DateTime dtEnd, out int accountFailure)
    {
        int account = SiteProvider.CurrentProvider.LoadAccountElements(dtBegin, dtEnd, out accountFailure);
        return account;
    }
    #endregion
    #region Сохранение, загрузка и удаление планов
    
    public ErrCode SavePlane(PlaneDetails pd, out int plane_id)
    {
        ErrCode err = SiteProvider.CurrentProvider.SavePlan(pd, out plane_id);

        return err;
    }
    
    public ErrCode DeletePlane(int plane_id)
    {
        ErrCode err = SiteProvider.CurrentProvider.DeletePlane(plane_id);

        return err;
    }
    
    public List<PlaneDetails> LoadPlanes(out ErrCode err)
    {
        err = null;
        List<PlaneDetails> planes = SiteProvider.CurrentProvider.LoadPlanes(out err);

        return planes;
    }
    #endregion

    #region Сохранение, загрузка и удаление вариантов плана
    
    public ErrCode SaveVariant(VariantDetails vd, out int id)
    {
        ErrCode err = SiteProvider.CurrentProvider.SaveVariant(vd, out id);

        return err;
    }
    
    public ErrCode DeleteVariant(int variant_id)
    {
        ErrCode err = SiteProvider.CurrentProvider.DeleteVariant(variant_id);

        return err;
    }
    
    public List<VariantDetails> LoadVariants(out ErrCode err)
    {
        err = null;
        List<VariantDetails> variants = SiteProvider.CurrentProvider.LoadVariants(out err);

        return variants;
    }

    public List<VariantDetails> LoadNAnnientedVariants(out ErrCode err)
    {
        err = null;
        List<VariantDetails> variants = SiteProvider.CurrentProvider.LoadNAnnientedAndNExecutedVariants(out err);

        return variants;
    }
    
    public List<VariantDetails> LoadVariantsWithPlaneId(int plane_id, out ErrCode err)
    {
        err = null;
        List<VariantDetails> variants = SiteProvider.CurrentProvider.LoadVariantsWithPlaneId(plane_id, out err);

        return variants;
    }
    #endregion

    #region Сохранение, загрузка, удаление элементов плана
    
    public ErrCode SavePE(PEDetails ped, out int id)
    {
        ErrCode err = SiteProvider.CurrentProvider.SavePE(ped, out id);

        return err;
    }
    
    public List<PEDetails> LoadPlaneElements(int variant_id, out ErrCode err)
    {
        err = null;
        List<PEDetails> pes = SiteProvider.CurrentProvider.LoadPEs(variant_id, out err);

        return pes;
    }
    
    public ErrCode DeleteElementOfPlane(int variant_id, int element_id)
    {
        ErrCode err = SiteProvider.CurrentProvider.DeleteElementOfPlane(variant_id, element_id);

        return err;
    }
    #endregion

    #region Сохранение, загрузка и удаление интервалов
    
    public ErrCode SaveInterval(IntervalDetail idt, out int id)
    {
        ErrCode err = SiteProvider.CurrentProvider.SaveInterval(idt, out id);

        return err;
    }
    
    public ErrCode DeleteInterval(int interval_id)
    {
        ErrCode err = SiteProvider.CurrentProvider.DeleteInterval(interval_id);

        return err;
    }
    
    public List<IntervalDetail> LoadIntervals(out ErrCode err)
    {
        err = null;
        List<IntervalDetail> ids = SiteProvider.CurrentProvider.LoadIntervals(out err);

        return ids;
    }
    #endregion

    #region Загрузка всех утверждённых планов
    
    public List<PlaneDetails> GetAllRatifiedPlanes(out ErrCode err)
    {
        err = null;
        List<PlaneDetails> pds = SiteProvider.CurrentProvider.GetAllRatifiedPlanes(out err);

        return pds;
    }
    #endregion

    #region Загрузка всех планов, кроме утверждённых и отменённых
    public List<PlaneDetails> LoadNAnnientedPlanes(out ErrCode err)
    {
        err = null;
        List<PlaneDetails> pds = SiteProvider.CurrentProvider.LoadNAnnientedAndNExecutedPlanes(out err);
       
        return pds;
    }
    #endregion

    #region Сохранение, загрузка и удаление режимов
    
    public ErrCode SaveMode(ModeDetails md, out int id)
    {
        ErrCode err = SiteProvider.CurrentProvider.SaveMode(md, out id);

        return err;
    }
    
    public ErrCode DeleteMode(int mode_id)
    {
        ErrCode err = SiteProvider.CurrentProvider.DeleteMode(mode_id);

        return err;
    }
    
    public List<ModeDetails> LoadModes(out ErrCode err)
    {
        err = null;
        List<ModeDetails> mds = SiteProvider.CurrentProvider.LoadModes(out err);

        return mds;
    }
    
    public int GetIdMode(string name, out ErrCode err)
    {
        int id = SiteProvider.CurrentProvider.LoadIdMode(name, out err);

        return id;
    }
    #endregion

    #region Сохранение, загрузка и удаление однотипных данных
    
    public ErrCode SaveGeneric(GenericDetails gd, out int id)
    {
        ErrCode err = SiteProvider.CurrentProvider.SaveGeneric(gd, out id);

        return err;
    }
    
    public ErrCode DeleteGeneric(byte sign, int genid)//(string table_name, int genid)
    {
        ErrCode err = SiteProvider.CurrentProvider.DeleteGeneric(sign, genid);//(table_name, genid);

        return err;
    }
    
    public List<GenericDetails> LoadGeneric(byte sign, out ErrCode err)//(string table_name, out ErrCode err)
    {
        err = null;
        List<GenericDetails> gds = SiteProvider.CurrentProvider.LoadGeneric(sign, out err);//(table_name, out err);

        return gds;
    }
    #endregion

    #region Временные метки
    
    public ErrCode SaveTemporalMark(TemporalAxisDetails tad, out int id)
    {
        ErrCode err = SiteProvider.CurrentProvider.SaveTemporalMark(tad, out id);

        return err;
    }
    
    public ErrCode DeleteTemporalMark(int mark_id)
    {
        ErrCode err = SiteProvider.CurrentProvider.DeleteTemporalMark(mark_id);

        return err;
    }
    
    public List<TemporalAxisDetails> LoadTemporalAxis(int idVariant, out ErrCode err)
    {
        err = null;
        List<TemporalAxisDetails> tadl = SiteProvider.CurrentProvider.LoadTemporalAxis(idVariant, out err);

        return tadl;
    }
    #endregion

    #region Временная ось
    
    public ErrCode SaveTimeMark(TimeMarkDetails tmd, out int id)
    {
        ErrCode err = SiteProvider.CurrentProvider.SaveTimeMark(tmd, out id);

        return err;
    }
    
    public ErrCode DeleteTimeMark(int mark_id)
    {
        ErrCode err = SiteProvider.CurrentProvider.DeleteTimeMark(mark_id);

        return err;
    }
    
    public List<TimeMarkDetails> LoadTimeBase(int idMark, out ErrCode err)
    {
        err = null;
        List<TimeMarkDetails> tmdl = SiteProvider.CurrentProvider.LoadTimeBase(idMark, out err);

        return tmdl;
    }
    #endregion

    #region Таблица приоритетов
    
    public ErrCode SavePriority(PriorityDetails pd, out int id)
    {
        ErrCode err = SiteProvider.CurrentProvider.SavePriority(pd, out id);

        return err;
    }
    
    public List<PriorityDetails> LoadPriorities(out ErrCode err)
    {
        err = null;
        List<PriorityDetails> pds = SiteProvider.CurrentProvider.LoadAllPriorities(out err);

        return pds;
    }
    
    public ErrCode ClearAllPriority()
    {
        ErrCode err = SiteProvider.CurrentProvider.ClearAllPriorities();

        return err;
    }
    
    public ErrCode RemovePriority(int priority_id)
    {
        ErrCode err = SiteProvider.CurrentProvider.RemovePriority(priority_id);

        return err;
    }

    #endregion

    #region Таблица запретов
    
    public ErrCode SaveSubsystem(DisabledDetails dd, out int id)
    {
        ErrCode err = SiteProvider.CurrentProvider.SaveSubsystem(dd, out id);

        return err;
    }
    
    public List<DisabledDetails> LoadAllSubsystems(out ErrCode err)
    {
        err = null;
        List<DisabledDetails> dds = SiteProvider.CurrentProvider.LoadAllSubsystems(out err);

        return dds;
    }
    
    public ErrCode ClearAllSubsystems()
    {
        ErrCode err = SiteProvider.CurrentProvider.ClearAllSubsystems();

        return err;
    }
    #endregion

    #region Таблица фиксированных частот
    public List<int> SaveAllFrequencies(FrequencyDetails[] frequencies, out ErrCode err)
    {
        List<int> ids = SiteProvider.CurrentProvider.SaveAllFrequencies(frequencies, out err);

        return ids;

    }
    public ErrCode SaveFrequency(FrequencyDetails fd, out int id)
    {
        ErrCode err = SiteProvider.CurrentProvider.SaveFrequency(fd, out id);

        return err;
    }

    public List<FrequencyDetails> LoadFrequencies(out ErrCode err)
    {
        err = null;
        List<FrequencyDetails> frequencies = SiteProvider.CurrentProvider.LoadAllFrequencies(out err);

        return frequencies;
    }

    public ErrCode ClearAllFrequencies()
    {
        ErrCode err = SiteProvider.CurrentProvider.ClearAllFrequencies();

        return err;
    }

    public ErrCode RemoveFrequency(int frequency_id)
    {
        ErrCode err = SiteProvider.CurrentProvider.RemoveFrequency(frequency_id);

        return err;
    }
    #endregion

    #region Порог пропускной способности TCP/IP соединений
    public List<int> SaveAllThresholds(ThresholdDetails[] thresholds, out ErrCode err)
    {
        List<int> ids = SiteProvider.CurrentProvider.SaveAllThresholds(thresholds, out err);

        return ids;

    }
    public ErrCode SaveThreshold(ThresholdDetails td, out int id)
    {
        ErrCode err = SiteProvider.CurrentProvider.SaveThreshold(td, out id);

        return err;
    }

    public List<ThresholdDetails> LoadThresholds(out ErrCode err)
    {
        err = null;
        List<ThresholdDetails> thresholds = SiteProvider.CurrentProvider.LoadAllThresholds(out err);

        return thresholds;
    }

    public ErrCode ClearAllThresholds()
    {
        ErrCode err = SiteProvider.CurrentProvider.ClearAllThresholds();

        return err;
    }
    #endregion

    #region Скрипты

    public ErrCode SaveScript(ScriptDetails sd, out int id)
    {
        ErrCode err = SiteProvider.CurrentProvider.SaveScript(sd, out id);

        return err;
    }
    
    public ErrCode DeleteScript(int script_id)
    {
        ErrCode err = SiteProvider.CurrentProvider.DeleteScript(script_id);

        return err;
    }
    
    public List<ScriptDetails> LoadScriptWithIdVariant(int variant_id, out ErrCode err)
    {
        err = null;
        List<ScriptDetails> sd = SiteProvider.CurrentProvider.LoadScriptWithIdVariant(variant_id, out err);

        return sd;
    }
    
    public List<ScriptDetails> LoadScriptWithIdTimeMark(int idMark, out ErrCode err)
    {
        err = null;
        List<ScriptDetails> sd = SiteProvider.CurrentProvider.LoadScriptWithTimeMark(idMark, out err);

        return sd;
    }

    #endregion

    #region События, вызывающие скрипты
    
    public ErrCode SaveAction(ActionDetails ad, out int id)
    {
        ErrCode err = SiteProvider.CurrentProvider.SaveAction(ad, out id);

        return err;
    }
    
    public ErrCode DeleteAction(int action_id)
    {
        ErrCode err = SiteProvider.CurrentProvider.DeleteAction(action_id);

        return err;
    }
    
    public List<ActionDetails> LoadActions(int script_id, out ErrCode err)
    {
        err = null;
        List<ActionDetails> ad = SiteProvider.CurrentProvider.LoadActions(script_id, out err);

        return ad;
    }

    #endregion

    #region Таблица ОТД
    
    public ErrCode SaveOTD(OTDDetails[] otdd, int port_id)
    {
        ErrCode err = SiteProvider.CurrentProvider.SaveOTD(otdd, port_id);

        return err;
    }

    #endregion
    #region Таблица загрузки линий и трактов связи
    
    public ErrCode SaveLoadingTbl(LoadingDetails[] lds, int port_id, string nameOfLine)
    {
        ErrCode err = SiteProvider.CurrentProvider.SaveLoadingTbl(lds, port_id, nameOfLine);

        return err;
    }

    #endregion
    #region Тренды измерений
    
    public ErrCode SaveCapacity(int site1, int site2, float measurement, float measurementNominal, string notes)
    {
        ErrCode err = SiteProvider.CurrentProvider.SaveCapacity(site1, site2, measurement, measurementNominal, notes);

        return err;
    }
    #endregion

    #region Директивы
    
    public ErrCode SaveDirective(int directive_id, string name, string number, DateTime date, DateTime time, int code, out int id)
    {
        ErrCode errCode = SiteProvider.CurrentProvider.SaveDirective(directive_id, name, number, date, time, code, out id);

        return errCode;
    }
    
    public ErrCode SaveDirectiveParameters(DirectivePrmsDetails dprms, out int id)
    {
        ErrCode errCode = SiteProvider.CurrentProvider.SaveDirectivePrms(dprms, out id);

        return errCode;

    }
    
    public ErrCode SaveRelation(int pd_id, int directive_id, int plane_id, out int id)
    {
        ErrCode errCode = SiteProvider.CurrentProvider.SaveRelation(pd_id, directive_id, plane_id, out id);

        return errCode;
    }
    
    public DirectiveDetails GetDirectiveWithPlaneId(int plane_id, out ErrCode err)
    {
        return SiteProvider.CurrentProvider.GetDirective(plane_id, out err);
    }
    #endregion

    #region Команды
    
    public ErrCode SaveCommand(int command_id, string name, string number, DateTime date, DateTime time, int code, out int id)
    {
        ErrCode errCode = SiteProvider.CurrentProvider.SaveCommand(command_id, name, number, date, time, code, out id);

        return errCode;
    }
    #endregion

    #region Транзакции
    
    public TransactionInfo BeginClientTransaction(int timeout, out ErrCode err)
    {
        return SiteProvider.CurrentProvider.BeginClientTransaction(timeout, out err);
    }
    
    public TransactionInfo TerminateTransaction(out ErrCode err)
    {
        return SiteProvider.CurrentProvider.TerminateTransaction(out err);
    }
    
    public TransactionInfo GetTransactionInfo()
    {
        return SiteProvider.CurrentProvider.GetTransactionInfo();
    }
    
    public ErrCode RollbackClientTransaction()
    {
        return SiteProvider.CurrentProvider.RollbackClientTransaction();
    }
    #endregion

}

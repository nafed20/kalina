using System;
using System.Collections.Generic;
using System.Linq;
using System.Runtime.Serialization;
using System.ServiceModel;
using System.Text;
using DAL;

// NOTE: If you change the interface name "IService" here, you must also update the reference to "IService" in Web.config.
[ServiceContract]
public interface ISqlProviderService
{
    #region Схема
    [OperationContract]
    List<ItemDetails> LoadSites(int schema_id, out ErrCode err);
    [OperationContract]
    List<SchemaDetails> GetListOfSchemes(out ErrCode err);
    [OperationContract]
    List<ItemDetails> GetSchema(int schema_id, out ErrCode err);
    [OperationContract]
    void DeleteSchema(int schema_id, out ErrCode err);
    [OperationContract]
    ErrCode SaveSchema(ItemDetails[] schema, out ItemDetails[] so);

    #region Сохранение схемы в транзакции
    [OperationContract]
    ErrCode SaveSchemaTran(ItemDetails[] schema, out ItemDetails[] so);
    #endregion
    #region Элементы первого уровня узла
    [OperationContract]
    List<ItemDetails> LoadElementsOfFirstLevel(int site_id, out ErrCode err);
    #endregion
    #region Удаление элемента
    [OperationContract]
    void DeleteElement(int element_id, out ErrCode err);
    #endregion
    #endregion
    #region НСИ
    #region Элементы НСИ
    [OperationContract]
    List<ItemDetails> LoadUnits(int parent_id, out ErrCode err);
    #endregion
    #endregion
    #region Подразделение, НДР
    [OperationContract]
    List<Subdivision> GetSubdivisions(out ErrCode err);
    [OperationContract]
    List<NumberDuty> GetND(out ErrCode err);
    #endregion
    #region Пользователи
    [OperationContract]
    List<RolesDetails> GetRoles(out ErrCode err);
    [OperationContract]
    void SaveFunctionary(FunctionaryDetails fd, out int id, out ErrCode err);
    [OperationContract]
    void UpdateFunctionary(FunctionaryDetails fd, out ErrCode err);
    [OperationContract]
    void DeleteFunctionary(int functionary_id, out ErrCode err);
    [OperationContract]
    List<FunctionaryDetails> LoadFunctionaries(out ErrCode err);
    [OperationContract]
    LoginDetails LoadLogin(int functionary_id, out ErrCode err);
    [OperationContract]
    void SaveLogin(int functionary_id, string login, string password, int role_id, out ErrCode err);
    [OperationContract]
    ErrCode AuthenticateUser(LoginDetails login, out int functionary_id, out string role);
    #endregion
    #region Дежурства
    #region Реквизиты дежурного
    [OperationContract]
    DutyDetails GetEssentialElementsOfDuty(int uid, out ErrCode err);
    #endregion
    #region Журнал дежурств
    [OperationContract]
    ErrCode Duty(int functionary_id, string feature, int site_id, int arm);
    #endregion
    #region Метка времени
    [OperationContract]
    ErrCode SetLastTime(int functionary_id);
    #endregion
    #endregion
    #region Изображения
    [OperationContract]
    List<PicturePackage> LoadIcons(out ErrCode err);
    #endregion
    #region Стили
    [OperationContract]
    ErrCode SaveStyle(PicturePackage style, out int id);
    [OperationContract]
    List<PicturePackage> LoadStyles(out ErrCode err);
    [OperationContract]
    ErrCode DeleteStyle(int id);
    [OperationContract]
    ErrCode ApplyStyle(int element_id, int style_id);
    [OperationContract]
    PicturePackage LoadStyle(int element_id, out ErrCode err);
    #region Загрузка стилей кабеля
    [OperationContract]
    List<MediumStyle> LoadMediumStyles(out ErrCode err);
    #endregion
    #endregion

    #region Загрузка портов
    [OperationContract]
    ElementPorts LoadPorts(int element_id, out ErrCode err);
    [OperationContract]
    List<ElementPorts> LoadAllPorts(List<int> ids, out ErrCode err);
    #endregion
    #region Сохранение порта
    [OperationContract]
    ErrCode SavePort(PortDetails port, out int id);
    #endregion
    #region Сохранение всех портов
    [OperationContract]
    List<int> SavePorts(PortDetails[] ports, out ErrCode err);
    [OperationContract]
    List<int> SavePortsTran(PortDetails[] ports, out ErrCode err);
    #endregion
    #region Удаление порта
    [OperationContract]
    ErrCode DeletePort(int port_id);
    #endregion

    #region Загрузка соединения порта
    [OperationContract]
    ErrCode LoadPortConnection(int port_id1, int port_id2, out int connection_id);
    #endregion
    #region Загрузка всех соединений порта
    [OperationContract]
    List<UnitDetails> LoadAllPortsConnections(out ErrCode err);
    #endregion
    #region Сохранение соединения порта
    [OperationContract]
    ErrCode SavePortConnection(int port_id1, int port_id2);
    #endregion
    #region Сохранение всех соединений портов
    [OperationContract]
    ErrCode SaveAllPortConnection(PortConnectionDetails[] pcs);
    [OperationContract]
    ErrCode SaveAllPortConnectionTran(PortConnectionDetails[] pcs);
    #endregion
    #region Удаление соединения порта
    [OperationContract]
    ErrCode DeletePortConnection(int port_id1, int port_id2);
    #endregion

    #region Загрузка соединения
    [OperationContract]
    ErrCode LoadConnection(int element_id1, int element_id2, out int connection_id);
    #endregion
    #region Сохранение соединения порта
    [OperationContract]
    ErrCode SaveConnection(int element_id1, int element_id2);
    [OperationContract]
    ErrCode SaveConnectionTran(int element_id1, int element_id2);
    #endregion
    #region Удаление соединения
    [OperationContract]
    ErrCode DeleteConnection(int element_id1, int element_id2);
    [OperationContract]
    ErrCode DeleteConnectionTran(int element_id1, int element_id2);
    #endregion

    #region Кабели
    #region Загрузка всех кабелей
    [OperationContract]
    List<MediaDetails> LoadAllMedia(out ErrCode err);
    #endregion
    #region Загрузка кабеля по его идентификатору
    [OperationContract]
    MediaDetails LoadMedia(int media_id, out ErrCode err);
    #endregion
    #region Загрузка кабеля по идентификатору соединения
    [OperationContract]
    List<MediaDetails> LoadMediaForConnectId(int connection_id, out ErrCode err);
    #endregion
    #region Сохранение кабеля
    [OperationContract]
    ErrCode SaveMedia(MediaDetails media, out int id);
    [OperationContract]
    ErrCode SaveMediaTran(MediaDetails media, out int id);
    #endregion
    #region Удаление кабеля
    [OperationContract]
    ErrCode DeleteMedia(int media_id);
    #endregion
    #endregion

    #region Альтернативные элементы
    [OperationContract]
    AlterElement LoadAlterElement(int element_id, out ErrCode err);
    [OperationContract]
    List<AlterElement> LoadAlterElements(out ErrCode err);
    [OperationContract]
    ErrCode SaveAlterElement(AlterElement ae, out int id);
    [OperationContract]
    ErrCode SaveAlterElementTran(AlterElement ae, out int id);
    #endregion

    #region Значки видов связи
    [OperationContract]
    ErrCode SaveImage(DAL.Image image, out int id);
    [OperationContract]
    ErrCode DeleteImage(DAL.Image image);
    [OperationContract]
    List<DAL.Image> LoadImages(out ErrCode err);
    [OperationContract]
    DAL.Image GetImageById(int id, out ErrCode err);
    [OperationContract]
    DAL.Image GetImageByName(string name, out ErrCode err);
    #endregion

    #region Каналы
    [OperationContract]
    ErrCode SaveChannel(DAL.Channel channel, out int id);
    [OperationContract]
    ErrCode DeleteChannel(DAL.Channel channel);
    [OperationContract]
    List<DAL.Channel> LoadAllChannels(out ErrCode err);
    [OperationContract]
    List<DAL.Channel> LoadChannels(int tb_id, out ErrCode err);
    #endregion

    #region Информационные направления связи
    [OperationContract]
    ErrCode SaveIcd(int alter_id1, int alter_id2, out int id);
    [OperationContract]
    ErrCode SaveIcdTran(int alter_id1, int alter_id2, out int id);
    [OperationContract]
    List<UnitDetails> LoadAllIcd(out ErrCode err);
    [OperationContract]
    ErrCode DeleteIcd(int alter_id1, int alter_id2);
    [OperationContract]
    List<IcdItem> LoadIcdItems(out ErrCode err);
    [OperationContract]
    ErrCode SaveIcdItem(int item_id, int icd_id, string props, out int id);
    [OperationContract]
    ErrCode DeleteIcdItem(int item_id);
    [OperationContract]
    List<IcdWithNameDetails> LoadAllIcdWithNames(int workMode, out ErrCode err);
    #endregion

    #region Направления связи
    [OperationContract]
    int SaveСd(int element_id1, int element_id2, out ErrCode err);
    [OperationContract]
    int SaveСdTran(int element_id1, int element_id2, out ErrCode err);
    [OperationContract]
    List<UnitDetails> LoadAllCd(out ErrCode err);
    [OperationContract]
    ErrCode DeleteCd(int element_id1, int element_id2);
    [OperationContract]
    List<CdsItem> LoadCdsItems(int period_id, out ErrCode err);
    [OperationContract]
    ErrCode SaveCdsItem(int item_id, int cds_id, int port_id1, int port_id2, string props, string attachment, int mediumstyle_id, double capacity, int period_id, out int id);
    [OperationContract]
    ErrCode DeleteCdsItem(int item_id);
    #endregion

    #region Архивы и рабочие массивы
    [OperationContract]
    ErrCode CreateBackupDevice();
    [OperationContract]
    ErrCode GetExpireDay(out int expire_day, out string date_overwrite);
    [OperationContract]
    ErrCode SaveExpireDay(int expire_day, string date_overwrite);
    [OperationContract]
    ErrCode GetExpireArchive(out int expire_time, out string date_del);
    [OperationContract]
    ErrCode SaveExpireArchive(int expire_time, string date_del);
    [OperationContract]
    ErrCode CreateBackup();
    [OperationContract]
    ErrCode DeleteStatisticDataFromWorkArray();
    [OperationContract]
    ErrCode DeleteBackupDevice();
    [OperationContract]
    List<Archive> LoadAllBackup(out ErrCode err);
    [OperationContract]
    ErrCode RestoreFromBackup(int file);
    [OperationContract]
    byte IsArchiveExist(out ErrCode err);
    #endregion

    #region Журнал событий
    [OperationContract]
    ErrCode WriteEvent(string message, int uid, int element_id, string code, int arm);
    #endregion 

    #region Запись изменения состояния оборудования
    [OperationContract]
    ErrCode WriteElementStatus(int element_id, string code, string status, int site_id);
    #endregion

    #region Запись изменения состояния НС
    [OperationContract]
    ErrCode WriteCdStatus(int cds_item, string status);
    #endregion

    #region Сохранение и удаление подразделений
    [OperationContract]
    ErrCode SaveSubdivision(Subdivision _subdivision, out int subdivision_id);
    [OperationContract]
    ErrCode DeleteSubdivision(int subdivision_id);
    #endregion

    #region Сохранение и удаление НДР
    [OperationContract]
    ErrCode SaveNumberDuty(NumberDuty nd, out int number_id);
    [OperationContract]
    ErrCode DeleteNumberDuty(int number_id);
    #endregion

    #region Сохранение, загрузка и удаление ведомств
    [OperationContract]
    ErrCode SaveDepartment(DepartmentDetails _department, out int department_id);
    [OperationContract]
    ErrCode DeleteDepartment(int department_id);
    [OperationContract]
    List<DepartmentDetails> LoadDepartments(out ErrCode err);
    #endregion

    #region Сохранение, загрузка и удаление населённых пунктов
    [OperationContract]
    ErrCode SaveSettlement(SettlementDetail _settlement, out int settlement_id);
    [OperationContract]
    ErrCode DeleteSettlement(int settlement_id);
    [OperationContract]
    List<SettlementDetail> LoadSettlements(out ErrCode err);
    #endregion

    #region Кэш данных
    [OperationContract]
    ErrCode SaveParamsIntoCache(CachedData cachedData);
    [OperationContract]
    CachedData LoadCachedData();
    #endregion
    #region Расположение отчётов
    [OperationContract]
    ErrCode SetReportsPath(string rpath);
    [OperationContract]
    string LoadReportsPath(out ErrCode err);
    #endregion
    #region Количество комплектов оборудования
    [OperationContract]
    int LoadAccountElements(DateTime dtBegin, DateTime dtEnd, out int accountFailure);
    #endregion
    #region Сохранение, загрузка и удаление планов
    [OperationContract]
    ErrCode SavePlane(PlaneDetails pd, out int plane_id);
    [OperationContract]
    ErrCode DeletePlane(int plane_id);
    [OperationContract]
    List<PlaneDetails> LoadPlanes(out ErrCode err);
    #endregion

    #region Сохранение, загрузка и удаление вариантов плана
    [OperationContract]
    ErrCode SaveVariant(VariantDetails vd, out int id);
    [OperationContract]
    ErrCode DeleteVariant(int variant_id);
    [OperationContract]
    List<VariantDetails> LoadVariants(out ErrCode err);
    [OperationContract]
    List<VariantDetails> LoadVariantsWithPlaneId(int plane_id, out ErrCode err);
    [OperationContract]
    List<VariantDetails> LoadNAnnientedVariants(out ErrCode err);
    #endregion

    #region Сохранение, загрузка, удаление элементов плана
    [OperationContract]
    ErrCode SavePE(PEDetails ped, out int id);
    [OperationContract]
    List<PEDetails> LoadPlaneElements(int variant_id, out ErrCode err);
    [OperationContract]
    ErrCode DeleteElementOfPlane(int variant_id, int element_id);
    #endregion

    #region Сохранение, загрузка и удаление интервалов
    [OperationContract]
    ErrCode SaveInterval(IntervalDetail idt, out int id);
    [OperationContract]
    ErrCode DeleteInterval(int interval_id);
    [OperationContract]
    List<IntervalDetail> LoadIntervals(out ErrCode err);
    #endregion

    #region Загрузка всех утверждённых планов
    [OperationContract]
    List<PlaneDetails> GetAllRatifiedPlanes(out ErrCode err);
    #endregion

    #region Загрузка всех планов, кроме отменённых и утверждённых
    [OperationContract]
    List<PlaneDetails> LoadNAnnientedPlanes(out ErrCode err);
    #endregion

    #region Сохранение, загрузка и удаление режимов
    [OperationContract]
    ErrCode SaveMode(ModeDetails md, out int id);
    [OperationContract]
    ErrCode DeleteMode(int mode_id);
    [OperationContract]
    List<ModeDetails> LoadModes(out ErrCode err);
    [OperationContract]
    int GetIdMode(string name, out ErrCode err);
    #endregion

    #region Сохранение, загрузка и удаление однотипных данных
    [OperationContract]
    ErrCode SaveGeneric(GenericDetails gd, out int id);
    [OperationContract]
    ErrCode DeleteGeneric(byte sign, int genid);
    [OperationContract]
    List<GenericDetails> LoadGeneric(byte sign, out ErrCode err);
    #endregion

    #region Временные метки
    [OperationContract]
    ErrCode SaveTemporalMark(TemporalAxisDetails tad, out int id);
    [OperationContract]
    ErrCode DeleteTemporalMark(int mark_id);
    [OperationContract]
    List<TemporalAxisDetails> LoadTemporalAxis(int idVariant, out ErrCode err);
    #endregion

    #region Временная ось
    [OperationContract]
    ErrCode SaveTimeMark(TimeMarkDetails tmd, out int id);
    [OperationContract]
    ErrCode DeleteTimeMark(int mark_id);
    [OperationContract]
    List<TimeMarkDetails> LoadTimeBase(int idMark, out ErrCode err);
    #endregion

    #region Таблица приоритетов
    [OperationContract]
    ErrCode SavePriority(PriorityDetails pd, out int id);
    [OperationContract]
    List<PriorityDetails> LoadPriorities(out ErrCode err);
    [OperationContract]
    ErrCode ClearAllPriority();
    [OperationContract]
    ErrCode RemovePriority(int priority_id);
    #endregion

    #region Таблица фиксированных частот
    [OperationContract]
    List<int> SaveAllFrequencies(FrequencyDetails[] frequencies, out ErrCode err);
    [OperationContract]
    ErrCode SaveFrequency(FrequencyDetails fd, out int id);
    [OperationContract]
    List<FrequencyDetails> LoadFrequencies(out ErrCode err);
    [OperationContract]
    ErrCode ClearAllFrequencies();
    [OperationContract]
    ErrCode RemoveFrequency(int frequency_id);
    #endregion

    #region Порог пропускной способности TCP/IP соединений
    [OperationContract]
    List<int> SaveAllThresholds(ThresholdDetails[] thresholds, out ErrCode err);
    [OperationContract]
    ErrCode SaveThreshold(ThresholdDetails td, out int id);
    [OperationContract]
    List<ThresholdDetails> LoadThresholds(out ErrCode err);
    [OperationContract]
    ErrCode ClearAllThresholds();
    [OperationContract]
    List<CdInfo> GetCds(out ErrCode err);
    #endregion

    #region Таблица запретов
    [OperationContract]
    ErrCode SaveSubsystem(DisabledDetails dd, out int id);
    [OperationContract]
    List<DisabledDetails> LoadAllSubsystems(out ErrCode err);
    [OperationContract]
    ErrCode ClearAllSubsystems();
    #endregion

    #region Скрипты
    [OperationContract]
    ErrCode SaveScript(ScriptDetails sd, out int id);
    [OperationContract]
    ErrCode DeleteScript(int script_id);
    [OperationContract]
    List<ScriptDetails> LoadScriptWithIdVariant(int variant_id, out ErrCode err);
    [OperationContract]
    List<ScriptDetails> LoadScriptWithIdTimeMark(int idMark, out ErrCode err);
    #endregion

    #region События, вызывающие скрипты
    [OperationContract]
    ErrCode SaveAction(ActionDetails ad, out int id);
    [OperationContract]
    ErrCode DeleteAction(int action_id);
    [OperationContract]
    List<ActionDetails> LoadActions(int script_id, out ErrCode err);
    #endregion

    #region Таблица ОТД
    [OperationContract]
    ErrCode SaveOTD(OTDDetails[] otdd, int port_id);
    #endregion
    #region Таблица загрузки линий и трактов связи
    [OperationContract]
    ErrCode SaveLoadingTbl(LoadingDetails[] lds, int port_id, string nameOfLine);
    #endregion
    #region Тренды измерений
    [OperationContract]
    ErrCode SaveCapacity(int site1, int site2, float measurement, float measurementNominal, string notes);
    #endregion

    #region Директивы
    [OperationContract]
    ErrCode SaveDirective(int directive_id, string name, string number, string dateFrom, string dateTill, string typeOfDirective, out int id);
    [OperationContract]
    ErrCode SaveDirectiveParameters(DirectivePrmsDetails dprms, out int id);
    [OperationContract]
    ErrCode SaveRelation(int pd_id, int directive_id, int plane_id, out int id);
    [OperationContract]
    DirectiveDetails GetDirectiveWithPlaneId(int plane_id, out ErrCode err);
    #endregion

    #region Команды
    [OperationContract]
    ErrCode SaveCommand(int command_id, string name, string number, DateTime date, DateTime time, int code, out int id);
    #endregion

    #region Транзакции
    [OperationContract]
    TransactionInfo BeginClientTransaction(int timeout, out ErrCode err);
    [OperationContract]
    TransactionInfo TerminateTransaction(out ErrCode err);
    [OperationContract]
    TransactionInfo GetTransactionInfo();
    [OperationContract]
    ErrCode RollbackClientTransaction();
    #endregion

}



// 消息模块
enum EHCMsgModule
{
	// AS模块id，勿修改
	Product = 1,
	// AS模块测试id，勿修改
	Test = 2,
}

// 消息类型
enum EHCMsgType
{
	None = 0,
	// 检查点
	CheckPoint,
	// 高亮
	HighLight,
	// 输入
	Input,
	// 程序
	Procedure,
	// 玩家
	Player,
	// UI
	UI,
}

// 消息功能
enum EHCMsgFunc
{
	None = 0,
	// 任务
	Quest,
	// 区域
	Zone,
	// 门
	Door,
	// 场景
	Scene,
	// 主线程
	MainThread,
}

// 消息状态
enum EHCMsgId
{
	None = 0,
	// 开始
	Begin,
	// 完成
	Done,
	// 打开
	Open,
	// 关闭
	Close,
	// 改变
	Change,
	// 就绪
	Ready,
	// 锁定
	Lock,
	// 解锁
	UnLock,
	// 加载图片
	loadImg1
}

// 消息工具
namespace HCMsgUtils
{
	// 尝试把消息ID解析成的消息四元组
	UFUNCTION(BlueprintPure)
	bool ParseMsg(int Id, EHCMsgModule& OutModule, EHCMsgType& OutType, EHCMsgFunc& OutFunc, EHCMsgId& OutId)
	{
		uint8 Msg_Module = 0;
		uint8 Msg_Type = 0;
		uint8 Msg_Func = 0;
		uint8 Msg_Id = 0;
		UMessageCenterExt::ParseId(Id, Msg_Module, Msg_Type, Msg_Func, Msg_Id);
		if (Msg_Module != uint8(EHCMsgModule::Product) && Msg_Module != uint8(EHCMsgModule::Test))
		{
			return false;
		}
		else
		{
			OutModule = EHCMsgModule(Msg_Module);
			OutType = EHCMsgType(Msg_Type);
			OutFunc = EHCMsgFunc(Msg_Func);
			OutId = EHCMsgId(Msg_Id);
			return true;
		}
	}
}

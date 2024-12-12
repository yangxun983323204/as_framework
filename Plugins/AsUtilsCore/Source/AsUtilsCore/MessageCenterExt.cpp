#include "MessageCenterExt.h"

int UMessageCenterExt::MakeId(uint8 ModuleId, uint8 TypeId, uint8 FuncId, uint8 MsgId)
{
    return (ModuleId<<24) + (TypeId<<16) + (FuncId<<8) + MsgId;
}

void UMessageCenterExt::ParseId(int InCmdrId, uint8& OutModuleId, uint8& OutTypeId, uint8& OutFuncId, uint8& OutMsgId)
{
    OutModuleId = (InCmdrId&0xff000000)>>24;
    OutTypeId = (InCmdrId&0xff0000)>>16;
    OutFuncId = (InCmdrId&0xff00)>>8;
    OutMsgId = InCmdrId&0xff;
}

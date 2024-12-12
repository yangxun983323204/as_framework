#include "FunctionLibraryMath.h"

FColor UFunctionLibraryMath::FromHex(const FString& HexString)
{
    return FColor::FromHex(HexString);
}

FString UFunctionLibraryMath::ToASCII(const int& Code)
{
    TCHAR TStr[2]{};
    TStr[0] = static_cast<TCHAR>(Code);
    TStr[1] = '\0';
    FString Str(TStr);
    return Str;
}
